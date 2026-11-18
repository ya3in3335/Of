import 'package:flutter_test/flutter_test.dart';
import 'package:outifor/data/models/customer.dart';
import 'package:outifor/domain/customer_search.dart';

import '../helpers.dart';

void main() {
  final benali1 = testCustomer(id: 'b1', reference: 'OUT-000125', firstName: 'Mohamed', lastName: 'Benali',
      phone: '0555123456', commune: 'Bab Ezzouar');
  final benali2 = testCustomer(id: 'b2', reference: 'OUT-000310', firstName: 'Mohammed', lastName: 'Benali',
      phone: '0661987654', commune: 'Boufarik', wilaya: 'Blida');
  final kaci = testCustomer(id: 'k1', reference: 'OUT-000007', firstName: 'Amina', lastName: 'Kaci',
      phone: '0770112233', whatsapp: '0770112233', businessName: 'Quincaillerie El Amel', commune: 'Bir El Djir',
      wilaya: 'Oran');
  final arabic = testCustomer(id: 'a1', reference: 'OUT-000042', firstName: 'مُحَمَّد', lastName: 'بن علي',
      phone: '0550998877');
  final archived = testCustomer(id: 'x1', reference: 'OUT-000099', firstName: 'Rachid', lastName: 'Haddad',
      phone: '0699000000', status: CustomerStatus.archived);

  final engine = CustomerSearchEngine([benali1, benali2, kaci, arabic, archived]);
  List<String> ids(String q, {bool archivedToo = false}) =>
      engine.search(q, includeArchived: archivedToo).map((h) => h.customer.id).toList();

  test('empty and whitespace queries return nothing', () {
    expect(ids(''), isEmpty);
    expect(ids('   '), isEmpty);
  });

  test('similar names return every match with distinguishing details, never just one', () {
    final r = engine.search('benali');
    expect(r.map((h) => h.customer.id), containsAll(['b1', 'b2']));
    expect(r.length, greaterThanOrEqualTo(2));
  });

  test('first name, last name, full name in any order, partial, trimmed', () {
    expect(ids('Kaci'), ['k1']);
    expect(ids('amina'), ['k1']);
    expect(ids('kaci amina'), ['k1']);
    expect(ids('  ami  ka '), ['k1']);
    expect(ids('ben'), containsAll(['b1', 'b2']));
  });

  test('spelling variants: doubled letters and accents', () {
    expect(ids('Mohammed Benali').take(2), containsAll(['b1', 'b2']));
    expect(ids('quincaillérie'), ['k1']);
  });

  test('fuzzy match on a misspelled last name', () {
    expect(ids('Benaly'), containsAll(['b1', 'b2']));
  });

  test('reference: full, without prefix, short tail', () {
    expect(ids('OUT-000125').first, 'b1');
    expect(ids('out 000125').first, 'b1');
    expect(ids('000125').first, 'b1');
  });

  test('phone: partial with spaces, international prefix, secondary/whatsapp', () {
    expect(ids('0555 12'), ['b1']);
    expect(ids('+213 661 98').first, 'b2');
    expect(ids('0770112233').first, 'k1');
  });

  test('Arabic: diacritics and letter variants ignored', () {
    expect(ids('محمد'), ['a1']);
    expect(ids('بن'), contains('a1'));
  });

  test('business name and commune are searchable', () {
    expect(ids('el amel'), ['k1']);
    expect(ids('boufarik'), ['b2']);
  });

  test('archived customers are hidden unless requested', () {
    expect(ids('haddad'), isEmpty);
    expect(ids('haddad', archivedToo: true), ['x1']);
  });

  test('no false positives', () {
    expect(ids('qwerty'), isEmpty);
    expect(ids('99887766554'), isEmpty);
  });

  test('exact full name ranks above partial matches', () {
    final r = engine.search('mohamed benali');
    expect(r.first.customer.id, 'b1');
  });

  test('match kind tells the UI why a row matched', () {
    expect(engine.search('0555123').first.kind, MatchKind.phone);
    expect(engine.search('OUT-000007').first.kind, MatchKind.reference);
    expect(engine.search('kaci').first.kind, MatchKind.name);
  });

  group('local duplicate hints', () {
    test('same phone in any format', () {
      final d = engine.possibleDuplicates(firstName: 'X', lastName: 'Y', phones: ['+213 555 12 34 56']);
      expect(d.map((c) => c.id), ['b1']);
    });
    test('same name, swapped order', () {
      final d = engine.possibleDuplicates(firstName: 'Kaci', lastName: 'Amina', phones: const []);
      expect(d.map((c) => c.id), ['k1']);
    });
    test('the record being edited is excluded', () {
      final d = engine.possibleDuplicates(
          firstName: 'Amina', lastName: 'Kaci', phones: const ['0770112233'], excludeId: 'k1');
      expect(d, isEmpty);
    });
  });

  test('handles a large directory quickly', () {
    final many = [
      for (var i = 0; i < 20000; i++)
        testCustomer(id: 'm$i', firstName: 'Client$i', lastName: 'Nom${i % 500}', phone: '05${(i + 10000000).toString().padLeft(8, '0')}'),
    ];
    final big = CustomerSearchEngine(many);
    final sw = Stopwatch()..start();
    final r = big.search('nom42');
    sw.stop();
    expect(r, isNotEmpty);
    expect(sw.elapsedMilliseconds, lessThan(500));
  });
}
