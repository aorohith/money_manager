/// Infers payment channel from SMS keywords.
abstract final class SmsPaymentMethodDetector {
  static final upiRe = RegExp(r'\bUPI\b', caseSensitive: false);
  static final creditCardRe = RegExp(
    r'\bCredit\s+Card\b|\bCREDIT\s+Card\b|\bCC\b|\bCredit\s+Cd\b',
    caseSensitive: false,
  );
  static final debitCardRe = RegExp(
    r'\bDebit\s+Card\b|\bDC\b|\bDebit\s+Cd\b',
    caseSensitive: false,
  );
  static final walletRe = RegExp(
    r'\bWallet\b|\bPaytm\b|\bPhonePe\b|\bMobikwik\b|\bJio\s+Money\b|\bOla\s+Money\b|\bFreeCharge\b|\bPayZapp\b|\bFamPay\b',
    caseSensitive: false,
  );
  static final netBankingRe = RegExp(
    r'\bNet\s?Banking\b|\bNEFT\b|\bIMPS\b|\bRTGS\b',
    caseSensitive: false,
  );

  static String detect(String text) {
    if (upiRe.hasMatch(text)) return 'UPI';
    if (creditCardRe.hasMatch(text)) return 'Credit Card';
    if (debitCardRe.hasMatch(text)) return 'Debit Card';
    if (walletRe.hasMatch(text)) return 'Wallet';
    if (netBankingRe.hasMatch(text)) return 'Net Banking';
    return 'Unknown';
  }
}
