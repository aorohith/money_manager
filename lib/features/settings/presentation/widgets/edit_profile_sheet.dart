import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/providers/settings_providers.dart';

Future<void> showEditProfileSheet(BuildContext context) {
  return showAppBottomSheet(
    context: context,
    title: 'Edit Profile',
    child: const _EditProfileForm(),
  );
}

class _EditProfileForm extends ConsumerStatefulWidget {
  const _EditProfileForm();

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  int _selectedColor = 0xFF00BFA5;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final name = ref.read(profileNameProvider).valueOrNull ?? '';
    final color = ref.read(profileColorProvider).valueOrNull ?? 0xFF00BFA5;
    _nameCtrl.text = name;
    _selectedColor = color;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final ds = ref.read(authDatasourceProvider);
    await ds.saveProfile(
      name: _nameCtrl.text.trim(),
      colorValue: _selectedColor,
    );

    ref.invalidate(profileNameProvider);
    ref.invalidate(profileColorProvider);

    if (mounted) {
      Navigator.of(context).pop();
      showAppSnackBar(context,
          message: 'Profile updated', type: AppSnackBarType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text[0].toUpperCase()
        : '?';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              backgroundColor: Color(_selectedColor),
              radius: 36,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _nameCtrl,
            label: 'Name',
            hint: 'Your name',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Avatar Color',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: AppColors.avatarTones.map((c) {
              final isSelected = c.toARGB32() == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c.toARGB32()),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            expanded: true,
            label: 'Save',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
