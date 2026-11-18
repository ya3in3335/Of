import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/preferences.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/customers/customer_form_screen.dart';
import '../../features/customers/customer_profile_screen.dart';
import '../../features/customers/directory_screen.dart';
import '../../features/customers/duplicates_screen.dart';
import '../../features/dashboard/admin_dashboard_screen.dart';
import '../../features/dashboard/employee_home_screen.dart';
import '../../features/employees/employee_details_screen.dart';
import '../../features/employees/employee_form_screen.dart';
import '../../features/employees/employees_screen.dart';
import '../../features/maps/customer_location_screen.dart';
import '../../features/maps/map_overview_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/account_settings_screen.dart';
import '../../features/settings/activity_log_screen.dart';
import '../../features/settings/app_settings_screen.dart';
import '../../features/settings/language_screen.dart';
import '../../features/settings/profile_settings_screen.dart';
import '../../features/settings/settings_screen.dart';
import 'shells.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';

  // Admin shell
  static const dashboard = '/dashboard';
  static const customers = '/customers';
  static const employees = '/employees';
  static const map = '/map';
  static const settings = '/settings';

  // Employee shell
  static const home = '/home';
  static const directory = '/directory';
  static const explore = '/explore';
  static const me = '/me';

  // Shared pushed screens
  static const search = '/search';
  static const notifications = '/notifications';
  static String customer(String id) => '/customer/$id';
  static String customerLocation(String id) => '/customer/$id/location';
  static const accountSettings = '/account';
  static const profileSettings = '/profile';
  static const language = '/language';

  // Admin-only pushed screens
  static const newCustomer = '/customer-new';
  static String editCustomer(String id) => '/customer/$id/edit';
  static const duplicates = '/duplicates';
  static const newEmployee = '/employee-new';
  static String employee(String id) => '/employee/$id';
  static const activity = '/activity';
  static const appSettings = '/app-settings';
}

const _adminOnlyPrefixes = [
  Routes.dashboard,
  Routes.customers,
  Routes.employees,
  Routes.map,
  Routes.settings,
  Routes.newCustomer,
  Routes.duplicates,
  Routes.newEmployee,
  '/employee/',
  Routes.activity,
  Routes.appSettings,
];

const _employeeShellPrefixes = [Routes.home, Routes.directory, Routes.explore, Routes.me];

/// Redirect rules. The UI guard mirrors the server rules; the server (RLS)
/// remains the real enforcement.
String? resolveRedirect({required String location, required AuthState auth, required bool onboardingDone}) {
  final atSplash = location == Routes.splash;
  final atPublic = location == Routes.login || location == Routes.onboarding;

  switch (auth.phase) {
    case AuthPhase.initializing:
      return atSplash ? null : Routes.splash;
    case AuthPhase.signedOut:
      if (!onboardingDone) return location == Routes.onboarding ? null : Routes.onboarding;
      return location == Routes.login ? null : Routes.login;
    case AuthPhase.signedIn:
      final admin = auth.isAdmin;
      final home = admin ? Routes.dashboard : Routes.home;
      if (atSplash || atPublic || location == '/') return home;
      bool matches(String prefix) =>
          location == prefix || location.startsWith('$prefix/') || location.startsWith(prefix);
      final editRoute = RegExp(r'^/customer/[^/]+/edit$').hasMatch(location);
      if (!admin && (editRoute || _adminOnlyPrefixes.any(matches))) return Routes.home;
      if (admin && _employeeShellPrefixes.any(matches)) return Routes.dashboard;
      return null;
  }
}

/// Bridges Riverpod state changes to GoRouter's refreshListenable.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
    ref.listen(preferencesProvider.select((p) => p.onboardingDone), (_, _) => notifyListeners());
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  GoRoute pushed(String path, Widget Function(GoRouterState s) build) =>
      GoRoute(path: path, parentNavigatorKey: rootNavigatorKey, builder: (context, state) => build(state));

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      location: state.matchedLocation,
      auth: ref.read(authControllerProvider),
      onboardingDone: ref.read(preferencesProvider).onboardingDone,
    ),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => Routes.splash),
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdminShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.dashboard, builder: (_, _) => const AdminDashboardScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.customers, builder: (_, _) => const DirectoryScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.employees, builder: (_, _) => const EmployeesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.map, builder: (_, _) => const MapOverviewScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen())],
          ),
        ],
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => EmployeeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const EmployeeHomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.directory, builder: (_, _) => const DirectoryScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.explore, builder: (_, _) => const MapOverviewScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.me, builder: (_, _) => const SettingsScreen())],
          ),
        ],
      ),

      pushed(Routes.search, (_) => const SearchScreen()),
      pushed(Routes.notifications, (_) => const NotificationsScreen()),
      pushed(Routes.newCustomer, (_) => const CustomerFormScreen()),
      pushed('/customer/:id', (s) => CustomerProfileScreen(customerId: s.pathParameters['id']!)),
      pushed('/customer/:id/edit', (s) => CustomerFormScreen(customerId: s.pathParameters['id'])),
      pushed('/customer/:id/location', (s) => CustomerLocationScreen(customerId: s.pathParameters['id']!)),
      pushed(Routes.duplicates, (_) => const DuplicatesScreen()),
      pushed(Routes.newEmployee, (_) => const EmployeeFormScreen()),
      pushed('/employee/:id', (s) => EmployeeDetailsScreen(employeeId: s.pathParameters['id']!)),
      pushed(Routes.accountSettings, (_) => const AccountSettingsScreen()),
      pushed(Routes.profileSettings, (_) => const ProfileSettingsScreen()),
      pushed(Routes.language, (_) => const LanguageScreen()),
      pushed(Routes.activity, (_) => const ActivityLogScreen()),
      pushed(Routes.appSettings, (_) => const AppSettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
