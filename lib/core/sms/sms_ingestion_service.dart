import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:money_manager/core/constants/constants.dart';

import '../../features/sms/data/models/sms_parsed_transaction.dart';
import '../../features/sms/data/repositories/sms_repository.dart';
import '../../features/transactions/data/models/account_model.dart';
import '../../features/transactions/data/models/category_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../notifications/notification_service.dart';
import 'categorization_engine.dart';
import 'merchant_resolver.dart';
import 'sms_account_resolver.dart';
import 'sms_auto_add_policy.dart';
import 'transaction_parser.dart';

/// Coordinates the full SMS ingestion pipeline:
/// notification arrives → validate → parse → dedup → categorise → save → notify.
///
/// Initialised once in [main] and kept alive for the app's lifetime.
class SmsIngestionService {
  SmsIngestionService(this._isar, this._repo);

  final Isar _isar;
  final SmsRepository _repo;

  static const _channel = MethodChannel(AppConfig.smsMethodChannel);
  static const _parser = TransactionParser.instance;
  static const _categorizer = CategorizationEngine();

  late final MerchantResolver _resolver = MerchantResolver(_isar);

  static const _rateLimit = 20;
  static const _rateWindowMs = 60000;
  final _recentTimestamps = <int>[];

  void initialize() {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  static Future<bool> isNotificationListenerEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isNotificationListenerEnabled',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } on PlatformException {
      // ignore if not available (iOS, etc.)
    }
  }

  static Future<int> syncActiveNotifications() async {
    try {
      return await _channel.invokeMethod<int>('syncActiveNotifications') ?? 0;
    } on PlatformException {
      return 0;
    }
  }

  Future<SmsSyncResult> syncInbox({int limit = 250}) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'syncSmsInbox',
        {'limit': limit},
      );
      final granted = result?['granted'] as bool? ?? false;
      final rawMessages = result?['messages'] as List<dynamic>? ?? const [];
      if (!granted) {
        return const SmsSyncResult(permissionGranted: false);
      }

      // TEMP: dump every inbox row returned by the device (remove when done debugging).
      print('[SMS sync] fetched ${rawMessages.length} message(s) from device');
      for (var i = 0; i < rawMessages.length; i++) {
        final m = Map<String, dynamic>.from(rawMessages[i] as Map);
        print(
          '[SMS sync ${i + 1}/${rawMessages.length}] '
          'sender=${m['sender']} | '
          'title=${m['title']} | '
          'body=${m['body']} | '
          'timestamp=${m['timestamp']}',
        );
      }

      var queued = 0;
      for (final raw in rawMessages) {
        final message = Map<String, dynamic>.from(raw as Map);
        final processed = await _processNotification(
          sender: message['sender'] as String? ?? '',
          title: message['title'] as String? ?? '',
          body: message['body'] as String? ?? '',
          date: DateTime.fromMillisecondsSinceEpoch(
            message['timestamp'] as int? ??
                DateTime.now().millisecondsSinceEpoch,
          ),
          bypassRateLimit: true,
          showDetectedNotification: false,
        );
        if (processed) queued++;
      }

      return SmsSyncResult(
        permissionGranted: true,
        scannedMessages: rawMessages.length,
        queuedTransactions: queued,
      );
    } on PlatformException {
      return const SmsSyncResult(permissionGranted: false);
    }
  }

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
      isIncome: pending.isIncome,
      note: note ?? pending.merchantRaw,
    );
    final txId = await _repo.approveTransaction(
      smsId: pending.id,
      tx: tx,
      merchantKey: pending.merchantNormalized,
      categoryId: categoryId,
    );
    if (pending.merchantIdentityId != null) {
      await _resolver.recordCategoryChoice(
        pending.merchantIdentityId!,
        categoryId,
      );
    }
    return txId;
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationReceived':
        final args = Map<String, dynamic>.from(call.arguments as Map);
        final sender = args['sender'] as String? ?? '';
        final title = args['title'] as String? ?? '';
        final body = args['body'] as String? ?? '';
        final timestamp =
            args['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;

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
            return false;
          }),
        );
      default:
        break;
    }
    return null;
  }

  Future<bool> _processNotification({
    required String sender,
    required String title,
    required String body,
    required DateTime date,
    bool bypassRateLimit = false,
    bool showDetectedNotification = true,
  }) async {
    if (!bypassRateLimit && _isRateLimited()) {
      log('SmsIngestionService: rate limit exceeded, dropping notification');
      return false;
    }

    if (sender.length < 2 || RegExp(r'^\d+$').hasMatch(sender)) {
      log(
        'SmsIngestionService: rejected notification from invalid sender "$sender"',
      );
      return false;
    }

    final fullText = '$title $body'.trim();
    final settings = await _repo.loadSettings();
    if (!settings.enabled) return false;

    final parsed = _parser.parse(
      fullText,
      overrideDate: date,
      detectRefunds: settings.detectRefunds,
      detectSubscriptions: settings.detectSubscriptions,
    );
    if (parsed == null) return false;

    final fingerprint = TransactionParser.buildFingerprint(
      parsed.amount,
      parsed.merchantNormalized,
      date,
      referenceNumber: parsed.referenceNumber,
    );
    final isNew = await _repo.logFingerprintIfNew(fingerprint, sender);
    if (!isNew) return false;

    final userRule = await _repo.findRule(parsed.merchantNormalized);
    final categories = await _isar.categoryModels.where().findAll();

    // Resolve merchant identity — links name variants and UPI handles across
    // different bank messages to a single profile, enabling learned suggestions.
    final resolveResult = await _resolver.resolve(
      canonicalKey: parsed.merchantNormalized,
      displayName: parsed.merchantRaw,
      vpa: parsed.counterpartyVpa,
    );

    final result = _categorizer.categorize(
      parsed.merchantNormalized,
      categories,
      userRule: userRule,
      merchantIdentity: resolveResult.identity,
      isIncome: parsed.isIncome,
    );

    final safeText = TransactionParser.redactSensitive(fullText);

    final record = SmsParsedTransaction(
      amount: parsed.amount,
      merchantRaw: parsed.merchantRaw,
      merchantNormalized: parsed.merchantNormalized,
      transactionDate: parsed.transactionDate,
      paymentMethod: parsed.paymentMethod,
      rawText: safeText,
      senderAddress: sender,
      accountHint: parsed.accountHint,
      availableBalance: parsed.availableBalance,
      referenceNumber: parsed.referenceNumber,
      suggestedCategoryId: result.categoryId,
      confidence: result.confidence,
      isIncome: parsed.isIncome,
      directionConfidence: parsed.directionConfidence,
      directionSignals: parsed.directionSignals,
      merchantExtractionSource: parsed.merchantExtractionSource?.name,
      counterpartyType: parsed.counterpartyType,
      isRecurring: parsed.isRecurring,
      merchantIdentityId: resolveResult.identity.id,
      counterpartyVpa: parsed.counterpartyVpa,
    );

    final autoApprove = SmsAutoAddPolicy.shouldAutoApprove(
      settings: settings,
      parsed: parsed,
      categoryConfidence: result.confidence,
      userRule: userRule,
    );

    if (autoApprove) {
      final accounts = await _isar.accountModels.where().findAll();
      final account = SmsAccountResolver.resolve(
        accounts: accounts,
        accountHint: parsed.accountHint,
      );
      if (account != null) {
        final smsId = await _repo.addParsedTransaction(record);
        await _repo.approveTransaction(
          smsId: smsId,
          tx: TransactionModel(
            amount: record.amount,
            categoryId: result.categoryId,
            accountId: account.id,
            date: record.transactionDate,
            isIncome: record.isIncome,
            note: record.merchantRaw,
          ),
          merchantKey: parsed.merchantNormalized,
          categoryId: result.categoryId,
          alwaysApply: userRule != null,
        );
        await _resolver.recordCategoryChoice(
          resolveResult.identity.id,
          result.categoryId,
        );
        if (showDetectedNotification) {
          final cat = categories
              .where((c) => c.id == result.categoryId)
              .firstOrNull;
          unawaited(
            NotificationService.instance.showSmsDetectedAlert(
              merchant: '${parsed.merchantNormalized} (saved)',
              amount: parsed.amount,
              categoryName: cat?.name ?? 'Uncategorised',
            ),
          );
        }
        return true;
      }
    }

    await _repo.addParsedTransaction(record);

    if (!showDetectedNotification) return true;
    final cat = categories.where((c) => c.id == result.categoryId).firstOrNull;
    unawaited(
      NotificationService.instance.showSmsDetectedAlert(
        merchant: parsed.merchantNormalized,
        amount: parsed.amount,
        categoryName: cat?.name ?? 'Uncategorised',
      ),
    );
    return true;
  }

  bool _isRateLimited() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _recentTimestamps.removeWhere((t) => now - t > _rateWindowMs);
    if (_recentTimestamps.length >= _rateLimit) return true;
    _recentTimestamps.add(now);
    return false;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}

class SmsSyncResult {
  const SmsSyncResult({
    required this.permissionGranted,
    this.scannedMessages = 0,
    this.queuedTransactions = 0,
  });

  final bool permissionGranted;
  final int scannedMessages;
  final int queuedTransactions;
}
