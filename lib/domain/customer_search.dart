import '../core/utils/text_normalizer.dart';
import '../data/models/customer.dart';

/// Why a customer matched; shown as a hint next to the result.
enum MatchKind { reference, phone, name, fuzzyName }

class SearchHit {
  const SearchHit(this.customer, this.score, this.kind);
  final Customer customer;
  final double score;
  final MatchKind kind;
}

class _Entry {
  _Entry(this.customer)
    : nameKey = TextNormalizer.normalize(customer.fullName),
      reverseKey = TextNormalizer.normalize('${customer.lastName} ${customer.firstName}'),
      referenceKey = TextNormalizer.normalize(customer.reference),
      searchText = [
        TextNormalizer.normalize(
          [
            customer.firstName,
            customer.lastName,
            customer.businessName ?? '',
            customer.reference,
            customer.commune,
            customer.wilaya,
          ].join(' '),
        ),
        customer.primaryPhone,
        customer.secondaryPhone ?? '',
        customer.whatsappPhone ?? '',
      ].join(' '),
      phones = [customer.primaryPhone, customer.secondaryPhone, customer.whatsappPhone].whereType<String>().toList() {
    nameWords = nameKey.split(' ');
    trigrams = TextNormalizer.trigrams(nameKey);
    wordTrigrams = [for (final w in nameWords) TextNormalizer.trigrams(w)];
  }

  final Customer customer;
  final String nameKey;
  final String reverseKey;
  final String referenceKey;
  final String searchText;
  final List<String> phones;
  late final List<String> nameWords;
  late final Set<String> trigrams;
  late final List<Set<String>> wordTrigrams;
}

/// In-memory customer search over the synced directory. Pure Dart, so it is
/// fast (no network) and unit-tested. Matching rules mirror the server's
/// `search_customers` function.
class CustomerSearchEngine {
  CustomerSearchEngine(Iterable<Customer> customers) : _entries = customers.map(_Entry.new).toList();

  final List<_Entry> _entries;

  int get size => _entries.length;

  List<SearchHit> search(String rawQuery, {bool includeArchived = false, int limit = 50}) {
    final query = rawQuery.trim();
    final q = TextNormalizer.normalize(query);
    if (q.isEmpty) return const [];

    final tokens = q.split(' ');
    final digits = TextNormalizer.phoneQueryDigits(query);
    final digitsOnlyQuery = RegExp(r'^[\d\s+().-]+$').hasMatch(query);
    final queryTrigrams = TextNormalizer.trigrams(q);
    final hits = <SearchHit>[];

    for (final e in _entries) {
      if (!includeArchived && e.customer.isArchived) continue;

      double score = 0;
      MatchKind? kind;

      // 1. Reference ("OUT-000125", "000125", "125")
      if (e.referenceKey == q) {
        score = 1000;
        kind = MatchKind.reference;
      } else if (q.length >= 3 && e.referenceKey.contains(q)) {
        score = 800;
        kind = MatchKind.reference;
      } else if (digits.length >= 3 && !digitsOnlyQuery && e.customer.reference.endsWith(digits)) {
        score = 780;
        kind = MatchKind.reference;
      }

      // 2. Phone numbers (any of the three, partial, spaces and +213 allowed)
      if (digits.length >= 4) {
        for (final p in e.phones) {
          final s = p == digits ? 950.0 : (p.startsWith(digits) ? 900.0 : (p.contains(digits) ? 700.0 : 0.0));
          if (s > score) {
            score = s;
            kind = MatchKind.phone;
          }
        }
      }

      // 3. Names: every token must appear (any order). Word-prefix matches rank higher.
      if (score < 500 && tokens.every(e.searchText.contains)) {
        var s = 500.0;
        for (final t in tokens) {
          if (e.nameWords.any((w) => w.startsWith(t))) s += 40;
          if (e.nameWords.contains(t)) s += 20;
        }
        if (e.nameKey == q || e.reverseKey == q) s += 200;
        if (e.nameKey.startsWith(q) || e.reverseKey.startsWith(q)) s += 60;
        score = s;
        kind = MatchKind.name;
      }

      // 4. Fuzzy names (spelling variants: Benaly / Benali, Abdelkader / Abdelkadir)
      if (score == 0 && q.length >= 3 && !digitsOnlyQuery) {
        // Compare with the full name and with each single name, so a
        // misspelled last name alone ("Benaly") still finds "Mohamed Benali".
        var sim = TextNormalizer.similarity(queryTrigrams, e.trigrams);
        if (tokens.length == 1) {
          for (final w in e.wordTrigrams) {
            final s = TextNormalizer.similarity(queryTrigrams, w);
            if (s > sim) sim = s;
          }
        }
        if (sim >= 0.35) {
          score = 300 * sim;
          kind = MatchKind.fuzzyName;
        }
      }

      if (score > 0) hits.add(SearchHit(e.customer, score, kind!));
    }

    hits.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byLast = a.customer.lastName.toLowerCase().compareTo(b.customer.lastName.toLowerCase());
      if (byLast != 0) return byLast;
      return a.customer.firstName.toLowerCase().compareTo(b.customer.firstName.toLowerCase());
    });
    return hits.length > limit ? hits.sublist(0, limit) : hits;
  }

  /// Local duplicate hints while the admin types (the server check on save is
  /// authoritative). Returns customers sharing a phone, or with a near-identical name.
  List<Customer> possibleDuplicates({
    required String firstName,
    required String lastName,
    required List<String> phones,
    String? excludeId,
  }) {
    final normalizedPhones = phones.map(TextNormalizer.normalizePhone).whereType<String>().toSet();
    final name = TextNormalizer.normalize('$firstName $lastName');
    final nameTrigrams = TextNormalizer.trigrams(name);
    final result = <Customer>[];
    for (final e in _entries) {
      if (e.customer.id == excludeId) continue;
      final phoneMatch = e.phones.any(normalizedPhones.contains);
      final nameMatch =
          name.length >= 4 &&
          (e.nameKey == name || e.reverseKey == name || TextNormalizer.similarity(nameTrigrams, e.trigrams) >= 0.6);
      if (phoneMatch || nameMatch) result.add(e.customer);
    }
    return result;
  }
}
