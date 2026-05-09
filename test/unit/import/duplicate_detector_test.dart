import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/import/data/models/import_row.dart';
import 'package:money_manager/features/import/data/services/duplicate_detector.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('DuplicateDetector', () {
    test('detects matching expense fingerprint', () {
      final detector = DuplicateDetector();
      final existing = detector.existingFingerprints(
        transactions: [
          makeTx(
            id: 1,
            amount: 100,
            accountId: 1,
            categoryId: 1,
            note: 'Lunch',
            date: DateTime(2026, 5, 8),
          ),
        ],
        accounts: [makeAccount(id: 1, name: 'Main')],
        categories: [makeCat(id: 1, name: 'Food')],
      );
      final row = ExpenseImportRow(
        rowNumber: 2,
        date: DateTime(2026, 5, 8),
        categoryName: 'food',
        accountName: ' main ',
        amount: 100,
        currencyCode: 'INR',
        note: 'Lunch',
      );

      expect(detector.isDuplicate(row, existing), isTrue);
    });

    test('does not mark near-miss amount as duplicate', () {
      final detector = DuplicateDetector();
      final existing = {
        detector.fingerprint(
          date: DateTime(2026, 5, 8),
          amount: 100,
          accountName: 'Main',
          categoryName: 'Food',
          note: 'Lunch',
        ),
      };
      final row = ExpenseImportRow(
        rowNumber: 2,
        date: DateTime(2026, 5, 8),
        categoryName: 'Food',
        accountName: 'Main',
        amount: 101,
        currencyCode: 'INR',
        note: 'Lunch',
      );

      expect(detector.isDuplicate(row, existing), isFalse);
    });

    test('transfer rows produce outgoing and incoming fingerprints', () {
      final row = TransferImportRow(
        rowNumber: 2,
        date: DateTime(2026, 5, 9),
        outgoingAccountName: 'Main',
        incomingAccountName: 'Credit Card',
        amount: 500,
        currencyCode: 'INR',
      );

      expect(DuplicateDetector().fingerprintsFor(row), hasLength(2));
    });
  });
}
