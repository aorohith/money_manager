import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  int _selectedColorIndex = 0;
  final _formKey = GlobalKey<FormState>();

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ds = ref.read(authDatasourceProvider);
    await ds.saveProfile(
      name: _nameController.text.trim(),
      colorValue: AppColors.avatarTones[_selectedColorIndex].toARGB32(),
    );
    await ref.read(authProvider.notifier).completeOnboarding();
    if (mounted) context.go(AppRoutes.pinSetup);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar preview
              Center(
                child: AnimatedContainer(
                  duration: AppDurations.standard,
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.avatarTones[_selectedColorIndex],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : '?',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Name input
              AppTextField(
                controller: _nameController,
                label: 'Your name',
                hint: 'Enter your name',
                prefixIcon: const Icon(Icons.person_rounded),
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                semanticLabel: 'Your name input field',
              ),
              const SizedBox(height: AppSpacing.xl),

              // Color picker
              Text('Pick a color',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  AppColors.avatarTones.length,
                  (i) => Semantics(
                    label: 'Color option ${i + 1}',
                    button: true,
                    selected: i == _selectedColorIndex,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = i),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.avatarTones[i],
                          shape: BoxShape.circle,
                          border: i == _selectedColorIndex
                              ? Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 2.5,
                                )
                              : null,
                        ),
                        child: i == _selectedColorIndex
                            ? const Icon(Icons.check, color: Colors.white,
                                size: 20)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              AppButton(
                expanded: true,
                label: 'Continue',
                onPressed: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
