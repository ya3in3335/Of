// Renders the splash animation frame by frame (25 fps) for review.
// Run:  flutter test tool/splash_frames --update-goldens
// Then: python3 tool/splash_frames/make_gif.py
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:outifor/core/l10n_ext.dart';
import 'package:outifor/core/theme/app_theme.dart';
import 'package:outifor/features/auth/splash_screen.dart';

void main() {
  testWidgets('splash frames', (tester) async {
    for (final family in ['Inter', 'Cairo']) {
      final loader = FontLoader(family);
      for (final w in [400, 500, 600, 700]) {
        loader.addFont(Future.value(ByteData.view(File('assets/fonts/$family-$w.ttf').readAsBytesSync().buffer)));
      }
      await loader.load();
    }
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: AppTheme.light(arabic: false),
          home: const SplashScreen(),
        ),
      ),
    );
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(SplashScreen));
      for (final l in ['lines', 'hammer', 'wordmark', 'subtitle']) {
        await precacheImage(AssetImage('assets/brand/splash/$l.png'), ctx);
      }
    });
    await tester.pump();
    for (var i = 0; i <= 62; i++) {
      await expectLater(find.byType(SplashScreen), matchesGoldenFile('out/f${i.toString().padLeft(3, '0')}.png'));
      await tester.pump(const Duration(milliseconds: 40));
    }
  });
}
