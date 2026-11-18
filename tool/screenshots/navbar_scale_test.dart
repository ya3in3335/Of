// Renders the glass bar with English labels and large system text, for review.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:outifor/core/theme/app_theme.dart';
import 'package:outifor/shared/widgets/glass_nav_bar.dart';

void main() {
  testWidgets('glass bar large text', (tester) async {
    for (final family in ['Inter', 'Cairo']) {
      final loader = FontLoader(family);
      for (final w in [400, 500, 600, 700]) {
        loader.addFont(Future.value(ByteData.view(File('assets/fonts/$family-$w.ttf').readAsBytesSync().buffer)));
      }
      await loader.load();
    }
    final icons = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.view(File(
              '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/sdk/flutter'}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
          .readAsBytesSync()
          .buffer)));
    await icons.load();
    tester.view.physicalSize = const Size(1080, 500);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(arabic: false),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: Scaffold(
            extendBody: true,
            body: const SizedBox.expand(),
            bottomNavigationBar: GlassNavBar(
              currentIndex: 2,
              onTap: (_) {},
              items: const [
                GlassNavItem(icon: Icons.space_dashboard_outlined, selectedIcon: Icons.space_dashboard_rounded, label: 'Home'),
                GlassNavItem(icon: Icons.people_alt_outlined, selectedIcon: Icons.people_alt_rounded, label: 'Customers'),
                GlassNavItem(icon: Icons.badge_outlined, selectedIcon: Icons.badge_rounded, label: 'Employees'),
                GlassNavItem(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: 'Map'),
                GlassNavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/15_glass_bar_large_text.png'));
  });
}
