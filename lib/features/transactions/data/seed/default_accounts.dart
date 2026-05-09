import 'package:flutter/material.dart';

import '../models/account_model.dart';

List<AccountModel> get defaultAccounts => [
      AccountModel(
        name: 'Cash',
        iconCodePoint: Icons.payments_rounded.codePoint,
        colorValue: const Color(0xFF1B8A4D).toARGB32(),
        initialBalance: 0,
        isDefault: true,
      ),
      AccountModel(
        name: 'Bank Account',
        iconCodePoint: Icons.account_balance_rounded.codePoint,
        colorValue: const Color(0xFF2563EB).toARGB32(),
        initialBalance: 0,
        isDefault: false,
      ),
      AccountModel(
        name: 'Credit Card',
        iconCodePoint: Icons.credit_card_rounded.codePoint,
        colorValue: const Color(0xFF9C27B0).toARGB32(),
        initialBalance: 0,
        isDefault: false,
      ),
    ];
