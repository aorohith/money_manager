import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Confirmation dialog shown when the user presses the device back button on
/// the home tab. Returns `true` if the user confirms exit, `false`/`null`
/// otherwise.
class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  /// Convenience helper that shows the dialog and resolves to whether the
  /// user confirmed the exit.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const ExitConfirmationDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.exitAppTitle),
      content: Text(l10n.exitAppMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.exit),
        ),
      ],
    );
  }
}
