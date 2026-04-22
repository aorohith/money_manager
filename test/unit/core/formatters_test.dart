import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/utils/formatters.dart';

void main() {
  group('AppFormatters.currency', () {
    test('formats whole number with two decimals', () {
      expect(AppFormatters.currency(1000, '\$'), '\$1,000.00');
    });

    test('formats fractional amount', () {
      expect(AppFormatters.currency(99.5, '\$'), '\$99.50');
    });

    test('formats zero', () {
      expect(AppFormatters.currency(0, '\$'), '\$0.00');
    });

    test('uses provided currency symbol', () {
      expect(AppFormatters.currency(500, '₹'), '₹500.00');
      expect(AppFormatters.currency(500, '€'), '€500.00');
    });

    test('formats large amount with thousands separator', () {
      expect(AppFormatters.currency(1234567.89, '\$'), '\$1,234,567.89');
    });

    test('rounds to 2 decimal places', () {
      expect(AppFormatters.currency(1.999, '\$'), '\$2.00');
    });
  });

  group('AppFormatters.shortDate', () {
    test('formats a known date correctly', () {
      final date = DateTime(2024, 3, 15);
      expect(AppFormatters.shortDate(date), 'Mar 15, 2024');
    });

    test('formats single-digit day without padding', () {
      final date = DateTime(2024, 1, 5);
      expect(AppFormatters.shortDate(date), 'Jan 5, 2024');
    });

    test('formats December correctly', () {
      final date = DateTime(2024, 12, 31);
      expect(AppFormatters.shortDate(date), 'Dec 31, 2024');
    });
  });

  group('AppFormatters.monthYear', () {
    test('returns full month name and year', () {
      final date = DateTime(2024, 6, 15);
      expect(AppFormatters.monthYear(date), 'June 2024');
    });

    test('January is formatted correctly', () {
      final date = DateTime(2024, 1, 1);
      expect(AppFormatters.monthYear(date), 'January 2024');
    });
  });

  group('AppFormatters.groupDate', () {
    test('"Today" for today\'s date', () {
      final today = DateTime.now();
      final d = DateTime(today.year, today.month, today.day);
      expect(AppFormatters.groupDate(d), 'Today');
    });

    test('"Yesterday" for yesterday\'s date', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final d = DateTime(yesterday.year, yesterday.month, yesterday.day);
      expect(AppFormatters.groupDate(d), 'Yesterday');
    });

    test('returns weekday name for 2-6 days ago', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final d = DateTime(
          threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day);
      final result = AppFormatters.groupDate(d);
      // Should be a day name (e.g. "Monday"), not "Today" or "Yesterday"
      const dayNames = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday', 'Sunday'
      ];
      expect(dayNames, contains(result));
    });

    test('returns long date format for 7+ days ago', () {
      final oldDate = DateTime(2020, 5, 15);
      expect(AppFormatters.groupDate(oldDate), 'May 15, 2020');
    });
  });
}
