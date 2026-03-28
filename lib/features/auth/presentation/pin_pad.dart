import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/constants.dart';

/// Reusable PIN dot display + number pad.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.enteredLength,
    required this.pinLength,
    required this.onDigit,
    required this.onDelete,
    this.shake = false,
    this.errorMessage,
    this.biometricButton,
  });

  final int enteredLength;
  final int pinLength;
  final void Function(String digit) onDigit;
  final VoidCallback onDelete;
  final bool shake;
  final String? errorMessage;
  final Widget? biometricButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN dots
        _ShakeWidget(
          shake: shake,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pinLength,
              (i) => AnimatedContainer(
                duration: AppDurations.fast,
                margin: const EdgeInsets.all(AppSpacing.sm),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < enteredLength
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
        ),

        // Error message
        AnimatedSwitcher(
          duration: AppDurations.fast,
          child: errorMessage != null
              ? Padding(
                  key: ValueKey(errorMessage),
                  padding:
                      const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    semanticsLabel: errorMessage,
                  ),
                )
              : const SizedBox(key: ValueKey('empty'), height: 20),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Digit grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          children: [
            ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(
              (d) => _DialButton(label: d, onTap: () => onDigit(d)),
            ),
            biometricButton ?? const SizedBox(),
            _DialButton(label: '0', onTap: () => onDigit('0')),
            Semantics(
              label: 'Delete last digit',
              button: true,
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
                onTap: onDelete,
                child: const Center(
                  child: Icon(Icons.backspace_outlined),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DialButton extends StatelessWidget {
  const _DialButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Digit $label',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}

class _ShakeWidget extends StatefulWidget {
  const _ShakeWidget({required this.shake, required this.child});
  final bool shake;
  final Widget child;

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_ShakeWidget old) {
    super.didUpdateWidget(old);
    if (widget.shake && !old.shake) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: widget.child,
      builder: (_, child) {
        final offset = _ctrl.isAnimating
            ? 8 * (0.5 - (_anim.value % 0.25 / 0.25)).abs() * 2 - 8
            : 0.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
    );
  }
}
