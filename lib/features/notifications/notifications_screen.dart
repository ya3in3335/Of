import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../domain/directory_controller.dart';
import '../../domain/directory_sync.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/states.dart';

/// Changes to the directory received by this device (new customers, moved
/// locations, archives, deletions), newest first.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  DateTime? _seenBefore;

  @override
  void initState() {
    super.initState();
    _seenBefore = ref.read(notificationsProvider).lastSeen;
    // Mark as read on open; items stay highlighted for this visit.
    Future.microtask(() => ref.read(notificationsProvider.notifier).markAllSeen());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(notificationsProvider);
    final byId = ref.watch(directoryProvider.select((s) => s.byId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (state.items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).clear(),
              child: Text(l10n.actionClear),
            ),
        ],
      ),
      body: state.items.isEmpty
          ? EmptyState(
              icon: Icons.notifications_none_rounded,
              title: l10n.notificationsEmptyTitle,
              message: l10n.notificationsEmptyBody,
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(directoryProvider.notifier).sync(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.xxl),
                itemCount: state.items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: Space.xs),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: Row(children: [
                        Expanded(child: Text(l10n.notificationsIntro, style: Theme.of(context).textTheme.bodySmall)),
                        const SyncStatusBadge(),
                      ]),
                    );
                  }
                  final item = state.items[i - 1];
                  final unread = _seenBefore == null || item.at.isAfter(_seenBefore!);
                  final exists = byId.containsKey(item.customerId);
                  return _NotificationTile(
                    item: item,
                    unread: unread,
                    onTap: exists ? () => context.push(Routes.customer(item.customerId)) : null,
                  );
                },
              ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.unread, this.onTap});
  final DirectoryChange item;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final (icon, color, title) = switch (item.kind) {
      ChangeKind.created => (Icons.person_add_alt_1_rounded, AppColors.success, l10n.notifCreated),
      ChangeKind.updated => (Icons.edit_rounded, AppColors.blue, l10n.notifUpdated),
      ChangeKind.locationUpdated => (Icons.edit_location_alt_rounded, AppColors.blue, l10n.notifLocation),
      ChangeKind.archived => (Icons.archive_rounded, AppColors.textSecondary, l10n.notifArchived),
      ChangeKind.restored => (Icons.unarchive_rounded, AppColors.success, l10n.notifRestored),
      ChangeKind.deleted => (Icons.delete_rounded, AppColors.error, l10n.notifDeleted),
    };
    return Material(
      color: unread ? const Color(0xFFF2F7FF) : AppColors.surface,
      borderRadius: Radii.card,
      child: InkWell(
        borderRadius: Radii.card,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(Space.sm),
          decoration: BoxDecoration(borderRadius: Radii.card, border: Border.all(color: AppColors.divider)),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: text.labelSmall),
                Row(children: [
                  Flexible(child: Text(item.name, style: text.titleSmall, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  ReferencePill(item.reference),
                ]),
                Text(Formatters.relative(context, item.at), style: text.bodySmall),
              ]),
            ),
            if (unread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle)),
          ]),
        ),
      ),
    );
  }
}
