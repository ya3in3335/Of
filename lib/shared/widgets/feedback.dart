import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';

enum ToastKind { success, error, info }

/// Floating confirmation/error message.
void showToast(BuildContext context, String message, {ToastKind kind = ToastKind.info}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final (icon, color) = switch (kind) {
    ToastKind.success => (Icons.check_circle_rounded, AppColors.success),
    ToastKind.error => (Icons.error_rounded, AppColors.error),
    ToastKind.info => (Icons.info_rounded, AppColors.cyan),
  };
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: Duration(seconds: kind == ToastKind.error ? 5 : 3),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: Space.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

void showErrorToast(BuildContext context, Object error) =>
    showToast(context, errorMessage(context, error), kind: ToastKind.error);

/// Confirmation dialog. Destructive actions use the error colour.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: icon == null
          ? null
          : Container(
              padding: const EdgeInsets.all(Space.sm),
              decoration: BoxDecoration(
                color: destructive ? AppColors.errorSoft : AppColors.infoSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: destructive ? AppColors.error : AppColors.blue, size: 26),
            ),
      title: Text(title, textAlign: icon == null ? null : TextAlign.center),
      content: Text(message, textAlign: icon == null ? null : TextAlign.center),
      actionsPadding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n.actionCancel),
              ),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: FilledButton(
                style: destructive ? FilledButton.styleFrom(backgroundColor: AppColors.error) : null,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

String? fieldErrorText(BuildContext context, FieldError? error) {
  if (error == null) return null;
  final l10n = context.l10n;
  return switch (error) {
    FieldError.required => l10n.validationRequired,
    FieldError.tooShort => l10n.validationTooShort,
    FieldError.tooLong => l10n.validationTooLong,
    FieldError.invalidPhone => l10n.validationPhone,
    FieldError.invalidUsername => l10n.validationUsername,
    FieldError.weakPassword => l10n.validationPassword,
    FieldError.mismatch => l10n.validationMismatch,
    FieldError.invalidNumber => l10n.validationNumber,
  };
}
