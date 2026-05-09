import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import '../../features/sms/data/models/sms_parsed_transaction.dart';
import '../../features/sms/data/repositories/sms_repository.dart';
import '../../features/transactions/data/models/category_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../notifications/notification_service.dart';
import 'categorization_engine.dart';
import 'transaction_parser.dart';

/// Coordinates the full SMS ingestion pipeline:
/// notification arrives → validate → parse → dedup → categorise → save → notify.
///
/// Initialised once in [main] and kept alive for the app's lifetime.
class SmsIngestionService {
  SmsIngestionService(this._isar, this._repo);

  final Isar _isar;
  final SmsRepository _repo;

  static const _channel = MethodChannel('com.example.money_manager/sms');
  static const _parser = TransactionParser.instance;
  static const _categorizer = CategorizationEngine();

  // ── Rate limiting ──────────────────────────────────────────────────────────
  // Max 20 notifications per 60-second sliding window.
  static const _rateLimit = 20;
  static const _rateWindowMs = 60000;
  final _recentTimestamps = <int>[];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Wires up the MethodChannel handler.
  /// Call once from [main], before [runApp].
  void initialize() {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  /// Returns true if the NotificationListenerService is enabled in settings.
  static Future<bool> isNotificationListenerEnabled() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isNotificationListenerEnabled');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Opens Android → Settings → Notification Access.
  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } on PlatformException {
      // ignore if not available (iOS, etc.)
    }
  }

  /// Approves a pending [SmsParsedTransaction] and saves it as a real
  /// [TransactionModel] with the selected [categoryId].
  ///
  /// Both writes are executed in a single Isar transaction so a crash
  /// between them can never leave data in an inconsistent state.
  Future<int> approve({
    required SmsParsedTransaction pending,
    required int categoryId,
    required int accountId,
    String? note,
  }) async {
    final tx = TransactionModel(
      amount: pending.amount,
      categoryId: categoryId,
      accountId: accountId,
      date: pending.transactionDate,
      isIncome: false,
      note: note ?? pending.merchantRaw,
    );
    return _repo.approveTransaction(smsId: pending.id, tx: tx);
  }

  // ── Platform ↔ Dart bridge ─────────────────────────────────────────────────

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationReceived':
        final args = Map<String, dynamic>.from(call.arguments as Map);
        final sender = args['sender'] as String? ?? '';
        final title = args['title'] as String? ?? '';
        final body = args['body'] as String? ?? '';
        final timestamp =
            args['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;

        // Fire-and-forget but log errors so data loss is never silent
        unawaited(
          _processNotification(
            sender: sender,
            title: title,
            body: body,
            date: DateTime.fromMillisecondsSinceEpoch(timestamp),
          ).catchError((Object e, StackTrace st) {
            log(
              'SmsIngestionService: failed to process notification '
              'from "$sender": $e',
              stackTrace: st,
            );
          }),
        );
      default:
        break;
    }
    return null;
  }

  // ── Internal pipeline ──────────────────────────────────────────────────────

  Future<void> _processNotification({
    required String sender,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    // ── Rate limit ─────────────────────────────────────────────────────────
    if (_isRateLimited()) {
      log('SmsIngestionService: rate limit exceeded, dropping notification');
      return;
    }

    // ── Sender sanity check ────────────────────────────────────────────────
    // Reject obviously invalid senders (empty, single char, pure numbers).
    // The Kotlin side already filters by trusted app packages; this is an
    // additional defence-in-depth layer.
    if (sender.length < 2 || RegExp(r'^\d+$').hasMatch(sender)) {
      log('SmsIngestionService: rejected notification from invalid sender "$sender"');
      return;
    }

    // ── Parse ──────────────────────────────────────────────────────────────
    final fullText = '$title $body'.trim();
    final parsed = _parser.parse(fullText, overrideDate: date);
    if (parsed == null) return; // Not a banking transaction

    // ── Atomic duplicate check + fingerprint log ───────────────────────────
    final fingerprint = TransactionParser.buildFingerprint(
        parsed.amount, parsed.merchantNormalized, date);
    final isNew = await _repo.logFingerprintIfNew(fingerprint, sender);
    if (!isNew) return; // Already processed this transaction

    // ── Fetch user rule (before categorization) ────────────────────────────
    final userRule = await _repo.findRule(parsed.merchantNormalized);

    // ── Categorise ─────────────────────────────────────────────────────────
    final categories = await _isar.categoryModels.where().findAll();
    final expenseCategories = categories.where((c) => !c.isIncome).toList();
    final result = _categorizer.categorize(
      parsed.merchantNormalized,
      expenseCategories,
      userRule: userRule,
    );

    // ── Redact sensitive data before storage ───────────────────────────────
    final safeText = TransactionParser.redactSensitive(fullText);

    // ── Save to pending queue ──────────────────────────────────────────────
    final record = SmsParsedTransaction(
      amount: parsed.amount,
      merchantRaw: parsed.merchantRaw,
      merchantNormalized: parsed.merchantNormalized,
      transactionDate: parsed.transactionDate,
      paymentMethod: parsed.paymentMethod,
      rawText: safeText, // never stores unredacted card/account numbers
      senderAddress: sender,
      accountHint: parsed.accountHint,
      availableBalance: parsed.availableBalance,
      referenceNumber: parsed.referenceNumber,
      suggestedCategoryId: result.categoryId,
      confidence: result.confidence,
    );
    await _repo.addParsedTransaction(record);

    // ── Show notification badge ────────────────────────────────────────────
    final cat = expenseCategories
        .where((c) => c.id == result.categoryId)
        .firstOrNull;
    unawaited(NotificationService.instance.showSmsDetectedAlert(
      merchant: parsed.merchantNormalized,
      amount: parsed.amount,
      categoryName: cat?.name ?? 'Uncategorised',
    ));
  }

  // ── Rate limiter ───────────────────────────────────────────────────────────

  bool _isRateLimited() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _recentTimestamps
        .removeWhere((t) => now - t > _rateWindowMs);
    if (_recentTimestamps.length >= _rateLimit) return true;
    _recentTimestamps.add(now);
    return false;
  }
}
