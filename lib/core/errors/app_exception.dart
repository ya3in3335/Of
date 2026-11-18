import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Error categories the UI knows how to explain in the user's language.
enum AppErrorKind {
  offline,
  timeout,
  invalidCredentials,
  accountDisabled,
  sessionExpired,
  forbidden,
  notFound,
  conflict,
  usernameTaken,
  weakPassword,
  validation,
  notConfigured,
  server,
  unknown,
}

class AppException implements Exception {
  const AppException(this.kind, [this.detail]);

  final AppErrorKind kind;

  /// Technical detail (server message); shown only as secondary text.
  final String? detail;

  @override
  String toString() => 'AppException($kind${detail == null ? '' : ': $detail'})';

  static AppException from(Object error) {
    if (error is AppException) return error;
    if (error is SocketException || error is HttpException) return const AppException(AppErrorKind.offline);
    if (error is TimeoutException) return const AppException(AppErrorKind.timeout);
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (error is AuthRetryableFetchException || msg.contains('socket') || msg.contains('failed host lookup')) {
        return const AppException(AppErrorKind.offline);
      }
      if (msg.contains('invalid login') || msg.contains('invalid credentials') || error.code == 'invalid_credentials') {
        return const AppException(AppErrorKind.invalidCredentials);
      }
      if (msg.contains('banned') || error.code == 'user_banned') return const AppException(AppErrorKind.accountDisabled);
      if (msg.contains('jwt') || msg.contains('refresh token') || msg.contains('session')) {
        return AppException(AppErrorKind.sessionExpired, error.message);
      }
      if (msg.contains('password')) return AppException(AppErrorKind.weakPassword, error.message);
      return AppException(AppErrorKind.unknown, error.message);
    }
    if (error is PostgrestException) {
      switch (error.code) {
        case '42501':
          return AppException(AppErrorKind.forbidden, error.message);
        case 'PGRST301':
        case 'PGRST303':
          return AppException(AppErrorKind.sessionExpired, error.message);
        case 'P0002':
        case 'PGRST116':
          return AppException(AppErrorKind.notFound, error.message);
        case '40001':
          return AppException(AppErrorKind.conflict, error.message);
        case '23505':
          return AppException(AppErrorKind.conflict, error.message);
        case '23514':
        case '23502':
        case '22023':
        case '22P02':
          return AppException(AppErrorKind.validation, error.message);
      }
      return AppException(AppErrorKind.server, error.message);
    }
    if (error is FunctionException) {
      final details = error.details;
      final code = details is Map ? details['error'] as String? : null;
      final message = details is Map ? details['message'] as String? : null;
      switch (code) {
        case 'username_taken':
          return AppException(AppErrorKind.usernameTaken, message);
        case 'weak_password':
          return AppException(AppErrorKind.weakPassword, message);
        case 'forbidden':
          return AppException(AppErrorKind.forbidden, message);
        case 'unauthenticated':
          return AppException(AppErrorKind.sessionExpired, message);
        case 'not_found':
          return AppException(AppErrorKind.notFound, message);
        case 'invalid_input':
        case 'invalid_username':
        case 'invalid_name':
        case 'self_change':
          return AppException(AppErrorKind.validation, message);
      }
      if (error.status == 404) return const AppException(AppErrorKind.notConfigured, 'admin-users function not deployed');
      return AppException(AppErrorKind.server, message ?? 'HTTP ${error.status}');
    }
    if (error is RealtimeSubscribeException) return AppException(AppErrorKind.server, error.toString());
    final text = error.toString();
    if (text.contains('SocketException') || text.contains('Failed host lookup') || text.contains('ClientException')) {
      return const AppException(AppErrorKind.offline);
    }
    return AppException(AppErrorKind.unknown, text);
  }
}
