/// App-wide identifiers shared across platforms (Play Store, deep links, channels).
abstract final class AppConfig {
  static const String applicationId = 'com.rapps.moneymanager';

  /// Must match [SmsListenerService.CHANNEL_NAME] on Android.
  static const String smsMethodChannel = '$applicationId/sms';
}
