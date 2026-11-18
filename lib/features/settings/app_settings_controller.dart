import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/preferences.dart';
import '../../core/providers.dart';
import '../../data/models/activity.dart';
import '../auth/auth_controller.dart';

/// Company-wide settings (company name, default map centre). Loaded from the
/// server, remembered on the device for offline start.
class AppSettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final signedIn = ref.watch(authControllerProvider.select((s) => s.profile != null));
    final memory = ref.read(sessionMemoryProvider);
    final cached = memory.loadSettings() ?? AppSettings.fallback;
    if (!signedIn) return cached;
    try {
      final fresh = await ref.read(settingsRepositoryProvider).fetch();
      await memory.saveSettings(fresh);
      return fresh;
    } catch (_) {
      return cached;
    }
  }

  Future<void> save(AppSettings settings) async {
    final saved = await ref.read(settingsRepositoryProvider).update(settings);
    await ref.read(sessionMemoryProvider).saveSettings(saved);
    state = AsyncData(saved);
  }
}

final appSettingsProvider = AsyncNotifierProvider<AppSettingsController, AppSettings>(AppSettingsController.new);
