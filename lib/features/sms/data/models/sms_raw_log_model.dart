import 'package:isar/isar.dart';

part 'sms_raw_log_model.g.dart';

/// Lightweight fingerprint store used for duplicate detection.
///
/// Stores a string key derived from (amount, merchant, 5-minute time window)
/// rather than the full notification body, so it is privacy-safe.
@collection
class SmsRawLogModel {
  SmsRawLogModel({
    required this.fingerprint,
    required this.senderAddress,
  });

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String fingerprint;

  DateTime seenAt = DateTime.now();
  late String senderAddress;
}
