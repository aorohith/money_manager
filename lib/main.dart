import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  // Open the database before runApp because every screen's build path reads
  // from `isarProvider`. Everything else is deferred to a post-first-frame
  // task so the splash renders as quickly as possible.
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

Future<void> _bootstrapBackground(dynamic isar) async {
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
