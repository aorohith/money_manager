import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/models/analytics_data.dart';

// ── Animated donut chart ──────────────────────────────────────────────────────

class AnimatedDonutChart extends StatefulWidget {
  const AnimatedDonutChart({
    super.key,
    required this.categories,
    required this.totalExpense,
    required this.selectedIndex,
    required this.onTap,
    this.size = 200,
  });

  final List<CategorySummary> categories;
  final double totalExpense;
  final int? selectedIndex;
  final ValueChanged<int?> onTap;
  final double size;

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sweepAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.emphasis,
    );
    _sweepAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedDonutChart old) {
    super.didUpdateWidget(old);
    // Re-animate when categories change (period or date change)
    if (old.categories != widget.categories ||
        old.totalExpense != widget.totalExpense) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _sweepAnim,
        builder: (_, __) {
          return GestureDetector(
            onTapDown: (details) => _handleTap(details.localPosition),
            child: CustomPaint(
              painter: _DonutPainter(
                categories: widget.categories,
                totalExpense: widget.totalExpense,
                sweepProgress: _sweepAnim.value,
                selectedIndex: widget.selectedIndex,
              ),
              child: _CenterLabel(
                categories: widget.categories,
                totalExpense: widget.totalExpense,
                selectedIndex: widget.selectedIndex,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(Offset localPos) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final offset = localPos - center;
    final distance = offset.distance;
    final outerRadius = widget.size / 2 - 4;
    final innerRadius = outerRadius * 0.56;

    // Only register taps within the donut ring
    if (distance < innerRadius || distance > outerRadius) {
      widget.onTap(null);
      return;
    }

    // Find which segment was tapped
    double angle = math.atan2(offset.dy, offset.dx);
    // Convert to 0..2π starting from top (-π/2)
    angle = (angle + math.pi / 2 + math.pi * 2) % (math.pi * 2);

    double cumulative = 0;
    for (int i = 0; i < widget.categories.length; i++) {
      final sweep =
          (widget.categories[i].percentage / 100) * math.pi * 2;
      cumulative += sweep;
      if (angle <= cumulative) {
        widget.onTap(widget.selectedIndex == i ? null : i);
        return;
      }
    }
    widget.onTap(null);
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.categories,
    required this.totalExpense,
    required this.sweepProgress,
    required this.selectedIndex,
  });

  final List<CategorySummary> categories;
  final double totalExpense;
  final double sweepProgress;
  final int? selectedIndex;

  static const _gapAngle = 0.025; // radians gap between segments

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 4;
    final innerRadius = outerRadius * 0.56;
    final strokeWidth = outerRadius - innerRadius;

    if (categories.isEmpty || totalExpense == 0) {
      // Empty state ring
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = const Color(0x1A94A3B8);
      canvas.drawCircle(center, (outerRadius + innerRadius) / 2, paint);
      return;
    }

    double startAngle = -math.pi / 2; // start from top

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final sweepFraction = cat.percentage / 100;
      final fullSweep = sweepFraction * math.pi * 2 * sweepProgress;

      // Apply gap
      final gapTotal = categories.length > 1 ? _gapAngle : 0.0;
      final actualSweep = math.max(0.0, fullSweep - gapTotal);

      if (actualSweep <= 0) {
        startAngle += fullSweep;
        continue;
      }

      final isSelected = selectedIndex == i;
      final radius = isSelected
          ? (outerRadius + innerRadius) / 2 + 4
          : (outerRadius + innerRadius) / 2;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 6 : strokeWidth
        ..color = isSelected
            ? cat.color
            : cat.color.withAlpha(selectedIndex != null ? 140 : 255)
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        actualSweep,
        false,
        paint,
      );

      startAngle += fullSweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.sweepProgress != sweepProgress ||
      old.selectedIndex != selectedIndex ||
      old.categories != categories;
}

// ── Center label ──────────────────────────────────────────────────────────────

class _CenterLabel extends StatelessWidget {
  const _CenterLabel({
    required this.categories,
    required this.totalExpense,
    required this.selectedIndex,
  });

  final List<CategorySummary> categories;
  final double totalExpense;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    if (selectedIndex != null && selectedIndex! < categories.length) {
      final cat = categories[selectedIndex!];
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(cat.icon, size: 20, color: cat.color),
            const SizedBox(height: 4),
            Text(
              '${cat.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              cat.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: subColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _fmt(totalExpense),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Total Spent',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
