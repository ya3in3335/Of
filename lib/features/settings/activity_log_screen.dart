import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/activity.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/states.dart';

enum ActivityFilter { all, admin, field }

const _fieldActions = ['customer_viewed', 'customer_called', 'customer_whatsapp', 'customer_navigated'];
const _adminActions = [
  'customer_created', 'customer_updated', 'customer_location_updated', 'customer_archived', 'customer_restored',
  'customer_deleted', 'employee_created', 'employee_activated', 'employee_deactivated', 'employee_password_reset',
  'employee_updated', 'duplicate_dismissed', 'settings_updated',
];

/// Audit trail (admin only, enforced by RLS on activity_logs).
class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  static const _page = 40;
  final _items = <ActivityLog>[];
  ActivityFilter _filter = ActivityFilter.all;
  Object? _error;
  bool _loading = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _items.clear();
        _done = false;
      }
    });
    try {
      final list = await ref.read(activityRepositoryProvider).recent(
            limit: _page,
            offset: _items.length,
            actions: switch (_filter) {
              ActivityFilter.all => null,
              ActivityFilter.admin => _adminActions,
              ActivityFilter.field => _fieldActions,
            },
          );
      if (!mounted) return;
      setState(() {
        _items.addAll(list);
        _done = list.length < _page;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget body;
    if (_items.isEmpty && _loading) {
      body = const ListSkeleton();
    } else if (_items.isEmpty && _error != null) {
      body = ErrorState(error: _error!, onRetry: () => _load(reset: true));
    } else if (_items.isEmpty) {
      body = EmptyState(icon: Icons.history_rounded, title: l10n.activityEmpty);
    } else {
      body = RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 300 && !_done && !_loading && _error == null) _load();
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.xxl),
            itemCount: _items.length + 1,
            itemBuilder: (context, i) {
              if (i == _items.length) {
                if (_error != null) {
                  return TextButton(onPressed: _load, child: Text(l10n.actionRetry));
                }
                return _done
                    ? const SizedBox(height: Space.lg)
                    : const Padding(
                        padding: EdgeInsets.all(Space.md),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
              }
              return ActivityTile(log: _items[i]);
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityTitle)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.sm),
          child: SegmentedButton<ActivityFilter>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: ActivityFilter.all, label: Text(l10n.filterAll)),
              ButtonSegment(value: ActivityFilter.admin, label: Text(l10n.activityFilterAdmin)),
              ButtonSegment(value: ActivityFilter.field, label: Text(l10n.activityFilterField)),
            ],
            selected: {_filter},
            onSelectionChanged: (s) {
              setState(() => _filter = s.first);
              _load(reset: true);
            },
          ),
        ),
        Expanded(child: body),
      ]),
    );
  }
}

class ActivityTile extends ConsumerWidget {
  const ActivityTile({super.key, required this.log, this.dense = false});
  final ActivityLog log;
  final bool dense;

  static (IconData, Color) visual(String action) => switch (action) {
        'customer_created' => (Icons.person_add_alt_1_rounded, AppColors.success),
        'customer_updated' => (Icons.edit_rounded, AppColors.blue),
        'customer_location_updated' => (Icons.edit_location_alt_rounded, AppColors.blue),
        'customer_archived' => (Icons.archive_rounded, AppColors.textSecondary),
        'customer_restored' => (Icons.unarchive_rounded, AppColors.success),
        'customer_deleted' => (Icons.delete_rounded, AppColors.error),
        'customer_viewed' => (Icons.visibility_rounded, AppColors.textTertiary),
        'customer_called' => (Icons.call_rounded, AppColors.navy),
        'customer_whatsapp' => (Icons.chat_rounded, AppColors.whatsapp),
        'customer_navigated' => (Icons.navigation_rounded, AppColors.blue),
        'employee_created' => (Icons.badge_rounded, AppColors.success),
        'employee_activated' => (Icons.lock_open_rounded, AppColors.success),
        'employee_deactivated' => (Icons.block_rounded, AppColors.error),
        'employee_password_reset' => (Icons.key_rounded, AppColors.warning),
        'employee_updated' => (Icons.manage_accounts_rounded, AppColors.blue),
        'duplicate_dismissed' => (Icons.do_not_disturb_on_rounded, AppColors.textSecondary),
        'settings_updated' => (Icons.tune_rounded, AppColors.navy),
        _ => (Icons.history_rounded, AppColors.textSecondary),
      };

  static String describe(BuildContext context, ActivityLog log) {
    final l10n = context.l10n;
    final c = log.customerName ?? log.customerReference ?? '—';
    final t = log.targetName ?? '—';
    return switch (log.action) {
      'customer_created' => l10n.logCustomerCreated(c),
      'customer_updated' => l10n.logCustomerUpdated(c),
      'customer_location_updated' => l10n.logCustomerLocation(c),
      'customer_archived' => l10n.logCustomerArchived(c),
      'customer_restored' => l10n.logCustomerRestored(c),
      'customer_deleted' => l10n.logCustomerDeleted(c),
      'customer_viewed' => l10n.logCustomerViewed(c),
      'customer_called' => l10n.logCustomerCalled(c),
      'customer_whatsapp' => l10n.logCustomerWhatsapp(c),
      'customer_navigated' => l10n.logCustomerNavigated(c),
      'employee_created' => l10n.logEmployeeCreated(t),
      'employee_activated' => l10n.logEmployeeActivated(t),
      'employee_deactivated' => l10n.logEmployeeDeactivated(t),
      'employee_password_reset' => l10n.logEmployeePassword(t),
      'employee_updated' => l10n.logEmployeeUpdated(t),
      'duplicate_dismissed' => l10n.logDuplicateDismissed,
      'settings_updated' => l10n.logSettingsUpdated,
      _ => log.action,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (icon, color) = visual(log.action);
    final text = Theme.of(context).textTheme;
    // Field actions on customers are resolved against the live directory so the
    // name is shown even though view/call logs carry no details.
    final liveName = log.customerId == null ? null : ref.watch(customerByIdProvider(log.customerId!))?.fullName;
    final resolved = log.customerName == null && liveName != null
        ? ActivityLog(
            id: log.id,
            action: log.action,
            createdAt: log.createdAt,
            actorName: log.actorName,
            customerId: log.customerId,
            targetName: log.targetName,
            details: {...log.details, 'name': liveName},
          )
        : log;
    final canOpen = log.customerId != null && liveName != null;
    return InkWell(
      borderRadius: Radii.field,
      onTap: canOpen ? () => context.push(Routes.customer(log.customerId!)) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 6 : Space.xs),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(describe(context, resolved), style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 1),
              Text(
                '${log.actorName ?? context.l10n.activitySystem} · ${Formatters.relative(context, log.createdAt)}',
                style: text.bodySmall,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
