# SMS parser corpus

Baseline (Sprint 0): run `fvm flutter test test/unit/sms/transaction_parser_corpus_test.dart`.

Targets (plan):
- Parse rate on `expectParse: true` rows: ≥90%
- Merchant hit rate (rows with `merchantContains`): ≥80%
- Reject rows: 100% null parse

Add 5–10 fixtures monthly from user-reported parse failures (redact PII).
