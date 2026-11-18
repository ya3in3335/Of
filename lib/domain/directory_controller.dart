import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;

import '../core/errors/app_exception.dart';
import '../core/providers.dart';
import '../data/models/customer.dart';
import '../data/services/local_cache.dart';
import '../features/auth/auth_controller.dart';
import 'customer_search.dart';
import 'directory_sync.dart';

enum SyncStatus { idle, syncing, offline, error }

class DirectoryState {
  DirectoryState({
    required this.userId,
    required Map<String, Customer> byId,
    required this.status,
    required this.loaded,
    this.lastSyncedAt,
    this.error,
  }) : byId = Map.unmodifiable(byId),
       customers = _sorted(byId.values),
       engine = CustomerSearchEngine(byId.values);

  DirectoryState.empty()
    : userId = null,
      byId = const {},
      customers = const [],
      engine = CustomerSearchEngine(const []),
      status = SyncStatus.idle,
      loaded = false,
      lastSyncedAt = null,
      error = null;

  final String? userId;
  final Map<String, Customer> byId;

  /// Sorted by last name, then first name.
  final List<Customer> customers;
  final CustomerSearchEngine engine;
  final SyncStatus status;

  /// True once data is available (from the device cache or a first sync).
  final bool loaded;
  final DateTime? lastSyncedAt;
  final AppException? error;

  static List<Customer> _sorted(Iterable<Customer> values) {
    final list = values.toList()
      ..sort((a, b) {
        final c = a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
        return c != 0 ? c : a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
      });
    return List.unmodifiable(list);
  }

  DirectoryState copyWith({
    Map<String, Customer>? byId,
    SyncStatus? status,
    bool? loaded,
    DateTime? lastSyncedAt,
    AppException? error,
    bool clearError = false,
  }) {
    if (byId == null) {
      return DirectoryState._keep(
        this,
        status: status ?? this.status,
        loaded: loaded ?? this.loaded,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        error: clearError ? null : (error ?? this.error),
      );
    }
    return DirectoryState(
      userId: userId,
      byId: byId,
      status: status ?? this.status,
      loaded: loaded ?? this.loaded,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // Status-only updates reuse the existing list and search index.
  DirectoryState._keep(
    DirectoryState o, {
    required this.status,
    required this.loaded,
    required this.lastSyncedAt,
    required this.error,
  }) : userId = o.userId,
       byId = o.byId,
       customers = o.customers,
       engine = o.engine;
}

/// Keeps the device copy of the directory in sync with Supabase:
/// cache on start, delta sync, realtime triggers, reconnect triggers.
class DirectoryController extends Notifier<DirectoryState> {
  RealtimeChannel? _channel;
  Timer? _debounce;
  bool _syncing = false;
  bool _pending = false;
  DateTime? _customersCursor;
  DateTime? _deletionsCursor;

  @override
  DirectoryState build() {
    final userId = ref.watch(authControllerProvider.select((s) => s.profile?.id));
    ref.onDispose(_teardown);
    _customersCursor = null;
    _deletionsCursor = null;
    if (userId == null) return DirectoryState.empty();

    ref.listen<AsyncValue<bool>>(connectivityProvider, (prev, next) {
      if (next.value == true && prev?.value == false) unawaited(sync());
      if (next.value == false && state.status == SyncStatus.syncing) {
        state = state.copyWith(status: SyncStatus.offline);
      }
    });

    Future.microtask(() => _start(userId));
    return DirectoryState(userId: userId, byId: const {}, status: SyncStatus.syncing, loaded: false);
  }

  void _teardown() {
    _debounce?.cancel();
    final channel = _channel;
    _channel = null;
    if (channel != null) unawaited(ref.read(customerRepositoryProvider).unsubscribe(channel));
  }

  Future<void> _start(String userId) async {
    final snapshot = await ref.read(localCacheProvider).load(userId);
    if (!ref.mounted || state.userId != userId) return;
    if (snapshot != null) {
      _customersCursor = snapshot.customersCursor;
      _deletionsCursor = snapshot.deletionsCursor;
      state = DirectoryState(
        userId: userId,
        byId: {for (final c in snapshot.customers) c.id: c},
        status: SyncStatus.syncing,
        loaded: true,
        lastSyncedAt: snapshot.lastSyncedAt,
      );
    }
    _channel = ref.read(customerRepositoryProvider).subscribe(_onRemoteChange);
    await sync();
  }

  void _onRemoteChange() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => unawaited(sync()));
  }

  /// Delta sync. Concurrent calls are coalesced into one follow-up run.
  Future<void> sync({bool full = false}) async {
    final userId = state.userId;
    if (userId == null) return;
    if (_syncing) {
      _pending = true;
      return;
    }
    _syncing = true;
    state = state.copyWith(status: SyncStatus.syncing, clearError: true);
    try {
      final repo = ref.read(customerRepositoryProvider);
      final fullRefresh = full || _customersCursor == null;
      final changed = await repo.fetchChangedSince(fullRefresh ? null : _customersCursor);
      final deletions = await repo.fetchDeletionsSince(fullRefresh ? null : _deletionsCursor);
      if (!ref.mounted || state.userId != userId) return;

      final result = DirectoryMerger.merge(
        current: state.byId,
        changed: changed,
        deletions: deletions,
        customersCursor: fullRefresh ? null : _customersCursor,
        deletionsCursor: fullRefresh ? null : _deletionsCursor,
        fullRefresh: fullRefresh,
      );
      _customersCursor = result.customersCursor;
      _deletionsCursor = result.deletionsCursor;
      final now = DateTime.now();
      state = state.copyWith(byId: result.customers, status: SyncStatus.idle, loaded: true, lastSyncedAt: now);
      if (result.changes.isNotEmpty) {
        unawaited(ref.read(notificationsProvider.notifier).add(result.changes));
      }
      await ref
          .read(localCacheProvider)
          .save(
            DirectorySnapshot(
              userId: userId,
              customers: result.customers.values.toList(),
              customersCursor: _customersCursor,
              deletionsCursor: _deletionsCursor,
              lastSyncedAt: now,
            ),
          );
    } catch (e) {
      if (!ref.mounted) return;
      final error = AppException.from(e);
      final offline = error.kind == AppErrorKind.offline || error.kind == AppErrorKind.timeout;
      state = state.copyWith(status: offline ? SyncStatus.offline : SyncStatus.error, error: error);
      if (error.kind == AppErrorKind.sessionExpired || error.kind == AppErrorKind.forbidden) {
        unawaited(ref.read(authControllerProvider.notifier).refreshProfile());
      }
    } finally {
      _syncing = false;
      if (_pending && ref.mounted) {
        _pending = false;
        unawaited(sync());
      }
    }
  }

  /// Applies a server-confirmed write immediately (the realtime echo and the
  /// next delta sync will bring the same row again; merging is idempotent).
  void applyServerRow(Customer customer) {
    if (state.userId == null) return;
    state = state.copyWith(byId: {...state.byId, customer.id: customer});
    unawaited(_persist());
  }

  void applyServerDeletion(String id) {
    if (!state.byId.containsKey(id)) return;
    state = state.copyWith(byId: Map.of(state.byId)..remove(id));
    unawaited(_persist());
  }

  Future<void> _persist() async {
    final userId = state.userId;
    if (userId == null) return;
    await ref
        .read(localCacheProvider)
        .save(
          DirectorySnapshot(
            userId: userId,
            customers: state.byId.values.toList(),
            customersCursor: _customersCursor,
            deletionsCursor: _deletionsCursor,
            lastSyncedAt: state.lastSyncedAt,
          ),
        );
  }
}

final directoryProvider = NotifierProvider<DirectoryController, DirectoryState>(DirectoryController.new);

final customerByIdProvider = Provider.family<Customer?, String>(
  (ref, id) => ref.watch(directoryProvider.select((s) => s.byId[id])),
);

// ---------------------------------------------------------------------------
// Notifications feed (changes received through sync), stored per user.
// ---------------------------------------------------------------------------

class NotificationsState {
  const NotificationsState({required this.items, required this.lastSeen});
  final List<DirectoryChange> items;
  final DateTime? lastSeen;

  int get unread => items.where((i) => lastSeen == null || i.at.isAfter(lastSeen!)).length;
}

class NotificationsController extends Notifier<NotificationsState> {
  static const _max = 100;
  String get _itemsKey => 'user.notifications';
  String get _seenKey => 'user.notifications_seen';

  @override
  NotificationsState build() {
    ref.watch(authControllerProvider.select((s) => s.profile?.id));
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_itemsKey);
    final seen = prefs.getString(_seenKey);
    List<DirectoryChange> items = const [];
    if (raw != null) {
      try {
        items = (jsonDecode(raw) as List)
            .map((e) => DirectoryChange.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {}
    }
    return NotificationsState(items: items, lastSeen: seen == null ? null : DateTime.tryParse(seen));
  }

  Future<void> add(List<DirectoryChange> changes) async {
    final merged = [...changes, ...state.items];
    final items = merged.length > _max ? merged.sublist(0, _max) : merged;
    state = NotificationsState(items: items, lastSeen: state.lastSeen);
    await ref.read(sharedPreferencesProvider).setString(_itemsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> markAllSeen() async {
    final now = DateTime.now();
    state = NotificationsState(items: state.items, lastSeen: now);
    await ref.read(sharedPreferencesProvider).setString(_seenKey, now.toUtc().toIso8601String());
  }

  Future<void> clear() async {
    state = NotificationsState(items: const [], lastSeen: DateTime.now());
    await ref.read(sharedPreferencesProvider).remove(_itemsKey);
  }
}

final notificationsProvider = NotifierProvider<NotificationsController, NotificationsState>(
  NotificationsController.new,
);

// ---------------------------------------------------------------------------
// Recently opened customers (employee home), stored per user.
// ---------------------------------------------------------------------------

class RecentCustomersController extends Notifier<List<String>> {
  static const _key = 'user.recent_customers';

  @override
  List<String> build() {
    ref.watch(authControllerProvider.select((s) => s.profile?.id));
    return ref.read(sharedPreferencesProvider).getStringList(_key) ?? const [];
  }

  Future<void> touch(String customerId) async {
    final next = [customerId, ...state.where((id) => id != customerId)].take(12).toList();
    state = next;
    await ref.read(sharedPreferencesProvider).setStringList(_key, next);
  }

  Future<void> clear() async {
    state = const [];
    await ref.read(sharedPreferencesProvider).remove(_key);
  }
}

final recentCustomersProvider = NotifierProvider<RecentCustomersController, List<String>>(
  RecentCustomersController.new,
);
