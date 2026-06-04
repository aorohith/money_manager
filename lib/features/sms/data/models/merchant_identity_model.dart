import 'package:isar/isar.dart';

part 'merchant_identity_model.g.dart';

/// Persistent merchant profile that links name variants, UPI handles, and
/// account-number endings to a single identity and tracks per-category
/// frequency for smarter auto-suggestions.
@collection
class MerchantIdentityModel {
  Id id = Isar.autoIncrement;

  /// User-visible display name. Auto-derived from the first seen raw name;
  /// can be overridden by the user ([isUserNamed] = true).
  late String displayName;

  /// Primary normalised key (uppercase, non-alphanumeric stripped). Unique.
  @Index(unique: true, replace: true)
  late String canonicalKey;

  /// All normalised name variants seen for this merchant (superset of
  /// [canonicalKey]). Indexed so Isar can do element-level lookups.
  @Index()
  List<String> nameAliases = [];

  /// UPI VPA handles linked to this merchant, e.g. "swiggy@icici",
  /// "9562802757@superyes". Populated when the SMS carries a VPA token.
  @Index()
  List<String> upiHandles = [];

  /// Category frequency stored as "categoryId:count" strings (e.g. "3:5").
  /// Isar cannot index Map<int,int> so we encode manually.
  List<String> categoryScores = [];

  /// Highest-scoring category id for fast access during ingestion.
  int? topCategoryId;

  /// Score of the current top category (used to compute confidence tier).
  int topCategoryScore = 0;

  late int totalTransactions;
  late DateTime lastSeen;
  late DateTime createdAt;

  /// True when the user has explicitly set [displayName] via the UI.
  bool isUserNamed = false;
}
