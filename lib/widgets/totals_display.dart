import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalsDisplay extends StatelessWidget {
  final double totalExpenses;
  final double remainingSavings;
  final double initialSavings;

  const TotalsDisplay({
    super.key,
    required this.totalExpenses,
    required this.remainingSavings,
    required this.initialSavings,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final savingsPercentage =
        initialSavings > 0
            ? (remainingSavings / initialSavings * 100).clamp(0, 100).toDouble()
            : 0.0;

    Color getColorForPercentage(double percentage) {
      if (percentage >= 70) return Colors.green;
      if (percentage >= 30) return Colors.orange;
      return Colors.red;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTotalItem(
                  context,
                  'Total Expenses',
                  currencyFormat.format(totalExpenses),
                  Colors.red,
                ),
                _buildTotalItem(
                  context,
                  'Remaining',
                  currencyFormat.format(remainingSavings),
                  getColorForPercentage(savingsPercentage),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (savingsPercentage / 100).toDouble(),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  getColorForPercentage(savingsPercentage),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${savingsPercentage.toStringAsFixed(1)}% of savings remaining',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
