import 'dart:convert';
import 'dart:io';

import 'package:money_manager/core/sms/extraction/amount_extractor.dart';
import 'package:money_manager/core/sms/extraction/direction_scorer.dart';
import 'package:money_manager/core/sms/extraction/rejection_filter.dart';
import 'package:money_manager/core/sms/transaction_parser.dart';

void main() {
  const parser = TransactionParser();
  final corpus = (jsonDecode(
    File('test/fixtures/sms_corpus/corpus.json').readAsStringSync(),
  ) as List)
      .cast<Map<String, dynamic>>();

  const card =
      'Thank you for using Debit Card ending 4321 for Rs.99.0 in MUMBAI at RELIANCE on 04-06-26';
  stdout.writeln('reject=${SmsRejectionFilter.shouldReject(card)}');
  final amt = SmsAmountExtractor.extract(card);
  stdout.writeln('amount=$amt');
  final dir = SmsDirectionScorer.detect(card, amountIndex: amt?.start);
  stdout.writeln('dir=${dir.direction} conf=${dir.confidence}');
  stdout.writeln('parse=${const TransactionParser().parse(card)?.merchantRaw}');

  for (final row in corpus) {
    final parsed = parser.parse(row['text'] as String);
    if (row['expectParse'] == false) {
      if (parsed != null) stdout.writeln('${row['id']}: should reject');
      continue;
    }
    if (parsed == null) {
      stdout.writeln('${row['id']}: parse null');
      continue;
    }
    final need = row['merchantContains'] as String?;
    if (need != null && !parsed.merchantNormalized.contains(need.toUpperCase())) {
      stdout.writeln('${row['id']}: merchant ${parsed.merchantNormalized}');
    }
    final hint = row['accountHint'] as String?;
    if (hint != null && parsed.accountHint != hint) {
      stdout.writeln('${row['id']}: hint ${parsed.accountHint} != $hint');
    }
  }
}
