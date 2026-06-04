import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/sms/transaction_parser.dart';

void main() {
  const parser = TransactionParser();

  late List<Map<String, dynamic>> corpus;

  setUpAll(() {
    final file = File('test/fixtures/sms_corpus/corpus.json');
    corpus = (jsonDecode(file.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
  });

  test('corpus regression — parse rate and merchant coverage', () {
    var txnRows = 0;
    var parsedOk = 0;
    var merchantCases = 0;
    var merchantOk = 0;
    var rejectOk = 0;
    final failures = <String>[];

    for (final row in corpus) {
      final id = row['id'] as String;
      final text = row['text'] as String;
      final expectParse = row['expectParse'] as bool;
      final parsed = parser.parse(text);

      if (!expectParse) {
        if (parsed == null) {
          rejectOk++;
        } else {
          failures.add('$id: expected reject, got parse');
        }
        continue;
      }

      txnRows++;
      if (parsed == null) {
        failures.add('$id: expected parse, got null');
        continue;
      }
      parsedOk++;

      final direction = row['direction'] as String?;
      if (direction != null) {
        final expected = switch (direction) {
          'expense' => TransactionDirection.expense,
          'income' => TransactionDirection.income,
          'ambiguous' => TransactionDirection.ambiguous,
          _ => null,
        };
        if (expected != null && parsed.direction != expected) {
          failures.add(
            '$id: direction ${parsed.direction.name} != $direction',
          );
        }
      }

      final amount = (row['amount'] as num?)?.toDouble();
      if (amount != null && (parsed.amount - amount).abs() > 0.01) {
        failures.add('$id: amount ${parsed.amount} != $amount');
      }

      final merchantContains = row['merchantContains'] as String?;
      if (merchantContains != null) {
        merchantCases++;
        if (parsed.merchantNormalized.contains(
          merchantContains.toUpperCase(),
        )) {
          merchantOk++;
        } else {
          failures.add(
            '$id: merchant ${parsed.merchantNormalized} '
            'missing $merchantContains',
          );
        }
      }

      final paymentMethod = row['paymentMethod'] as String?;
      if (paymentMethod != null &&
          parsed.paymentMethod != paymentMethod) {
        failures.add(
          '$id: payment ${parsed.paymentMethod} != $paymentMethod',
        );
      }

      final ref = row['referenceNumber'] as String?;
      if (ref != null && parsed.referenceNumber != ref) {
        failures.add('$id: ref ${parsed.referenceNumber} != $ref');
      }

      final hint = row['accountHint'] as String?;
      if (hint != null && parsed.accountHint != hint) {
        failures.add('$id: hint ${parsed.accountHint} != $hint');
      }
    }

    final parseRate = txnRows == 0 ? 0.0 : parsedOk / txnRows;
    final merchantRate =
        merchantCases == 0 ? 0.0 : merchantOk / merchantCases;
    final rejectTotal =
        corpus.where((r) => r['expectParse'] == false).length;

    // Baseline targets from sprint plan (enforced as tests mature).
    expect(parseRate, greaterThanOrEqualTo(0.85),
        reason: 'parse rate $parsedOk/$txnRows failures:\n${failures.join('\n')}');
    expect(merchantRate, greaterThanOrEqualTo(0.80),
        reason: 'merchant rate $merchantOk/$txnRows');
    expect(rejectOk, rejectTotal, reason: 'rejection corpus');

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  test('fingerprint uses UPI ref when present', () {
    final withRef = TransactionParser.buildFingerprint(
      250.5,
      'SWIGGY',
      DateTime(2026, 5, 10, 11, 2),
      referenceNumber: '1234567890',
    );
    final withoutRef = TransactionParser.buildFingerprint(
      250.5,
      'SWIGGY',
      DateTime(2026, 5, 10, 11, 2),
    );
    expect(withRef, contains('1234567890'));
    expect(withoutRef, isNot(equals(withRef)));
  });
}
