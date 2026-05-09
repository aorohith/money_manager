import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/transactions/data/models/account_model.dart';
import 'package:money_manager/features/transactions/data/models/transaction_model.dart';
import 'package:money_manager/features/transactions/data/repositories/account_repository.dart';
import 'package:money_manager/features/transactions/data/repositories/transaction_repository.dart';
import 'package:money_manager/features/transactions/domain/providers/transaction_providers.dart';

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

void main() {
  late _MockAccountRepository accountRepo;
  late _MockTransactionRepository txRepo;
  late ProviderContainer container;
  late AccountModel account;

  setUpAll(() {
    registerFallbackValue(
      TransactionModel(
        amount: 0,
        categoryId: 0,
        accountId: 0,
        date: DateTime(2026, 1, 1),
        isIncome: false,
      ),
    );
    registerFallbackValue(
      AccountModel(name: 'fallback', iconCodePoint: 0, colorValue: 0),
    );
  });

  setUp(() {
    accountRepo = _MockAccountRepository();
    txRepo = _MockTransactionRepository();
    account = AccountModel(
      name: 'Cash',
      iconCodePoint: 0xe4c7,
      colorValue: 0xFF0052FF,
      initialBalance: 1000,
    )..id = 10;

    container = ProviderContainer(
      overrides: [
        accountRepositoryProvider.overrideWithValue(accountRepo),
        transactionRepositoryProvider.overrideWithValue(txRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'no adjustment transaction when target equals calculated balance',
    () async {
      when(
        () => txRepo.getTransactionDeltaForAccount(
          any(),
          baseCurrencyCode: any(named: 'baseCurrencyCode'),
        ),
      ).thenAnswer((_) async => 250.0);
      when(() => accountRepo.update(account)).thenAnswer((_) async {});

      await container
          .read(accountReconciliationActionsProvider)
          .setActualBalance(account: account, targetBalance: 1250.0);

      verify(() => accountRepo.update(account)).called(1);
      verifyNever(
        () => txRepo.addWithAccountUpdate(
          transaction: any(named: 'transaction'),
          account: any(named: 'account'),
        ),
      );
      expect(account.actualBalance, 1250.0);
    },
  );

  test('creates adjustment income transaction when target is higher', () async {
    when(
      () => txRepo.getTransactionDeltaForAccount(
        any(),
        baseCurrencyCode: any(named: 'baseCurrencyCode'),
      ),
    ).thenAnswer((_) async => 200.0); // calculated = 1200
    when(
      () => txRepo.addWithAccountUpdate(
        transaction: any(named: 'transaction'),
        account: any(named: 'account'),
      ),
    ).thenAnswer((_) async => 101);

    await container
        .read(accountReconciliationActionsProvider)
        .setActualBalance(
          account: account,
          targetBalance: 1400.0, // gap +200
          note: 'Cash counted',
        );

    final captured = verify(
      () => txRepo.addWithAccountUpdate(
        transaction: captureAny(named: 'transaction'),
        account: captureAny(named: 'account'),
      ),
    ).captured;
    final tx = captured[0] as TransactionModel;
    final acc = captured[1] as AccountModel;
    expect(tx.entryType, TransactionEntryType.adjustment);
    expect(tx.isIncome, isTrue);
    expect(tx.amount, 200.0);
    expect(tx.accountId, account.id);
    expect(tx.note, 'Cash counted');
    expect(acc.actualBalance, 1400.0);
    expect(account.actualBalance, 1400.0);
  });

  test('creates adjustment expense transaction when target is lower', () async {
    when(
      () => txRepo.getTransactionDeltaForAccount(
        any(),
        baseCurrencyCode: any(named: 'baseCurrencyCode'),
      ),
    ).thenAnswer((_) async => 100.0); // calculated = 1100
    when(
      () => txRepo.addWithAccountUpdate(
        transaction: any(named: 'transaction'),
        account: any(named: 'account'),
      ),
    ).thenAnswer((_) async => 102);

    await container
        .read(accountReconciliationActionsProvider)
        .setActualBalance(
          account: account,
          targetBalance: 900.0, // gap -200
          note: '',
        );

    final captured = verify(
      () => txRepo.addWithAccountUpdate(
        transaction: captureAny(named: 'transaction'),
        account: captureAny(named: 'account'),
      ),
    ).captured;
    final tx = captured[0] as TransactionModel;
    final acc = captured[1] as AccountModel;
    expect(tx.entryType, TransactionEntryType.adjustment);
    expect(tx.isIncome, isFalse);
    expect(tx.amount, 200.0);
    expect(tx.note, 'Balance adjustment');
    expect(acc.actualBalance, 900.0);
    expect(account.actualBalance, 900.0);
  });
}
