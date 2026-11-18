// Renders the main screens to PNG with the real fonts, for review.
// Run:  flutter test tool/screenshots --update-goldens
// Output: tool/screenshots/out/*.png   (illustrative sample data, not shipped)
import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:outifor/core/l10n_ext.dart';
import 'package:outifor/core/providers.dart';
import 'package:outifor/core/theme/app_theme.dart';
import 'package:outifor/data/models/activity.dart';
import 'package:outifor/data/models/customer.dart';
import 'package:outifor/data/models/profile.dart';
import 'package:outifor/data/repositories/customer_repository.dart';
import 'package:outifor/domain/directory_controller.dart';
import 'package:outifor/features/auth/auth_controller.dart';
import 'package:outifor/features/auth/login_screen.dart';
import 'package:outifor/features/auth/onboarding_screen.dart';
import 'package:outifor/features/customers/customer_form_screen.dart';
import 'package:outifor/features/customers/customer_profile_screen.dart';
import 'package:outifor/features/customers/directory_screen.dart';
import 'package:outifor/features/dashboard/admin_dashboard_screen.dart';
import 'package:outifor/features/dashboard/employee_home_screen.dart';
import 'package:outifor/features/employees/employees_screen.dart';
import 'package:outifor/features/settings/app_settings_controller.dart';
import 'package:outifor/features/settings/settings_screen.dart';
import 'package:outifor/shared/widgets/glass_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/helpers.dart';

class _Repo extends Mock implements CustomerRepository {}

class _Auth extends AuthController {
  _Auth(this.s);
  final AuthState s;
  @override
  AuthState build() => s;
}

class _Dir extends DirectoryController {
  _Dir(this.list);
  final List<Customer> list;
  @override
  DirectoryState build() => DirectoryState(
    userId: 'u',
    byId: {for (final c in list) c.id: c},
    status: SyncStatus.idle,
    loaded: true,
    lastSyncedAt: DateTime.now(),
  );
  @override
  Future<void> sync({bool full = false}) async {}
}

class _Settings extends AppSettingsController {
  @override
  Future<AppSettings> build() async => const AppSettings(
    companyName: 'OutiFor Quincaillerie',
    defaultLatitude: 36.75,
    defaultLongitude: 3.05,
    defaultZoom: 11,
  );
}

Future<void> _loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.view(File(f).readAsBytesSync().buffer)));
    }
    await loader.load();
  }

  await family('Inter', [
    for (final w in [400, 500, 600, 700]) 'assets/fonts/Inter-$w.ttf',
  ]);
  await family('Cairo', [
    for (final w in [400, 500, 600, 700]) 'assets/fonts/Cairo-$w.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/sdk/flutter';
  await family('MaterialIcons', ['$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
}

Profile _p(UserRole r, String name) =>
    Profile(id: r.name, fullName: name, username: r.name, role: r, isActive: true, createdAt: DateTime.utc(2026));

final _now = DateTime.now().toUtc();
final _customers = [
  testCustomer(
    id: 'c1',
    reference: 'OUT-000125',
    firstName: 'Mohamed',
    lastName: 'Benali',
    businessName: 'Quincaillerie Benali',
    phone: '0555123456',
    whatsapp: '0555123456',
    secondaryPhone: '021543210',
    createdAt: _now.subtract(const Duration(hours: 3)),
  ),
  testCustomer(
    id: 'c2',
    reference: 'OUT-000310',
    firstName: 'Mohammed',
    lastName: 'Benali',
    phone: '0661987654',
    commune: 'Boufarik',
    wilaya: 'Blida',
    lat: 36.57,
    lng: 2.91,
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
  testCustomer(
    id: 'c3',
    reference: 'OUT-000007',
    firstName: 'Amina',
    lastName: 'Kaci',
    businessName: 'Droguerie El Amel',
    phone: '0770112233',
    commune: 'Bir El Djir',
    wilaya: 'Oran',
    lat: 35.72,
    lng: -0.55,
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
  testCustomer(
    id: 'c4',
    reference: 'OUT-000042',
    firstName: 'Karim',
    lastName: 'Haddad',
    businessName: 'Matériaux Haddad',
    phone: '0550998877',
    commune: 'El Eulma',
    wilaya: 'Sétif',
    lat: 36.15,
    lng: 5.69,
    createdAt: _now.subtract(const Duration(days: 4)),
  ),
  testCustomer(
    id: 'c5',
    reference: 'OUT-000051',
    firstName: 'Yacine',
    lastName: 'Bouzid',
    phone: '0699112244',
    commune: 'Kouba',
    wilaya: 'Alger',
    lat: 36.72,
    lng: 3.08,
    status: CustomerStatus.active,
  ),
];

void main() {
  late SharedPreferences prefs;
  final repo = _Repo();

  setUpAll(() async {
    await _loadFonts();
    registerFallbackValue(CustomerAction.viewed);
    when(() => repo.logAction(any(), any())).thenAnswer((_) async {});
    when(() => repo.fetchAdminNotes(any())).thenAnswer((_) async => 'Paie à la livraison. Fermé le vendredi.');
  });

  setUp(() async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({'pref.onboarding_done': true});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> shot(
    WidgetTester tester,
    String name,
    Widget screen, {
    UserRole role = UserRole.employee,
    Locale locale = const Locale('fr'),
    Future<void> Function()? interact,
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final stats = const DashboardStats(
      customersTotal: 248,
      customersActive: 236,
      customersArchived: 12,
      customersLast7d: 9,
      customersLast30d: 31,
      customersNoLocation: 14,
      employeesTotal: 7,
      employeesActive: 6,
    );
    final logs = [
      ActivityLog(
        id: 1,
        action: 'customer_created',
        createdAt: _now.subtract(const Duration(minutes: 12)),
        actorName: 'Karim Directeur',
        details: const {'name': 'Mohamed Benali'},
      ),
      ActivityLog(
        id: 2,
        action: 'customer_location_updated',
        createdAt: _now.subtract(const Duration(hours: 2)),
        actorName: 'Karim Directeur',
        details: const {'name': 'Amina Kaci'},
      ),
      ActivityLog(
        id: 3,
        action: 'employee_created',
        createdAt: _now.subtract(const Duration(days: 1)),
        actorName: 'Karim Directeur',
        targetName: 'Samir Livreur',
      ),
    ];
    final employees = [
      _p(UserRole.admin, 'Karim Directeur'),
      Profile(
        id: 'e1',
        fullName: 'Samir Livreur',
        username: 'samir',
        role: UserRole.employee,
        isActive: true,
        createdAt: DateTime.utc(2026),
        lastLoginAt: _now.subtract(const Duration(minutes: 40)),
      ),
      Profile(
        id: 'e2',
        fullName: 'Yacine Mansouri',
        username: 'yacine.m',
        role: UserRole.employee,
        isActive: false,
        createdAt: DateTime.utc(2026),
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          customerRepositoryProvider.overrideWithValue(repo),
          connectivityProvider.overrideWith((ref) => Stream.value(true)),
          authControllerProvider.overrideWith(
            () => _Auth(
              AuthState.signedIn(
                role == UserRole.admin ? _p(UserRole.admin, 'Karim Directeur') : _p(UserRole.employee, 'Samir Livreur'),
              ),
            ),
          ),
          directoryProvider.overrideWith(() => _Dir(_customers)),
          appSettingsProvider.overrideWith(_Settings.new),
          dashboardStatsProvider.overrideWith((ref) async => stats),
          recentActivityProvider.overrideWith((ref) async => logs),
          employeesProvider.overrideWith((ref) async => employees),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(arabic: locale.languageCode == 'ar'),
          home: screen,
        ),
      ),
    );
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(Scaffold).first);
      await precacheImage(const AssetImage('assets/brand/outifor_logo.png'), ctx);
    });
    await tester.pumpAndSettle();
    if (interact != null) await interact();
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
  }

  testWidgets('login', (t) => shot(t, '01_login', const LoginScreen()));
  testWidgets('onboarding', (t) => shot(t, '02_onboarding', const OnboardingScreen()));
  testWidgets('employee home', (t) => shot(t, '03_employee_home', const EmployeeHomeScreen()));
  testWidgets(
    'search results',
    (t) => shot(
      t,
      '04_search_results',
      const EmployeeHomeScreen(),
      interact: () async {
        await t.enterText(find.byType(TextField), 'benali');
      },
    ),
  );
  testWidgets('customer profile', (t) => shot(t, '05_customer_profile', const CustomerProfileScreen(customerId: 'c1')));
  testWidgets(
    'customer profile ar',
    (t) => shot(t, '06_customer_profile_ar', const CustomerProfileScreen(customerId: 'c1'), locale: const Locale('ar')),
  );
  testWidgets(
    'admin dashboard',
    (t) => shot(t, '07_admin_dashboard', const AdminDashboardScreen(), role: UserRole.admin),
  );
  testWidgets('directory', (t) => shot(t, '08_directory', const DirectoryScreen(), role: UserRole.admin));
  testWidgets('customer form', (t) => shot(t, '09_customer_form', const CustomerFormScreen(), role: UserRole.admin));
  testWidgets('employees', (t) => shot(t, '10_employees', const EmployeesScreen(), role: UserRole.admin));
  testWidgets('settings', (t) => shot(t, '11_settings', const SettingsScreen(), role: UserRole.admin));
  Widget withBar(Widget body, List<GlassNavItem> items, int index, {Widget? fab}) => Builder(
    builder: (context) => Scaffold(
      extendBody: true,
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: GlassNavBar(items: items, currentIndex: index, onTap: (_) {}),
    ),
  );

  const adminItems = [
    GlassNavItem(icon: Icons.space_dashboard_outlined, selectedIcon: Icons.space_dashboard_rounded, label: 'Accueil'),
    GlassNavItem(icon: Icons.people_alt_outlined, selectedIcon: Icons.people_alt_rounded, label: 'Clients'),
    GlassNavItem(icon: Icons.badge_outlined, selectedIcon: Icons.badge_rounded, label: 'Employés'),
    GlassNavItem(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: 'Carte'),
    GlassNavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Paramètres'),
  ];
  const employeeItemsAr = [
    GlassNavItem(icon: Icons.search_rounded, selectedIcon: Icons.search_rounded, label: 'البحث'),
    GlassNavItem(icon: Icons.people_alt_outlined, selectedIcon: Icons.people_alt_rounded, label: 'الزبائن'),
    GlassNavItem(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: 'الخريطة'),
    GlassNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'الملف الشخصي'),
  ];

  testWidgets(
    'glass bar admin',
    (t) => shot(
      t,
      '13_glass_bar_admin',
      withBar(
        const DirectoryScreen(),
        adminItems,
        1,
        fab: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Nouveau client'),
        ),
      ),
      role: UserRole.admin,
    ),
  );
  testWidgets(
    'glass bar employee ar',
    (t) => shot(
      t,
      '14_glass_bar_employee_ar',
      withBar(const EmployeeHomeScreen(), employeeItemsAr, 0),
      locale: const Locale('ar'),
    ),
  );

  testWidgets(
    'employee home ar',
    (t) => shot(t, '12_employee_home_ar', const EmployeeHomeScreen(), locale: const Locale('ar')),
  );
}
