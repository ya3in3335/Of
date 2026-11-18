import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/customer.dart';

class CustomerDeletion {
  const CustomerDeletion(this.customerId, this.reference, this.deletedAt);
  final String customerId;
  final String reference;
  final DateTime deletedAt;
}

/// Employee field actions recorded in the activity log.
enum CustomerAction {
  viewed('customer_viewed'),
  called('customer_called'),
  whatsapp('customer_whatsapp'),
  navigated('customer_navigated');

  const CustomerAction(this.code);
  final String code;
}

class CustomerRepository {
  CustomerRepository(this._client);

  final SupabaseClient _client;
  static const _pageSize = 1000;

  /// Late commits can carry an `updated_at` slightly older than rows already
  /// synced, so each delta re-reads a short window (rows are upserted by id).
  static const syncOverlap = Duration(seconds: 90);

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body().timeout(const Duration(seconds: 30));
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Customers created or changed since [since] (all customers when null).
  Future<List<Customer>> fetchChangedSince(DateTime? since) => _guard(() async {
        final result = <Customer>[];
        var from = 0;
        while (true) {
          var query = _client.from('customers').select(Customer.selectColumns);
          if (since != null) {
            query = query.gte('updated_at', since.subtract(syncOverlap).toUtc().toIso8601String());
          }
          final rows = await query.order('updated_at').order('id').range(from, from + _pageSize - 1);
          result.addAll(rows.map(Customer.fromJson));
          if (rows.length < _pageSize) break;
          from += _pageSize;
        }
        return result;
      });

  Future<List<CustomerDeletion>> fetchDeletionsSince(DateTime? since) => _guard(() async {
        var query = _client.from('customer_deletions').select('customer_id, reference, deleted_at');
        if (since != null) {
          query = query.gte('deleted_at', since.subtract(syncOverlap).toUtc().toIso8601String());
        }
        final rows = await query.order('deleted_at').limit(10000);
        return rows
            .map((r) => CustomerDeletion(
                  r['customer_id'] as String,
                  r['reference'] as String,
                  DateTime.parse(r['deleted_at'] as String),
                ))
            .toList();
      });

  Future<Customer?> fetchOne(String id) => _guard(() async {
        final row = await _client.from('customers').select(Customer.selectColumns).eq('id', id).maybeSingle();
        return row == null ? null : Customer.fromJson(row);
      });

  /// Creates ([id] null) or updates a customer atomically, together with its
  /// extra addresses and admin notes. [expectedUpdatedAt] protects against
  /// overwriting another admin's newer change.
  Future<Customer> save({String? id, required CustomerDraft draft, DateTime? expectedUpdatedAt}) =>
      _guard(() async {
        final json = await _client.rpc('save_customer', params: {
          'p_id': id,
          'p_data': draft.toPayload(),
          'p_addresses': draft.addresses.map((a) => a.toJson()).toList(),
          'p_notes': draft.adminNotes ?? '',
          'p_expected_updated_at': expectedUpdatedAt?.toUtc().toIso8601String(),
        });
        return Customer.fromJson(Map<String, dynamic>.from(json as Map));
      });

  Future<Customer> setStatus(String id, CustomerStatus status) => _guard(() async {
        final row = await _client
            .from('customers')
            .update({'status': status.name})
            .eq('id', id)
            .select(Customer.selectColumns)
            .maybeSingle();
        if (row == null) throw const AppException(AppErrorKind.notFound);
        return Customer.fromJson(row);
      });

  Future<void> delete(String id) => _guard(() async {
        final rows = await _client.from('customers').delete().eq('id', id).select('id');
        if (rows.isEmpty) throw const AppException(AppErrorKind.notFound);
      });

  Future<String?> fetchAdminNotes(String customerId) => _guard(() async {
        final row = await _client
            .from('customer_admin_notes')
            .select('notes')
            .eq('customer_id', customerId)
            .maybeSingle();
        final notes = row?['notes'] as String?;
        return (notes == null || notes.trim().isEmpty) ? null : notes;
      });

  Future<List<DuplicateCandidate>> findDuplicates(CustomerDraft draft, {String? excludeId}) => _guard(() async {
        final rows = await _client.rpc('find_customer_duplicates', params: {
          'p_first_name': draft.firstName,
          'p_last_name': draft.lastName,
          'p_phones': draft.phones,
          'p_exclude_id': excludeId,
        }) as List;
        return rows.map((r) => DuplicateCandidate.fromJson(Map<String, dynamic>.from(r as Map))).toList();
      });

  Future<List<DuplicatePair>> listDuplicatePairs() => _guard(() async {
        final rows = await _client.rpc('list_potential_duplicates', params: {'p_limit': 200}) as List;
        return rows.map((r) => DuplicatePair.fromJson(Map<String, dynamic>.from(r as Map))).toList();
      });

  Future<void> dismissDuplicatePair(String a, String b) =>
      _guard(() => _client.rpc('dismiss_duplicate_pair', params: {'p_a': a, 'p_b': b}));

  /// Best effort: a failed log (e.g. offline) never blocks the field action.
  Future<void> logAction(CustomerAction action, String customerId) async {
    try {
      await _client
          .rpc('log_customer_action', params: {'p_action': action.code, 'p_customer_id': customerId})
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  /// Notifies [onChange] whenever another device changes the directory.
  RealtimeChannel subscribe(void Function() onChange) {
    final channel = _client.channel('directory-changes');
    for (final table in ['customers', 'customer_addresses', 'customer_deletions']) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (_) => onChange(),
      );
    }
    channel.subscribe();
    return channel;
  }

  Future<void> unsubscribe(RealtimeChannel channel) async {
    try {
      await _client.removeChannel(channel);
    } catch (_) {}
  }
}
