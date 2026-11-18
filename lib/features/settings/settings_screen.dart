import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/feedback.dart';
import '../auth/auth_controller.dart';

/// Settings hub (admin "Settings" tab, employee "Profile" tab).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(currentProfileProvider);
    final isAdmin = profile?.isAdmin ?? false;
    final unread = ref.watch(notificationsProvider.select((s) => s.unread));
    final count = ref.watch(directoryProvider.select((s) => s.customers.length));
    final last = ref.watch(directoryProvider.select((s) => s.lastSyncedAt));

    Future<void> signOut() async {
      final ok = await showConfirmDialog(
        context,
        icon: Icons.logout_rounded,
        title: l10n.signOutTitle,
        message: l10n.signOutBody,
        confirmLabel: l10n.actionSignOut,
        destructive: true,
      );
      if (ok) await ref.read(authControllerProvider.notifier).signOut();
    }

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? l10n.navSettings : l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.xxl),
        children: [
          if (profile != null)
            Container(
              padding: const EdgeInsets.all(Space.md),
              decoration: AppDecorations.card(),
              child: Row(children: [
                InitialsAvatar(initials: profile.initials, seed: profile.id, size: 56),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(profile.fullName, style: text.titleMedium),
                    Text('@${profile.username}', textDirection: TextDirection.ltr, style: text.bodySmall),
                    const SizedBox(height: Space.xs),
                    StatusChip(label: isAdmin ? l10n.roleAdmin : l10n.roleEmployee, tone: ChipTone.info),
                  ]),
                ),
              ]),
            ),
          const SizedBox(height: Space.md),
          _Group(title: l10n.settingsAccountGroup, children: [
            _Item(icon: Icons.person_outline_rounded, label: l10n.settingsProfile, onTap: () => context.push(Routes.profileSettings)),
            _Item(icon: Icons.lock_outline_rounded, label: l10n.settingsAccount, onTap: () => context.push(Routes.accountSettings)),
            _Item(
              icon: Icons.notifications_none_rounded,
              label: l10n.notificationsTitle,
              trailing: unread > 0 ? StatusChip(label: '$unread', tone: ChipTone.danger) : null,
              onTap: () => context.push(Routes.notifications),
            ),
            _Item(icon: Icons.translate_rounded, label: l10n.settingsLanguage, onTap: () => context.push(Routes.language)),
          ]),
          if (isAdmin) ...[
            const SizedBox(height: Space.md),
            _Group(title: l10n.settingsAdminGroup, children: [
              _Item(icon: Icons.business_rounded, label: l10n.settingsApp, onTap: () => context.push(Routes.appSettings)),
              _Item(icon: Icons.history_rounded, label: l10n.activityTitle, onTap: () => context.push(Routes.activity)),
              _Item(icon: Icons.content_copy_rounded, label: l10n.duplicatesTitle, onTap: () => context.push(Routes.duplicates)),
            ]),
          ],
          const SizedBox(height: Space.md),
          _Group(title: l10n.settingsDataGroup, children: [
            _Item(
              icon: Icons.sync_rounded,
              label: l10n.syncNow,
              subtitle: '${l10n.directoryCount(count)} · ${last == null ? l10n.syncNever : l10n.syncDone(Formatters.time(context, last))}',
              onTap: () async {
                await ref.read(directoryProvider.notifier).sync(full: true);
                if (!context.mounted) return;
                final status = ref.read(directoryProvider).status;
                showToast(
                  context,
                  status == SyncStatus.idle ? l10n.syncCompleted : l10n.syncFailed,
                  kind: status == SyncStatus.idle ? ToastKind.success : ToastKind.error,
                );
              },
            ),
          ]),
          const SizedBox(height: Space.lg),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: signOut,
            icon: const Icon(Icons.logout_rounded),
            label: Text(l10n.actionSignOut),
          ),
          const SizedBox(height: Space.lg),
          Center(child: Text(l10n.appVersion('1.0.0'), style: text.bodySmall)),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.xs, Space.xs),
      child: Column(children: children),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.onTap, this.subtitle, this.trailing});
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(Radii.sm)),
        child: Icon(icon, size: 20, color: AppColors.navy),
      ),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        ?trailing,
        Icon(
          Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          color: AppColors.textTertiary,
        ),
      ]),
      onTap: onTap,
    );
  }
}
