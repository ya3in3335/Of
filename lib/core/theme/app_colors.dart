import 'package:material_ui/material_ui.dart';

/// OUTIFOR colour tokens. Navy/blue product palette, with the brand red from
/// the OutiFor logo kept for the logo itself and for destructive emphasis.
abstract final class AppColors {
  static const navy = Color(0xFF123B70);
  static const blue = Color(0xFF2478E5);
  static const cyan = Color(0xFF48B9F5);
  static const brandRed = Color(0xFFED1A2D);
  static const brandTeal = Color(0xFF1E5E7E);

  static const background = Color(0xFFF7F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0F4F9);
  static const border = Color(0xFFE3E9F1);
  static const divider = Color(0xFFEDF1F6);

  static const textPrimary = Color(0xFF0E2340);
  static const textSecondary = Color(0xFF5B6B80);
  static const textTertiary = Color(0xFF8E9BAD);

  static const success = Color(0xFF1E9E63);
  static const successSoft = Color(0xFFE6F6EE);
  static const warning = Color(0xFFD98A14);
  static const warningSoft = Color(0xFFFDF3E2);
  static const error = Color(0xFFD9474F);
  static const errorSoft = Color(0xFFFCECED);
  static const infoSoft = Color(0xFFE8F1FD);

  static const whatsapp = Color(0xFF1FAF5A);

  /// Avatar tints derived from a stable hash of the customer's name.
  static const avatarPalette = [
    Color(0xFF2478E5),
    Color(0xFF123B70),
    Color(0xFF0E8C9B),
    Color(0xFF6B5BD2),
    Color(0xFFC2681A),
    Color(0xFF1E9E63),
    Color(0xFFB8436A),
  ];
}
