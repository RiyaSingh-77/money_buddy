import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

// fl_chart is used because it gives Flutter-ready chart widgets like BarChart,
// LineChart, and PieChart without manually drawing charts using CustomPainter.
// For this app, BarChart is a good choice because income vs expense is a simple comparison.

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    super.key,
    required this.transactions,
    required this.selectedMonth,
    required this.selectedYear,
  });

  // The full transaction list comes from Provider.
  // This widget filters it to only the selected month and year.
  final List<TransactionModel> transactions;
  final int selectedMonth;
  final int selectedYear;

  @override
  Widget build(BuildContext context) {
    // Chart data is calculated by first keeping only transactions
    // from the selected month and selected year.
    final monthlyTransactions = transactions.where((transaction) {
      return transaction.date.month == selectedMonth &&
          transaction.date.year == selectedYear;
    }).toList();

    // Total monthly income is calculated by taking only income transactions
    // and adding their amounts together.
    final monthlyIncome = monthlyTransactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold<double>(
          0,
          (total, transaction) => total + transaction.amount,
        );

    // Total monthly expense is calculated the same way,
    // but only for expense transactions.
    final monthlyExpense = monthlyTransactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold<double>(
          0,
          (total, transaction) => total + transaction.amount,
        );

    // This value helps the chart choose a sensible height for the bars.
    // If both totals are zero, we use 1 to avoid an empty chart scale.
    final highestAmount = monthlyIncome > monthlyExpense
        ? monthlyIncome
        : monthlyExpense;
    final maxY = highestAmount == 0 ? 1.0 : highestAmount * 1.2;

    // LayoutBuilder makes the chart mobile responsive.
    // It lets us read the available width and adjust spacing for smaller screens.
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

              // Border is hidden for a cleaner mobile UI.
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
                        return const Text('Income');
                      }

                      if (value == 1) {
                        return const Text('Expense');
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
                      toY: monthlyIncome,
                      width: barWidth,
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: monthlyExpense,
                      width: barWidth,
                      color: Colors.red,
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
