import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/providers/settings_providers.dart';

/// Settings tile that toggles biometric unlock.
///
/// Wraps a [SwitchListTile] inside an [AppCard] so the entire row is tappable
/// (no dead-zone around the inner switch) and the active thumb uses the brand
/// colour, matching the rest of the app's switch styling.
class BiometricTile extends ConsumerWidget {
  const BiometricTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(biometricEnabledProvider).valueOrNull ?? false;

    return AppCard(
      onTap: () => _toggle(context, ref, !enabled),
      child: IgnorePointer(
        child: SwitchListTile(
          secondary: const Icon(Icons.fingerprint_rounded),
          title: const Text('Biometric Unlock'),
          subtitle: const Text('Use fingerprint or face to unlock'),
          value: enabled,
          onChanged: (_) {},
          activeThumbColor: AppColors.brand,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    bool requested,
  ) async {
    final authNotifier = ref.read(authProvider.notifier);

    if (!requested) {
      await ref.read(biometricEnabledProvider.notifier).toggle(false);
      if (context.mounted) {
        showAppSnackBar(
          context,
          message: 'Biometric unlock disabled',
          type: AppSnackBarType.info,
        );
      }
      return;
    }

    final hasBio = await authNotifier.hasBiometrics;
    if (!hasBio) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          message: 'Biometrics not available on this device',
          type: AppSnackBarType.error,
        );
      }
      return;
    }

    final verified = await authNotifier.confirmBiometricIdentity(
      localizedReason: 'Confirm biometric to enable quick unlock',
    );
    if (!verified) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          message: 'Biometric verification cancelled or failed',
          type: AppSnackBarType.error,
        );
      }
      return;
    }

    await ref.read(biometricEnabledProvider.notifier).toggle(true);
    if (context.mounted) {
      showAppSnackBar(
        context,
        message: 'Biometric unlock enabled',
        type: AppSnackBarType.success,
      );
    }
  }
}
