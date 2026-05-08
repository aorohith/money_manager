import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/isar_service.dart';
import '../../data/models/sms_parsed_transaction.dart';
import '../../data/models/sms_rule_model.dart';
import '../../data/repositories/sms_repository.dart';
import '../models/sms_settings.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final smsRepositoryProvider = Provider<SmsRepository>((ref) {
  final isar = ref.read(isarProvider);
  return SmsRepository(isar);
});

// ── Pending queue (live stream) ───────────────────────────────────────────────

final smsPendingProvider =
    StreamProvider<List<SmsParsedTransaction>>((ref) {
  return ref.read(smsRepositoryProvider).watchPending();
});

/// Badge count — number of pending SMS transactions awaiting review.
final smsPendingCountProvider = Provider<int>((ref) {
  return ref.watch(smsPendingProvider).maybeWhen(
        data: (list) => list.length,
        orElse: () => 0,
      );
});

// ── Merchant rules ────────────────────────────────────────────────────────────

final smsRulesProvider = StreamProvider<List<SmsRuleModel>>((ref) {
  return ref.read(smsRepositoryProvider).watchAllRules();
});

// ── Settings ──────────────────────────────────────────────────────────────────

class SmsSettingsNotifier extends AsyncNotifier<SmsSettings> {
  @override
  Future<SmsSettings> build() {
    return ref.read(smsRepositoryProvider).loadSettings();
  }

  Future<void> save(SmsSettings settings) async {
    try {
      await ref.read(smsRepositoryProvider).saveSettings(settings);
      state = AsyncData(settings);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setEnabled(bool v) async =>
      save((state.valueOrNull ?? const SmsSettings()).copyWith(enabled: v));

  Future<void> setAutoAddMode(SmsAutoAddMode v) async => save(
      (state.valueOrNull ?? const SmsSettings()).copyWith(autoAddMode: v));

  Future<void> setConfidenceThreshold(int v) async => save(
      (state.valueOrNull ?? const SmsSettings())
          .copyWith(confidenceThreshold: v));

  Future<void> setDetectSubscriptions(bool v) async => save(
      (state.valueOrNull ?? const SmsSettings())
          .copyWith(detectSubscriptions: v));

  Future<void> setDetectRefunds(bool v) async => save(
      (state.valueOrNull ?? const SmsSettings()).copyWith(detectRefunds: v));
}

final smsSettingsProvider =
    AsyncNotifierProvider<SmsSettingsNotifier, SmsSettings>(
        SmsSettingsNotifier.new);

// ── Notification-listener permission ─────────────────────────────────────────

const _smsChannel = MethodChannel('com.example.money_manager/sms');

final smsPermissionProvider = FutureProvider.autoDispose<bool>((ref) async {
  try {
    return await _smsChannel
            .invokeMethod<bool>('isNotificationListenerEnabled') ??
        false;
  } on PlatformException {
    return false;
  }
});
