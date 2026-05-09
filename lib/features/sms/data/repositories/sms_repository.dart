import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../transactions/data/models/transaction_model.dart';
import '../models/sms_parsed_transaction.dart';
import '../models/sms_raw_log_model.dart';
import '../models/sms_rule_model.dart';
import '../../domain/models/sms_settings.dart';

class SmsRepository {
  SmsRepository(this._isar);

  final Isar _isar;

  // ── SmsParsedTransaction ────────────────────────────────────────────────────

  /// Emits up to 50 most-recent pending transactions.
  /// Capped to prevent full-table loads on low-end devices.
  Stream<List<SmsParsedTransaction>> watchPending() {
    return _isar.smsParsedTransactions
        .filter()
        .statusEqualTo(SmsReviewStatus.pending)
        .sortByDetectedAtDesc()
        .limit(50)
        .watch(fireImmediately: true);
  }

  Future<List<SmsParsedTransaction>> getPending() {
    return _isar.smsParsedTransactions
        .filter()
        .statusEqualTo(SmsReviewStatus.pending)
        .sortByDetectedAtDesc()
        .limit(50)
        .findAll();
  }

  Future<int> addParsedTransaction(SmsParsedTransaction tx) async {
    return _isar.writeTxn(() => _isar.smsParsedTransactions.put(tx));
  }

  Future<void> updateStatus(int id, SmsReviewStatus status,
      {int? linkedTransactionId}) async {
    await _isar.writeTxn(() async {
      final tx = await _isar.smsParsedTransactions.get(id);
      if (tx == null) return;
      tx.status = status;
      tx.updatedAt = DateTime.now();
      if (linkedTransactionId != null) {
        tx.linkedTransactionId = linkedTransactionId;
      }
      // Drop the raw notification body once the user has acted on the row.
      // We keep merchant + amount for display but the full text is privacy
      // sensitive (account hints, balances, OTPs in noisy senders).
      if (status != SmsReviewStatus.pending) {
        tx.rawText = '';
      }
      await _isar.smsParsedTransactions.put(tx);
    });
  }

  /// Atomically saves a [TransactionModel], marks the SMS as approved, and
  /// optionally upserts a merchant rule — all inside a single Isar transaction.
  ///
  /// Returns the new transaction's id.
  Future<int> approveTransaction({
    required int smsId,
    required TransactionModel tx,
    String? merchantKey,
    int? categoryId,
    bool alwaysApply = false,
  }) async {
    return _isar.writeTxn(() async {
      // 1. Persist the real transaction
      final txId = await _isar.transactionModels.put(tx);

      // 2. Mark the SMS record as approved and drop its raw body.
      final sms = await _isar.smsParsedTransactions.get(smsId);
      if (sms != null) {
        sms.status = SmsReviewStatus.approved;
        sms.linkedTransactionId = txId;
        sms.rawText = '';
        sms.updatedAt = DateTime.now();
        await _isar.smsParsedTransactions.put(sms);
      }

      // 3. Upsert merchant rule when caller provides one
      if (merchantKey != null && categoryId != null) {
        await _upsertRuleInTxn(
          merchantKey: merchantKey,
          categoryId: categoryId,
          alwaysApply: alwaysApply,
        );
      }

      return txId;
    });
  }

  // ── TTL-style purge ─────────────────────────────────────────────────────────

  /// Purges historic parsed-SMS rows.
  ///
  /// * Reviewed rows (approved/skipped/duplicate) older than [reviewedTtl]
  ///   are hard-deleted — their content is no longer useful and keeping
  ///   redacted-but-still-personal merchant/amount data forever is bad
  ///   privacy hygiene.
  /// * Pending rows older than [pendingTtl] are also deleted; if the user
  ///   hasn't acted on a notification within a few months they almost
  ///   certainly won't.
  Future<void> pruneOldParsedTransactions({
    Duration reviewedTtl = const Duration(days: 30),
    Duration pendingTtl = const Duration(days: 90),
  }) async {
    final now = DateTime.now();
    final reviewedCutoff = now.subtract(reviewedTtl);
    final pendingCutoff = now.subtract(pendingTtl);

    await _isar.writeTxn(() async {
      final reviewed = await _isar.smsParsedTransactions
          .filter()
          .not()
          .statusEqualTo(SmsReviewStatus.pending)
          .updatedAtLessThan(reviewedCutoff)
          .findAll();
      final pending = await _isar.smsParsedTransactions
          .filter()
          .statusEqualTo(SmsReviewStatus.pending)
          .detectedAtLessThan(pendingCutoff)
          .findAll();

      final ids = <int>[
        ...reviewed.map((e) => e.id),
        ...pending.map((e) => e.id),
      ];
      if (ids.isNotEmpty) {
        await _isar.smsParsedTransactions.deleteAll(ids);
      }
    });
  }

  // ── SmsRuleModel ────────────────────────────────────────────────────────────

  Future<SmsRuleModel?> findRule(String merchantKey) async {
    return _isar.smsRuleModels
        .filter()
        .merchantKeyEqualTo(merchantKey)
        .findFirst();
  }

  Stream<List<SmsRuleModel>> watchAllRules() {
    return _isar.smsRuleModels.where().watch(fireImmediately: true);
  }

  Future<void> upsertRule({
    required String merchantKey,
    required int categoryId,
    required bool alwaysApply,
  }) async {
    await _isar.writeTxn(
      () => _upsertRuleInTxn(
        merchantKey: merchantKey,
        categoryId: categoryId,
        alwaysApply: alwaysApply,
      ),
    );
  }

  /// Must be called inside an active writeTxn.
  Future<void> _upsertRuleInTxn({
    required String merchantKey,
    required int categoryId,
    required bool alwaysApply,
  }) async {
    final existing = await _isar.smsRuleModels
        .filter()
        .merchantKeyEqualTo(merchantKey)
        .findFirst();
    if (existing != null) {
      existing.categoryId = categoryId;
      existing.useCount++;
      existing.alwaysApply = alwaysApply || existing.useCount >= 3;
      existing.lastUsed = DateTime.now();
      await _isar.smsRuleModels.put(existing);
    } else {
      final rule = SmsRuleModel(
        merchantKey: merchantKey,
        categoryId: categoryId,
      );
      rule.alwaysApply = alwaysApply;
      await _isar.smsRuleModels.put(rule);
    }
  }

  Future<void> deleteRule(int id) async {
    await _isar.writeTxn(() => _isar.smsRuleModels.delete(id));
  }

  // ── Duplicate detection ─────────────────────────────────────────────────────

  /// Atomically checks for a duplicate fingerprint and logs it if new.
  ///
  /// Returns **true** if the notification is new (and was logged).
  /// Returns **false** if a matching fingerprint already exists (duplicate).
  Future<bool> logFingerprintIfNew(String fingerprint, String sender) async {
    return _isar.writeTxn(() async {
      final existing = await _isar.smsRawLogModels
          .filter()
          .fingerprintEqualTo(fingerprint)
          .findFirst();
      if (existing != null) return false;
      await _isar.smsRawLogModels.put(
        SmsRawLogModel(fingerprint: fingerprint, senderAddress: sender),
      );
      return true;
    });
  }

  /// Deletes fingerprint log entries older than [maxAge] (default 90 days).
  /// Call once on app startup to prevent unbounded growth.
  Future<void> pruneOldFingerprints({
    Duration maxAge = const Duration(days: 90),
  }) async {
    final cutoff = DateTime.now().subtract(maxAge);
    await _isar.writeTxn(() async {
      final old = await _isar.smsRawLogModels
          .filter()
          .seenAtLessThan(cutoff)
          .findAll();
      if (old.isEmpty) return;
      await _isar.smsRawLogModels.deleteAll(old.map((e) => e.id).toList());
    });
  }

  // ── Settings ────────────────────────────────────────────────────────────────

  Future<SmsSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return SmsSettings.fromPrefs({
      'sms_enabled': prefs.getBool('sms_enabled'),
      'sms_auto_add_mode': prefs.getInt('sms_auto_add_mode'),
      'sms_confidence_threshold': prefs.getInt('sms_confidence_threshold'),
      'sms_detect_subscriptions': prefs.getBool('sms_detect_subscriptions'),
      'sms_detect_refunds': prefs.getBool('sms_detect_refunds'),
    });
  }

  Future<void> saveSettings(SmsSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final map = settings.toPrefs();
    for (final entry in map.entries) {
      final v = entry.value;
      if (v is bool) await prefs.setBool(entry.key, v);
      if (v is int) await prefs.setInt(entry.key, v);
      if (v is String) await prefs.setString(entry.key, v);
    }
  }
}
