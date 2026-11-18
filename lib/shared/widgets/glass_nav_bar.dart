import 'dart:ui' show ImageFilter;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';

class GlassNavItem {
  const GlassNavItem({required this.icon, required this.selectedIcon, required this.label});
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Floating frosted-glass bottom navigation.
///
/// The bar has rounded corners ([radius]); the selection bubble sits inside
/// it with an inset of [inset] and a radius of `radius - inset`, so the
/// bubble's corners are concentric with the bar's corners. The bubble slides
/// between tabs. Works left-to-right and right-to-left.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({super.key, required this.items, required this.currentIndex, required this.onTap, this.top});

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Optional content floating just above the bar (e.g. the offline notice).
  final Widget? top;

  static const height = 68.0;
  static const radius = 28.0;
  static const inset = 6.0;
  static const _duration = Duration(milliseconds: 320);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomSafe > 0 ? bottomSafe : 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?top,
          DecoratedBox(
            // Soft shadow outside the glass, so the bar floats above content.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(color: Color(0x24123B70), blurRadius: 30, offset: Offset(0, 12)),
                BoxShadow(color: Color(0x0F123B70), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xC7FFFFFF), Color(0xB3F4F8FD)],
                    ),
                    border: Border.all(color: const Color(0x99FFFFFF), width: 1.2),
                  ),
                  padding: const EdgeInsets.all(inset),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = constraints.maxWidth / items.length;
                      return Stack(
                        children: [
                          // Selection bubble, concentric with the bar's corners.
                          AnimatedPositionedDirectional(
                            duration: _duration,
                            curve: _curve,
                            start: itemWidth * currentIndex,
                            top: 0,
                            bottom: 0,
                            width: itemWidth,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.navy.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(radius - inset),
                                border: Border.all(color: AppColors.navy.withValues(alpha: 0.06)),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              for (var i = 0; i < items.length; i++)
                                Expanded(
                                  child: _Item(
                                    item: items[i],
                                    selected: i == currentIndex,
                                    textStyle: text.labelSmall,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      onTap(i);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.selected, required this.onTap, required this.textStyle});
  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GlassNavBar.radius - GlassNavBar.inset),
        splashColor: Colors.transparent,
        highlightColor: AppColors.navy.withValues(alpha: 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: GlassNavBar._duration,
              curve: GlassNavBar._curve,
              child: Icon(selected ? item.selectedIcon : item.icon, color: color, size: 24),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle?.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom space a scrolling tab screen needs so its last item can scroll
/// clear of the floating bar (and of a floating action button, if any).
/// Inside a shell with `extendBody: true`, MediaQuery.padding.bottom already
/// includes the bar's height.
double navBarClearance(BuildContext context, {bool fab = false}) =>
    MediaQuery.paddingOf(context).bottom + (fab ? 88 : 24);

/// Spacer form of [navBarClearance], for use at the end of a Column.
class NavBarSpacer extends StatelessWidget {
  const NavBarSpacer({super.key, this.fab = false});
  final bool fab;

  @override
  Widget build(BuildContext context) => SizedBox(height: navBarClearance(context, fab: fab));
}
