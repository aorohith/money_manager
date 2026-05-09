import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/import/data/services/account_resolver.dart';
import 'package:money_manager/features/import/data/services/category_resolver.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('AccountResolver', () {
    test('indexes accounts by case-insensitive name', () {
      final index = const AccountResolver().indexByName([
        makeAccount(id: 1, name: 'Main'),
      ]);

      expect(index[AccountResolver.normalize(' main ')]?.id, 1);
    });

    test('builds imported accounts as non-default accounts', () {
      final account = const AccountResolver().buildImportedAccount(
        'HDFC Credit Card',
      );

      expect(account.name, 'HDFC Credit Card');
      expect(account.isDefault, isFalse);
    });
  });

  group('CategoryResolver', () {
    test('indexes categories by income type', () {
      final resolver = const CategoryResolver();
      final categories = [
        makeCat(id: 1, name: 'Other', isIncome: false),
        makeCat(id: 2, name: 'Other', isIncome: true),
      ];

      expect(resolver.indexByName(categories, isIncome: false)['other']?.id, 1);
      expect(resolver.indexByName(categories, isIncome: true)['other']?.id, 2);
    });

    test('builds imported income category', () {
      final category = const CategoryResolver().buildImportedCategory(
        'Cashback',
        isIncome: true,
      );

      expect(category.name, 'Cashback');
      expect(category.isIncome, isTrue);
      expect(category.isDefault, isFalse);
    });
  });
}
