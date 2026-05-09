import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware number / date formatters used throughout the app.
///
/// Every formatter accepts an optional [locale] tag; when omitted, the
/// helper resolves the active locale via [Localizations.localeOf] when a
/// [BuildContext] is supplied, otherwise it falls back to [Intl.getCurrentLocale].
class AppFormatters {
  AppFormatters._();

  static String _resolveLocale({BuildContext? context, String? locale}) {
    if (locale != null && locale.isNotEmpty) return locale;
    if (context != null) {
      final l = Localizations.maybeLocaleOf(context);
      if (l != null) return l.toLanguageTag();
    }
    return Intl.getCurrentLocale();
  }

  static String currency(
    double amount,
    String symbol, {
    BuildContext? context,
    String? locale,
  }) {
    final f = NumberFormat(
      '#,##0.00',
      _resolveLocale(context: context, locale: locale),
    );
    return '$symbol${f.format(amount)}';
  }

  static String shortDate(
    DateTime date, {
    BuildContext? context,
    String? locale,
  }) =>
      DateFormat('MMM d, yyyy',
              _resolveLocale(context: context, locale: locale))
          .format(date);

  static String groupDate(
    DateTime date, {
    BuildContext? context,
    String? locale,
  }) {
    final loc = _resolveLocale(context: context, locale: locale);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE', loc).format(date);
    return DateFormat('MMMM d, yyyy', loc).format(date);
  }

  static String monthYear(
    DateTime date, {
    BuildContext? context,
    String? locale,
  }) =>
      DateFormat('MMMM yyyy',
              _resolveLocale(context: context, locale: locale))
          .format(date);
}
