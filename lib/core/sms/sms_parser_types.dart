/// Shared types for SMS parsing and ingestion.
library;

enum TransactionDirection { expense, income, ambiguous }

enum SmsCounterpartyType { merchant, person, unknown }

enum MerchantExtractionSource {
  upiTo,
  debitedFor,
  spentAt,
  atMerchant,
  fromParty,
  byParty,
  paidAt,
  infoBlock,
  beneficiary,
  toMerchant,
  unknown,
}

class DirectionResult {
  const DirectionResult({
    required this.direction,
    required this.confidence,
    required this.matchedSignals,
  });

  final TransactionDirection direction;
  final double confidence;
  final List<String> matchedSignals;
}

class AmountMatch {
  const AmountMatch({
    required this.amount,
    required this.start,
  });

  final double amount;
  final int start;
}

class MerchantExtractionResult {
  const MerchantExtractionResult({
    required this.raw,
    required this.source,
    this.counterpartyType = SmsCounterpartyType.merchant,
  });

  final String raw;
  final MerchantExtractionSource source;
  final SmsCounterpartyType counterpartyType;
}
