import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:outifor/app.dart';
import 'package:outifor/core/errors/app_exception.dart';
import 'package:outifor/core/providers.dart';
import 'package:outifor/data/models/customer.dart';
import 'package:outifor/data/services/local_cache.dart';
import 'package:outifor/demo/demo_backend.dart';
import 'package:outifor/features/customers/customer_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full app (router, role shells, sync controller) on the in-memory backend.
void main() {
  late Directory tmp;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('outifor_flow');
    // Map tile cache asks path_provider for a folder; point it at the temp dir.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tmp.path,
    );
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<DemoBackend> start(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'pref.onboarding_done': true, 'pref.locale': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final demo = DemoBackend();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          connectivityProvider.overrideWith((ref) => Stream.value(true)),
          localCacheProvider.overrideWithValue(LocalCacheService(directoryProvider: () async => tmp)),
          authRepositoryProvider.overrideWithValue(DemoAuthRepository(demo)),
          customerRepositoryProvider.overrideWithValue(DemoCustomerRepository(demo)),
          employeeRepositoryProvider.overrideWithValue(DemoEmployeeRepository(demo)),
          activityRepositoryProvider.overrideWithValue(DemoActivityRepository(demo)),
          settingsRepositoryProvider.overrideWithValue(DemoSettingsRepository(demo)),
        ],
        child: const OutiforApp(),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    return demo;
  }

  /// Advances fake time (demo latency, animations) and lets real file I/O
  /// (device cache) complete.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> login(WidgetTester tester, String user) async {
    await tester.enterText(find.byType(TextFormField).at(0), user);
    await tester.enterText(find.byType(TextFormField).at(1), 'demo1234');
    await tester.tap(find.text('Sign in'));
    await settle(tester);
  }

  testWidgets('employee: login → search → pick one of two similar names → profile', (tester) async {
    await start(tester);
    expect(find.text('Welcome back'), findsOneWidget);
    await login(tester, 'livreur');

    expect(find.text('Find a customer'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing, reason: 'employee shell has no admin tabs');

    await tester.enterText(find.byType(TextField).first, 'benali');
    await settle(tester);
    expect(find.text('2 customers found'), findsOneWidget);

    await tester.tap(find.text('Mohammed Benali'));
    await settle(tester);
    expect(find.byType(CustomerProfileScreen), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsNothing);
  });

  testWidgets('admin: login lands on the dashboard with live statistics', (tester) async {
    await start(tester);
    await login(tester, 'admin');
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('New customer'), findsWidgets);
  });

  testWidgets('wrong password is refused', (tester) async {
    await start(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'livreur');
    await tester.enterText(find.byType(TextFormField).at(1), 'nope1234');
    await tester.tap(find.text('Sign in'));
    await settle(tester);
    expect(find.text('Incorrect username or password.'), findsOneWidget);
  });

  test('demo backend applies the same rules as the server', () async {
    final demo = DemoBackend();
    final auth = DemoAuthRepository(demo);
    final customers = DemoCustomerRepository(demo);
    const draft = CustomerDraft(
      firstName: 'Test',
      lastName: 'Client',
      primaryPhone: '0555000111',
      wilaya: 'Alger',
      commune: 'Alger',
      address: 'Rue X',
    );

    await auth.signIn(identifier: 'livreur', password: 'demo1234');
    await expectLater(customers.save(draft: draft), throwsA(isA<AppException>()));
    expect(await customers.fetchAdminNotes(demo.customers.keys.first), isNull);

    await auth.signIn(identifier: 'admin', password: 'demo1234');
    final saved = await customers.save(draft: draft);
    expect(saved.reference, startsWith('OUT-'));
    expect(await customers.findDuplicates(draft), isNotEmpty);

    await expectLater(
      auth.signIn(identifier: 'ancien', password: 'demo1234').then((_) => auth.fetchActiveProfile()),
      completion(isNull),
      reason: 'deactivated account has no active profile',
    );
  });
}
