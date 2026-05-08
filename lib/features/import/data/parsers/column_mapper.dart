import 'package:money_manager/features/import/data/models/column_mapping.dart';

class ColumnMapper {
  const ColumnMapper();

  static const Map<String, List<String>> _synonyms = {
    ImportColumn.date: ['date and time', 'date', 'transaction date'],
    ImportColumn.category: ['category', 'category name'],
    ImportColumn.account: ['account', 'wallet', 'payment account'],
    ImportColumn.defaultAmount: [
      'amount in default currency',
      'default amount',
      'amount',
    ],
    ImportColumn.defaultCurrency: ['default currency', 'currency'],
    ImportColumn.accountAmount: [
      'amount in account currency',
      'account amount',
    ],
    ImportColumn.accountCurrency: ['account currency'],
    ImportColumn.transactionAmount: [
      'transaction amount in transaction currency',
      'transaction amount',
      'original amount',
    ],
    ImportColumn.transactionCurrency: [
      'transaction currency',
      'original currency',
    ],
    ImportColumn.tags: ['tags', 'tag', 'labels'],
    ImportColumn.comment: ['comment', 'note', 'description', 'memo'],
    ImportColumn.outgoingAccount: ['outgoing', 'from', 'from account'],
    ImportColumn.incomingAccount: ['incoming', 'to', 'to account'],
    ImportColumn.outgoingAmount: [
      'amount in outgoing currency',
      'outgoing amount',
      'amount',
    ],
    ImportColumn.outgoingCurrency: ['outgoing currency'],
    ImportColumn.incomingAmount: [
      'amount in incoming currency',
      'incoming amount',
    ],
    ImportColumn.incomingCurrency: ['incoming currency'],
  };

  ColumnMapping detect(List<String> headers) {
    final normalizedHeaders = {
      for (final header in headers) _normalize(header): header,
    };
    final mapped = <String, String>{};

    for (final entry in _synonyms.entries) {
      for (final synonym in entry.value) {
        final source = normalizedHeaders[_normalize(synonym)];
        if (source != null) {
          mapped[entry.key] = source;
          break;
        }
      }
    }

    return ColumnMapping(columns: mapped);
  }

  static String normalizeHeader(String value) => _normalize(value);

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}
