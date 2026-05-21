import 'package:flutter/material.dart';

import '../constants/constants.dart';

/// Shared, restrained entrance motion for list rows and repeated cards.
///
/// Keep this subtle. It is meant to make refreshed lists feel responsive
/// without drawing attention away from the financial data.
class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.enabled = true,
    this.duration = AppDurations.standard,
  });

  final int index;
  final Widget child;
  final bool enabled;
  final Duration duration;

  static const _staggerStep = Duration(milliseconds: 24);
  static const _maxStagger = Duration(milliseconds: 144);
  static const _startOffset = 10.0;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final delayMs = (index * _staggerStep.inMilliseconds).clamp(
      0,
      _maxStagger.inMilliseconds,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + Duration(milliseconds: delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayed = _delayedProgress(
          value,
          delayMs / (duration.inMilliseconds + delayMs),
        );
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, (1 - delayed) * _startOffset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  double _delayedProgress(double value, double delayFraction) {
    if (delayFraction <= 0) return value;
    if (value <= delayFraction) return 0;
    return ((value - delayFraction) / (1 - delayFraction)).clamp(0.0, 1.0);
  }
}
