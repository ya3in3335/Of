import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/activity.dart';
import '../models/profile.dart';

Future<T> _guard<T>(Future<T> Function() body) async {
  try {
    return await body().timeout(const Duration(seconds: 30));
  } catch (e) {
    throw AppException.from(e);
  }
}

/// Staff accounts. Reads go through RLS (admins see every profile);
/// account changes go through the `admin-users` Edge Function, which holds
/// the service-role key server-side.
class EmployeeRepository {
  EmployeeRepository(this._client);

  final SupabaseClient _client;
  static const _columns = 'id, full_name, username, role, is_active, phone, created_at, last_login_at';

  Future<List<Profile>> list() => _guard(() async {
        final rows = await _client.from('profiles').select(_columns).order('full_name');
        return rows.map(Profile.fromJson).toList();
      });

  Future<Profile> get(String id) => _guard(() async {
        final row = await _client.from('profiles').select(_columns).eq('id', id).maybeSingle();
        if (row == null) throw const AppException(AppErrorKind.notFound);
        return Profile.fromJson(row);
      });

  Future<Profile> _invoke(Map<String, dynamic> body) => _guard(() async {
        final response = await _client.functions.invoke('admin-users', body: body);
        final data = response.data;
        if (data is! Map || data['profile'] == null) throw const AppException(AppErrorKind.server);
        return Profile.fromJson(Map<String, dynamic>.from(data['profile'] as Map));
      });

  Future<Profile> create({
    required String fullName,
    required String username,
    required String password,
    required UserRole role,
  }) =>
      _invoke({
        'action': 'create',
        'full_name': fullName,
        'username': username,
        'password': password,
        'role': role.name,
      });

  Future<Profile> setActive(String id, bool active) =>
      _invoke({'action': 'set_active', 'user_id': id, 'active': active});

  Future<Profile> resetPassword(String id, String password) =>
      _invoke({'action': 'reset_password', 'user_id': id, 'password': password});

  Future<Profile> update(String id, {required String fullName, required UserRole role}) =>
      _invoke({'action': 'update', 'user_id': id, 'full_name': fullName, 'role': role.name});
}

class ActivityRepository {
  ActivityRepository(this._client);

  final SupabaseClient _client;

  Future<List<ActivityLog>> recent({int limit = 50, int offset = 0, String? actorId, List<String>? actions}) =>
      _guard(() async {
        var query = _client.from('activity_logs').select(ActivityLog.selectColumns);
        if (actorId != null) query = query.eq('actor_id', actorId);
        if (actions != null && actions.isNotEmpty) query = query.inFilter('action', actions);
        final rows = await query.order('created_at', ascending: false).range(offset, offset + limit - 1);
        return rows.map(ActivityLog.fromJson).toList();
      });

  Future<DashboardStats> dashboardStats() => _guard(() async {
        final json = await _client.rpc('admin_dashboard_stats');
        return DashboardStats.fromJson(Map<String, dynamic>.from(json as Map));
      });
}

class SettingsRepository {
  SettingsRepository(this._client);

  final SupabaseClient _client;

  Future<AppSettings> fetch() => _guard(() async {
        final row = await _client
            .from('app_settings')
            .select('company_name, default_latitude, default_longitude, default_zoom')
            .eq('id', 1)
            .maybeSingle();
        return row == null ? AppSettings.fallback : AppSettings.fromJson(row);
      });

  Future<AppSettings> update(AppSettings settings) => _guard(() async {
        final row = await _client
            .from('app_settings')
            .update(settings.toJson())
            .eq('id', 1)
            .select('company_name, default_latitude, default_longitude, default_zoom')
            .maybeSingle();
        if (row == null) throw const AppException(AppErrorKind.forbidden);
        return AppSettings.fromJson(row);
      });
}
