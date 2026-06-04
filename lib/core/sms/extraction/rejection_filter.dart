/// Pre-parse rejection rules for non-transaction SMS.
abstract final class SmsRejectionFilter {
  static final otpRe = RegExp(
    r'\b(?:OTP|one.time.password|verification.code|do not share)\b',
    caseSensitive: false,
  );

  static final failureRe = RegExp(
    r'\b(?:fail(?:ed|ure)|declin(?:ed|e)|reversal?|reversed|blocked|rejected|unsuccessful)\b',
    caseSensitive: false,
  );

  /// Bill reminder without a debit/credit on the user's account.
  static final billDueOnlyRe = RegExp(
    r'\b(?:please pay|payment due|overdue|reflects\s+rs\.?\s*\d.*due|against bill dated)\b',
    caseSensitive: false,
  );

  static final loanMarketingRe = RegExp(
    r'\b(?:insta\s+loan|pre-approved\s+loan|emi\s+is\s+rs|loan\s+pass|credited\s+to\s+savings\s+a/c\s+ending)\b',
    caseSensitive: false,
  );

  static final promoOrPendingRe = RegExp(
    r'\b(?:congratulations|click to claim|complete your kyc|collect request|not a debit yet|you won|no charge yet|subscribe\s+\w+\s+at\s+rs)\b',
    caseSensitive: false,
  );

  static final txnSignalRe = RegExp(
    r'\b(?:debited?|credited?|spent|received|paid|withdrawn|deposited|purchase)\b',
    caseSensitive: false,
  );

  static bool shouldReject(String text) {
    if (otpRe.hasMatch(text)) return true;
    if (failureRe.hasMatch(text)) return true;
    if (loanMarketingRe.hasMatch(text)) return true;
    if (promoOrPendingRe.hasMatch(text)) return true;
    if (billDueOnlyRe.hasMatch(text) && !txnSignalRe.hasMatch(text)) {
      return true;
    }
    return false;
  }
}
