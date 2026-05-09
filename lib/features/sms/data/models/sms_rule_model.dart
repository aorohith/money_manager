import 'package:isar/isar.dart';

part 'sms_rule_model.g.dart';

/// A user-confirmed merchant → category mapping.
///
/// After [useCount] reaches 3 for the same merchant + category pair,
/// [alwaysApply] is set automatically and future detections are silently
/// categorised without prompting.
@collection
class SmsRuleModel {
  SmsRuleModel({
    required this.merchantKey,
    required this.categoryId,
  })  : useCount = 1,
        alwaysApply = false,
        lastUsed = DateTime.now();

  Id id = Isar.autoIncrement;

  /// Uppercase-normalised merchant name, unique per collection.
  @Index(unique: true, replace: true)
  late String merchantKey;

  late int categoryId;

  late int useCount;

  /// When true the engine skips the confirmation prompt entirely.
  late bool alwaysApply;

  late DateTime lastUsed;

  /// Optional friendly display name set by the user (e.g. "My Gym").
  String? userAlias;
}
