import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/import/data/models/column_mapping.dart';
import 'package:money_manager/features/import/data/parsers/column_mapper.dart';

void main() {
  group('ColumnMapper', () {
    test('maps sample transaction headers to canonical columns', () {
      final mapping = const ColumnMapper().detect([
        'Date and time',
        'Category',
        'Account',
        'Amount in default currency',
        'Default currency',
        'Tags',
        'Comment',
      ]);

      expect(mapping.sourceFor(ImportColumn.date), 'Date and time');
      expect(mapping.sourceFor(ImportColumn.tags), 'Tags');
      expect(mapping.sourceFor(ImportColumn.comment), 'Comment');
    });

    test('maps sample transfer headers', () {
      final mapping = const ColumnMapper().detect([
        'Date and time',
        'Outgoing',
        'Incoming',
        'Amount in outgoing currency',
        'Outgoing currency',
      ]);

      expect(mapping.sourceFor(ImportColumn.outgoingAccount), 'Outgoing');
      expect(mapping.sourceFor(ImportColumn.incomingAccount), 'Incoming');
      expect(
        mapping.sourceFor(ImportColumn.outgoingAmount),
        'Amount in outgoing currency',
      );
    });
  });
}
