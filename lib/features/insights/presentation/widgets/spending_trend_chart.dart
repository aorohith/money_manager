import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/models/insights_data.dart';

class SpendingTrendChart extends StatelessWidget {
  const SpendingTrendChart({super.key, required this.dailySpending});
  final List<DailySpending> dailySpending;

  @override
  Widget build(BuildContext context) {
    if (dailySpending.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxY = dailySpending.fold<double>(
            0, (m, d) => d.amount > m ? d.amount : m) *
        1.2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: _interval,
              getTitlesWidget: (v, _) {
                final day = v.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: dailySpending.length.toDouble(),
        minY: 0,
        maxY: maxY > 0 ? maxY : 10,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                'Day ${s.x.toInt()}\n\$${s.y.toStringAsFixed(0)}',
                TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: dailySpending
                .map((d) => FlSpot(d.day.toDouble(), d.amount))
                .toList(),
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppColors.brand,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.brand.withAlpha(60),
                  AppColors.brand.withAlpha(5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _interval {
    final count = dailySpending.length;
    if (count <= 7) return 1;
    if (count <= 15) return 3;
    return 5;
  }
}
