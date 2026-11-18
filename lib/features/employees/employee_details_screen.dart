import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../data/models/activity.dart';
import '../../data/models/profile.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/states.dart';
import '../auth/auth_controller.dart';
import '../settings/activity_log_screen.dart';
import 'password_tools.dart';

final employeeProvider = FutureProvider.autoDispose.family<Profile, String>(
  (ref, id) => ref.read(employeeRepositoryProvider).get(id),
);

final employeeActivityProvider = FutureProvider.autoDispose.family<List<ActivityLog>, String>(
  (ref, id) => ref.read(activityRepositoryProvider).recent(actorId: id, limit: 15),
);

class EmployeeDetailsScreen extends ConsumerWidget {
  const EmployeeDetailsScreen({super.key, required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(employeeProvider(employeeId));
    final me = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.employeeDetailsTitle)),
      body: profile.when(
        loading: () => const ListSkeleton(rows: 3),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(employeeProvider(employeeId))),
        data: (p) => _Details(profile: p, isSelf: me?.id == p.id),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.profile, required this.isSelf});
  final Profile profile;
  final bool isSelf;

  void _refresh(WidgetRef ref) => ref.invalidate(employeeProvider(profile.id));

  Future<void> _toggleActive(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final deactivate = profile.isActive;
    final ok = await showConfirmDialog(
      context,
      icon: deactivate ? Icons.block_rounded : Icons.lock_open_rounded,
      destructive: deactivate,
      title: deactivate ? l10n.employeeDeactivateTitle : l10n.employeeActivateTitle,
      message: deactivate ? l10n.employeeDeactivateBody(profile.fullName) : l10n.employeeActivateBody(profile.fullName),
      confirmLabel: deactivate ? l10n.actionDeactivate : l10n.actionActivate,
    );
    if (!ok) return;
    try {
      await ref.read(employeeRepositoryProvider).setActive(profile.id, !deactivate);
      _refresh(ref);
      if (context.mounted) {
        showToast(context, deactivate ? l10n.employeeDeactivated : l10n.employeeActivated, kind: ToastKind.success);
      }
    } catch (e) {
      if (context.mounted) showErrorToast(context, e);
    }
  }

  Future<void> _resetPassword(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: generateTemporaryPassword());
    final formKey = GlobalKey<FormState>();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.employeeResetTitle),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.employeeResetBody(profile.fullName)),
            const SizedBox(height: Space.md),
            TextFormField(
              controller: controller,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: l10n.loginPassword,
                suffixIcon: IconButton(
                  tooltip: l10n.actionGenerate,
                  icon: const Icon(Icons.autorenew_rounded),
                  onPressed: () => controller.text = generateTemporaryPassword(),
                ),
              ),
              validator: (v) => fieldErrorText(context, Validators.password(v)),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, controller.text);
            },
            child: Text(l10n.actionReset),
          ),
        ],
      ),
    );
    controller.dispose();
    if (password == null) return;
    try {
      await ref.read(employeeRepositoryProvider).resetPassword(profile.id, password);
      if (context.mounted) await showCredentialsDialog(context, username: profile.username, password: password);
    } catch (e) {
      if (context.mounted) showErrorToast(context, e);
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = TextEditingController(text: profile.fullName);
    var role = profile.role;
    final formKey = GlobalKey<FormState>();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(Space.page, 0, Space.page, MediaQuery.viewInsetsOf(context).bottom + Space.page),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(l10n.employeeEditTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Space.md),
              TextFormField(
                controller: name,
                decoration: InputDecoration(labelText: l10n.fieldFullName),
                validator: (v) => fieldErrorText(context, Validators.required(v, min: 2, max: 120)),
              ),
              if (!isSelf) ...[
                const SizedBox(height: Space.sm),
                SegmentedButton<UserRole>(
                  segments: [
                    ButtonSegment(value: UserRole.employee, label: Text(l10n.roleEmployee)),
                    ButtonSegment(value: UserRole.admin, label: Text(l10n.roleAdmin)),
                  ],
                  selected: {role},
                  onSelectionChanged: (s) => setSheet(() => role = s.first),
                ),
              ],
              const SizedBox(height: Space.md),
              AsyncButton(
                label: l10n.actionSaveChanges,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  try {
                    await ref.read(employeeRepositoryProvider).update(profile.id, fullName: name.text.trim(), role: role);
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (e) {
                    if (context.mounted) showErrorToast(context, e);
                  }
                },
              ),
            ]),
          ),
        ),
      ),
    );
    name.dispose();
    if (saved == true) {
      _refresh(ref);
      if (isSelf) ref.read(authControllerProvider.notifier).refreshProfile();
      if (context.mounted) showToast(context, l10n.employeeUpdated, kind: ToastKind.success);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final activity = ref.watch(employeeActivityProvider(profile.id));

    return RefreshIndicator(
      onRefresh: () async {
        _refresh(ref);
        ref.invalidate(employeeActivityProvider(profile.id));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.xxl),
        children: [
          Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration: AppDecorations.card(),
            child: Column(children: [
              InitialsAvatar(initials: profile.initials, seed: profile.id, size: 68, muted: !profile.isActive),
              const SizedBox(height: Space.sm),
              Text(profile.fullName, style: text.headlineSmall, textAlign: TextAlign.center),
              Text('@${profile.username}', textDirection: TextDirection.ltr, style: text.bodyMedium),
              const SizedBox(height: Space.sm),
              Wrap(spacing: Space.xs, alignment: WrapAlignment.center, children: [
                StatusChip(
                  label: profile.isActive ? l10n.statusActive : l10n.statusInactive,
                  tone: profile.isActive ? ChipTone.success : ChipTone.danger,
                ),
                StatusChip(label: profile.isAdmin ? l10n.roleAdmin : l10n.roleEmployee, tone: ChipTone.info),
              ]),
            ]),
          ),
          const SizedBox(height: Space.md),
          SectionCard(
            title: l10n.employeeAccount,
            child: Column(children: [
              InfoRow(
                icon: Icons.event_outlined,
                label: l10n.fieldCreatedAt,
                value: Formatters.dateTime(context, profile.createdAt),
              ),
              InfoRow(
                icon: Icons.login_rounded,
                label: l10n.fieldLastLogin,
                value: profile.lastLoginAt == null
                    ? l10n.employeeNeverLoggedIn
                    : Formatters.dateTime(context, profile.lastLoginAt!),
              ),
              if (profile.phone != null)
                InfoRow(
                  icon: Icons.phone_outlined,
                  label: l10n.fieldPhone,
                  value: Formatters.phone(profile.phone),
                  valueDirection: TextDirection.ltr,
                ),
            ]),
          ),
          const SizedBox(height: Space.md),
          SectionCard(
            title: l10n.employeeManage,
            child: Column(children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_outlined, color: AppColors.navy),
                title: Text(l10n.employeeEditTitle),
                onTap: () => _edit(context, ref),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.key_outlined, color: AppColors.warning),
                title: Text(l10n.employeeResetTitle),
                subtitle: Text(l10n.employeeResetHint),
                onTap: () => _resetPassword(context, ref),
              ),
              if (!isSelf)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(profile.isActive ? Icons.block_rounded : Icons.lock_open_rounded,
                      color: profile.isActive ? AppColors.error : AppColors.success),
                  title: Text(
                    profile.isActive ? l10n.actionDeactivate : l10n.actionActivate,
                    style: TextStyle(color: profile.isActive ? AppColors.error : AppColors.success),
                  ),
                  subtitle: Text(profile.isActive ? l10n.employeeDeactivateHint : l10n.employeeActivateHint),
                  onTap: () => _toggleActive(context, ref),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: Space.xs),
                  child: Text(l10n.employeeSelfHint, style: text.bodySmall),
                ),
            ]),
          ),
          const SizedBox(height: Space.md),
          SectionCard(
            title: l10n.employeeRecentActivity,
            child: activity.when(
              loading: () => const Skeleton(height: 40),
              error: (e, _) => ErrorState(
                error: e,
                compact: true,
                onRetry: () => ref.invalidate(employeeActivityProvider(profile.id)),
              ),
              data: (logs) => logs.isEmpty
                  ? Text(l10n.activityEmpty, style: text.bodySmall)
                  : Column(children: [for (final l in logs) ActivityTile(log: l, dense: true)]),
            ),
          ),
        ],
      ),
    );
  }
}
