import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/providers/dashboard_providers.dart';

class SpendingRing extends ConsumerStatefulWidget {
  const SpendingRing({super.key});

  @override
  ConsumerState<SpendingRing> createState() => _SpendingRingState();
}

class _SpendingRingState extends ConsumerState<SpendingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: AppDurations.slow);
    _progress = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeInOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dashboardProvider).valueOrNull;
    if (data == null || data.totalExpense == 0) {
      return const SizedBox.shrink();
    }

    final summary = data.categoryExpenseSummary;
    final categories = data.categories;
    final total = data.totalExpense;

    // Build segments sorted by value desc
    final segments = summary.entries
        .where((e) => e.value > 0)
        .map((e) {
          final cat = categories.firstWhere(
            (c) => c.id == e.key,
            orElse: () => categories.first,
          );
          return _Segment(
            label: cat.name,
            value: e.value,
            color: cat.color,
            fraction: e.value / total,
          );
        })
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding),
          child: Text(
            'Spending Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: AppSpacing.screenPadding),
            // Donut chart
            GestureDetector(
              onTapDown: (details) =>
                  _handleTap(details, segments, context),
              child: Semantics(
                label:
                    'Spending ring chart. Total expense: ${total.toStringAsFixed(2)}',
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) => CustomPaint(
                    size: const Size(160, 160),
                    painter: _DonutPainter(
                      segments: segments,
                      progress: _progress.value,
                      tappedIndex: _tappedIndex,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tappedIndex != null
                                  ? _pct(
                                      segments[_tappedIndex!].fraction)
                                  : _pct(1.0),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              _tappedIndex != null
                                  ? segments[_tappedIndex!].label
                                  : 'Total',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            // Legend
            Expanded(
              child: _Legend(
                segments: segments,
                tappedIndex: _tappedIndex,
                onTap: (i) => setState(
                    () => _tappedIndex = _tappedIndex == i ? null : i),
              ),
            ),
            const SizedBox(width: AppSpacing.screenPadding),
          ],
        ),
      ],
    );
  }

  void _handleTap(
    TapDownDetails details,
    List<_Segment> segments,
    BuildContext context,
  ) {
    const center = Offset(80, 80);
    final tap = details.localPosition;
    final dx = tap.dx - center.dx;
    final dy = tap.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 42 || dist > 76) {
      setState(() => _tappedIndex = null);
      return;
    }
    // Angle from -π/2 (top) going clockwise
    double angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += math.pi * 2;

    double sweep = 0;
    for (int i = 0; i < segments.length; i++) {
      final segSweep = segments[i].fraction * math.pi * 2;
      if (angle >= sweep && angle < sweep + segSweep) {
        setState(() => _tappedIndex = _tappedIndex == i ? null : i);
        return;
      }
      sweep += segSweep;
    }
    setState(() => _tappedIndex = null);
  }

  String _pct(double f) => '${(f * 100).toStringAsFixed(1)}%';
}

// ── Donut CustomPainter ───────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.segments,
    required this.progress,
    required this.tappedIndex,
    required this.backgroundColor,
  });

  final List<_Segment> segments;
  final double progress;
  final int? tappedIndex;
  final Color backgroundColor;

  static const double _strokeWidth = 28;
  static const double _gap = 0.015; // radians between segments

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - _strokeWidth / 2 - 4;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, radius, bgPaint);

    // Segments
    double startAngle = -math.pi / 2;
    final totalSweep = math.pi * 2 * progress;
    double consumed = 0;

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final sweepFull = seg.fraction * math.pi * 2;
      final sweep = math.min(sweepFull - _gap, totalSweep - consumed);
      if (sweep <= 0) break;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            tappedIndex == i ? _strokeWidth + 6 : _strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + _gap / 2,
        sweep,
        false,
        paint,
      );

      startAngle += sweepFull;
      consumed += sweepFull;
      if (consumed >= totalSweep) break;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress ||
      old.tappedIndex != tappedIndex ||
      old.segments != segments;
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend({
    required this.segments,
    required this.tappedIndex,
    required this.onTap,
  });

  final List<_Segment> segments;
  final int? tappedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final visible = segments.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visible.length; i++)
          GestureDetector(
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: AnimatedOpacity(
                duration: AppDurations.fast,
                opacity:
                    tappedIndex == null || tappedIndex == i ? 1.0 : 0.4,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: visible[i].color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        visible[i].label,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              fontWeight: tappedIndex == i
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(visible[i].fraction * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (segments.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${segments.length - 5} more',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _Segment {
  const _Segment({
    required this.label,
    required this.value,
    required this.color,
    required this.fraction,
  });

  final String label;
  final double value;
  final Color color;
  final double fraction;
}
