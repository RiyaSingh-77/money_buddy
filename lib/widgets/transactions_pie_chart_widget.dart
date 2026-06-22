import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

// TransactionsPieChartWidget breaks a list of transactions down by title
// (e.g. "Salary", "Rent", "Food") instead of just Income vs Expense. Each
// distinct title gets its own slice sized by how much of the total amount
// it makes up, so you can see at a glance which transactions dominate
// the month — same donut style as PieChartWidget, just with N slices
// instead of a fixed 2.
//
// Like PieChartWidget, this only needs a list of transactions — it does
// its own grouping/summing internally — so it's reusable for any month,
// year, or filtered subset (e.g. expenses only) just by changing what
// list gets passed in.
class TransactionsPieChartWidget extends StatelessWidget {
  const TransactionsPieChartWidget({
    super.key,
    required this.transactions,
  });

  final List<TransactionModel> transactions;

  // A fixed color palette that cycles if there are more distinct titles
  // than colors. Kept as a list (not generated randomly) so colors stay
  // stable and visually distinct from each other.
  static const List<Color> _palette = [
    Color(0xFF168A4A), // green
    Color(0xFFD43D32), // red
    Color(0xFF2364AA), // blue
    Color(0xFFE07828), // orange
    Color(0xFF7B4FA0), // purple
    Color(0xFF1FA2A6), // teal
    Color(0xFFC2914F), // amber/brown
    Color(0xFFB23B7A), // pink
  ];

  @override
  Widget build(BuildContext context) {
    // Group transactions by title and sum their amounts, so two "Food"
    // entries in the same month become one combined slice instead of two.
    final Map<String, double> totalsByTitle = {};

    for (final transaction in transactions) {
      totalsByTitle.update(
        transaction.title,
        (existing) => existing + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final grandTotal =
        totalsByTitle.values.fold<double>(0, (sum, value) => sum + value);

    // Sort largest-first so the legend and slice order read naturally,
    // biggest contributors first.
    final entries = totalsByTitle.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final hasData = grandTotal > 0 && entries.isNotEmpty;

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
                          for (var i = 0; i < entries.length; i++)
                            PieChartSectionData(
                              value: entries[i].value,
                              color: _palette[i % _palette.length],
                              radius: radius,
                              title:
                                  '${((entries[i].value / grandTotal) * 100).toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                        ]
                      : [
                          // Placeholder slice shown when there is no data.
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

            // Legend lists every title with its color, so slices remain
            // identifiable even once there are several of them.
            if (hasData)
              Wrap(
                spacing: 20,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < entries.length; i++)
                    _LegendItem(
                      color: _palette[i % _palette.length],
                      label: entries[i].key,
                      amount: entries[i].value,
                    ),
                ],
              )
            else
              Text(
                'No transactions yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.amount,
  });

  final Color color;
  final String label;
  final double amount;

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
          '$label (₹${amount.toStringAsFixed(0)})',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
