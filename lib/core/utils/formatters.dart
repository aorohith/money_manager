import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String currency(double amount, String symbol) {
    final f = NumberFormat('#,##0.00');
    return '$symbol${f.format(amount)}';
  }

  static String shortDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  static String groupDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMMM d, yyyy').format(date);
  }

  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);
}
