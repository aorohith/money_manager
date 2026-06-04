import 'package:isar/isar.dart';

import '../../features/sms/data/models/merchant_identity_model.dart';

/// How a merchant identity was matched.
enum MerchantMatchType { exact, alias, upiHandle, fuzzy, created }

/// Result of a [MerchantResolver.resolve] call.
class MerchantResolveResult {
  const MerchantResolveResult({
    required this.identity,
    required this.isNew,
    required this.matchType,
  });

  final MerchantIdentityModel identity;

  /// True when a new [MerchantIdentityModel] was just created.
  final bool isNew;

  final MerchantMatchType matchType;
}

/// Resolves a parsed merchant name + optional UPI VPA to a persistent
/// [MerchantIdentityModel], creating one when no match exists.
///
/// Match priority:
///   1. Exact canonical key
///   2. Key found in another identity's [nameAliases]
///   3. VPA found in another identity's [upiHandles]
///   4. Token-overlap fuzzy match (≥2 significant tokens in common)
///   5. Create new identity
///
/// After the user approves a transaction, call [recordCategoryChoice] so
/// the identity accumulates frequency data for smarter future suggestions.
class MerchantResolver {
  MerchantResolver(this._isar);

  final Isar _isar;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Finds or creates an identity for the given [canonicalKey].
  ///
  /// [displayName] is the human-readable merchant name (used when creating).
  /// [vpa] is the raw UPI VPA extracted from the SMS, e.g. "9562802757@superyes".
  Future<MerchantResolveResult> resolve({
    required String canonicalKey,
    required String displayName,
    String? vpa,
  }) async {
    if (canonicalKey.isEmpty || canonicalKey == 'UNKNOWN MERCHANT') {
      final identity = _buildNew(canonicalKey, displayName, vpa);
      final savedId = await _isar.writeTxn(
        () => _isar.merchantIdentityModels.put(identity),
      );
      identity.id = savedId;
      return MerchantResolveResult(
        identity: identity,
        isNew: true,
        matchType: MerchantMatchType.created,
      );
    }

    // 1. Exact canonical key
    var existing = await _isar.merchantIdentityModels
        .filter()
        .canonicalKeyEqualTo(canonicalKey)
        .findFirst();
    if (existing != null) {
      await _touch(existing, canonicalKey, vpa);
      return MerchantResolveResult(
        identity: existing,
        isNew: false,
        matchType: MerchantMatchType.exact,
      );
    }

    // 2. Name alias match
    existing = await _isar.merchantIdentityModels
        .filter()
        .nameAliasesElementEqualTo(canonicalKey)
        .findFirst();
    if (existing != null) {
      await _touch(existing, canonicalKey, vpa);
      return MerchantResolveResult(
        identity: existing,
        isNew: false,
        matchType: MerchantMatchType.alias,
      );
    }

    // 3. UPI handle match
    if (vpa != null && vpa.isNotEmpty) {
      existing = await _isar.merchantIdentityModels
          .filter()
          .upiHandlesElementEqualTo(vpa)
          .findFirst();
      if (existing != null) {
        await _touch(existing, canonicalKey, vpa);
        return MerchantResolveResult(
          identity: existing,
          isNew: false,
          matchType: MerchantMatchType.upiHandle,
        );
      }
    }

    // 4. Fuzzy token overlap — tolerable O(n) scan for personal-finance scale
    final myTokens = _significantTokens(canonicalKey);
    if (myTokens.length >= 2) {
      final all = await _isar.merchantIdentityModels.where().findAll();
      for (final candidate in all) {
        if (_tokenOverlap(myTokens, _significantTokens(candidate.canonicalKey)) >= 2) {
          await _touch(candidate, canonicalKey, vpa);
          return MerchantResolveResult(
            identity: candidate,
            isNew: false,
            matchType: MerchantMatchType.fuzzy,
          );
        }
        for (final alias in candidate.nameAliases) {
          if (_tokenOverlap(myTokens, _significantTokens(alias)) >= 2) {
            await _touch(candidate, canonicalKey, vpa);
            return MerchantResolveResult(
              identity: candidate,
              isNew: false,
              matchType: MerchantMatchType.fuzzy,
            );
          }
        }
      }
    }

    // 5. Create new
    final identity = _buildNew(canonicalKey, displayName, vpa);
    final savedId = await _isar.writeTxn(
      () => _isar.merchantIdentityModels.put(identity),
    );
    identity.id = savedId;
    return MerchantResolveResult(
      identity: identity,
      isNew: true,
      matchType: MerchantMatchType.created,
    );
  }

  /// Increments the [categoryId] score for [identityId] and recomputes top.
  Future<void> recordCategoryChoice(int identityId, int categoryId) async {
    await _isar.writeTxn(() async {
      final identity = await _isar.merchantIdentityModels.get(identityId);
      if (identity == null) return;
      _incrementScore(identity, categoryId);
      await _isar.merchantIdentityModels.put(identity);
    });
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  MerchantIdentityModel _buildNew(
    String canonicalKey,
    String displayName,
    String? vpa,
  ) {
    final now = DateTime.now();
    return MerchantIdentityModel()
      ..displayName = displayName.isEmpty ? canonicalKey : displayName
      ..canonicalKey = canonicalKey
      ..nameAliases = [if (canonicalKey.isNotEmpty) canonicalKey]
      ..upiHandles = [if (vpa != null && vpa.isNotEmpty) vpa]
      ..categoryScores = []
      ..topCategoryId = null
      ..topCategoryScore = 0
      ..totalTransactions = 1
      ..lastSeen = now
      ..createdAt = now
      ..isUserNamed = false;
  }

  Future<void> _touch(
    MerchantIdentityModel identity,
    String canonicalKey,
    String? vpa,
  ) async {
    if (canonicalKey.isNotEmpty &&
        !identity.nameAliases.contains(canonicalKey)) {
      identity.nameAliases = [...identity.nameAliases, canonicalKey];
    }
    if (vpa != null && vpa.isNotEmpty && !identity.upiHandles.contains(vpa)) {
      identity.upiHandles = [...identity.upiHandles, vpa];
    }
    identity.totalTransactions++;
    identity.lastSeen = DateTime.now();
    await _isar.writeTxn(() => _isar.merchantIdentityModels.put(identity));
  }

  static void _incrementScore(MerchantIdentityModel identity, int categoryId) {
    final key = '$categoryId';
    final scores = <String, int>{};
    for (final s in identity.categoryScores) {
      final idx = s.indexOf(':');
      if (idx < 0) continue;
      scores[s.substring(0, idx)] = int.tryParse(s.substring(idx + 1)) ?? 0;
    }
    scores[key] = (scores[key] ?? 0) + 1;
    identity.categoryScores =
        scores.entries.map((e) => '${e.key}:${e.value}').toList();

    var topKey = '';
    var topScore = 0;
    for (final e in scores.entries) {
      if (e.value > topScore) {
        topScore = e.value;
        topKey = e.key;
      }
    }
    identity.topCategoryId = topKey.isEmpty ? null : int.tryParse(topKey);
    identity.topCategoryScore = topScore;
  }

  static Set<String> _significantTokens(String key) =>
      key.split(RegExp(r'\s+')).where((t) => t.length >= 3).toSet();

  static int _tokenOverlap(Set<String> a, Set<String> b) =>
      a.intersection(b).length;
}
