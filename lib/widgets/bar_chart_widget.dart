import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// BarChartWidget compares two amounts — income and expense — as side-by-side
// bars. Like PieChartWidget, it only takes the two totals (not the full
// transaction list), so any screen can reuse it for any month, year, or
// custom date range just by computing two numbers and passing them in.
class BarChartWidget extends StatelessWidget {
  const BarChartWidget({
    super.key,
    required this.income,
    required this.expense,
    this.incomeColor = const Color(0xFF168A4A),
    this.expenseColor = const Color(0xFFD43D32),
  });

  final double income;
  final double expense;

  final Color incomeColor;
  final Color expenseColor;

  @override
  Widget build(BuildContext context) {
    // This value helps the chart choose a sensible height for the bars.
    // If both totals are zero, we use 1 to avoid an empty chart scale.
    final highestAmount = income > expense ? income : expense;
    final maxY = highestAmount == 0 ? 1.0 : highestAmount * 1.2;

    // LayoutBuilder makes the chart responsive: bar width and reserved
    // label space adjust based on how much horizontal room is available,
    // so it reads well on a small phone or a wide screen.
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        final barWidth = isSmallScreen ? 28.0 : 40.0;

        return SizedBox(
          height: 240,
          width: double.infinity,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,

              // Grid lines make it easier to read the bar values.
              gridData: const FlGridData(show: true),

              // Border is hidden for a cleaner UI.
              borderData: FlBorderData(show: false),

              // These titles label the bottom of the chart as Income and Expense.
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: isSmallScreen ? 36 : 44,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text('Income'),
                        );
                      }

                      if (value == 1) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text('Expense'),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              // Bar groups are the actual chart data.
              // x: 0 is income, and x: 1 is expense.
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      width: barWidth,
                      color: incomeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: expense,
                      width: barWidth,
                      color: expenseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
