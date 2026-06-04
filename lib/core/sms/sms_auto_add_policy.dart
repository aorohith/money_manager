import '../../features/sms/data/models/sms_rule_model.dart';
import '../../features/sms/domain/models/sms_settings.dart';
import 'extraction/merchant_extractor.dart';
import 'transaction_parser.dart';

/// Decides whether an ingested SMS should be auto-approved.
abstract final class SmsAutoAddPolicy {
  static const unknownMerchantKey = 'UNKNOWN MERCHANT';

  static bool shouldAutoApprove({
    required SmsSettings settings,
    required ParsedSmsData parsed,
    required double categoryConfidence,
    SmsRuleModel? userRule,
  }) {
    if (!settings.enabled) return false;
    if (settings.autoAddMode == SmsAutoAddMode.askAlways) return false;

    final threshold = settings.confidenceThreshold / 100.0;
    if (parsed.directionConfidence < threshold) return false;
    if (categoryConfidence < threshold) return false;

    final isUnknown = parsed.merchantNormalized == unknownMerchantKey ||
        parsed.merchantRaw == SmsMerchantExtractor.unknownMerchant;

    switch (settings.autoAddMode) {
      case SmsAutoAddMode.autoAddKnown:
        return userRule != null && !isUnknown;
      case SmsAutoAddMode.silentAll:
        if (isUnknown) return false;
        return userRule != null || categoryConfidence >= 0.90;
      case SmsAutoAddMode.askAlways:
        return false;
    }
  }
}
