import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/directory_controller.dart';
import '../../features/employees/employees_screen.dart' show employeesProvider;
import '../../shared/widgets/glass_nav_bar.dart';
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
    // The shell owns the floating button so it always sits above the glass
    // bar: "New customer" on Dashboard/Customers, "New employee" on Employees.
    final tab = shell.currentIndex;
    final showFab = tab <= 2;
    final employeesTab = tab == 2;
    return Scaffold(
      // Content scrolls behind the frosted bar; screens read the bar height
      // from MediaQuery.padding.bottom.
      extendBody: true,
      body: shell,
      floatingActionButton: AnimatedScale(
        scale: showFab ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: FloatingActionButton.extended(
          heroTag: 'shell-fab',
          onPressed: !showFab
              ? null
              : employeesTab
              ? () async {
                  await context.push(Routes.newEmployee);
                  ref.invalidate(employeesProvider);
                }
              : () => context.push(Routes.newCustomer),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              employeesTab ? Icons.badge_rounded : Icons.person_add_alt_1_rounded,
              key: ValueKey(employeesTab),
            ),
          ),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(employeesTab ? l10n.employeeNew : l10n.customerNew, key: ValueKey(employeesTab)),
          ),
        ),
      ),
      bottomNavigationBar: ShellNavBar(
        shell: shell,
        items: [
          GlassNavItem(
            icon: Icons.space_dashboard_outlined,
            selectedIcon: Icons.space_dashboard_rounded,
            label: l10n.navDashboard,
          ),
          GlassNavItem(
            icon: Icons.people_alt_outlined,
            selectedIcon: Icons.people_alt_rounded,
            label: l10n.navCustomers,
          ),
          GlassNavItem(icon: Icons.badge_outlined, selectedIcon: Icons.badge_rounded, label: l10n.navEmployees),
          GlassNavItem(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: l10n.navMap),
          GlassNavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: l10n.navSettings),
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
      extendBody: true,
      body: shell,
      bottomNavigationBar: ShellNavBar(
        shell: shell,
        items: [
          GlassNavItem(icon: Icons.search_rounded, selectedIcon: Icons.search_rounded, label: l10n.navSearch),
          GlassNavItem(
            icon: Icons.people_alt_outlined,
            selectedIcon: Icons.people_alt_rounded,
            label: l10n.navCustomers,
          ),
          GlassNavItem(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: l10n.navMap),
          GlassNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: l10n.navProfile),
        ],
      ),
    );
  }
}

/// Glass bar wired to the router, with the offline notice floating above it.
class ShellNavBar extends ConsumerWidget {
  const ShellNavBar({super.key, required this.shell, required this.items});
  final StatefulNavigationShell shell;
  final List<GlassNavItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityProvider).value ?? true;
    final status = ref.watch(directoryProvider.select((s) => s.status));
    final offline = !online || status == SyncStatus.offline;
    return GlassNavBar(
      items: items,
      currentIndex: shell.currentIndex,
      onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      top: offline ? const OfflinePill() : null,
    );
  }
}

/// Small floating notice above the bar while offline.
class OfflinePill extends StatelessWidget {
  const OfflinePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xF2FDF3E2),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFF3D9A8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 15, color: Color(0xFFD98A14)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                context.l10n.offlineBanner,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8A5A0C)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
