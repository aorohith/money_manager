import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/sms/transaction_parser.dart';

void main() {
  const parser = TransactionParser();

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
  });

  test('parses credit message as income', () {
    final parsed = parser.parse(
      'Rs. 1,500 credited to your account XX1234 via IMPS. Ref No 9876543210',
    );

    expect(parsed, isNotNull);
    expect(parsed!.amount, 1500.0);
    expect(parsed.isIncome, isTrue);
  });

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
