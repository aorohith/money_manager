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
        () => txRepo.getTransactionDeltaForAccount(account.id),
      ).thenAnswer((_) async => 250.0);
      when(() => accountRepo.update(account)).thenAnswer((_) async {});

      await container
          .read(accountReconciliationActionsProvider)
          .setActualBalance(account: account, targetBalance: 1250.0);

      verify(() => accountRepo.update(account)).called(1);
      verifyNever(() => txRepo.add(any()));
      expect(account.actualBalance, 1250.0);
    },
  );

  test('creates adjustment income transaction when target is higher', () async {
    when(
      () => txRepo.getTransactionDeltaForAccount(account.id),
    ).thenAnswer((_) async => 200.0); // calculated = 1200
    when(() => txRepo.add(any())).thenAnswer((_) async => 101);
    when(() => accountRepo.update(account)).thenAnswer((_) async {});

    await container
        .read(accountReconciliationActionsProvider)
        .setActualBalance(
          account: account,
          targetBalance: 1400.0, // gap +200
          note: 'Cash counted',
        );

    final captured =
        verify(() => txRepo.add(captureAny())).captured.single
            as TransactionModel;
    expect(captured.entryType, TransactionEntryType.adjustment);
    expect(captured.isIncome, isTrue);
    expect(captured.amount, 200.0);
    expect(captured.accountId, account.id);
    expect(captured.note, 'Cash counted');
    verify(() => accountRepo.update(account)).called(1);
    expect(account.actualBalance, 1400.0);
  });

  test('creates adjustment expense transaction when target is lower', () async {
    when(
      () => txRepo.getTransactionDeltaForAccount(account.id),
    ).thenAnswer((_) async => 100.0); // calculated = 1100
    when(() => txRepo.add(any())).thenAnswer((_) async => 102);
    when(() => accountRepo.update(account)).thenAnswer((_) async {});

    await container
        .read(accountReconciliationActionsProvider)
        .setActualBalance(
          account: account,
          targetBalance: 900.0, // gap -200
          note: '',
        );

    final captured =
        verify(() => txRepo.add(captureAny())).captured.single
            as TransactionModel;
    expect(captured.entryType, TransactionEntryType.adjustment);
    expect(captured.isIncome, isFalse);
    expect(captured.amount, 200.0);
    expect(captured.note, 'Balance adjustment');
    verify(() => accountRepo.update(account)).called(1);
    expect(account.actualBalance, 900.0);
  });
}
