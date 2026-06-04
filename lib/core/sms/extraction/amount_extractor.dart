import '../sms_parser_types.dart';

/// Extracts transaction amount from Indian bank SMS text.
abstract final class SmsAmountExtractor {
  /// Indian amounts: plain digits (1000), grouped (1,23,456.78), or decimals (1200.00).
  static const _amountGroup = r'(\d+(?:,\d{2,3})*(?:\.\d{1,2})?)';

  static final currencyPrefixRe = RegExp(
    r'(?:Rs\.?|INR|₹)\s*' + _amountGroup,
    caseSensitive: false,
  );

  static final verbLedRe = RegExp(
    r'\b(?:debited|debited\s+by|credited|credited\s+with|received|paid|spent|sent)\s+(?:by\s+)?(?:Rs\.?|INR|₹)?\s*' +
        _amountGroup,
    caseSensitive: false,
  );

  static final reverseVerbRe = RegExp(
    r'(?:Rs\.?|INR|₹)\s*' + _amountGroup + r'\s+(?:debited|credited|received|paid|spent)',
    caseSensitive: false,
  );

  /// Picks the transaction amount, preferring matches near [directionAnchor].
  static AmountMatch? extract(String text, {int? directionAnchor}) {
    final candidates = <AmountMatch>[];

    for (final re in [verbLedRe, reverseVerbRe, currencyPrefixRe]) {
      for (final match in re.allMatches(text)) {
        final amount = _parseAmount(match.group(1)!);
        if (amount != null && amount >= 0.01) {
          candidates.add(AmountMatch(amount: amount, start: match.start));
        }
      }
    }

    if (candidates.isEmpty) return null;

    final lower = text.toLowerCase();
    final anchor = directionAnchor ??
        _firstIndexOfAny(lower, const [
          'debited',
          'credited',
          'spent',
          'received',
          'paid',
          'sent',
        ]);
    candidates.sort((a, b) {
      final distA = (a.start - anchor).abs();
      final distB = (b.start - anchor).abs();
      return distA.compareTo(distB);
    });

    // When multiple amounts, prefer the one closest to direction keywords;
    // deprioritize balance lines (often after "Avl Bal").
    final balanceIdx = text.toLowerCase().indexOf('avl');
    if (balanceIdx >= 0 && candidates.length > 1) {
      final nonBalance = candidates
          .where((c) => c.start < balanceIdx || balanceIdx < 20)
          .toList();
      if (nonBalance.isNotEmpty) return nonBalance.first;
    }

    return candidates.first;
  }

  static double? _parseAmount(String raw) {
    return double.tryParse(raw.replaceAll(',', ''));
  }

  static int _firstIndexOfAny(String lower, List<String> needles) {
    var best = lower.length;
    for (final n in needles) {
      final i = lower.indexOf(n);
      if (i >= 0 && i < best) best = i;
    }
    return best == lower.length ? 0 : best;
  }
}
