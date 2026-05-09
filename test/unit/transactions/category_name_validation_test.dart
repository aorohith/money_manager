import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/transactions/presentation/widgets/add_edit_category_sheet.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('isDuplicateCategoryName', () {
    final categories = [
      makeCat(id: 1, name: 'Food', isIncome: false),
      makeCat(id: 2, name: 'Salary', isIncome: true),
      makeCat(id: 3, name: 'Transport', isIncome: false),
    ];

    test('returns true for same type duplicate ignoring case/whitespace', () {
      final duplicated = isDuplicateCategoryName(
        candidate: '  food  ',
        categories: categories,
        isIncome: false,
      );

      expect(duplicated, isTrue);
    });

    test('returns false for same name in different transaction type', () {
      final duplicated = isDuplicateCategoryName(
        candidate: 'Salary',
        categories: categories,
        isIncome: false,
      );

      expect(duplicated, isFalse);
    });

    test('returns false when editing the same category id', () {
      final duplicated = isDuplicateCategoryName(
        candidate: 'Food',
        categories: categories,
        isIncome: false,
        excludeCategoryId: 1,
      );

      expect(duplicated, isFalse);
    });
  });
}
