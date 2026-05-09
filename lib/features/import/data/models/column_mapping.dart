class ColumnMapping {
  const ColumnMapping({required this.columns});

  final Map<String, String> columns;

  String? sourceFor(String canonicalName) => columns[canonicalName];

  ColumnMapping merge(ColumnMapping? override) {
    if (override == null) return this;
    return ColumnMapping(columns: {...columns, ...override.columns});
  }
}

abstract final class ImportColumn {
  static const date = 'date';
  static const category = 'category';
  static const account = 'account';
  static const defaultAmount = 'defaultAmount';
  static const defaultCurrency = 'defaultCurrency';
  static const accountAmount = 'accountAmount';
  static const accountCurrency = 'accountCurrency';
  static const transactionAmount = 'transactionAmount';
  static const transactionCurrency = 'transactionCurrency';
  static const tags = 'tags';
  static const comment = 'comment';
  static const outgoingAccount = 'outgoingAccount';
  static const incomingAccount = 'incomingAccount';
  static const outgoingAmount = 'outgoingAmount';
  static const outgoingCurrency = 'outgoingCurrency';
  static const incomingAmount = 'incomingAmount';
  static const incomingCurrency = 'incomingCurrency';
}
