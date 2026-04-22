import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/sms/categorization_engine.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/sms/data/models/sms_rule_model.dart';

import '../../helpers/test_factories.dart';

CategoryModel _cat(int id, String name, {bool isIncome = false}) =>
    makeCat(id: id, name: name, isIncome: isIncome);

void main() {
  const engine = CategorizationEngine();

  // Minimal category set that covers all categorization tiers
  final categories = [
    _cat(1, 'Food & Dining'),
    _cat(2, 'Shopping'),
    _cat(3, 'Transport'),
    _cat(4, 'Entertainment'),
    _cat(5, 'Other'),
    _cat(6, 'Salary', isIncome: true),
  ];

  // ── Tier 1: user rule ──────────────────────────────────────────────────────

  group('Tier 1 – user rule', () {
    test('user rule overrides everything with confidence 1.0', () {
      final rule = SmsRuleModel(merchantKey: 'SWIGGY', categoryId: 99);

      final result = engine.categorize('SWIGGY', categories, userRule: rule);

      expect(result.categoryId, 99);
      expect(result.confidence, 1.0);
      expect(result.source, CategorizationSource.userRule);
    });

    test('user rule with unknown merchant still wins', () {
      final rule = SmsRuleModel(merchantKey: 'UNKNOWN_MERCHANT', categoryId: 42);

      final result =
          engine.categorize('UNKNOWN_MERCHANT', categories, userRule: rule);
      expect(result.source, CategorizationSource.userRule);
    });
  });

  // ── Tier 2: merchant database ──────────────────────────────────────────────

  group('Tier 2 – merchant database', () {
    test('SWIGGY maps to Food & Dining with 0.90 confidence', () {
      final result = engine.categorize('SWIGGY', categories);
      expect(result.confidence, 0.90);
      expect(result.source, CategorizationSource.merchantDatabase);
      expect(result.categoryId, 1); // Food & Dining id
    });

    test('exact key match is preferred over substring', () {
      // ZOMATO is in the db — should get merchantDatabase source
      final result = engine.categorize('ZOMATO', categories);
      expect(result.source, CategorizationSource.merchantDatabase);
    });
  });

  // ── Tier 3: keyword matching ───────────────────────────────────────────────

  group('Tier 3 – keyword match', () {
    test('merchant containing "uber" falls back to keyword transport', () {
      // 'uber' keyword → Transport in kKeywordCategoryNames
      final result = engine.categorize('UBER EATS', categories);
      // Either merchantDb or keyword — just check it's not fallback
      expect(result.source, isNot(CategorizationSource.fallback));
    });

    test('unknown merchant with no keyword match uses fallback', () {
      final result =
          engine.categorize('XYZCOMPANY12345UNKNOWN', categories);
      expect(result.source, CategorizationSource.fallback);
      expect(result.confidence, 0.30);
    });
  });

  // ── Tier 4: fallback ───────────────────────────────────────────────────────

  group('Tier 4 – fallback', () {
    test('fallback confidence is 0.30', () {
      final result =
          engine.categorize('TOTALLY_UNKNOWN_VENDOR_XYZ', categories);
      expect(result.confidence, 0.30);
    });

    test('fallback picks "Other" category id', () {
      final result =
          engine.categorize('TOTALLY_UNKNOWN_VENDOR_XYZ', categories);
      expect(result.categoryId, 5); // id of 'Other'
    });

    test('fallback returns first expense cat when Other missing', () {
      final noCats = [_cat(10, 'Misc')];
      final result = engine.categorize('TOTALLY_UNKNOWN_VENDOR_XYZ', noCats);
      expect(result.categoryId, 10);
    });

    test('fallback categoryId is 0 when no expense cats exist', () {
      final result = engine.categorize('TOTALLY_UNKNOWN_VENDOR_XYZ', []);
      expect(result.categoryId, 0);
    });
  });

  // ── _findByName edge cases ─────────────────────────────────────────────────

  group('category name matching', () {
    test('case-insensitive exact match', () {
      final cats = [_cat(7, 'food & dining')];
      final result = engine.categorize('SWIGGY', cats);
      // SWIGGY maps to 'Food & Dining' in db; category name is lowercase
      expect(result.categoryId, 7);
    });

    test('income categories are excluded from expense matching', () {
      // All categories are income — fallback should return 0 or use expense-only
      final incomeCats = [_cat(8, 'Food & Dining', isIncome: true)];
      final result = engine.categorize('SWIGGY', incomeCats);
      // No expense categories → falls through to fallback with id=0
      expect(result.source, CategorizationSource.fallback);
    });
  });
}
