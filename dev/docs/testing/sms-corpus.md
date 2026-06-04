# SMS Corpus Testing

## Purpose

Regression suite for the **Indian banking SMS parser**. Fixtures live in JSON; tests assert parse rate, merchant extraction, rejection, and account hints.

## Entry points

| File | Role |
|------|------|
| [`test/fixtures/sms_corpus/corpus.json`](../../../test/fixtures/sms_corpus/corpus.json) | Fixture rows |
| [`test/unit/sms/transaction_parser_corpus_test.dart`](../../../test/unit/sms/transaction_parser_corpus_test.dart) | Test runner |
| [`tool/corpus_debug.dart`](../../tool/corpus_debug.dart) | CLI debug helper |

## Fixture format

Each row in `corpus.json`:

```json
{
  "id": "unique_id",
  "text": "Rs 500 debited via UPI to ZOMATO on 01-01-25",
  "expectParse": true,
  "merchantContains": "ZOMATO",
  "accountHint": "XX1234"
}
```

| Field | Required | Meaning |
|-------|----------|---------|
| `id` | yes | Stable identifier for failures |
| `text` | yes | Raw SMS (redact PII) |
| `expectParse` | yes | `true` = must parse; `false` = must reject |
| `merchantContains` | no | Substring expected in normalized merchant |
| `accountHint` | no | Expected last-4 hint |
| `isIncome` | no | Direction assertion |

## Targets

From [`test/fixtures/sms_corpus/README.md`](../../../test/fixtures/sms_corpus/README.md):

- Parse rate on `expectParse: true` rows: ≥ 90%
- Merchant hit rate (rows with `merchantContains`): ≥ 80%
- Reject rows: 100% null parse

## Workflow

```mermaid
flowchart LR
  Report[User-reported failure] --> Redact[Redact account numbers]
  Redact --> JSON[Add corpus.json row]
  JSON --> Test[Run corpus test]
  Test --> Fix[Fix extractor]
  Fix --> Test
```

1. Add fixture **before** shipping regex changes.
2. Run corpus test.
3. Fix failing extractor in `lib/core/sms/extraction/`.
4. Update [gap-analysis.md](../core/sms/gap-analysis.md) if closing a gap.

## Commands

```bash
# Full corpus test
flutter test test/unit/sms/transaction_parser_corpus_test.dart

# Debug output for all rows
dart run dev/tool/corpus_debug.dart

# Single parser tests
flutter test test/unit/sms/transaction_parser_test.dart
```

## Maintenance

Add **5–10 fixtures per month** from user-reported failures. Always redact:

- Full card numbers
- Full account numbers
- Phone numbers

Use `TransactionParser.redactSensitive` when displaying SMS in UI.

## Related docs

- [../core/sms/overview.md](../core/sms/overview.md)
- [../core/sms/extraction-modules.md](../core/sms/extraction-modules.md)
- [../core/sms/gap-analysis.md](../core/sms/gap-analysis.md)
- `.cursor/rules/sms-merchant-extraction.mdc`
