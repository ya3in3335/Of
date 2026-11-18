import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:supabase_flutter/supabase_flutter.dart' as sb show AuthState;

import '../../core/errors/app_exception.dart';
import '../../core/preferences.dart';
import '../../core/providers.dart';
import '../../data/models/profile.dart';

enum AuthPhase { initializing, signedOut, signedIn }

class AuthState {
  const AuthState._(this.phase, {this.profile, this.signOutReason, this.verified = true});

  const AuthState.initializing() : this._(AuthPhase.initializing);
  const AuthState.signedOut([AppErrorKind? reason]) : this._(AuthPhase.signedOut, signOutReason: reason);
  const AuthState.signedIn(Profile profile, {bool verified = true})
    : this._(AuthPhase.signedIn, profile: profile, verified: verified);

  final AuthPhase phase;
  final Profile? profile;

  /// Why the user was signed out without asking (session expired, account disabled).
  final AppErrorKind? signOutReason;

  /// False when the profile comes from the device (started offline); it is
  /// re-checked with the server as soon as the network is back.
  final bool verified;

  bool get isAdmin => profile?.isAdmin ?? false;
}

class AuthController extends Notifier<AuthState> {
  StreamSubscription<sb.AuthState>? _authSub;
  RealtimeChannel? _profileChannel;
  bool _userInitiatedSignOut = false;
  bool _checking = false;

  @override
  AuthState build() {
    final repo = ref.watch(authRepositoryProvider);
    _authSub = repo.authStateChanges.listen(_onAuthEvent, onError: (_) {});
    ref.onDispose(() {
      _authSub?.cancel();
      _removeProfileChannel();
    });

    // Re-verify an offline start as soon as the network returns.
    ref.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
      if (next.value == true && state.phase == AuthPhase.signedIn && !state.verified) {
        unawaited(refreshProfile());
      }
    });

    final session = repo.currentSession;
    if (session == null) return const AuthState.signedOut();
    Future.microtask(() => _restore(session.user.id));
    return const AuthState.initializing();
  }

  Future<void> _restore(String userId) async {
    try {
      final profile = await ref.read(authRepositoryProvider).fetchActiveProfile();
      if (profile == null) {
        await _forceSignOut(AppErrorKind.accountDisabled);
        return;
      }
      await _setSignedIn(profile);
    } on AppException catch (e) {
      if (e.kind == AppErrorKind.offline || e.kind == AppErrorKind.timeout) {
        // Offline start: use the profile remembered on this device.
        final cached = ref.read(sessionMemoryProvider).loadProfile(userId);
        if (cached != null) {
          state = AuthState.signedIn(cached, verified: false);
          return;
        }
      }
      await _forceSignOut(e.kind == AppErrorKind.offline ? null : AppErrorKind.sessionExpired);
    }
  }

  Future<void> _setSignedIn(Profile profile) async {
    await ref.read(sessionMemoryProvider).saveProfile(profile);
    state = AuthState.signedIn(profile);
    _watchOwnProfile(profile.id);
  }

  /// Supabase pushes changes to the user's own profile row: a deactivation or
  /// role change takes effect on the device within seconds.
  void _watchOwnProfile(String userId) {
    _removeProfileChannel();
    final client = ref.read(supabaseClientProvider);
    _profileChannel = client
        .channel('own-profile-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: userId),
          callback: (_) => unawaited(refreshProfile()),
        )
        .subscribe();
  }

  void _removeProfileChannel() {
    final channel = _profileChannel;
    _profileChannel = null;
    if (channel != null) {
      unawaited(ref.read(supabaseClientProvider).removeChannel(channel).catchError((_) => 'error'));
    }
  }

  void _onAuthEvent(sb.AuthState event) {
    if (event.event == AuthChangeEvent.signedOut && state.phase == AuthPhase.signedIn && !_userInitiatedSignOut) {
      // Refresh token rejected (expired, revoked or account banned).
      unawaited(_forceSignOut(AppErrorKind.sessionExpired));
    }
  }

  Future<void> signIn({required String identifier, required String password}) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signIn(identifier: identifier, password: password);
    Profile? profile;
    try {
      profile = await repo.fetchActiveProfile();
    } on AppException {
      await repo.signOut();
      rethrow;
    }
    if (profile == null) {
      await repo.signOut();
      throw const AppException(AppErrorKind.accountDisabled);
    }
    await _setSignedIn(profile);
  }

  /// Called on resume and on realtime profile updates.
  Future<void> refreshProfile() async {
    if (state.phase != AuthPhase.signedIn || _checking) return;
    _checking = true;
    try {
      final profile = await ref.read(authRepositoryProvider).fetchActiveProfile();
      if (profile == null) {
        await _forceSignOut(AppErrorKind.accountDisabled);
      } else {
        await ref.read(sessionMemoryProvider).saveProfile(profile);
        state = AuthState.signedIn(profile);
        if (_profileChannel == null) _watchOwnProfile(profile.id);
      }
    } on AppException catch (e) {
      if (e.kind == AppErrorKind.sessionExpired || e.kind == AppErrorKind.forbidden) {
        await _forceSignOut(AppErrorKind.sessionExpired);
      }
      // Offline: keep working with the device copy.
    } finally {
      _checking = false;
    }
  }

  void updateLocalProfile(Profile profile) {
    if (state.phase == AuthPhase.signedIn) {
      state = AuthState.signedIn(profile, verified: state.verified);
      unawaited(ref.read(sessionMemoryProvider).saveProfile(profile));
    }
  }

  Future<void> signOut() async {
    _userInitiatedSignOut = true;
    try {
      await _wipeAndSignOut();
      state = const AuthState.signedOut();
    } finally {
      _userInitiatedSignOut = false;
    }
  }

  Future<void> _forceSignOut(AppErrorKind? reason) async {
    _userInitiatedSignOut = true;
    try {
      await _wipeAndSignOut();
      state = AuthState.signedOut(reason);
    } finally {
      _userInitiatedSignOut = false;
    }
  }

  Future<void> _wipeAndSignOut() async {
    _removeProfileChannel();
    await ref.read(authRepositoryProvider).signOut();
    await ref.read(localCacheProvider).clear();
    await ref.read(sessionMemoryProvider).clearUserData();
  }

  /// Acknowledge the sign-out message shown on the login screen.
  void clearSignOutReason() {
    if (state.phase == AuthPhase.signedOut && state.signOutReason != null) {
      state = const AuthState.signedOut();
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// The signed-in profile (null when signed out).
final currentProfileProvider = Provider<Profile?>((ref) => ref.watch(authControllerProvider).profile);
