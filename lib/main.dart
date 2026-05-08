import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/isar_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/sms/sms_ingestion_service.dart';
import 'features/budgets/data/models/budget_model.dart';
import 'features/goals/data/models/goal_model.dart';
import 'features/sms/data/models/sms_parsed_transaction.dart';
import 'features/sms/data/models/sms_raw_log_model.dart';
import 'features/sms/data/models/sms_rule_model.dart';
import 'features/sms/data/repositories/sms_repository.dart';
import 'features/transactions/data/models/account_model.dart';
import 'features/transactions/data/models/category_model.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/transactions/domain/services/recurrence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarService.open([
    TransactionModelSchema,
    CategoryModelSchema,
    AccountModelSchema,
    BudgetModelSchema,
    GoalModelSchema,
    SmsParsedTransactionSchema,
    SmsRuleModelSchema,
    SmsRawLogModelSchema,
  ]);

  await RecurrenceService(isar).processRecurringTransactions();
  await NotificationService.instance.initialize();

  // Wire up the MethodChannel handler for banking notification detection.
  final smsRepo = SmsRepository(isar);
  // Prune stale dedup fingerprints (>90 days) to prevent unbounded DB growth.
  unawaited(smsRepo.pruneOldFingerprints());
  SmsIngestionService(isar, smsRepo).initialize();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const App(),
    ),
  );
}
