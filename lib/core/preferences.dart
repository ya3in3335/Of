import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/models/activity.dart';
import '../data/models/profile.dart';
import 'providers.dart';

/// Device-level preferences (language, onboarding) plus small per-user
/// conveniences. Nothing here is required for correctness.
class AppPreferences {
  const AppPreferences({required this.localeCode, required this.onboardingDone});

  /// 'ar', 'fr', 'en', or null to follow the phone.
  final String? localeCode;
  final bool onboardingDone;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);
}

class PreferencesController extends Notifier<AppPreferences> {
  static const _kLocale = 'pref.locale';
  static const _kOnboarding = 'pref.onboarding_done';

  @override
  AppPreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppPreferences(
      localeCode: prefs.getString(_kLocale),
      onboardingDone: prefs.getBool(_kOnboarding) ?? false,
    );
  }

  Future<void> setLocale(String? code) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (code == null) {
      await prefs.remove(_kLocale);
    } else {
      await prefs.setString(_kLocale, code);
    }
    state = AppPreferences(localeCode: code, onboardingDone: state.onboardingDone);
  }

  Future<void> completeOnboarding() async {
    await ref.read(sharedPreferencesProvider).setBool(_kOnboarding, true);
    state = AppPreferences(localeCode: state.localeCode, onboardingDone: true);
  }
}

final preferencesProvider = NotifierProvider<PreferencesController, AppPreferences>(PreferencesController.new);

/// Profile and settings remembered for offline start-up.
class SessionMemory {
  SessionMemory(this._ref);
  final Ref _ref;

  static const _kProfile = 'session.profile';
  static const _kSettings = 'session.settings';

  Profile? loadProfile(String userId) {
    final raw = _ref.read(sharedPreferencesProvider).getString(_kProfile);
    if (raw == null) return null;
    try {
      final p = Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return p.id == userId ? p : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(Profile p) => _ref.read(sharedPreferencesProvider).setString(
        _kProfile,
        jsonEncode({
          'id': p.id,
          'full_name': p.fullName,
          'username': p.username,
          'role': p.role.name,
          'is_active': p.isActive,
          'phone': p.phone,
          'created_at': p.createdAt.toIso8601String(),
          'last_login_at': p.lastLoginAt?.toIso8601String(),
        }),
      );

  AppSettings? loadSettings() {
    final raw = _ref.read(sharedPreferencesProvider).getString(_kSettings);
    if (raw == null) return null;
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSettings(AppSettings s) =>
      _ref.read(sharedPreferencesProvider).setString(_kSettings, jsonEncode(s.toJson()));

  /// Removes everything tied to the signed-in user.
  Future<void> clearUserData() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith('session.') || key.startsWith('user.')) await prefs.remove(key);
    }
  }
}

final sessionMemoryProvider = Provider((ref) => SessionMemory(ref));
