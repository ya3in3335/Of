import 'dart:math';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/feedback.dart';

/// Temporary passwords: 10 characters from an unambiguous alphabet (no
/// 0/O, 1/l/I), always with letters and digits, from a secure RNG.
String generateTemporaryPassword({int length = 10, Random? random}) {
  final rng = random ?? Random.secure();
  const letters = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ';
  const digits = '23456789';
  const all = letters + digits;
  final chars = <String>[
    letters[rng.nextInt(letters.length)],
    digits[rng.nextInt(digits.length)],
    for (var i = 2; i < length; i++) all[rng.nextInt(all.length)],
  ]..shuffle(rng);
  return chars.join();
}

/// Shown once after creating an account or resetting a password, so the
/// admin can pass the credentials on. The password is not stored anywhere.
Future<void> showCredentialsDialog(BuildContext context, {required String username, required String password}) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.key_rounded, color: AppColors.blue, size: 32),
      title: Text(l10n.credentialsTitle, textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(l10n.credentialsBody, textAlign: TextAlign.center),
        const SizedBox(height: Space.md),
        Container(
          padding: const EdgeInsets.all(Space.md),
          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: Radii.field),
          child: Column(children: [
            _CredentialLine(label: l10n.loginUsername, value: username),
            const Divider(height: Space.lg),
            _CredentialLine(label: l10n.loginPassword, value: password),
          ]),
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: '${l10n.loginUsername}: $username\n${l10n.loginPassword}: $password'));
            if (context.mounted) showToast(context, l10n.copiedCredentials, kind: ToastKind.success);
          },
          child: Text(l10n.actionCopyAll),
        ),
        FilledButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionDone)),
      ],
    ),
  );
}

class _CredentialLine extends StatelessWidget {
  const _CredentialLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const Spacer(),
      SelectableText(
        value,
        textDirection: TextDirection.ltr,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'monospace', letterSpacing: 0.5),
      ),
    ]);
  }
}
