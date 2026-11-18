import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/activity.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/states.dart';
import '../auth/auth_controller.dart';
import '../customers/widgets/customer_tile.dart';
import '../settings/activity_log_screen.dart';
import '../settings/app_settings_controller.dart';
import 'employee_home_screen.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>(
  (ref) => ref.read(activityRepositoryProvider).dashboardStats(),
);

final recentActivityProvider = FutureProvider.autoDispose<List<ActivityLog>>(
  (ref) => ref.read(activityRepositoryProvider).recent(limit: 6),
);

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(currentProfileProvider);
    final company = ref.watch(appSettingsProvider).value?.companyName ?? 'OUTIFOR';
    final unread = ref.watch(notificationsProvider.select((s) => s.unread));
    final stats = ref.watch(dashboardStatsProvider);
    final activity = ref.watch(recentActivityProvider);
    final customers = ref.watch(directoryProvider.select((s) => s.customers));
    final recent = [...customers]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Refresh the counters when the directory changes (another admin's edit).
    ref.listen(directoryProvider.select((s) => s.lastSyncedAt), (prev, next) {
      if (prev != null && next != prev) {
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(recentActivityProvider);
      }
    });

    Future<void> refresh() async {
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(recentActivityProvider);
      await ref.read(directoryProvider.notifier).sync();
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 120),
            children: [
              Row(children: [
                const BrandLogo(size: 44),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(company, style: text.labelSmall),
                    Text(l10n.homeGreeting((profile?.fullName ?? '').split(' ').first), style: text.titleLarge),
                  ]),
                ),
                NotificationBell(unread: unread),
              ]),
              const SizedBox(height: Space.md),
              SearchField(
                controller: null,
                readOnly: true,
                hint: l10n.searchHint,
                onTap: () => context.push(Routes.search),
              ),
              const SizedBox(height: Space.sm),
              const Align(alignment: AlignmentDirectional.centerStart, child: SyncStatusBadge()),
              const SizedBox(height: Space.lg),
              stats.when(
                loading: () => const _StatsSkeleton(),
                error: (e, _) => SectionCard(
                  child: ErrorState(error: e, compact: true, onRetry: () => ref.invalidate(dashboardStatsProvider)),
                ),
                data: (s) => _StatsGrid(stats: s),
              ),
              const SizedBox(height: Space.lg),
              Text(l10n.dashboardQuickActions, style: text.titleMedium),
              const SizedBox(height: Space.sm),
              Row(children: [
                _QuickAction(
                  icon: Icons.person_add_alt_1_rounded,
                  label: l10n.customerNew,
                  color: AppColors.blue,
                  onTap: () => context.push(Routes.newCustomer),
                ),
                const SizedBox(width: Space.xs),
                _QuickAction(
                  icon: Icons.badge_rounded,
                  label: l10n.navEmployees,
                  color: AppColors.navy,
                  onTap: () => context.go(Routes.employees),
                ),
                const SizedBox(width: Space.xs),
                _QuickAction(
                  icon: Icons.people_alt_rounded,
                  label: l10n.dashboardDirectory,
                  color: const Color(0xFF0E8C9B),
                  onTap: () => context.go(Routes.customers),
                ),
                const SizedBox(width: Space.xs),
                _QuickAction(
                  icon: Icons.content_copy_rounded,
                  label: l10n.duplicatesShort,
                  color: AppColors.warning,
                  onTap: () => context.push(Routes.duplicates),
                ),
              ]),
              const SizedBox(height: Space.lg),
              SectionCard(
                title: l10n.dashboardRecentCustomers,
                trailing: TextButton(onPressed: () => context.go(Routes.customers), child: Text(l10n.actionSeeAll)),
                child: recent.isEmpty
                    ? EmptyState(
                        compact: true,
                        icon: Icons.person_add_alt_outlined,
                        title: l10n.directoryEmptyTitle,
                        message: l10n.directoryEmptyAdmin,
                      )
                    : Column(children: [
                        for (final c in recent.take(4)) ...[
                          CustomerTile(customer: c, onTap: () => context.push(Routes.customer(c.id))),
                          const SizedBox(height: Space.xs),
                        ],
                      ]),
              ),
              const SizedBox(height: Space.md),
              SectionCard(
                title: l10n.dashboardRecentActivity,
                trailing: TextButton(onPressed: () => context.push(Routes.activity), child: Text(l10n.actionSeeAll)),
                child: activity.when(
                  loading: () => const Column(children: [Skeleton(height: 40), SizedBox(height: 8), Skeleton(height: 40)]),
                  error: (e, _) =>
                      ErrorState(error: e, compact: true, onRetry: () => ref.invalidate(recentActivityProvider)),
                  data: (logs) => logs.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: Space.md),
                          child: Text(l10n.activityEmpty, style: text.bodySmall),
                        )
                      : Column(children: [for (final log in logs) ActivityTile(log: log, dense: true)]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(children: [
      Row(children: [
        Expanded(
          child: _StatCard(
            icon: Icons.groups_rounded,
            color: AppColors.navy,
            value: stats.customersTotal,
            label: l10n.statTotalCustomers,
            footer: l10n.statAddedThisWeek(stats.customersLast7d),
            emphasis: true,
          ),
        ),
        const SizedBox(width: Space.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            value: stats.customersActive,
            label: l10n.statActiveCustomers,
            footer: l10n.statArchived(stats.customersArchived),
          ),
        ),
      ]),
      const SizedBox(height: Space.sm),
      Row(children: [
        Expanded(
          child: _StatCard(
            icon: Icons.badge_rounded,
            color: AppColors.blue,
            value: stats.employeesTotal,
            label: l10n.statEmployees,
            footer: l10n.statEmployeesActive(stats.employeesActive),
          ),
        ),
        const SizedBox(width: Space.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.fiber_new_rounded,
            color: const Color(0xFF0E8C9B),
            value: stats.customersLast30d,
            label: l10n.statAdded30Days,
            footer: stats.customersNoLocation > 0
                ? l10n.statMissingLocation(stats.customersNoLocation)
                : l10n.statAllLocated,
            footerWarning: stats.customersNoLocation > 0,
          ),
        ),
      ]),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.footer,
    this.emphasis = false,
    this.footerWarning = false,
  });
  final IconData icon;
  final Color color;
  final int value;
  final String label;
  final String footer;
  final bool emphasis;
  final bool footerWarning;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fg = emphasis ? Colors.white : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: emphasis
          ? BoxDecoration(color: AppColors.navy, borderRadius: Radii.card, boxShadow: Shadows.card)
          : AppDecorations.card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: emphasis ? const Color(0x22FFFFFF) : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(icon, size: 20, color: emphasis ? AppColors.cyan : color),
        ),
        const SizedBox(height: Space.sm),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: Motion.slow,
          curve: Motion.curve,
          builder: (context, v, _) => Text('${v.round()}', style: text.headlineMedium?.copyWith(color: fg)),
        ),
        Text(label, style: text.labelMedium?.copyWith(color: emphasis ? const Color(0xFFD5E2F3) : AppColors.textSecondary)),
        const SizedBox(height: Space.xs),
        Text(
          footer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.bodySmall?.copyWith(
            color: emphasis ? AppColors.cyan : (footerWarning ? AppColors.warning : AppColors.textTertiary),
            fontWeight: FontWeight.w600,
          ),
        ),
      ]),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget card() => Expanded(
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(Space.md),
            decoration: AppDecorations.card(),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Skeleton(width: 36, height: 36, radius: 10),
              SizedBox(height: Space.sm),
              Skeleton(width: 60, height: 26),
              SizedBox(height: Space.xs),
              Skeleton(width: 100, height: 12),
            ]),
          ),
        );
    return Column(children: [
      Row(children: [card(), const SizedBox(width: Space.sm), card()]),
      const SizedBox(height: Space.sm),
      Row(children: [card(), const SizedBox(width: Space.sm), card()]),
    ]);
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: Radii.card,
        child: InkWell(
          borderRadius: Radii.card,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: Space.md, horizontal: 4),
            decoration: BoxDecoration(borderRadius: Radii.card, border: Border.all(color: AppColors.divider)),
            child: Column(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: Space.xs),
              Text(label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textPrimary)),
            ]),
          ),
        ),
      ),
    );
  }
}
