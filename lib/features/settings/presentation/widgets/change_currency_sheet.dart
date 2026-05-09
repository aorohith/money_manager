import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/data/currency_data.dart';
import '../../../auth/providers/auth_provider.dart';

Future<void> showChangeCurrencySheet(BuildContext context) {
  return showAppBottomSheet(
    context: context,
    title: 'Select Currency',
    maxHeightFraction: 0.85,
    child: const _CurrencyPicker(),
  );
}

class _CurrencyPicker extends ConsumerStatefulWidget {
  const _CurrencyPicker();

  @override
  ConsumerState<_CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends ConsumerState<_CurrencyPicker> {
  final _searchCtrl = TextEditingController();
  List<CurrencyInfo> _filtered = kCurrencies;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() {
      final query = q.toLowerCase();
      _filtered = kCurrencies
          .where((c) =>
              c.code.toLowerCase().contains(query) ||
              c.name.toLowerCase().contains(query) ||
              c.symbol.contains(query))
          .toList();
    });
  }

  Future<void> _select(CurrencyInfo c) async {
    final ds = ref.read(authDatasourceProvider);
    await ds.saveCurrency(code: c.code, symbol: c.symbol);
    ref.invalidate(currencyCodeProvider);
    ref.invalidate(currencySymbolProvider);
    if (mounted) {
      Navigator.of(context).pop();
      showAppSnackBar(context,
          message: 'Currency changed to ${c.code}',
          type: AppSnackBarType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = ref.watch(currencyCodeProvider).valueOrNull ?? 'USD';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          controller: _searchCtrl,
          hint: 'Search currency...',
          prefixIcon: const Icon(Icons.search_rounded),
          onChanged: _onSearch,
        ),
        const SizedBox(height: AppSpacing.sm),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filtered.length,
          itemBuilder: (_, i) {
            final c = _filtered[i];
            final isSelected = c.code == currentCode;
            return ListTile(
              leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
              title: Text(c.name),
              subtitle: Text('${c.code} (${c.symbol})'),
              trailing: isSelected
                  ? Icon(Icons.check_circle_rounded, color: AppColors.brand)
                  : null,
              onTap: () => _select(c),
            );
          },
        ),
      ],
    );
  }
}
