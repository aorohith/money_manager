/// Parses transaction dates from SMS body when present.
abstract final class SmsDateExtractor {
  static final _patterns = <RegExp>[
    RegExp(
      r'\bon\s+(\d{1,2})[-\s]([A-Za-z]{3})[-\s](\d{2,4})\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bon\s+(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})\b',
    ),
    RegExp(
      r'\b(\d{1,2})[-\s]([A-Za-z]{3})[-\s](\d{2,4})\b',
      caseSensitive: false,
    ),
  ];

  static const _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  static DateTime? extract(String text, DateTime fallback) {
    for (final re in _patterns) {
      final m = re.firstMatch(text);
      if (m == null) continue;

      if (m.groupCount >= 3 && _months.containsKey(m.group(2)!.toLowerCase())) {
        final day = int.tryParse(m.group(1)!);
        final month = _months[m.group(2)!.toLowerCase()];
        var year = int.tryParse(m.group(3)!);
        if (day == null || month == null || year == null) continue;
        if (year < 100) year += 2000;
        return DateTime(year, month, day);
      }

      if (m.groupCount >= 3) {
        final day = int.tryParse(m.group(1)!);
        final month = int.tryParse(m.group(2)!);
        var year = int.tryParse(m.group(3)!);
        if (day == null || month == null || year == null) continue;
        if (year < 100) year += 2000;
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      }
    }
    return fallback;
  }
}
