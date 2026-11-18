import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/directory_controller.dart';
import '../auth/auth_controller.dart';
import '../search/search_panel.dart';

/// Employee home = search. The field is focused on launch so the employee can
/// type the name from the invoice right away.
class EmployeeHomeScreen extends ConsumerWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SafeArea(
        bottom: false,
        child: SearchPanel(
          autofocus: true,
          header: _Header(),
          idle: Column(children: [_DirectorySummary(), RecentCustomers(), SearchTips(), SizedBox(height: 120)]),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider);
    final unread = ref.watch(notificationsProvider.select((s) => s.unread));
    final text = Theme.of(context).textTheme;
    final firstName = (profile?.fullName ?? '').split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.xs, Space.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeGreeting(firstName), style: text.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(l10n.homeTitle, style: text.headlineSmall),
              ],
            ),
          ),
          NotificationBell(unread: unread),
        ],
      ),
    );
  }
}

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, required this.unread});
  final int unread;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.notificationsTitle,
      onPressed: () => context.push(Routes.notifications),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        backgroundColor: AppColors.brandRed,
        child: const Icon(Icons.notifications_none_rounded, color: AppColors.navy, size: 26),
      ),
    );
  }
}

class _DirectorySummary extends ConsumerWidget {
  const _DirectorySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final customers = ref.watch(directoryProvider.select((s) => s.customers));
    final active = customers.where((c) => !c.isArchived).toList();
    final located = active.where((c) => c.hasLocation).length;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, 0),
      child: Container(
        padding: const EdgeInsets.all(Space.md),
        decoration: BoxDecoration(color: AppColors.navy, borderRadius: Radii.card, boxShadow: Shadows.card),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${active.length}', style: text.headlineMedium?.copyWith(color: Colors.white)),
                  Text(l10n.homeCustomersAvailable, style: text.bodySmall?.copyWith(color: const Color(0xFFB9CCE6))),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: const Color(0x33FFFFFF)),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$located', style: text.headlineMedium?.copyWith(color: Colors.white)),
                  Text(l10n.homeWithLocation, style: text.bodySmall?.copyWith(color: const Color(0xFFB9CCE6))),
                ],
              ),
            ),
            const SyncStatusBadgeOnDark(),
          ],
        ),
      ),
    );
  }
}

/// Compact sync indicator for the navy summary card.
class SyncStatusBadgeOnDark extends ConsumerWidget {
  const SyncStatusBadgeOnDark({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(directoryProvider.select((s) => s.status));
    final (icon, color) = switch (status) {
      SyncStatus.idle => (Icons.cloud_done_rounded, AppColors.cyan),
      SyncStatus.syncing => (Icons.sync_rounded, Colors.white),
      SyncStatus.offline => (Icons.cloud_off_rounded, const Color(0xFFFFC46B)),
      SyncStatus.error => (Icons.sync_problem_rounded, const Color(0xFFFF9AA0)),
    };
    return IconButton(
      tooltip: context.l10n.syncNow,
      onPressed: () => ref.read(directoryProvider.notifier).sync(),
      icon: status == SyncStatus.syncing
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(icon, color: color),
    );
  }
}
