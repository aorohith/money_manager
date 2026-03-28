import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/data/currency_data.dart';
import '../../auth/providers/auth_provider.dart';

class CurrencySetupScreen extends ConsumerStatefulWidget {
  const CurrencySetupScreen({super.key});

  @override
  ConsumerState<CurrencySetupScreen> createState() =>
      _CurrencySetupScreenState();
}

class _CurrencySetupScreenState extends ConsumerState<CurrencySetupScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  CurrencyInfo _selected = kCurrencies.first;

  List<CurrencyInfo> get _filtered {
    if (_query.isEmpty) return kCurrencies;
    final q = _query.toLowerCase();
    return kCurrencies
        .where((c) =>
            c.code.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _confirm() async {
    final ds = ref.read(authDatasourceProvider);
    await ds.saveCurrency(code: _selected.code, symbol: _selected.symbol);
    if (mounted) context.go(AppRoutes.profileSetup);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Currency')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.sm,
            ),
            child: AppTextField(
              controller: _searchController,
              hint: 'Search currencies…',
              prefixIcon: const Icon(Icons.search_rounded),
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              semanticLabel: 'Search currencies',
            ),
          ),

          // Selected chip
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding),
            child: Row(
              children: [
                Text('Selected: ',
                    style: Theme.of(context).textTheme.bodyMedium),
                Chip(
                  avatar: Text(_selected.flag,
                      style: const TextStyle(fontSize: 18)),
                  label: Text('${_selected.code} – ${_selected.symbol}'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),
          const Divider(height: 1),

          // Currency list
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final isSelected = c.code == _selected.code;
                return ListTile(
                  leading: Semantics(
                    label: c.flag,
                    child: Text(c.flag, style: const TextStyle(fontSize: 26)),
                  ),
                  title: Text(c.code,
                      style: Theme.of(context).textTheme.titleSmall),
                  subtitle: Text(c.name),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary)
                      : Text(c.symbol,
                          style: Theme.of(context).textTheme.bodyMedium),
                  selected: isSelected,
                  onTap: () => setState(() => _selected = c),
                );
              },
            ),
          ),

          // Confirm
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: AppButton(
              expanded: true,
              label: 'Continue',
              onPressed: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}
