import 'package:flutter/material.dart';
import 'package:money_manager/features/goals/data/models/goal_model.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';

TransactionModel makeTx({
  int id = 0,
  double amount = 100.0,
  int categoryId = 1,
  int accountId = 1,
  DateTime? date,
  bool isIncome = false,
  String? note,
  RecurrenceType recurrence = RecurrenceType.none,
  bool isDeleted = false,
}) {
  final tx = TransactionModel(
    amount: amount,
    categoryId: categoryId,
    accountId: accountId,
    date: date ?? DateTime(2024, 1, 15),
    isIncome: isIncome,
    note: note,
    recurrence: recurrence,
    isDeleted: isDeleted,
  );
  tx.id = id;
  return tx;
}

CategoryModel makeCat({
  int id = 0,
  String name = 'Food',
  bool isIncome = false,
  bool isDefault = false,
  int iconCodePoint = 0xe25a,
  int colorValue = 0xFFFF6B6B,
}) {
  final cat = CategoryModel(
    name: name,
    iconCodePoint: iconCodePoint,
    colorValue: colorValue,
    isIncome: isIncome,
    isDefault: isDefault,
  );
  cat.id = id;
  return cat;
}

AccountModel makeAccount({
  int id = 0,
  String name = 'Cash',
  double initialBalance = 0.0,
  bool isDefault = false,
  int iconCodePoint = 0xe4c7,
  int colorValue = 0xFF0052FF,
}) {
  final acc = AccountModel(
    name: name,
    iconCodePoint: iconCodePoint,
    colorValue: colorValue,
    initialBalance: initialBalance,
    isDefault: isDefault,
  );
  acc.id = id;
  return acc;
}

GoalModel makeGoal({
  int id = 0,
  String name = 'Emergency Fund',
  double targetAmount = 1000.0,
  double currentAmount = 0.0,
  DateTime? deadline,
  bool isCompleted = false,
  String? notes,
}) {
  final goal = GoalModel(
    name: name,
    targetAmount: targetAmount,
    currentAmount: currentAmount,
    isCompleted: isCompleted,
    notes: notes,
  );
  goal.id = id;
  goal.deadline = deadline;
  return goal;
}

/// Returns a minimal set of expense categories (ids 1-4) useful for
/// CategorizationEngine tests.
List<CategoryModel> defaultTestCategories() => [
      makeCat(id: 1, name: 'Food', isIncome: false),
      makeCat(id: 2, name: 'Transport', isIncome: false),
      makeCat(id: 3, name: 'Other', isIncome: false),
      makeCat(id: 4, name: 'Salary', isIncome: true),
    ];
