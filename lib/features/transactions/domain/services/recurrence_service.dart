import 'package:isar/isar.dart';

import '../../data/models/transaction_model.dart';
import 'recurrence_calculator.dart';

class RecurrenceService {
  RecurrenceService(this._isar);

  final Isar _isar;
  final _calc = const RecurrenceCalculator();

  /// On app startup, inspect every transaction with a recurrence rule.
  /// For each one, creates historical instances for any periods that have
  /// elapsed since the last recorded occurrence, then advances the template's
  /// date so the next run won't duplicate them.
  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final templates = await _isar.transactionModels
        .filter()
        .not()
        .recurrenceEqualTo(RecurrenceType.none)
        .isDeletedEqualTo(false)
        .findAll();

    for (final template in templates) {
      final lastOccurrence = DateTime(
        template.date.year,
        template.date.month,
        template.date.day,
      );

      final dueDates = _calc.missedDates(lastOccurrence, template.recurrence, today);
      if (dueDates.isEmpty) continue;

      await _isar.writeTxn(() async {
        for (final d in dueDates) {
          final instance = TransactionModel(
            amount: template.amount,
            categoryId: template.categoryId,
            accountId: template.accountId,
            date: d,
            isIncome: template.isIncome,
            note: template.note,
            recurrence: RecurrenceType.none,
          );
          await _isar.transactionModels.put(instance);
        }
        template.date = dueDates.last;
        await _isar.transactionModels.put(template);
      });
    }
  }
}
