/// Filters merchant candidates that are account refs, ATM codes, etc.
abstract final class SmsNoiseFilter {
  static const _atmNoise = [
    'cash wdl',
    'cash-atm',
    'nfs*cash',
    'atm*cash',
    'mob/ccpmt',
  ];

  static const _infoNoisePrefixes = [
    'bil*',
    'neft-',
    'imps-',
    'to rd',
    'by int',
    'int.pd',
    'axisdirect',
    'phr0 emi',
  ];

  /// Call-to-action words that appear in bank SMS footers (e.g. "To dispute
  /// call 18003097986 - Utkarsh SFBL") and must never be treated as merchants.
  static const _callToActionStarts = [
    'dispute',
    'block',
    'report',
    'register',
    'track',
    'visit',
    'click',
    'call us',
    'contact',
    'reach',
    'raise',
    'know more',
    'for more',
    'download',
    'tap here',
  ];

  static bool looksLikeNoise(String s) {
    final lower = s.toLowerCase().trim();
    if (lower.length < 3) return true;
    if (RegExp(r'^\d+$').hasMatch(lower)) return true;
    if (RegExp(r'\d').hasMatch(lower)) return true;
    if (lower.contains('account')) return true;
    if (lower.contains('your')) return true;
    if (lower.startsWith('beneficiary')) return true;
    if (lower.startsWith('inr ') || lower.startsWith('rs ')) return true;
    if (lower == 'a/c' || lower.startsWith('a/c ')) return true;
    if (_atmNoise.any(lower.contains)) return true;
    if (_infoNoisePrefixes.any(lower.startsWith)) return true;
    if (_callToActionStarts.any(lower.startsWith)) return true;
    return false;
  }

  static String stripVpaSuffix(String merchant) {
    return merchant.replaceFirst(RegExp(r'@[A-Za-z0-9]+$'), '').trim();
  }

  static String normalizeMerchantKey(String raw) {
    final stripped = stripVpaSuffix(raw);
    return stripped
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
