import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/analytics/domain/providers/analytics_providers.dart';

void main() {
  // ── periodRange ────────────────────────────────────────────────────────────

  group('periodRange', () {
    test('day range spans 24 hours', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.day,
        referenceDate: DateTime(2024, 6, 15),
      );
      final (from, to) = periodRange(params);
      expect(from, DateTime(2024, 6, 15));
      expect(to, DateTime(2024, 6, 16));
    });

    test('week starts on Monday', () {
      // June 12, 2024 is a Wednesday (weekday == 3)
      final params = AnalyticsParams(
        period: AnalyticsPeriod.week,
        referenceDate: DateTime(2024, 6, 12),
      );
      final (from, to) = periodRange(params);
      expect(from, DateTime(2024, 6, 10)); // Monday
      expect(to, DateTime(2024, 6, 17)); // following Monday
    });

    test('month range covers whole month', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 2, 15),
      );
      final (from, to) = periodRange(params);
      expect(from, DateTime(2024, 2, 1));
      expect(to, DateTime(2024, 3, 1));
    });

    test('year range covers whole year', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.year,
        referenceDate: DateTime(2024, 6, 15),
      );
      final (from, to) = periodRange(params);
      expect(from, DateTime(2024, 1, 1));
      expect(to, DateTime(2025, 1, 1));
    });
  });

  // ── periodLabel ────────────────────────────────────────────────────────────

  group('periodLabel', () {
    test('day label includes weekday, month, day', () {
      // June 15, 2024 = Saturday
      final params = AnalyticsParams(
        period: AnalyticsPeriod.day,
        referenceDate: DateTime(2024, 6, 15),
      );
      final label = periodLabel(params);
      expect(label, contains('Jun'));
      expect(label, contains('15'));
    });

    test('month label includes full month and year', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 3, 15),
      );
      expect(periodLabel(params), 'March 2024');
    });

    test('year label is just the year', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.year,
        referenceDate: DateTime(2024, 6, 15),
      );
      expect(periodLabel(params), '2024');
    });
  });

  // ── previousPeriod ─────────────────────────────────────────────────────────

  group('previousPeriod', () {
    test('previous day goes back 1 day', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.day,
        referenceDate: DateTime(2024, 6, 15),
      );
      final prev = previousPeriod(params);
      expect(prev.normalised, DateTime(2024, 6, 14));
    });

    test('previous week goes back 7 days', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.week,
        referenceDate: DateTime(2024, 6, 15),
      );
      final prev = previousPeriod(params);
      expect(prev.normalised, DateTime(2024, 6, 8));
    });

    test('previous month decrements month', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 6, 15),
      );
      final prev = previousPeriod(params);
      expect(prev.normalised, DateTime(2024, 5, 1));
    });

    test('previous month wraps from January to December of prior year', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 1, 15),
      );
      final prev = previousPeriod(params);
      expect(prev.normalised, DateTime(2023, 12, 1));
    });

    test('previous year decrements year', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.year,
        referenceDate: DateTime(2024, 6, 15),
      );
      final prev = previousPeriod(params);
      expect(prev.normalised, DateTime(2023, 1, 1));
    });
  });

  // ── nextPeriod ─────────────────────────────────────────────────────────────

  group('nextPeriod', () {
    test('next day advances 1 day', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.day,
        referenceDate: DateTime(2024, 6, 15),
      );
      expect(nextPeriod(params).normalised, DateTime(2024, 6, 16));
    });

    test('next week advances 7 days', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.week,
        referenceDate: DateTime(2024, 6, 15),
      );
      expect(nextPeriod(params).normalised, DateTime(2024, 6, 22));
    });

    test('next month advances month', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 6, 1),
      );
      expect(nextPeriod(params).normalised, DateTime(2024, 7, 1));
    });

    test('next year advances year', () {
      final params = AnalyticsParams(
        period: AnalyticsPeriod.year,
        referenceDate: DateTime(2024, 1, 1),
      );
      expect(nextPeriod(params).normalised, DateTime(2025, 1, 1));
    });
  });

  // ── AnalyticsParams equality ───────────────────────────────────────────────

  group('AnalyticsParams equality', () {
    test('same period + normalised date are equal', () {
      final a = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 3, 15, 10, 30),
      );
      final b = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 3, 15, 22, 0),
      );
      expect(a, b); // normalised to midnight, so equal
    });

    test('different period are not equal', () {
      final a = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 3, 15),
      );
      final b = AnalyticsParams(
        period: AnalyticsPeriod.year,
        referenceDate: DateTime(2024, 3, 15),
      );
      expect(a, isNot(b));
    });

    test('different date are not equal', () {
      final a = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 3, 15),
      );
      final b = AnalyticsParams(
        period: AnalyticsPeriod.month,
        referenceDate: DateTime(2024, 4, 15),
      );
      expect(a, isNot(b));
    });
  });
}
