/// Detects same-SMS internal transfer legs (debit + credit same account).
abstract final class SmsInternalTransferDetector {
  static final dualLegRe = RegExp(
    r'\bdebited\s+for\b.*\bcredited\b|\bdebited\b.*\band\s+a/c\b.*\bcredited\b',
    caseSensitive: false,
  );

  static bool shouldSkip(String text) => dualLegRe.hasMatch(text);
}
