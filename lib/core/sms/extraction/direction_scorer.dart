import '../sms_parser_types.dart';

/// Resolves expense vs income from SMS direction keywords.
abstract final class SmsDirectionScorer {
  static const strongDebitSignals = ['debited', 'sent', 'paid'];
  static const strongCreditSignals = ['credited', 'received'];
  static const refundSignals = ['refunded', 'cashback'];

  static final paymentMethodCardRe = RegExp(
    r'\b(?:debit\s+card|credit\s+card|debit\s+cd|credit\s+cd)\b',
    caseSensitive: false,
  );

  static final contextualExpenseRe = RegExp(
    r'\bto\s+[A-Za-z][A-Za-z0-9\s&@._\-]{2,40}\b',
    caseSensitive: false,
  );

  static final contextualIncomeRe = RegExp(
    r'\bfrom\s+[A-Za-z][A-Za-z0-9\s&@._\-]{2,40}\b',
    caseSensitive: false,
  );

  static final _debitPatterns = <({String label, RegExp pattern, int weight})>[
    (
      label: 'debited',
      pattern: RegExp(
        r'\b(?:debited?|has been debited|a/c debited|account debited|debited from|debited by)\b',
        caseSensitive: false,
      ),
      weight: 3,
    ),
    (
      label: 'sent',
      pattern: RegExp(
        r'\b(?:sent|sent to|you sent|transferred to|transfer to)\b',
        caseSensitive: false,
      ),
      weight: 3,
    ),
    (
      label: 'paid',
      pattern: RegExp(
        r'\b(?:paid|you paid|paid to|payment made|payment of)\b',
        caseSensitive: false,
      ),
      weight: 3,
    ),
    (
      label: 'spent',
      pattern: RegExp(
        r'\b(?:spent|spent on|swiped|txn at|card\s+txn|txn\s+of)\b',
        caseSensitive: false,
      ),
      weight: 2,
    ),
    (
      label: 'withdrawn',
      pattern: RegExp(
        r'\b(?:withdrawn?|deducted|charged to)\b',
        caseSensitive: false,
      ),
      weight: 2,
    ),
    (
      label: 'purchase',
      pattern: RegExp(
        r'\b(?:purchase[d]?|used|using\s+Debit\s+Card|using\s+Credit\s+Card)\b',
        caseSensitive: false,
      ),
      weight: 2,
    ),
    (
      label: 'dr',
      pattern: RegExp(r'\bDr\.?\b'),
      weight: 2,
    ),
    (
      label: 'debit',
      pattern: RegExp(r'\bdebit\b', caseSensitive: false),
      weight: 1,
    ),
  ];

  static final _creditPatterns = <({String label, RegExp pattern, int weight})>[
    (
      label: 'credited',
      pattern: RegExp(
        r'\b(?:credited|credited to|credited in|has been credited|a/c credited|account credited)\b',
        caseSensitive: false,
      ),
      weight: 3,
    ),
    (
      label: 'received',
      pattern: RegExp(
        r'\b(?:received|received from|you received|payment received|money received)\b',
        caseSensitive: false,
      ),
      weight: 3,
    ),
    (
      label: 'deposited',
      pattern: RegExp(r'\bdeposited\b', caseSensitive: false),
      weight: 2,
    ),
    (
      label: 'refunded',
      pattern: RegExp(r'\b(?:refunded|cashback)\b', caseSensitive: false),
      weight: 2,
    ),
    (
      label: 'salary',
      pattern: RegExp(
        r'\b(?:salary|interest credited|dividend)\b',
        caseSensitive: false,
      ),
      weight: 2,
    ),
    (
      label: 'cr',
      pattern: RegExp(r'\bCr\.?\b'),
      weight: 2,
    ),
    (
      label: 'credit',
      pattern: RegExp(r'\bcredit\b', caseSensitive: false),
      weight: 1,
    ),
  ];

  static DirectionResult detect(
    String text, {
    bool detectRefunds = true,
    int? amountIndex,
  }) {
    final sanitized = text.replaceAll(paymentMethodCardRe, ' ');
    final debitMatches = _collect(sanitized, _debitPatterns);
    final creditMatches = _collect(sanitized, _creditPatterns);

    final cardUse = RegExp(
      r'\busing\s+(?:Debit|Credit)\s+Card\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (cardUse != null) {
      debitMatches.add((
        label: 'purchase',
        weight: 2,
        index: cardUse.start,
      ));
    }

    var debitScore =
        debitMatches.fold<int>(0, (sum, m) => sum + m.weight);
    var creditScore =
        creditMatches.fold<int>(0, (sum, m) => sum + m.weight);

    final refundOnly = creditMatches.isNotEmpty &&
        creditMatches.every((m) => refundSignals.contains(m.label));
    if (!detectRefunds && refundOnly) creditScore = 0;

    final debitSignals = debitMatches.map((m) => m.label).toList();
    final creditSignals = creditMatches.map((m) => m.label).toList();

    if (debitScore > 0 && creditScore == 0) {
      return DirectionResult(
        direction: TransactionDirection.expense,
        confidence: 0.95,
        matchedSignals: debitSignals,
      );
    }

    if (creditScore > 0 && debitScore == 0) {
      return DirectionResult(
        direction: TransactionDirection.income,
        confidence: 0.95,
        matchedSignals: creditSignals,
      );
    }

    if (debitScore > 0 && creditScore > 0) {
      final resolved = _resolveConflict(
        debitMatches,
        creditMatches,
        amountIndex: amountIndex,
      );
      if (resolved != null) return resolved;
      return DirectionResult(
        direction: TransactionDirection.ambiguous,
        confidence: 0.30,
        matchedSignals: [...debitSignals, ...creditSignals],
      );
    }

    if (!detectRefunds && refundOnly) {
      return const DirectionResult(
        direction: TransactionDirection.ambiguous,
        confidence: 0.30,
        matchedSignals: [],
      );
    }

    if (contextualExpenseRe.hasMatch(sanitized) &&
        !contextualIncomeRe.hasMatch(sanitized)) {
      return const DirectionResult(
        direction: TransactionDirection.expense,
        confidence: 0.60,
        matchedSignals: ['context_to'],
      );
    }

    if (contextualIncomeRe.hasMatch(sanitized) &&
        !contextualExpenseRe.hasMatch(sanitized)) {
      return const DirectionResult(
        direction: TransactionDirection.income,
        confidence: 0.60,
        matchedSignals: ['context_from'],
      );
    }

    return const DirectionResult(
      direction: TransactionDirection.ambiguous,
      confidence: 0.0,
      matchedSignals: [],
    );
  }

  static List<({String label, int weight, int index})> _collect(
    String text,
    List<({String label, RegExp pattern, int weight})> patterns,
  ) {
    final matches = <({String label, int weight, int index})>[];
    for (final p in patterns) {
      final m = p.pattern.firstMatch(text);
      if (m != null) {
        matches.add((label: p.label, weight: p.weight, index: m.start));
      }
    }
    return matches;
  }

  static DirectionResult? _resolveConflict(
    List<({String label, int weight, int index})> debitMatches,
    List<({String label, int weight, int index})> creditMatches, {
    int? amountIndex,
  }) {
    final anchor = amountIndex ?? 0;
    int? closestDebit;
    int? closestCredit;

    for (final m in debitMatches) {
      if (!strongDebitSignals.contains(m.label)) continue;
      final d = (m.index - anchor).abs();
      closestDebit = closestDebit == null ? d : d < closestDebit ? d : closestDebit;
    }
    for (final m in creditMatches) {
      if (!strongCreditSignals.contains(m.label)) continue;
      final d = (m.index - anchor).abs();
      closestCredit =
          closestCredit == null ? d : d < closestCredit ? d : closestCredit;
    }

    final debitScore =
        debitMatches.fold<int>(0, (s, m) => s + m.weight);
    final creditScore =
        creditMatches.fold<int>(0, (s, m) => s + m.weight);

    if (closestDebit != null &&
        closestCredit != null &&
        closestDebit == closestCredit) {
      return null;
    }

    if (closestDebit != null &&
        (closestCredit == null || closestDebit < closestCredit)) {
      return DirectionResult(
        direction: TransactionDirection.expense,
        confidence: 0.70,
        matchedSignals: debitMatches.map((m) => m.label).toList(),
      );
    }
    if (closestCredit != null &&
        (closestDebit == null || closestCredit < closestDebit)) {
      return DirectionResult(
        direction: TransactionDirection.income,
        confidence: 0.70,
        matchedSignals: creditMatches.map((m) => m.label).toList(),
      );
    }

    if (debitScore > creditScore) {
      return DirectionResult(
        direction: TransactionDirection.expense,
        confidence: 0.70,
        matchedSignals: debitMatches.map((m) => m.label).toList(),
      );
    }
    if (creditScore > debitScore) {
      return DirectionResult(
        direction: TransactionDirection.income,
        confidence: 0.70,
        matchedSignals: creditMatches.map((m) => m.label).toList(),
      );
    }
    return null;
  }
}
