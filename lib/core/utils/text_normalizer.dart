/// Search normalisation, kept identical to `public.normalize_search` and
/// `public.normalize_phone` in the database (see supabase/migrations).
/// test/unit/text_normalizer_test.dart checks parity against a fixture that
/// is generated from the SQL functions.
abstract final class TextNormalizer {
  static const _latinFolds = <String, String>{
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'ā': 'a',
    'ă': 'a',
    'ą': 'a',
    'ç': 'c',
    'ć': 'c',
    'č': 'c',
    'ĉ': 'c',
    'ċ': 'c',
    'ď': 'd',
    'đ': 'd',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ē': 'e',
    'ĕ': 'e',
    'ė': 'e',
    'ę': 'e',
    'ě': 'e',
    'ĝ': 'g',
    'ğ': 'g',
    'ġ': 'g',
    'ģ': 'g',
    'ĥ': 'h',
    'ħ': 'h',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ĩ': 'i',
    'ī': 'i',
    'ĭ': 'i',
    'į': 'i',
    'ı': 'i',
    'ĵ': 'j',
    'ķ': 'k',
    'ĺ': 'l',
    'ļ': 'l',
    'ľ': 'l',
    'ŀ': 'l',
    'ł': 'l',
    'ñ': 'n',
    'ń': 'n',
    'ņ': 'n',
    'ň': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ø': 'o',
    'ō': 'o',
    'ŏ': 'o',
    'ő': 'o',
    'ŕ': 'r',
    'ŗ': 'r',
    'ř': 'r',
    'ś': 's',
    'ŝ': 's',
    'ş': 's',
    'š': 's',
    'ţ': 't',
    'ť': 't',
    'ŧ': 't',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ũ': 'u',
    'ū': 'u',
    'ŭ': 'u',
    'ů': 'u',
    'ű': 'u',
    'ų': 'u',
    'ŵ': 'w',
    'ý': 'y',
    'ÿ': 'y',
    'ŷ': 'y',
    'ź': 'z',
    'ż': 'z',
    'ž': 'z',
    'æ': 'ae',
    'œ': 'oe',
    'ß': 'ss',
    'þ': 'th',
    'ð': 'd',
  };

  // Alef variants -> alef, alef maqsura -> ya, ta marbuta -> ha, hamza carriers.
  static const _arabicFolds = <int, int>{
    0x0623: 0x0627,
    0x0625: 0x0627,
    0x0622: 0x0627,
    0x0671: 0x0627,
    0x0649: 0x064A,
    0x0629: 0x0647,
    0x0624: 0x0648,
    0x0626: 0x064A,
  };

  static final _arabicMarks = RegExp('[ً-ْٰـ]');
  static final _nonAlnum = RegExp('[^a-z0-9؀-ۿ]+');
  static final _repeatedLetters = RegExp('([a-zء-ي])\\1+');
  static final _spaces = RegExp(r'\s+');
  static final _nonDigits = RegExp('[^0-9]');

  static String _foldDigits(String s) {
    final out = StringBuffer();
    for (final rune in s.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        out.writeCharCode(0x30 + rune - 0x0660);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        out.writeCharCode(0x30 + rune - 0x06F0);
      } else {
        out.writeCharCode(rune);
      }
    }
    return out.toString();
  }

  /// Normalised form used for search keys and queries.
  static String normalize(String? input) {
    if (input == null || input.isEmpty) return '';
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final ch = String.fromCharCode(rune);
      final latin = _latinFolds[ch];
      if (latin != null) {
        buffer.write(latin);
        continue;
      }
      buffer.writeCharCode(_arabicFolds[rune] ?? rune);
    }
    var s = buffer.toString().replaceAll(_arabicMarks, '');
    s = _foldDigits(s);
    s = s.replaceAll(_nonAlnum, ' ');
    s = s.replaceAllMapped(_repeatedLetters, (m) => m.group(1)!);
    return s.replaceAll(_spaces, ' ').trim();
  }

  /// Canonical phone digits; +213 / 00213 become a leading 0. Null if no digits.
  static String? normalizePhone(String? input) {
    if (input == null) return null;
    var d = _foldDigits(input).replaceAll(_nonDigits, '');
    if (d.isEmpty) return null;
    if (d.startsWith('00213')) {
      d = '0${d.substring(5)}';
    } else if (d.startsWith('213') && d.length >= 11) {
      d = '0${d.substring(3)}';
    }
    return d;
  }

  /// Digits of a (possibly partial) phone query, with a +213 prefix mapped to 0.
  static String phoneQueryDigits(String input) {
    var d = _foldDigits(input).replaceAll(_nonDigits, '');
    if (d.startsWith('00213')) {
      d = '0${d.substring(5)}';
    } else if (d.startsWith('213')) {
      d = '0${d.substring(3)}';
    }
    return d;
  }

  /// pg_trgm-compatible trigram set (words padded with two leading and one
  /// trailing space).
  static Set<String> trigrams(String normalized) {
    final result = <String>{};
    for (final word in normalized.split(' ')) {
      if (word.isEmpty) continue;
      final padded = '  $word ';
      final runes = padded.runes.toList();
      for (var i = 0; i + 3 <= runes.length; i++) {
        result.add(String.fromCharCodes(runes.sublist(i, i + 3)));
      }
    }
    return result;
  }

  static double similarity(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final common = a.intersection(b).length;
    return common / (a.length + b.length - common);
  }
}
