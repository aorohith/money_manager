import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/transactions/domain/services/recurrence_calculator.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';

void main() {
  const calc = RecurrenceCalculator();

  // ── nextDate ───────────────────────────────────────────────────────────────

  group('nextDate', () {
    test('daily adds exactly 1 day', () {
      final from = DateTime(2024, 1, 15);
      expect(calc.nextDate(from, RecurrenceType.daily), DateTime(2024, 1, 16));
    });

    test('weekly adds exactly 7 days', () {
      final from = DateTime(2024, 1, 15);
      expect(calc.nextDate(from, RecurrenceType.weekly), DateTime(2024, 1, 22));
    });

    test('monthly adds 1 month same day', () {
      final from = DateTime(2024, 1, 15);
      expect(
        calc.nextDate(from, RecurrenceType.monthly),
        DateTime(2024, 2, 15),
      );
    });

    test('monthly clamps Jan 31 → Feb 29 on leap year', () {
      final from = DateTime(2024, 1, 31);
      expect(
        calc.nextDate(from, RecurrenceType.monthly),
        DateTime(2024, 2, 29),
      );
    });

    test('monthly clamps Jan 31 → Feb 28 on non-leap year', () {
      final from = DateTime(2023, 1, 31);
      expect(
        calc.nextDate(from, RecurrenceType.monthly),
        DateTime(2023, 2, 28),
      );
    });

    test('monthly wraps Dec → Jan of next year', () {
      final from = DateTime(2024, 12, 15);
      expect(
        calc.nextDate(from, RecurrenceType.monthly),
        DateTime(2025, 1, 15),
      );
    });

    test('yearly adds 12 months', () {
      final from = DateTime(2024, 1, 15);
      expect(calc.nextDate(from, RecurrenceType.yearly), DateTime(2025, 1, 15));
    });

    test('yearly on Feb 29 leap → Feb 28 non-leap', () {
      final from = DateTime(2024, 2, 29);
      expect(calc.nextDate(from, RecurrenceType.yearly), DateTime(2025, 2, 28));
    });

    test('none returns same date', () {
      final from = DateTime(2024, 3, 10);
      expect(calc.nextDate(from, RecurrenceType.none), from);
    });
  });

  // ── addMonths ──────────────────────────────────────────────────────────────

  group('addMonths', () {
    test('adds across year boundary', () {
      expect(calc.addMonths(DateTime(2023, 11, 15), 3), DateTime(2024, 2, 15));
    });

    test('clamps March 31 + 1 month → April 30', () {
      expect(calc.addMonths(DateTime(2024, 3, 31), 1), DateTime(2024, 4, 30));
    });

    test('adds 0 months returns same date', () {
      final d = DateTime(2024, 6, 15);
      expect(calc.addMonths(d, 0), d);
    });

    test('adds 12 months = 1 year', () {
      expect(calc.addMonths(DateTime(2024, 3, 15), 12), DateTime(2025, 3, 15));
    });
  });

  // ── missedDates ────────────────────────────────────────────────────────────

  group('missedDates', () {
    test('returns empty when today equals lastDate for daily', () {
      final d = DateTime(2024, 1, 15);
      expect(calc.missedDates(d, RecurrenceType.daily, d), isEmpty);
    });

    test('returns single entry for daily when 1 day has elapsed', () {
      final last = DateTime(2024, 1, 14);
      final today = DateTime(2024, 1, 15);
      final due = calc.missedDates(last, RecurrenceType.daily, today);
      expect(due, [DateTime(2024, 1, 15)]);
    });

    test('returns multiple entries for daily over 3 days', () {
      final last = DateTime(2024, 1, 10);
      final today = DateTime(2024, 1, 13);
      final due = calc.missedDates(last, RecurrenceType.daily, today);
      expect(due, [
        DateTime(2024, 1, 11),
        DateTime(2024, 1, 12),
        DateTime(2024, 1, 13),
      ]);
    });

    test('returns empty for none type', () {
      final d = DateTime(2024, 1, 1);
      expect(
        calc.missedDates(d, RecurrenceType.none, DateTime(2024, 12, 31)),
        isEmpty,
      );
    });

    test('weekly: 2 missed weeks', () {
      final last = DateTime(2024, 1, 1);
      final today = DateTime(2024, 1, 15);
      final due = calc.missedDates(last, RecurrenceType.weekly, today);
      expect(due, [DateTime(2024, 1, 8), DateTime(2024, 1, 15)]);
    });

    test('monthly: 3 missed months', () {
      final last = DateTime(2024, 1, 15);
      final today = DateTime(2024, 4, 15);
      final due = calc.missedDates(last, RecurrenceType.monthly, today);
      expect(due, [
        DateTime(2024, 2, 15),
        DateTime(2024, 3, 15),
        DateTime(2024, 4, 15),
      ]);
    });

    test('returns in ascending order', () {
      final last = DateTime(2024, 1, 1);
      final today = DateTime(2024, 1, 5);
      final due = calc.missedDates(last, RecurrenceType.daily, today);
      for (var i = 1; i < due.length; i++) {
        expect(due[i].isAfter(due[i - 1]), isTrue);
      }
    });

    test('does not include dates after today', () {
      final last = DateTime(2024, 1, 1);
      final today = DateTime(2024, 1, 3);
      final due = calc.missedDates(last, RecurrenceType.daily, today);
      expect(due.every((d) => !d.isAfter(today)), isTrue);
    });

    test('yearly: 2 missed years', () {
      final last = DateTime(2022, 6, 15);
      final today = DateTime(2024, 6, 15);
      final due = calc.missedDates(last, RecurrenceType.yearly, today);
      expect(due, [DateTime(2023, 6, 15), DateTime(2024, 6, 15)]);
    });
  });
}
