import 'text_normalizer.dart';

/// Form validation. Each validator returns an error code (resolved to text by
/// the UI) or null. The database enforces the same rules with constraints.
enum FieldError { required, tooShort, tooLong, invalidPhone, invalidUsername, weakPassword, mismatch, invalidNumber }

abstract final class Validators {
  static FieldError? required(String? v, {int min = 1, int max = 200}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return FieldError.required;
    if (t.length < min) return FieldError.tooShort;
    if (t.length > max) return FieldError.tooLong;
    return null;
  }

  static FieldError? optional(String? v, {int max = 200}) {
    final t = v?.trim() ?? '';
    if (t.length > max) return FieldError.tooLong;
    return null;
  }

  /// Algerian numbers: mobile 05/06/07 + 8 digits, landline 0 + 8 digits;
  /// +213 / 00213 accepted. Other international numbers: 8 to 15 digits.
  static FieldError? phone(String? v, {bool isRequired = true}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return isRequired ? FieldError.required : null;
    if (!RegExp(r'^[+\d\s().\-٠-٩]+$').hasMatch(t)) return FieldError.invalidPhone;
    final d = TextNormalizer.normalizePhone(t);
    if (d == null) return FieldError.invalidPhone;
    if (d.startsWith('0') && !d.startsWith('00')) {
      final mobile = RegExp(r'^0[567]\d{8}$').hasMatch(d);
      final landline = RegExp(r'^0[1-49]\d{7}$').hasMatch(d);
      return (mobile || landline) ? null : FieldError.invalidPhone;
    }
    return (d.length >= 8 && d.length <= 15) ? null : FieldError.invalidPhone;
  }

  static FieldError? username(String? v) {
    final t = v?.trim().toLowerCase() ?? '';
    if (t.isEmpty) return FieldError.required;
    return RegExp(r'^[a-z0-9][a-z0-9._-]{2,31}$').hasMatch(t) ? null : FieldError.invalidUsername;
  }

  /// Same rule as the admin-users Edge Function: 8+ characters, letters and digits.
  static FieldError? password(String? v) {
    final t = v ?? '';
    if (t.isEmpty) return FieldError.required;
    if (t.length < 8 || t.length > 72) return FieldError.weakPassword;
    if (!RegExp('[A-Za-z]').hasMatch(t) || !RegExp('[0-9]').hasMatch(t)) return FieldError.weakPassword;
    return null;
  }

  static FieldError? coordinate(String? v, {required double min, required double max}) {
    final value = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (value == null || value < min || value > max) return FieldError.invalidNumber;
    return null;
  }

  /// Suggests a username from a full name: "Samir Benali" -> "samir.benali".
  static String suggestUsername(String fullName) {
    final n = TextNormalizer.normalize(fullName).replaceAll(RegExp('[^a-z0-9 ]'), '').trim();
    if (n.isEmpty) return '';
    final parts = n.split(' ');
    final base = parts.length == 1 ? parts.first : '${parts.first}.${parts.last}';
    return base.length > 32 ? base.substring(0, 32) : base;
  }
}
