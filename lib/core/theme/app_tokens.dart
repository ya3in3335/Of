import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Spacing, radius, elevation and motion tokens. Every screen uses these
/// instead of literal values, so the interface stays consistent.
abstract final class Space {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Horizontal page gutter.
  static const page = 20.0;
}

abstract final class Radii {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const pill = 999.0;

  static const card = BorderRadius.all(Radius.circular(lg));
  static const field = BorderRadius.all(Radius.circular(md));
  static const chip = BorderRadius.all(Radius.circular(pill));
}

abstract final class Shadows {
  static const card = [
    BoxShadow(color: Color(0x0F123B70), blurRadius: 18, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x08123B70), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const floating = [
    BoxShadow(color: Color(0x26123B70), blurRadius: 24, offset: Offset(0, 10)),
  ];
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 380);
  static const curve = Curves.easeOutCubic;
}

abstract final class AppDecorations {
  static BoxDecoration card({Color color = AppColors.surface, bool border = false}) => BoxDecoration(
        color: color,
        borderRadius: Radii.card,
        boxShadow: Shadows.card,
        border: border ? Border.all(color: AppColors.border) : null,
      );
}
