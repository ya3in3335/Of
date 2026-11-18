import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/config/app_config.dart';
import 'core/l10n_ext.dart';
import 'core/preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/directory_controller.dart';
import 'features/auth/auth_controller.dart';

class OutiforApp extends ConsumerStatefulWidget {
  const OutiforApp({super.key});

  @override
  ConsumerState<OutiforApp> createState() => _OutiforAppState();
}

class _OutiforAppState extends ConsumerState<OutiforApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Coming back to the app re-checks the account (deactivation) and pulls
  /// the latest directory changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && ref.read(authControllerProvider).phase == AuthPhase.signedIn) {
      ref.read(authControllerProvider.notifier).refreshProfile();
      ref.read(directoryProvider.notifier).sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(preferencesProvider.select((p) => p.locale));
    // Keep the directory controller alive for the whole session.
    ref.watch(directoryProvider.select((s) => s.userId));

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (device, supported) {
        if (device == null) return const Locale('fr');
        return supported.firstWhere((l) => l.languageCode == device.languageCode, orElse: () => const Locale('fr'));
      },
      builder: (context, child) {
        final arabic = Localizations.localeOf(context).languageCode == 'ar';
        return Theme(
          data: AppTheme.light(arabic: arabic),
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: AppConfig.demoMode
                ? Banner(
                    message: context.l10n.demoRibbon,
                    location: BannerLocation.topEnd,
                    color: const Color(0xFFED1A2D),
                    child: child!,
                  )
                : child!,
          ),
        );
      },
      theme: AppTheme.light(arabic: false),
    );
  }
}
