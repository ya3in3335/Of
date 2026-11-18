import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    runApp(const _NotConfiguredApp());
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );

  runApp(
    ProviderScope(
      // Errors are shown to the user with a retry button; no silent retries.
      retry: (retryCount, error) => null,
      overrides: [
        supabaseClientProvider.overrideWithValue(Supabase.instance.client),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const OutiforApp(),
    ),
  );
}

/// Shown when the APK was built without backend configuration, instead of
/// pretending to work.
class _NotConfiguredApp extends StatelessWidget {
  const _NotConfiguredApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(arabic: false),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings_suggest_rounded, size: 56, color: AppColors.navy),
                const SizedBox(height: 20),
                Text('OUTIFOR', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  'This build has no server configuration.\n'
                  'Cette version n’est pas configurée.\n'
                  'هذا الإصدار غير مهيأ للاتصال بالخادم.\n\n'
                  'Build with: flutter build apk --dart-define-from-file=env/prod.json',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
