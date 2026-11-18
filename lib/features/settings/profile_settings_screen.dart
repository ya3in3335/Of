import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/feedback.dart';
import '../auth/auth_controller.dart';

/// Edit own display name and phone (update_own_profile RPC; role and status
/// cannot be changed from here).
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: ref.read(currentProfileProvider)?.fullName ?? '');
  late final _phone = TextEditingController(text: Formatters.phone(ref.read(currentProfileProvider)?.phone));

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    try {
      await ref.read(authRepositoryProvider).updateOwnProfile(
            fullName: _name.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          );
      await ref.read(authControllerProvider.notifier).refreshProfile();
      if (!mounted) return;
      showToast(context, l10n.profileSaved, kind: ToastKind.success);
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsProfile)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.xxl),
          children: [
            if (profile != null)
              Center(child: InitialsAvatar(initials: profile.initials, seed: profile.id, size: 80)),
            const SizedBox(height: Space.lg),
            SectionCard(
              child: Column(children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l10n.fieldFullName, prefixIcon: const Icon(Icons.badge_outlined)),
                  validator: (v) => err(Validators.required(v, min: 2, max: 120)),
                ),
                const SizedBox(height: Space.sm),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(labelText: l10n.fieldPhone, prefixIcon: const Icon(Icons.phone_outlined)),
                  validator: (v) => err(Validators.phone(v, isRequired: false)),
                ),
              ]),
            ),
            const SizedBox(height: Space.xs),
            Text(l10n.profileRoleHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Space.xl),
            AsyncButton(label: l10n.actionSaveChanges, icon: Icons.check_rounded, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
