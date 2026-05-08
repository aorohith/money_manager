import 'package:flutter/material.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';

class AccountResolver {
  const AccountResolver();

  Map<String, AccountModel> indexByName(List<AccountModel> accounts) {
    return {for (final account in accounts) normalize(account.name): account};
  }

  AccountModel buildImportedAccount(String name) {
    return AccountModel(
      name: name.trim(),
      iconCodePoint: Icons.account_balance_wallet_rounded.codePoint,
      colorValue: const Color(0xFF2563EB).toARGB32(),
      isDefault: false,
    );
  }

  static String normalize(String value) => value.trim().toLowerCase();
}
