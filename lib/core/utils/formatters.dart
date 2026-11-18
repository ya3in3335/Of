import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../errors/app_exception.dart';
import '../l10n_ext.dart';

abstract final class Formatters {
  /// 0555123456 -> 0555 12 34 56 ; 021543210 -> 021 54 32 10
  static String phone(String? digits) {
    if (digits == null || digits.isEmpty) return '';
    if (digits.length == 10) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 6)} ${digits.substring(6, 8)} ${digits.substring(8)}';
    }
    if (digits.length == 9) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 7)} ${digits.substring(7)}';
    }
    return digits;
  }

  static String date(BuildContext context, DateTime value) =>
      DateFormat.yMMMd(context.languageCode).format(value.toLocal());

  static String dateTime(BuildContext context, DateTime value) =>
      DateFormat.yMMMd(context.languageCode).add_Hm().format(value.toLocal());

  static String time(BuildContext context, DateTime value) => DateFormat.Hm(context.languageCode).format(value.toLocal());

  /// "just now", "5 min ago", "yesterday", or a date.
  static String relative(BuildContext context, DateTime value, {DateTime? now}) {
    final l10n = context.l10n;
    final diff = (now ?? DateTime.now()).difference(value.toLocal());
    if (diff.inSeconds < 60) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.timeYesterday;
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
    return date(context, value);
  }

  static String coordinates(double lat, double lng) => '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

  static String distance(BuildContext context, double meters) {
    if (meters < 1000) return context.l10n.distanceMeters(meters.round());
    return context.l10n.distanceKm((meters / 1000).toStringAsFixed(meters < 10000 ? 1 : 0));
  }
}

/// User-facing message for an error, in the current language.
String errorMessage(BuildContext context, Object error) {
  final l10n = context.l10n;
  final e = AppException.from(error);
  switch (e.kind) {
    case AppErrorKind.offline:
      return l10n.errorOffline;
    case AppErrorKind.timeout:
      return l10n.errorTimeout;
    case AppErrorKind.invalidCredentials:
      return l10n.errorInvalidCredentials;
    case AppErrorKind.accountDisabled:
      return l10n.errorAccountDisabled;
    case AppErrorKind.sessionExpired:
      return l10n.errorSessionExpired;
    case AppErrorKind.forbidden:
      return l10n.errorForbidden;
    case AppErrorKind.notFound:
      return l10n.errorNotFound;
    case AppErrorKind.conflict:
      return l10n.errorConflict;
    case AppErrorKind.usernameTaken:
      return l10n.errorUsernameTaken;
    case AppErrorKind.weakPassword:
      return l10n.errorWeakPassword;
    case AppErrorKind.validation:
      return l10n.errorValidation;
    case AppErrorKind.notConfigured:
      return l10n.errorNotConfigured;
    case AppErrorKind.server:
    case AppErrorKind.unknown:
      return l10n.errorGeneric;
  }
}
