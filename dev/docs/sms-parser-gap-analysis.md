# SMS parser gap analysis (hybrid eval)

## Approach

- **Runtime:** in-house modules under `lib/core/sms/extraction/`.
- **Regression:** `test/fixtures/sms_corpus/corpus.json` + `transaction_parser_corpus_test.dart`.
- **Reference:** patterns ported from public corpora (Indian bank SMS samples, DLT templates) and the [transaction-sms-parser](https://github.com/saurabhgupta050890/transaction-sms-parser) shape (`amount`, `type`, `merchant`, `balance`).

## Covered template families

| Family | Example signal | Module |
|--------|----------------|--------|
| UPI debit to merchant | `via UPI … to ZOMATO` | `merchant_extractor` |
| Card spent at | `spent … at MERCHANT` | `merchant_extractor` |
| Info block | `Info.VPS*MERCHANT` | `merchant_extractor` |
| Credit by party | `credited … by NAME` | `merchant_extractor` |
| Name before credited | `Beena Hotel credited` | `merchant_extractor` |
| Verb-led amount | `debited by Rs 240` | `amount_extractor` |
| UPI ref dedup | `UPI Ref: 1234567890` | `buildFingerprint` |

## Remaining gaps (maintain in corpus)

- POS terminal codes with no merchant name (`POS TERMINAL 4523`).
- Multi-leg transfers in one SMS (skipped via `internal_transfer_detector`).
- Some regional date formats not yet in `date_extractor`.

## Maintenance

Add 5–10 new JSON fixtures per month from user-reported failures (redact account numbers).
