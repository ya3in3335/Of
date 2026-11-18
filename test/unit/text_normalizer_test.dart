import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:outifor/core/utils/text_normalizer.dart';

/// The fixture is generated from the PostgreSQL functions
/// (scripts/gen_normalization_fixture.sh), so these tests prove that device
/// search and server search/duplicate checks normalise text identically.
void main() {
  final fixture = jsonDecode(File('test/fixtures/normalization_cases.json').readAsStringSync()) as Map<String, dynamic>;

  group('parity with public.normalize_search', () {
    for (final pair in fixture['normalize_search'] as List) {
      final input = pair[0] as String;
      final expected = pair[1] as String;
      test('"$input"', () => expect(TextNormalizer.normalize(input), expected));
    }
  });

  group('parity with public.normalize_phone', () {
    for (final pair in fixture['normalize_phone'] as List) {
      final input = pair[0] as String;
      final expected = pair[1] as String?;
      test('"$input"', () => expect(TextNormalizer.normalizePhone(input), expected));
    }
  });

  test('phone query digits map +213 prefixes even for partial numbers', () {
    expect(TextNormalizer.phoneQueryDigits('+213 555 12'), '055512');
    expect(TextNormalizer.phoneQueryDigits('00213 7'), '07');
    expect(TextNormalizer.phoneQueryDigits('0770'), '0770');
  });

  test('trigram similarity behaves like pg_trgm for close spellings', () {
    final a = TextNormalizer.trigrams(TextNormalizer.normalize('Benali'));
    final b = TextNormalizer.trigrams(TextNormalizer.normalize('Benaly'));
    final c = TextNormalizer.trigrams(TextNormalizer.normalize('Kaci'));
    expect(TextNormalizer.similarity(a, b), greaterThan(0.4));
    expect(TextNormalizer.similarity(a, c), lessThan(0.1));
    expect(TextNormalizer.similarity(a, a), 1.0);
  });
}
