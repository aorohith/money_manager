/// Detects likely subscription / recurring charges in SMS text.
abstract final class SmsSubscriptionDetector {
  static final recurringRe = RegExp(
    r'\b(?:netflix|prime\s+video|hotstar|spotify|youtube\s+premium|apple\s+music|'
    r'emi\s+of\s+rs|autopay|subscription|monthly\s+charge)\b',
    caseSensitive: false,
  );

  static bool isLikelySubscription(String text, {required bool enabled}) {
    if (!enabled) return false;
    return recurringRe.hasMatch(text);
  }
}
