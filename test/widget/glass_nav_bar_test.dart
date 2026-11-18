import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:outifor/core/theme/app_theme.dart';
import 'package:outifor/shared/widgets/glass_nav_bar.dart';

void main() {
  const items = [
    GlassNavItem(icon: Icons.space_dashboard_outlined, selectedIcon: Icons.space_dashboard_rounded, label: 'Home'),
    GlassNavItem(icon: Icons.people_alt_outlined, selectedIcon: Icons.people_alt_rounded, label: 'Customers'),
    GlassNavItem(icon: Icons.badge_outlined, selectedIcon: Icons.badge_rounded, label: 'Employees'),
    GlassNavItem(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: 'Map'),
    GlassNavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  for (final scale in [1.0, 1.3, 2.0]) {
    testWidgets('labels stay inside their bubble (narrow phone, text scale $scale)', (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(arabic: false),
          home: MediaQuery(
            data: MediaQueryData(size: const Size(320, 640), textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              extendBody: true,
              body: const SizedBox.expand(),
              bottomNavigationBar: GlassNavBar(items: items, currentIndex: 2, onTap: (_) {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bar = tester.getRect(find.byType(GlassNavBar));
      final itemWidth = (bar.width - 32 - 2 * GlassNavBar.inset) / items.length;
      for (final item in items) {
        final label = tester.getRect(find.text(item.label));
        expect(label.width, lessThanOrEqualTo(itemWidth - 10), reason: '${item.label} wider than its bubble');
        expect(find.text('${item.label}…'), findsNothing);
      }
      // Each label is centred within its own slot, so it never crosses into a neighbour.
      final employees = tester.getRect(find.text('Employees'));
      final customers = tester.getRect(find.text('Customers'));
      expect(employees.left, greaterThan(customers.right));
    });
  }
}
