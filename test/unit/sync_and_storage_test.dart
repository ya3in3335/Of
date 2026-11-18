import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:outifor/data/models/customer.dart';
import 'package:outifor/data/repositories/customer_repository.dart';
import 'package:outifor/data/services/local_cache.dart';
import 'package:outifor/domain/directory_sync.dart';

import '../helpers.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 1, 10);
  final t1 = t0.add(const Duration(minutes: 5));
  final t2 = t0.add(const Duration(minutes: 10));

  group('DirectoryMerger', () {
    test('first download fills the directory without notifications', () {
      final r = DirectoryMerger.merge(
        current: const {},
        changed: [testCustomer(id: 'a', updatedAt: t0), testCustomer(id: 'b', updatedAt: t1)],
        deletions: const [],
        customersCursor: null,
        deletionsCursor: null,
        fullRefresh: true,
      );
      expect(r.customers.keys, unorderedEquals(['a', 'b']));
      expect(r.changes, isEmpty);
      expect(r.customersCursor, t1);
    });

    test('delta: new, location change, info change, archive, delete', () {
      final a = testCustomer(id: 'a', updatedAt: t0, lat: 36.7, lng: 3.1);
      final b = testCustomer(id: 'b', updatedAt: t0, phone: '0555000001');
      final c = testCustomer(id: 'c', updatedAt: t0);
      final d = testCustomer(id: 'd', updatedAt: t0, reference: 'OUT-000040');
      final current = {for (final x in [a, b, c, d]) x.id: x};

      final r = DirectoryMerger.merge(
        current: current,
        changed: [
          testCustomer(id: 'a', updatedAt: t1, lat: 36.8, lng: 3.2),
          testCustomer(id: 'b', updatedAt: t1, phone: '0555000002'),
          testCustomer(id: 'c', updatedAt: t1, status: CustomerStatus.archived),
          testCustomer(id: 'e', updatedAt: t2),
        ],
        deletions: [CustomerDeletion('d', 'OUT-000040', t2)],
        customersCursor: t0,
        deletionsCursor: null,
        fullRefresh: false,
      );

      expect(r.customers.keys, unorderedEquals(['a', 'b', 'c', 'e']));
      final kinds = {for (final ch in r.changes) ch.customerId: ch.kind};
      expect(kinds['a'], ChangeKind.locationUpdated);
      expect(kinds['b'], ChangeKind.updated);
      expect(kinds['c'], ChangeKind.archived);
      expect(kinds['e'], ChangeKind.created);
      expect(kinds['d'], ChangeKind.deleted);
      expect(r.customersCursor, t2);
      expect(r.deletionsCursor, t2);
    });

    test('overlap re-reads of unchanged rows are idempotent and silent', () {
      final a = testCustomer(id: 'a', updatedAt: t1);
      final r = DirectoryMerger.merge(
        current: {'a': a},
        changed: [a],
        deletions: const [],
        customersCursor: t1,
        deletionsCursor: null,
        fullRefresh: false,
      );
      expect(r.changes, isEmpty);
      expect(r.customers['a'], same(a));
    });

    test('a row updated after its tombstone (restore) is kept', () {
      final a = testCustomer(id: 'a', updatedAt: t2);
      final r = DirectoryMerger.merge(
        current: {'a': a},
        changed: const [],
        deletions: [CustomerDeletion('a', 'OUT-1', t1)],
        customersCursor: t2,
        deletionsCursor: null,
        fullRefresh: false,
      );
      expect(r.customers.containsKey('a'), isTrue);
    });

    test('full refresh drops rows the server no longer returns', () {
      final r = DirectoryMerger.merge(
        current: {'old': testCustomer(id: 'old')},
        changed: [testCustomer(id: 'new', updatedAt: t1)],
        deletions: const [],
        customersCursor: null,
        deletionsCursor: null,
        fullRefresh: true,
      );
      expect(r.customers.keys, ['new']);
    });
  });

  group('LocalCacheService', () {
    late Directory dir;
    late LocalCacheService cache;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('outifor_cache');
      cache = LocalCacheService(directoryProvider: () async => dir);
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('round-trips a snapshot including extra addresses and nulls', () async {
      final c = testCustomer(
        id: 'a',
        lat: 36.75,
        lng: 3.05,
        addresses: const [CustomerAddress(id: 'x', label: 'Dépôt', address: 'ZI lot 12', latitude: 36.7, longitude: 3.2)],
      );
      await cache.save(DirectorySnapshot(userId: 'u1', customers: [c], customersCursor: t1, lastSyncedAt: t2));
      final s = await cache.load('u1');
      expect(s, isNotNull);
      expect(s!.customers.single.addresses.single.label, 'Dépôt');
      expect(s.customers.single.latitude, 36.75);
      expect(s.customersCursor, t1);
      expect(s.deletionsCursor, isNull);
    });

    test('a snapshot belonging to another user is wiped, not shown', () async {
      await cache.save(DirectorySnapshot(userId: 'u1', customers: [testCustomer()]));
      expect(await cache.load('u2'), isNull);
      expect(await cache.load('u1'), isNull, reason: 'file was deleted');
    });

    test('a corrupt file is discarded', () async {
      File('${dir.path}/directory_cache.json').writeAsStringSync('{not json');
      expect(await cache.load('u1'), isNull);
    });

    test('clear removes the data', () async {
      await cache.save(DirectorySnapshot(userId: 'u1', customers: [testCustomer()]));
      await cache.clear();
      expect(await cache.load('u1'), isNull);
    });
  });

  test('Customer JSON from the API (nested customer_addresses) round-trips', () {
    final json = {
      'id': 'id1',
      'reference': 'OUT-000001',
      'first_name': 'Amina',
      'last_name': 'Kaci',
      'business_name': null,
      'primary_phone': '0770112233',
      'secondary_phone': null,
      'whatsapp_phone': '0770112233',
      'wilaya': 'Oran',
      'commune': 'Oran',
      'address': 'Hai Khemisti',
      'latitude': 35,
      'longitude': -0.6,
      'status': 'archived',
      'created_at': '2026-11-01T10:00:00+00:00',
      'updated_at': '2026-11-02T10:00:00+00:00',
      'created_by': null,
      'customer_addresses': [
        {'id': 'a', 'label': 'Dépôt', 'address': 'ZI', 'wilaya': null, 'commune': null, 'latitude': null, 'longitude': null},
      ],
    };
    final c = Customer.fromJson(json);
    expect(c.isArchived, isTrue);
    expect(c.latitude, 35.0);
    expect(c.cityLine, 'Oran');
    expect(c.addresses.single.hasLocation, isFalse);
    expect(Customer.fromJson(c.toJson()).toJson(), c.toJson());
  });
}
