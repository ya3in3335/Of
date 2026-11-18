import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/l10n_ext.dart';
import '../../core/preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/common.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    ref.read(authControllerProvider.notifier).clearSignOutReason();
    try {
      await ref.read(authControllerProvider.notifier).signIn(identifier: _identifier.text, password: _password.text);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = errorMessage(context, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final reason = ref.watch(authControllerProvider.select((s) => s.signOutReason));
    final notice =
        _error ??
        switch (reason) {
          AppErrorKind.sessionExpired => l10n.errorSessionExpired,
          AppErrorKind.accountDisabled => l10n.errorAccountDisabled,
          _ => null,
        };

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Space.xl, vertical: Space.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(alignment: AlignmentDirectional.centerEnd, child: _LanguageButton()),
                      const Center(child: BrandLogo(size: 128)),
                      const SizedBox(height: Space.xl),
                      Text(l10n.loginTitle, style: text.headlineMedium, textAlign: TextAlign.center),
                      const SizedBox(height: Space.xs),
                      Text(
                        l10n.loginSubtitle,
                        style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Space.xl),
                      AnimatedSize(
                        duration: Motion.normal,
                        child: notice == null
                            ? const SizedBox(width: double.infinity)
                            : Container(
                                margin: const EdgeInsets.only(bottom: Space.md),
                                padding: const EdgeInsets.all(Space.sm),
                                decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: Radii.field),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                                    const SizedBox(width: Space.xs),
                                    Expanded(
                                      child: Text(
                                        notice,
                                        style: text.bodySmall?.copyWith(color: const Color(0xFF8C1D24)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      TextFormField(
                        controller: _identifier,
                        autofillHints: const [AutofillHints.username],
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: l10n.loginUsername,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
                        onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: Space.md),
                      TextFormField(
                        controller: _password,
                        focusNode: _passwordFocus,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: l10n.loginPassword,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscure ? l10n.actionShowPassword : l10n.actionHidePassword,
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? l10n.validationRequired : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: Space.xl),
                      AsyncButton(label: l10n.loginButton, icon: Icons.login_rounded, onPressed: _submit),
                      const SizedBox(height: Space.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.loginNoSignup,
                              style: text.bodySmall?.copyWith(color: AppColors.textTertiary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: context.l10n.settingsLanguage,
      onSelected: (code) => ref.read(preferencesProvider.notifier).setLocale(code),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'ar', child: Text('العربية')),
        PopupMenuItem(value: 'fr', child: Text('Français')),
        PopupMenuItem(value: 'en', child: Text('English')),
      ],
      child: Padding(
        padding: const EdgeInsets.all(Space.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(context.languageCode.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
