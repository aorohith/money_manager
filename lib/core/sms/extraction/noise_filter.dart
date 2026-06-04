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
