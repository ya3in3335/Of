import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/feedback.dart';
import '../auth/auth_controller.dart';

/// Change the signed-in user's password (current password required).
class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    try {
      await ref.read(authRepositoryProvider).changePassword(currentPassword: _current.text, newPassword: _next.text);
      if (!mounted) return;
      showToast(context, l10n.passwordChanged, kind: ToastKind.success);
      context.pop();
    } catch (e) {
      if (mounted) showErrorToast(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(currentProfileProvider);
    String? err(FieldError? e) => fieldErrorText(context, e);
    InputDecoration deco(String label) => InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        tooltip: _obscure ? l10n.actionShowPassword : l10n.actionHidePassword,
        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAccount)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.xxl),
          children: [
            SectionCard(
              title: l10n.settingsAccountInfo,
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.alternate_email_rounded,
                    label: l10n.loginUsername,
                    value: profile?.username ?? '',
                    valueDirection: TextDirection.ltr,
                  ),
                  InfoRow(
                    icon: Icons.verified_user_outlined,
                    label: l10n.employeeRole,
                    value: (profile?.isAdmin ?? false) ? l10n.roleAdmin : l10n.roleEmployee,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            SectionCard(
              title: l10n.changePasswordTitle,
              child: Column(
                children: [
                  TextFormField(
                    controller: _current,
                    obscureText: _obscure,
                    decoration: deco(l10n.fieldCurrentPassword),
                    validator: (v) => (v == null || v.isEmpty) ? l10n.validationRequired : null,
                  ),
                  const SizedBox(height: Space.sm),
                  TextFormField(
                    controller: _next,
                    obscureText: _obscure,
                    decoration: deco(l10n.fieldNewPassword),
                    validator: (v) {
                      final e = Validators.password(v);
                      if (e != null) return err(e);
                      if (v == _current.text) return l10n.validationSamePassword;
                      return null;
                    },
                  ),
                  const SizedBox(height: Space.sm),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    decoration: deco(l10n.fieldConfirmPassword),
                    validator: (v) => v != _next.text ? err(FieldError.mismatch) : null,
                  ),
                  const SizedBox(height: Space.xs),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(l10n.passwordRules, style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.xl),
            AsyncButton(label: l10n.changePasswordTitle, icon: Icons.check_rounded, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
