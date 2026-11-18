import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/validators.dart';
import '../../data/models/profile.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/feedback.dart';
import 'password_tools.dart';

/// Create a staff account (through the admin-users Edge Function).
class EmployeeFormScreen extends ConsumerStatefulWidget {
  const EmployeeFormScreen({super.key});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController(text: generateTemporaryPassword());
  UserRole _role = UserRole.employee;
  bool _usernameEdited = false;
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() {
      if (!_usernameEdited) _username.text = Validators.suggestUsername(_name.text);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    if (_role == UserRole.admin) {
      final ok = await showConfirmDialog(
        context,
        icon: Icons.admin_panel_settings_outlined,
        title: l10n.employeeAdminConfirmTitle,
        message: l10n.employeeAdminConfirmBody,
        confirmLabel: l10n.actionConfirm,
      );
      if (!ok || !mounted) return;
    }
    final username = _username.text.trim().toLowerCase();
    final password = _password.text;
    try {
      await ref
          .read(employeeRepositoryProvider)
          .create(fullName: _name.text.trim(), username: username, password: password, role: _role);
      if (!mounted) return;
      await showCredentialsDialog(context, username: username, password: password);
      if (!mounted) return;
      showToast(context, l10n.employeeCreated, kind: ToastKind.success);
      context.pop();
    } catch (e) {
      if (mounted) showErrorToast(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? err(FieldError? e) => fieldErrorText(context, e);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.employeeNew)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.xxl),
          children: [
            SectionCard(
              title: l10n.employeeIdentity,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: '${l10n.fieldFullName} *',
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => err(Validators.required(v, min: 2, max: 120)),
                  ),
                  const SizedBox(height: Space.sm),
                  TextFormField(
                    controller: _username,
                    textDirection: TextDirection.ltr,
                    autocorrect: false,
                    onChanged: (_) => _usernameEdited = true,
                    decoration: InputDecoration(
                      labelText: '${l10n.loginUsername} *',
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      helperText: l10n.usernameHelper,
                    ),
                    validator: (v) => err(Validators.username(v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            SectionCard(
              title: l10n.employeeRole,
              child: RadioGroup<UserRole>(
                groupValue: _role,
                onChanged: (v) => setState(() => _role = v!),
                child: Column(
                  children: [
                    for (final role in UserRole.values)
                      RadioListTile<UserRole>(
                        contentPadding: EdgeInsets.zero,
                        value: role,
                        title: Text(role == UserRole.admin ? l10n.roleAdmin : l10n.roleEmployee),
                        subtitle: Text(role == UserRole.admin ? l10n.roleAdminHint : l10n.roleEmployeeHint),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.md),
            SectionCard(
              title: l10n.employeeTempPassword,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    textDirection: TextDirection.ltr,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: '${l10n.loginPassword} *',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: _obscure ? l10n.actionShowPassword : l10n.actionHidePassword,
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          IconButton(
                            tooltip: l10n.actionGenerate,
                            icon: const Icon(Icons.autorenew_rounded),
                            onPressed: () => setState(() => _password.text = generateTemporaryPassword()),
                          ),
                        ],
                      ),
                    ),
                    validator: (v) => err(Validators.password(v)),
                  ),
                  const SizedBox(height: Space.xs),
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Expanded(child: Text(l10n.passwordRules, style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.xl),
            AsyncButton(label: l10n.actionCreateAccount, icon: Icons.check_rounded, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
