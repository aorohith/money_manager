import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/sms/transaction_parser.dart';

void main() {
  const parser = TransactionParser();

  group('expense direction', () {
    final cases = <({String text, String? merchantContains})>[
      (
        text: 'A/C XX1234 debited Rs.500 at SWIGGY',
        merchantContains: 'SWIGGY',
      ),
      (
        text: 'Rs.100 sent to merchant@ybl via UPI',
        merchantContains: 'merchant',
      ),
      (
        text: 'INR 500 Dr from A/c **1234',
        merchantContains: null,
      ),
      (
        text: 'You paid Rs 250 to ZOMATO',
        merchantContains: 'ZOMATO',
      ),
      (
        text: 'Txn of Rs 999 debited from HDFC Bank Card **4321',
        merchantContains: null,
      ),
      (
        text:
            'INR 250.50 debited via UPI to Swiggy on 10-05. Avl Bal INR 1200.00 Ref No 1234567890',
        merchantContains: 'SWIGGY',
      ),
    ];

    for (final testCase in cases) {
      test('parses expense: ${testCase.text}', () {
        final parsed = parser.parse(testCase.text);
        expect(parsed, isNotNull, reason: testCase.text);
        expect(parsed!.isIncome, isFalse, reason: testCase.text);
        expect(parsed.direction, TransactionDirection.expense);
        expect(parsed.directionConfidence, greaterThanOrEqualTo(0.75));
        if (testCase.merchantContains != null) {
          expect(
            parsed.merchantRaw.toUpperCase(),
            contains(testCase.merchantContains!.toUpperCase()),
          );
        }
      });
    }
  });

  group('income direction', () {
    final cases = <String>[
      'Rs. 1,500 credited to your account XX1234 via IMPS. Ref No 9876543210',
      'Rs 200 received from JOHN@ybl',
      'INR 500 Cr to A/c **1234',
      'Salary of Rs 50000 credited',
    ];

    for (final text in cases) {
      test('parses income: $text', () {
        final parsed = parser.parse(text);
        expect(parsed, isNotNull, reason: text);
        expect(parsed!.isIncome, isTrue, reason: text);
        expect(parsed.direction, TransactionDirection.income);
        expect(parsed.directionConfidence, greaterThanOrEqualTo(0.75));
      });
    }
  });

  group('ambiguous direction', () {
    test('conflicting debit and credit resolve via proximity to amount', () {
      final parsed = parser.parse('Rs 500 debited and Rs 500 credited');
      expect(parsed, isNotNull);
      expect(parsed!.direction, TransactionDirection.expense);
      expect(parsed.directionConfidence, greaterThanOrEqualTo(0.70));
      expect(parsed.isIncome, isFalse);
    });

    test('refund-only message is ambiguous when detectRefunds is false', () {
      final parsed = parser.parse(
        'Rs 200 refunded to your XX1234 account',
        detectRefunds: false,
      );
      expect(parsed, isNotNull);
      expect(parsed!.direction, TransactionDirection.ambiguous);
      expect(parsed.directionConfidence, 0.30);
    });
  });

  group('rejections', () {
    test('rejects OTP messages', () {
      final parsed = parser.parse('Your OTP is 123456. Do not share with anyone');
      expect(parsed, isNull);
    });

    test('rejects failure/reversal messages', () {
      final parsed = parser.parse('Txn failed. INR 500 debit attempted via UPI');
      expect(parsed, isNull);
    });

    test('rejects message without debit/credit signal', () {
      final parsed = parser.parse('INR 700 available in your wallet');
      expect(parsed, isNull);
    });

    test('debit card phrase alone does not create direction', () {
      final parsed = parser.parse('Your Debit Card ending 4321 is active');
      expect(parsed, isNull);
    });
  });

  group('detectDirection', () {
    test('debit card payment method does not count as expense direction', () {
      final result = parser.detectDirection(
        'Rs 500 spent using Debit Card at AMAZON',
      );
      expect(result.direction, TransactionDirection.expense);
      expect(result.matchedSignals, isNot(contains('debit')));
    });

    test('payment received is income', () {
      final result = parser.detectDirection('Payment received Rs 100 from RAHUL');
      expect(result.direction, TransactionDirection.income);
    });

    test('payment made is expense', () {
      final result = parser.detectDirection('Payment made Rs 100 to SWIGGY');
      expect(result.direction, TransactionDirection.expense);
    });
  });

  test('parses debit UPI message with amount and merchant', () {
    final parsed = parser.parse(
      'INR 250.50 debited via UPI to Swiggy on 10-05. Avl Bal INR 1200.00 Ref No 1234567890',
      overrideDate: DateTime(2026, 5, 10, 10, 20),
    );

    expect(parsed, isNotNull);
    expect(parsed!.amount, 250.50);
    expect(parsed.merchantRaw.toUpperCase(), contains('SWIGGY'));
    expect(parsed.paymentMethod, 'UPI');
    expect(parsed.availableBalance, 1200.0);
    expect(parsed.referenceNumber, '1234567890');
    expect(parsed.isIncome, isFalse);
    expect(parsed.directionConfidence, greaterThanOrEqualTo(0.75));
  });

  test('parses credit message as income', () {
    final parsed = parser.parse(
      'Rs. 1,500 credited to your account XX1234 via IMPS. Ref No 9876543210',
    );

    expect(parsed, isNotNull);
    expect(parsed!.amount, 1500.0);
    expect(parsed.isIncome, isTrue);
    expect(parsed.directionConfidence, greaterThanOrEqualTo(0.75));
  });

  test('parses debited by Rs amount', () {
    final parsed = parser.parse(
      'Your a/c XX5678 debited by Rs 240 on 04-06-26',
    );
    expect(parsed, isNotNull);
    expect(parsed!.amount, 240);
    expect(parsed.isIncome, isFalse);
  });

  test('parses Beena Hotel from credited phrase', () {
    final parsed = parser.parse(
      'Your A/C XX5678 debited by Rs 240. Beena Hotel credited.',
    );
    expect(parsed, isNotNull);
    expect(parsed!.merchantNormalized, contains('BEENA'));
  });

  test('rejects bill-due-only SMS', () {
    expect(
      parser.parse(
        'Your A/C reflects Rs 500 due against bill dated 04-Mar-26',
      ),
      isNull,
    );
  });

  test('rejects internal transfer dual leg', () {
    expect(
      parser.parse(
        'Your a/c is debited for Rs.5000 and a/c credited (IMPS Ref 999)',
      ),
      isNull,
    );
  });

  test('buildFingerprint creates same value within same 5-minute window', () {
    final first = TransactionParser.buildFingerprint(
      100,
      'SWIGGY',
      DateTime(2026, 5, 10, 11, 2),
    );
    final second = TransactionParser.buildFingerprint(
      100,
      'SWIGGY',
      DateTime(2026, 5, 10, 11, 4),
    );
    final third = TransactionParser.buildFingerprint(
      100,
      'SWIGGY',
      DateTime(2026, 5, 10, 11, 6),
    );

    expect(first, equals(second));
    expect(third, isNot(equals(first)));
  });

  test('redactSensitive masks full card and account numbers', () {
    final redacted = TransactionParser.redactSensitive(
      'Card 1234 5678 9012 3456 used. Account 123456789012 debited.',
    );
    expect(redacted, contains('XXXX-XXXX-XXXX-XXXX'));
    expect(redacted, contains('XX9012'));
    expect(redacted, isNot(contains('123456789012')));
  });
}
