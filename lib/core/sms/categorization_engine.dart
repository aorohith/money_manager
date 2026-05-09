import '../../features/transactions/data/models/category_model.dart';
import '../../features/sms/data/models/sms_rule_model.dart';
import 'merchant_database.dart';

class CategorizationResult {
  const CategorizationResult({
    required this.categoryId,
    required this.confidence,
    required this.source,
  });

  final int categoryId;

  /// 0.0 – 1.0. Below the user's threshold the confirmation UI is shown.
  final double confidence;

  final CategorizationSource source;
}

enum CategorizationSource { userRule, merchantDatabase, keyword, fallback }

/// Pure categorization engine — no repository dependency.
///
/// The caller is responsible for loading the user's [SmsRuleModel] and
/// passing it as [userRule]. This keeps the engine stateless and testable.
class CategorizationEngine {
  const CategorizationEngine();

  /// Returns the best guess for [merchantKey] given the available [categories].
  ///
  /// Priority:
  ///   1. [userRule]              (confidence 1.0 — always trusted)
  ///   2. Built-in merchant database  (confidence 0.90)
  ///   3. Keyword substring match     (confidence 0.65)
  ///   4. "Other" fallback            (confidence 0.30)
  CategorizationResult categorize(
    String merchantKey,
    List<CategoryModel> categories, {
    SmsRuleModel? userRule,
  }) {
    final expenseCategories =
        categories.where((c) => !c.isIncome).toList();

    // ── Tier 1: user rule ──────────────────────────────────────────────────
    if (userRule != null) {
      return CategorizationResult(
        categoryId: userRule.categoryId,
        confidence: 1.0,
        source: CategorizationSource.userRule,
      );
    }

    // ── Tier 2: built-in merchant database ─────────────────────────────────
    final dbCategoryName = _lookupMerchantDb(merchantKey);
    if (dbCategoryName != null) {
      final cat = _findByName(expenseCategories, dbCategoryName);
      if (cat != null) {
        return CategorizationResult(
          categoryId: cat.id,
          confidence: 0.90,
          source: CategorizationSource.merchantDatabase,
        );
      }
    }

    // ── Tier 3: keyword matching ───────────────────────────────────────────
    final keywordCategoryName = _lookupKeywords(merchantKey);
    if (keywordCategoryName != null) {
      final cat = _findByName(expenseCategories, keywordCategoryName);
      if (cat != null) {
        return CategorizationResult(
          categoryId: cat.id,
          confidence: 0.65,
          source: CategorizationSource.keyword,
        );
      }
    }

    // ── Tier 4: fallback to "Other" ────────────────────────────────────────
    final other = _findByName(expenseCategories, 'Other') ??
        expenseCategories.firstOrNull;
    return CategorizationResult(
      categoryId: other?.id ?? 0,
      confidence: 0.30,
      source: CategorizationSource.fallback,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  String? _lookupMerchantDb(String merchantKey) {
    // Exact match first
    if (kMerchantCategoryNames.containsKey(merchantKey)) {
      return kMerchantCategoryNames[merchantKey];
    }
    // Prefix / contains match
    for (final entry in kMerchantCategoryNames.entries) {
      if (merchantKey.contains(entry.key) || entry.key.contains(merchantKey)) {
        return entry.value;
      }
    }
    return null;
  }

  String? _lookupKeywords(String merchantKey) {
    final lower = merchantKey.toLowerCase();
    for (final entry in kKeywordCategoryNames.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  /// Finds a category by name, using exact → contains matching in that order.
  ///
  /// Avoids the fragile "split on first word" approach which caused false
  /// positives (e.g. "Other" matching "Other Expenses" unexpectedly).
  CategoryModel? _findByName(List<CategoryModel> cats, String name) {
    final lower = name.toLowerCase();

    // 1. Exact case-insensitive match
    final exact =
        cats.where((c) => c.name.toLowerCase() == lower).firstOrNull;
    if (exact != null) return exact;

    // 2. Category name contains the lookup string
    final catContains =
        cats.where((c) => c.name.toLowerCase().contains(lower)).firstOrNull;
    if (catContains != null) return catContains;

    // 3. Lookup string contains the category name
    // (e.g. lookup="Food & Dining", category="Food")
    final lookupContains =
        cats.where((c) => lower.contains(c.name.toLowerCase())).firstOrNull;
    return lookupContains;
  }
}
