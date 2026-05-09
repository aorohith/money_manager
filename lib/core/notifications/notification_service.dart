import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _budgetChannelId = 'budget_alerts';
  static const _budgetChannelName = 'Budget Alerts';

  static const _smsChannelId = 'sms_detections';
  static const _smsChannelName = 'Auto-Detected Expenses';

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Request Android 13+ notification permission
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showBudgetOverAlert({
    required int budgetId,
    required String budgetName,
    required double overBy,
    required String currencySymbol,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _budgetChannelId,
      _budgetChannelName,
      importance: Importance.high,
      priority: Priority.high,
      onlyAlertOnce: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      budgetId.abs() % 0x7FFFFFFF,
      'Budget Alert — $budgetName',
      'Over by $currencySymbol${overBy.toStringAsFixed(0)}',
      details,
    );
  }

  /// Shown when a banking notification is auto-detected and queued for review.
  Future<void> showSmsDetectedAlert({
    required String merchant,
    required double amount,
    required String categoryName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _smsChannelId,
      _smsChannelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      onlyAlertOnce: false,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    // Use merchant hashcode as ID so repeated detections from the same
    // merchant update the existing notification rather than stacking.
    await _plugin.show(
      merchant.hashCode.abs() % 0x7FFFFFFF,
      '₹${amount.toStringAsFixed(0)} detected — $merchant',
      'Added to review queue under $categoryName · Tap to review',
      details,
    );
  }
}
