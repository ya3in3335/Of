import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/customer.dart';

/// Snapshot of the directory kept on the device so search works instantly and
/// offline. It is tied to one user and wiped on logout or deactivation.
class DirectorySnapshot {
  const DirectorySnapshot({
    required this.userId,
    required this.customers,
    this.customersCursor,
    this.deletionsCursor,
    this.lastSyncedAt,
  });

  static const schemaVersion = 2;

  final String userId;
  final List<Customer> customers;

  /// Highest server `updated_at` seen; delta sync resumes from here.
  final DateTime? customersCursor;
  final DateTime? deletionsCursor;

  /// Device time of the last successful sync (shown to the user).
  final DateTime? lastSyncedAt;

  Map<String, dynamic> toJson() => {
    'schema': schemaVersion,
    'user_id': userId,
    'customers_cursor': customersCursor?.toUtc().toIso8601String(),
    'deletions_cursor': deletionsCursor?.toUtc().toIso8601String(),
    'last_synced_at': lastSyncedAt?.toUtc().toIso8601String(),
    'customers': customers.map((c) => c.toJson()).toList(),
  };

  static DirectorySnapshot? fromJson(Map<String, dynamic> json) {
    if (json['schema'] != schemaVersion) return null;
    DateTime? d(String k) => json[k] == null ? null : DateTime.parse(json[k] as String);
    return DirectorySnapshot(
      userId: json['user_id'] as String,
      customersCursor: d('customers_cursor'),
      deletionsCursor: d('deletions_cursor'),
      lastSyncedAt: d('last_synced_at'),
      customers: (json['customers'] as List)
          .map((e) => Customer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

/// Stores the snapshot as a JSON file in the app's private documents
/// directory (not readable by other apps).
class LocalCacheService {
  LocalCacheService({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directoryProvider;

  Future<File> _file() async {
    final dir = await _directoryProvider();
    return File('${dir.path}/directory_cache.json');
  }

  Future<DirectorySnapshot?> load(String userId) async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final snapshot = DirectorySnapshot.fromJson(json);
      if (snapshot == null || snapshot.userId != userId) {
        await clear();
        return null;
      }
      return snapshot;
    } on Object {
      // A corrupt cache is discarded; the next sync downloads everything.
      await clear();
      return null;
    }
  }

  Future<void> save(DirectorySnapshot snapshot) async {
    final file = await _file();
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
    await tmp.rename(file.path);
  }

  Future<void> clear() async {
    final file = await _file();
    if (await file.exists()) await file.delete();
  }
}
