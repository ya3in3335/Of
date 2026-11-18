import '../data/models/customer.dart';
import '../data/repositories/customer_repository.dart';

enum ChangeKind { created, updated, locationUpdated, archived, restored, deleted }

/// One entry of the "Notifications" feed: a change made on another device
/// (or by the admin) that reached this device through sync.
class DirectoryChange {
  const DirectoryChange({
    required this.kind,
    required this.customerId,
    required this.name,
    required this.reference,
    required this.at,
  });

  final ChangeKind kind;
  final String customerId;
  final String name;
  final String reference;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'customer_id': customerId,
        'name': name,
        'reference': reference,
        'at': at.toUtc().toIso8601String(),
      };

  factory DirectoryChange.fromJson(Map<String, dynamic> json) => DirectoryChange(
        kind: ChangeKind.values.byName(json['kind'] as String),
        customerId: json['customer_id'] as String,
        name: json['name'] as String,
        reference: json['reference'] as String,
        at: DateTime.parse(json['at'] as String),
      );
}

class MergeResult {
  const MergeResult({
    required this.customers,
    required this.changes,
    required this.customersCursor,
    required this.deletionsCursor,
  });

  final Map<String, Customer> customers;
  final List<DirectoryChange> changes;
  final DateTime? customersCursor;
  final DateTime? deletionsCursor;
}

/// Pure merge logic for delta sync (unit-tested).
abstract final class DirectoryMerger {
  static MergeResult merge({
    required Map<String, Customer> current,
    required List<Customer> changed,
    required List<CustomerDeletion> deletions,
    required DateTime? customersCursor,
    required DateTime? deletionsCursor,
    required bool fullRefresh,
  }) {
    final next = fullRefresh ? <String, Customer>{} : Map<String, Customer>.of(current);
    final changes = <DirectoryChange>[];
    // The first download is not "news"; later syncs are.
    final reportChanges = current.isNotEmpty;
    var cursor = customersCursor;

    for (final c in changed) {
      final previous = current[c.id];
      next[c.id] = c;
      if (cursor == null || c.updatedAt.isAfter(cursor)) cursor = c.updatedAt;
      if (!reportChanges) continue;
      final kind = _diff(previous, c);
      if (kind != null) {
        changes.add(DirectoryChange(
          kind: kind,
          customerId: c.id,
          name: c.fullName,
          reference: c.reference,
          at: c.updatedAt,
        ));
      }
    }

    var delCursor = deletionsCursor;
    for (final d in deletions) {
      if (delCursor == null || d.deletedAt.isAfter(delCursor)) delCursor = d.deletedAt;
      final existing = next[d.customerId];
      // A row updated after its tombstone (restored from backup) stays.
      if (existing != null && !existing.updatedAt.isAfter(d.deletedAt)) {
        next.remove(d.customerId);
        if (reportChanges && current.containsKey(d.customerId)) {
          changes.add(DirectoryChange(
            kind: ChangeKind.deleted,
            customerId: d.customerId,
            name: existing.fullName,
            reference: d.reference,
            at: d.deletedAt,
          ));
        }
      }
    }

    changes.sort((a, b) => b.at.compareTo(a.at));
    return MergeResult(customers: next, changes: changes, customersCursor: cursor, deletionsCursor: delCursor);
  }

  static ChangeKind? _diff(Customer? before, Customer after) {
    if (before == null) return ChangeKind.created;
    if (!after.updatedAt.isAfter(before.updatedAt)) return null; // overlap re-read
    if (before.status != after.status) {
      return after.isArchived ? ChangeKind.archived : ChangeKind.restored;
    }
    final infoChanged = before.firstName != after.firstName ||
        before.lastName != after.lastName ||
        before.businessName != after.businessName ||
        before.primaryPhone != after.primaryPhone ||
        before.secondaryPhone != after.secondaryPhone ||
        before.whatsappPhone != after.whatsappPhone ||
        before.address != after.address ||
        before.commune != after.commune ||
        before.wilaya != after.wilaya ||
        before.addresses.length != after.addresses.length;
    final locationChanged = before.latitude != after.latitude || before.longitude != after.longitude;
    if (locationChanged && !infoChanged) return ChangeKind.locationUpdated;
    return ChangeKind.updated;
  }
}
