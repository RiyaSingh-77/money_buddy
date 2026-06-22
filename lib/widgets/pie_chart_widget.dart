import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// PieChartWidget is a small, reusable visual that compares two amounts —
// income and expense — as slices of a pie. It only needs the two totals,
// not the full transaction list, so it can be dropped into any screen
// (StatisticsScreen, a monthly summary, a yearly overview, etc.) just by
// passing in whatever income/expense numbers are relevant there.
class PieChartWidget extends StatelessWidget {
  const PieChartWidget({
    super.key,
    required this.income,
    required this.expense,
    this.incomeColor = const Color(0xFF168A4A),
    this.expenseColor = const Color(0xFFD43D32),
  });

  final double income;
  final double expense;

  // Colors are configurable (with sensible defaults) so this widget can
  // match different screens' palettes without code changes.
  final Color incomeColor;
  final Color expenseColor;

  @override
  Widget build(BuildContext context) {
    final total = income + expense;

    // When there is no data at all, show one neutral placeholder slice
    // instead of a broken/empty pie chart.
    final hasData = total > 0;

    final incomePercent = hasData ? (income / total) * 100 : 0;
    final expensePercent = hasData ? (expense / total) * 100 : 0;

    // LayoutBuilder makes this widget responsive: the pie's radius scales
    // with whatever width it is given, so it looks right whether it sits
    // in a narrow phone column or a wide tablet/desktop layout.
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth.clamp(180.0, 320.0);
        final radius = size / 4.2;
        final centerSpace = radius * 0.6;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size * 0.65,
              width: double.infinity,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: centerSpace,
                  sections: hasData
                      ? [
                          PieChartSectionData(
                            value: income,
                            color: incomeColor,
                            radius: radius,
                            title: '${incomePercent.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: expense,
                            color: expenseColor,
                            radius: radius,
                            title: '${expensePercent.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ]
                      : [
                          // Placeholder slice shown only when both totals are zero.
                          PieChartSectionData(
                            value: 1,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            radius: radius,
                            title: '',
                          ),
                        ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Legend explains which color is which, since the slices
            // alone only show percentages.
            Wrap(
              spacing: 20,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _LegendItem(color: incomeColor, label: 'Income'),
                _LegendItem(color: expenseColor, label: 'Expense'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
