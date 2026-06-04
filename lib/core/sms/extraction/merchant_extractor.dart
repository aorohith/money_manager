import '../sms_parser_types.dart';
import 'noise_filter.dart';

/// Priority-ordered merchant extraction for Indian bank SMS.
abstract final class SmsMerchantExtractor {
  static final upiToRe = RegExp(
    r'(?:UPI[-\s]?|paid\s+to\s+|sent\s+to\s+|to\s+VPA\s+|via\s+UPI\s+(?:on\s+)?\d{1,2}[-/]\d{1,2}(?:[-/]\d{2,4})?\s+to\s+|(?<![A-Za-z])to\s+(?!your\b|account\b|a/c\b|the\b))([A-Za-z][A-Za-z0-9\s&@._\-]{2,40}?)(?:\s+(?:on|via|ref|Ref|\.|UPI|\d|\()|$)',
    caseSensitive: false,
  );

  static final debitedForRe = RegExp(
    r'\bdebited\s+for\s+([A-Za-z][A-Za-z0-9\s&]+?)(?:\s+subscription|\s+renewal|\s+on|\s+\.|$)',
    caseSensitive: false,
  );

  static final membershipBrandRe = RegExp(
    r'\b(?:Your\s+)?([A-Za-z][A-Za-z0-9\s]+?)\s+membership\s+fee\b',
    caseSensitive: false,
  );

  static final forOrderRe = RegExp(
    r'\bfor\s+([A-Za-z][A-Za-z0-9\s&]+?)\s+order\b',
    caseSensitive: false,
  );

  static final creditedByRe = RegExp(
    r'\bcredited\s+to\s+.+?\s+by\s+([A-Za-z][A-Za-z0-9\s&]+?)(?:\s|\.|$)',
    caseSensitive: false,
  );

  static final spentAtRe = RegExp(
    r'\b(?:was\s+)?spent\s+(?:on\s+(?:your\s+)?(?:Credit\s+)?Card\s+\S+\s+)?(?:on\s+)?\d{1,2}[-\w]{3}[-\d]*\s+at\s+([A-Za-z][A-Za-z0-9\s&\-\./]{2,40}?)(?:\s*\.|,|\s+Avbl|\s+Avl|$)',
    caseSensitive: false,
  );

  static final atMerchantRe = RegExp(
    r'(?<![A-Za-z])at\s+([A-Za-z][A-Za-z0-9\s&\-\./]{2,40}?)(?:\s+on\s+|\s+Avbl|\s+Avl|\.|,|$)',
    caseSensitive: false,
  );

  static final fromPartyRe = RegExp(
    r'\b(?:received|credited)\s+(?:with\s+)?(?:Rs\.?|INR|₹)?\s*[\d,\.]+\s+from\s+([A-Za-z][A-Za-z0-9\s&@._\-]{2,40}?)(?:\s|\.|$)',
    caseSensitive: false,
  );

  static final fromSimpleRe = RegExp(
    r'\b(?:credited\s+with\s+)?from\s+([A-Za-z][A-Za-z0-9\s&@._\-]{2,40}?)(?:\s+(?:on|via|in|for|with)|\.|$)',
    caseSensitive: false,
  );

  static final byPartyRe = RegExp(
    r'\bcredited\s+to\s+your\s+(?:A/?c|account)\s+\S+\s+on\s+\S+\s+by\s+([A-Za-z][A-Za-z0-9\s&\-\./]{2,40}?)(?:\.|,|\s+Available|$)',
    caseSensitive: false,
  );

  static final bySimpleRe = RegExp(
    r'\bby\s+(?!Rs\.?|INR|₹)(\d|[A-Za-z][A-Za-z0-9\s&\-\./]{2,40}?)(?:\.|,|\s+Available|\s+Avl|$)',
    caseSensitive: false,
  );

  static final paidAtRe = RegExp(
    r'\bYou\s+paid\s+(?:Rs\.?|INR|₹)?\s*[\d,\.]+\s+(?:via\s+\S+\s+)?at\s+([A-Za-z][A-Za-z0-9\s&\-\./\(\)]{2,50}?)(?:\s*\(|\.|$)',
    caseSensitive: false,
  );

  static final infoVendorStarRe = RegExp(
    r'Info[.:]\s*(?:VPS|BIL|IIN)\*([A-Za-z][A-Za-z0-9\s&\-\./]{2,40}?)(?:\s*\.|,|\s+Your|\s+Total|\s+Avbl|$)',
    caseSensitive: false,
  );

  static final infoBlockRe = RegExp(
    r'Info[.:]\s*(?:[A-Z]{2,4}\*)?([A-Za-z][A-Za-z0-9\s&\-\./]{2,40}?)(?:\s*\.|,|\s+Your|\s+Total|\s+Avbl|$)',
    caseSensitive: false,
  );

  static final infoSlashRe = RegExp(
    r'Info:\s*(?:UPI/)?([A-Za-z][A-Za-z0-9\s&/]{2,40}?)(?:\s*\.|,|\s+Avl|$)',
    caseSensitive: false,
  );

  static final neftInfoRe = RegExp(
    r'Info\.NEFT-\S+-([A-Za-z][A-Za-z0-9\s&\-]{2,30}?)(?:\.|\s+Your|$)',
    caseSensitive: false,
  );

  static final beneficiaryRe = RegExp(
    r'Beneficiary\s*:\s*([A-Za-z][A-Za-z0-9\s]{2,40}?)(?:\s+on\s+|\s+at\s+|\.|$)',
    caseSensitive: false,
  );

  static final toMerchantRe = RegExp(
    r'(?<![A-Za-z])to\s+(?!your\b|account\b|a/c\b|the\b|beneficiary\b)([A-Za-z][A-Za-z0-9\s&\-]{2,30}?)(?:\s+(?:from|via|on|ref|\.)|\.|$)',
    caseSensitive: false,
  );

  /// Counterparty name before "credited" in payer-side SMS (e.g. "Beena Hotel credited").
  static final nameBeforeCreditedRe = RegExp(
    r'\b([A-Za-z][A-Za-z\s&\-\.]{2,35}?)\s+credited\b',
    caseSensitive: false,
  );

  /// Matches any UPI VPA (numeric or alpha handles), e.g. "9562802757@superyes",
  /// "swiggy@icici", "rohith-1@okicici". Used to populate the identity's
  /// [upiHandles] list even when the name extractor doesn't find a name.
  static final standaloneVpaRe = RegExp(
    r'\b([\w.\-]{2,40}@[A-Za-z]{2,20})\b',
  );

  static const unknownMerchant = 'Unknown Merchant';

  static MerchantExtractionResult extract(String text) {
    // Extract any VPA present in the full text (used regardless of name match).
    final vpaMatch = standaloneVpaRe.firstMatch(text);
    final rawVpa = vpaMatch?.group(1);

    final tries = <(MerchantExtractionSource, RegExp, bool personIfAt)>[
      (MerchantExtractionSource.upiTo, upiToRe, false),
      (MerchantExtractionSource.infoBlock, infoVendorStarRe, false),
      (MerchantExtractionSource.infoBlock, infoSlashRe, false),
      (MerchantExtractionSource.infoBlock, infoBlockRe, false),
      (MerchantExtractionSource.infoBlock, neftInfoRe, false),
      (MerchantExtractionSource.debitedFor, debitedForRe, false),
      (MerchantExtractionSource.paidAt, membershipBrandRe, false),
      (MerchantExtractionSource.toMerchant, forOrderRe, false),
      (MerchantExtractionSource.byParty, creditedByRe, false),
      (MerchantExtractionSource.spentAt, spentAtRe, false),
      (MerchantExtractionSource.atMerchant, atMerchantRe, false),
      (MerchantExtractionSource.fromParty, fromPartyRe, true),
      (MerchantExtractionSource.fromParty, fromSimpleRe, true),
      (MerchantExtractionSource.byParty, byPartyRe, false),
      (MerchantExtractionSource.paidAt, paidAtRe, false),
      (MerchantExtractionSource.beneficiary, beneficiaryRe, false),
      (MerchantExtractionSource.byParty, nameBeforeCreditedRe, false),
      (MerchantExtractionSource.toMerchant, toMerchantRe, false),
      (MerchantExtractionSource.byParty, bySimpleRe, false),
    ];

    for (final (source, re, personIfAt) in tries) {
      final match = re.firstMatch(text);
      if (match == null) continue;
      final rawGroup = match.group(1)?.trim() ?? '';
      // Capture VPA from this specific match if standaloneVpaRe didn't find one.
      final matchVpa = rawGroup.contains('@') ? rawGroup : rawVpa;
      var m = SmsNoiseFilter.stripVpaSuffix(rawGroup);
      m = _cleanInfoMerchant(m);
      if (m.isEmpty || SmsNoiseFilter.looksLikeNoise(m)) continue;
      final hasVpa = rawGroup.contains('@');
      return MerchantExtractionResult(
        raw: m,
        source: source,
        counterpartyType: (personIfAt || hasVpa) && !m.contains(' ')
            ? SmsCounterpartyType.person
            : SmsCounterpartyType.merchant,
        vpa: matchVpa,
      );
    }

    return MerchantExtractionResult(
      raw: unknownMerchant,
      source: MerchantExtractionSource.unknown,
      vpa: rawVpa,
    );
  }

  static String _cleanInfoMerchant(String m) {
    var s = m.replaceAll(RegExp(r'^\*+'), '').trim();
    if (s.toUpperCase().startsWith('PUR/')) {
      final parts = s.split('/');
      if (parts.length >= 2) s = parts[1].trim();
    }
    if (s.toUpperCase().startsWith('VPS*')) {
      s = s.substring(4).trim();
    }
    final slashIdx = s.indexOf('/');
    if (slashIdx >= 0 && slashIdx < s.length - 1) {
      final prefix = s.substring(0, slashIdx).toUpperCase();
      if (prefix == 'MOB' ||
          prefix.endsWith('CCPMT') ||
          prefix == 'PUR' ||
          prefix.length <= 4) {
        s = s.substring(slashIdx + 1).trim();
      }
    }
    return s;
  }
}
