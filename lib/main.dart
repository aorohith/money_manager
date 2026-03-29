import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/isar_service.dart';
import 'features/budgets/data/models/budget_model.dart';
import 'features/transactions/data/models/account_model.dart';
import 'features/transactions/data/models/category_model.dart';
import 'features/transactions/data/models/transaction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarService.open([
    TransactionModelSchema,
    CategoryModelSchema,
    AccountModelSchema,
    BudgetModelSchema,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const App(),
    ),
  );
}
