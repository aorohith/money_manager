import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/sms/sms_auto_add_policy.dart';
import 'package:money_manager/core/sms/transaction_parser.dart';
import 'package:money_manager/features/sms/data/models/sms_rule_model.dart';
import 'package:money_manager/features/sms/domain/models/sms_settings.dart';

void main() {
  final validParsed = ParsedSmsData(
    amount: 100,
    merchantRaw: 'SWIGGY',
    merchantNormalized: 'SWIGGY',
    paymentMethod: 'UPI',
    transactionDate: DateTime(2026, 6, 4),
    direction: TransactionDirection.expense,
    directionConfidence: 0.95,
    directionSignals: 'debited',
  );

  final rule = SmsRuleModel(merchantKey: 'SWIGGY', categoryId: 1)
    ..alwaysApply = true;

  test('askAlways never auto-approves', () {
    expect(
      SmsAutoAddPolicy.shouldAutoApprove(
        settings: const SmsSettings(autoAddMode: SmsAutoAddMode.askAlways),
        parsed: validParsed,
        categoryConfidence: 1.0,
        userRule: rule,
      ),
      isFalse,
    );
  });

  test('autoAddKnown requires user rule', () {
    expect(
      SmsAutoAddPolicy.shouldAutoApprove(
        settings: const SmsSettings(
          autoAddMode: SmsAutoAddMode.autoAddKnown,
          confidenceThreshold: 75,
        ),
        parsed: validParsed,
        categoryConfidence: 0.9,
        userRule: rule,
      ),
      isTrue,
    );
    expect(
      SmsAutoAddPolicy.shouldAutoApprove(
        settings: const SmsSettings(
          autoAddMode: SmsAutoAddMode.autoAddKnown,
          confidenceThreshold: 75,
        ),
        parsed: validParsed,
        categoryConfidence: 0.9,
      ),
      isFalse,
    );
  });

  test('silentAll rejects unknown merchant', () {
    final unknown = ParsedSmsData(
      amount: 50,
      merchantRaw: 'Unknown Merchant',
      merchantNormalized: 'UNKNOWN MERCHANT',
      paymentMethod: 'Unknown',
      transactionDate: DateTime(2026, 1, 1),
      direction: TransactionDirection.expense,
      directionConfidence: 0.95,
      directionSignals: 'debited',
    );
    expect(
      SmsAutoAddPolicy.shouldAutoApprove(
        settings: const SmsSettings(
          autoAddMode: SmsAutoAddMode.silentAll,
          confidenceThreshold: 50,
        ),
        parsed: unknown,
        categoryConfidence: 0.95,
      ),
      isFalse,
    );
  });
}
