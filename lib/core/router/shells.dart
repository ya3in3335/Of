import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/directory_controller.dart';
import '../l10n_ext.dart';
import '../providers.dart';
import 'app_router.dart';

/// Admin navigation: Dashboard, Customers, Employees, Map, Settings, with a
/// floating "New customer" button on the first two tabs.
class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final showFab = shell.currentIndex <= 1;
    return Scaffold(
      body: shell,
      floatingActionButton: AnimatedScale(
        scale: showFab ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: FloatingActionButton.extended(
          heroTag: 'new-customer',
          onPressed: showFab ? () => context.push(Routes.newCustomer) : null,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: Text(l10n.customerNew),
        ),
      ),
      bottomNavigationBar: _NavBar(
        shell: shell,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.space_dashboard_outlined),
              selectedIcon: const Icon(Icons.space_dashboard_rounded),
              label: l10n.navDashboard),
          NavigationDestination(
              icon: const Icon(Icons.people_alt_outlined),
              selectedIcon: const Icon(Icons.people_alt_rounded),
              label: l10n.navCustomers),
          NavigationDestination(
              icon: const Icon(Icons.badge_outlined),
              selectedIcon: const Icon(Icons.badge_rounded),
              label: l10n.navEmployees),
          NavigationDestination(
              icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map_rounded), label: l10n.navMap),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: l10n.navSettings),
        ],
      ),
    );
  }
}

/// Employee navigation: Search first, then Customers, Map, Profile.
class EmployeeShell extends ConsumerWidget {
  const EmployeeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: _NavBar(
        shell: shell,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.search_rounded), selectedIcon: const Icon(Icons.search_rounded), label: l10n.navSearch),
          NavigationDestination(
              icon: const Icon(Icons.people_alt_outlined),
              selectedIcon: const Icon(Icons.people_alt_rounded),
              label: l10n.navCustomers),
          NavigationDestination(
              icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map_rounded), label: l10n.navMap),
          NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.navProfile),
        ],
      ),
    );
  }
}

class _NavBar extends ConsumerWidget {
  const _NavBar({required this.shell, required this.destinations});
  final StatefulNavigationShell shell;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityProvider).value ?? true;
    final status = ref.watch(directoryProvider.select((s) => s.status));
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (!online || status == SyncStatus.offline)
        Material(
          color: const Color(0xFFFDF3E2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.cloud_off_rounded, size: 16, color: Color(0xFFD98A14)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  context.l10n.offlineBanner,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8A5A0C)),
                ),
              ),
            ]),
          ),
        ),
      DecoratedBox(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEDF1F6)))),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: destinations,
        ),
      ),
    ]);
  }
}
