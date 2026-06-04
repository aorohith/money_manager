import '../../features/transactions/data/models/account_model.dart';

/// Resolves which user account to use when auto-adding an SMS transaction.
abstract final class SmsAccountResolver {
  static AccountModel? resolve({
    required List<AccountModel> accounts,
    String? accountHint,
  }) {
    if (accounts.isEmpty) return null;

    final digits = accountHint?.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits != null && digits.length >= 4) {
      final suffix = digits.substring(digits.length - 4);
      for (final a in accounts) {
        if (a.name.contains(suffix)) return a;
      }
    }

    for (final a in accounts) {
      if (a.isDefault) return a;
    }
    return accounts.first;
  }
}
