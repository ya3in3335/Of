import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../models/profile.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Session? get currentSession => _auth.currentSession;
  User? get currentUser => _auth.currentUser;
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Staff log in with a username; the matching Auth email is
  /// `username@LOGIN_DOMAIN`. A full email is accepted too (bootstrap admin).
  static String emailFor(String identifier) {
    final id = identifier.trim().toLowerCase();
    return id.contains('@') ? id : '$id@${AppConfig.loginDomain}';
  }

  Future<void> signIn({required String identifier, required String password}) async {
    try {
      await _auth.signInWithPassword(email: emailFor(identifier), password: password);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      // Local sign-out always clears the stored session, even offline.
    }
  }

  /// The caller's profile if it is active; null means the account was
  /// deactivated (or never provisioned) and the app must sign out.
  Future<Profile?> fetchActiveProfile() async {
    try {
      final rows = await _client.rpc('current_profile') as List;
      if (rows.isEmpty) return null;
      return Profile.fromJson(Map<String, dynamic>.from(rows.first as Map));
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Verifies the current password before setting a new one.
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    final email = currentUser?.email;
    if (email == null) throw const AppException(AppErrorKind.sessionExpired);
    try {
      await _auth.signInWithPassword(email: email, password: currentPassword);
    } catch (e) {
      final err = AppException.from(e);
      throw err.kind == AppErrorKind.invalidCredentials ? const AppException(AppErrorKind.invalidCredentials) : err;
    }
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> updateOwnProfile({required String fullName, String? phone}) async {
    try {
      await _client.rpc('update_own_profile', params: {'p_full_name': fullName, 'p_phone': phone});
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
