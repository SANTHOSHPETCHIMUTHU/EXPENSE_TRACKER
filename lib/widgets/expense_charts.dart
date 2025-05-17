import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class ExpenseCharts extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;
  final double remainingSavings;
  final double initialSavings;

  const ExpenseCharts({
    super.key,
    required this.categoryTotals,
    required this.remainingSavings,
    required this.initialSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _createPieChartSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _createLegendItems(context),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return ExpenseCategory.values.asMap().entries.map((entry) {
      final category = entry.key;
      final color = colors[category % colors.length];
      final total = categoryTotals[ExpenseCategory.values[category]] ?? 0.0;

      return PieChartSectionData(
        color: color,
        value: total,
        title: '',
        radius: 100,
      );
    }).toList();
  }

  List<Widget> _createLegendItems(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return ExpenseCategory.values.asMap().entries.map((entry) {
      final category = entry.key;
      final color = colors[category % colors.length];
      final total = categoryTotals[ExpenseCategory.values[category]] ?? 0.0;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '${ExpenseCategory.values[category].name}: ₹${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }).toList();
  }
}
