import 'package:flutter/material.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';

class CategoryResolver {
  const CategoryResolver();

  Map<String, CategoryModel> indexByName(
    List<CategoryModel> categories, {
    required bool isIncome,
  }) {
    return {
      for (final category in categories.where((c) => c.isIncome == isIncome))
        normalize(category.name): category,
    };
  }

  CategoryModel buildImportedCategory(String name, {required bool isIncome}) {
    return CategoryModel(
      name: name.trim(),
      iconCodePoint:
          (isIncome ? Icons.trending_up_rounded : Icons.category_rounded)
              .codePoint,
      colorValue: (isIncome ? const Color(0xFF1B8A4D) : const Color(0xFF78909C))
          .toARGB32(),
      isIncome: isIncome,
      isDefault: false,
    );
  }

  static String normalize(String value) => value.trim().toLowerCase();
}
