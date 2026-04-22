import 'dart:math' show min;

import '../../data/models/transaction_model.dart';

/// Pure date-math helpers for recurring transactions.
///
/// Extracted from [RecurrenceService] so the logic can be unit-tested
/// without any Isar dependency.
class RecurrenceCalculator {
  const RecurrenceCalculator();

  /// Returns the next occurrence date after [from] for the given [type].
  ///
  /// [RecurrenceType.none] returns [from] unchanged.
  DateTime nextDate(DateTime from, RecurrenceType type) {
    return switch (type) {
      RecurrenceType.daily => from.add(const Duration(days: 1)),
      RecurrenceType.weekly => from.add(const Duration(days: 7)),
      RecurrenceType.monthly => addMonths(from, 1),
      RecurrenceType.yearly => addMonths(from, 12),
      RecurrenceType.none => from,
    };
  }

  /// Returns every occurrence date from the one after [lastDate] up to and
  /// including [today], in ascending order.
  ///
  /// Returns an empty list when no occurrences are due.
  List<DateTime> missedDates(
    DateTime lastDate,
    RecurrenceType type,
    DateTime today,
  ) {
    if (type == RecurrenceType.none) return [];
    final due = <DateTime>[];
    var candidate = nextDate(lastDate, type);
    while (!candidate.isAfter(today)) {
      due.add(candidate);
      candidate = nextDate(candidate, type);
    }
    return due;
  }

  /// Adds [months] to [date], clamping the day to the last valid day of the
  /// target month.
  ///
  /// Example: Jan 31 + 1 month → Feb 28 (or 29), not March 2/3.
  DateTime addMonths(DateTime date, int months) {
    var month = date.month + months;
    var year = date.year;
    while (month > 12) {
      month -= 12;
      year++;
    }
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, min(date.day, lastDay));
  }
}
