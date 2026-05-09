import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/core/database/isar_service.dart';
import 'package:money_manager/core/notifications/notification_service.dart';
import 'package:money_manager/core/sms/sms_ingestion_service.dart';
import 'package:money_manager/features/budgets/data/models/budget_model.dart';
import 'package:money_manager/features/goals/data/models/goal_model.dart';
import 'package:money_manager/features/sms/data/models/sms_parsed_transaction.dart';
import 'package:money_manager/features/sms/data/models/sms_raw_log_model.dart';
import 'package:money_manager/features/sms/data/models/sms_rule_model.dart';
import 'package:money_manager/features/sms/data/repositories/sms_repository.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/category_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';
import 'package:money_manager/features/transactions/domain/services/recurrence_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarService.open(<CollectionSchema<dynamic>>[
    TransactionModelSchema,
    CategoryModelSchema,
    AccountModelSchema,
    BudgetModelSchema,
    GoalModelSchema,
    SmsParsedTransactionSchema,
    SmsRuleModelSchema,
    SmsRawLogModelSchema,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const App(),
    ),
  );

  // After the first frame, run the background bootstrap that the user
  // doesn't need to wait for: recurrence catch-up, notifications init, SMS
  // wiring, and dedup-fingerprint pruning.
  SchedulerBinding.instance.addPostFrameCallback((_) {
    unawaited(_bootstrapBackground(isar));
  });
}

Future<void> _bootstrapBackground(Isar isar) async {
  try {
    await RecurrenceService(isar).processRecurringTransactions();
  } catch (_) {/* swallow — non-fatal */}
  try {
    await NotificationService.instance.initialize();
  } catch (_) {/* swallow — non-fatal */}
  try {
    final smsRepo = SmsRepository(isar);
    unawaited(smsRepo.pruneOldFingerprints());
    SmsIngestionService(isar, smsRepo).initialize();
  } catch (_) {/* swallow — non-fatal */}
}
