import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:outifor/core/errors/app_exception.dart';
import 'package:outifor/core/l10n_ext.dart';
import 'package:outifor/core/providers.dart';
import 'package:outifor/core/theme/app_theme.dart';
import 'package:outifor/data/models/customer.dart';
import 'package:outifor/data/models/profile.dart';
import 'package:outifor/data/repositories/customer_repository.dart';
import 'package:outifor/domain/directory_controller.dart';
import 'package:outifor/features/auth/auth_controller.dart';
import 'package:outifor/features/auth/login_screen.dart';
import 'package:outifor/features/customers/customer_profile_screen.dart';
import 'package:outifor/features/dashboard/employee_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class FakeAuth extends AuthController {
  FakeAuth(this.initial, {this.signInError});
  final AuthState initial;
  final AppException? signInError;
  int signInCalls = 0;

  @override
  AuthState build() => initial;

  @override
  Future<void> signIn({required String identifier, required String password}) async {
    signInCalls++;
    if (signInError != null) throw signInError!;
  }
}

class FakeDirectory extends DirectoryController {
  FakeDirectory(this.customers);
  final List<Customer> customers;

  @override
  DirectoryState build() => DirectoryState(
    userId: 'u',
    byId: {for (final c in customers) c.id: c},
    status: SyncStatus.idle,
    loaded: true,
    lastSyncedAt: DateTime.now(),
  );

  @override
  Future<void> sync({bool full = false}) async {}
}

Profile profile(UserRole role) => Profile(
  id: role.name,
  fullName: role == UserRole.admin ? 'Karim Directeur' : 'Samir Livreur',
  username: role.name,
  role: role,
  isActive: true,
  createdAt: DateTime.utc(2026),
);

final noLocation = testCustomer(
  id: 'c1',
  reference: 'OUT-000125',
  firstName: 'Mohamed',
  lastName: 'Benali',
  whatsapp: '0555123456',
  businessName: 'Quincaillerie Benali',
);
final twin = testCustomer(id: 'c2', reference: 'OUT-000310', firstName: 'Mohammed', lastName: 'Benali', phone: '0661987654', commune: 'Boufarik');

void main() {
  late MockCustomerRepository repo;
  late SharedPreferences prefs;

  setUpAll(() => registerFallbackValue(CustomerAction.viewed));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = MockCustomerRepository();
    when(() => repo.logAction(any(), any())).thenAnswer((_) async {});
    when(() => repo.fetchAdminNotes(any())).thenAnswer((_) async => 'Pays on delivery only');
  });

  Future<void> pump(WidgetTester tester, Widget child, {required AuthController auth, Locale locale = const Locale('en')}) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          customerRepositoryProvider.overrideWithValue(repo),
          connectivityProvider.overrideWith((ref) => Stream.value(true)),
          authControllerProvider.overrideWith(() => auth),
          directoryProvider.overrideWith(() => FakeDirectory([noLocation, twin])),
        ],
        child: MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(arabic: locale.languageCode == 'ar'),
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('customer profile', () {
    testWidgets('employee: contact actions shown, admin notes and edit hidden, view logged', (tester) async {
      await pump(tester, const CustomerProfileScreen(customerId: 'c1'),
          auth: FakeAuth(AuthState.signedIn(profile(UserRole.employee))));

      expect(find.text('Mohamed Benali'), findsOneWidget);
      expect(find.text('OUT-000125'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Copy phone'), findsOneWidget);
      expect(find.text('Copy reference'), findsOneWidget);
      expect(find.text('Administrator notes'.toUpperCase()), findsNothing);
      expect(find.text('Pays on delivery only'), findsNothing);
      expect(find.byTooltip('Edit'), findsNothing);
      verifyNever(() => repo.fetchAdminNotes(any()));
      verify(() => repo.logAction(CustomerAction.viewed, 'c1')).called(1);
    });

    testWidgets('missing GPS is stated, never replaced by a guessed point', (tester) async {
      await pump(tester, const CustomerProfileScreen(customerId: 'c1'),
          auth: FakeAuth(AuthState.signedIn(profile(UserRole.employee))));
      await tester.scrollUntilVisible(find.text('No GPS location recorded'), 200);
      expect(find.text('No GPS location recorded'), findsOneWidget);
      expect(find.text('Search address in Google Maps'), findsOneWidget);
      expect(find.text('Set location on map'), findsNothing, reason: 'employees cannot edit');
    });

    testWidgets('admin: notes loaded and edit/archive/delete available', (tester) async {
      await pump(tester, const CustomerProfileScreen(customerId: 'c1'),
          auth: FakeAuth(AuthState.signedIn(profile(UserRole.admin))));
      expect(find.byTooltip('Edit'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Pays on delivery only'), 200);
      expect(find.text('Pays on delivery only'), findsOneWidget);
      verifyNever(() => repo.logAction(any(), any()));
    });

    testWidgets('Arabic: right-to-left layout with Arabic labels', (tester) async {
      await pump(tester, const CustomerProfileScreen(customerId: 'c1'),
          auth: FakeAuth(AuthState.signedIn(profile(UserRole.employee))), locale: const Locale('ar'));
      expect(find.text('اتصال'), findsOneWidget);
      final dir = Directionality.of(tester.element(find.text('اتصال')));
      expect(dir, TextDirection.rtl);
    });
  });

  testWidgets('search lists every similar name with phone and city, and opens nothing by itself', (tester) async {
    await pump(tester, const EmployeeHomeScreen(), auth: FakeAuth(AuthState.signedIn(profile(UserRole.employee))));
    await tester.enterText(find.byType(TextField), 'benali');
    await tester.pumpAndSettle();
    expect(find.text('2 customers found'), findsOneWidget);
    expect(find.textContaining('Several customers match'), findsOneWidget);
    expect(find.text('Mohamed Benali'), findsOneWidget);
    expect(find.text('Mohammed Benali'), findsOneWidget);
    expect(find.text('0555 12 34 56'), findsOneWidget);
    expect(find.text('0661 98 76 54'), findsOneWidget);
    expect(find.textContaining('Boufarik'), findsOneWidget);
    expect(find.byType(CustomerProfileScreen), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzqx');
    await tester.pumpAndSettle();
    expect(find.text('No customer found'), findsOneWidget);
  });

  group('login', () {
    testWidgets('validates empty fields without calling the server', (tester) async {
      final auth = FakeAuth(const AuthState.signedOut());
      await pump(tester, const LoginScreen(), auth: auth);
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Required'), findsNWidgets(2));
      expect(auth.signInCalls, 0);
    });

    testWidgets('shows a clear message for wrong credentials', (tester) async {
      final auth = FakeAuth(const AuthState.signedOut(),
          signInError: const AppException(AppErrorKind.invalidCredentials));
      await pump(tester, const LoginScreen(), auth: auth);
      await tester.enterText(find.byType(TextFormField).at(0), 'livreur1');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong-pass1');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(auth.signInCalls, 1);
      expect(find.text('Incorrect username or password.'), findsOneWidget);
    });

    testWidgets('explains a deactivated account after a forced sign-out', (tester) async {
      await pump(tester, const LoginScreen(), auth: FakeAuth(const AuthState.signedOut(AppErrorKind.accountDisabled)));
      expect(find.textContaining('deactivated'), findsOneWidget);
      expect(find.textContaining('created by your administrator'), findsOneWidget);
    });
  });
}
