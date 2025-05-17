import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/group_expense.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _showBarChart = true;
  final _currencyFormat = NumberFormat.currency(symbol: '₹');

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset All Data'),
            content: const Text(
              'Are you sure you want to reset all expense data? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ExpenseProvider>().resetAllData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data has been reset'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  Widget _buildChart() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final expenses = provider.getExpensesByDateRange(_startDate, _endDate);
        final groupExpenses = provider.getGroupExpensesByDateRange(
          _startDate,
          _endDate,
        );

        if (expenses.isEmpty && groupExpenses.isEmpty) {
          return const Center(
            child: Text('No expenses in the selected date range'),
          );
        }

        if (_showBarChart) {
          return _buildBarChart(expenses, groupExpenses);
        } else {
          return _buildPieChart(expenses, groupExpenses);
        }
      },
    );
  }

  Widget _buildBarChart(
    List<Expense> expenses,
    List<GroupExpense> groupExpenses,
  ) {
    final categoryTotals = <String, double>{};

    // Add individual expenses
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Add group expenses
    for (final expense in groupExpenses) {
      categoryTotals['Group Expenses'] =
          (categoryTotals['Group Expenses'] ?? 0) + expense.totalAmount;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: categoryTotals.values.reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(2)} ₹',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final categories = categoryTotals.keys.toList();
                if (value >= 0 && value < categories.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      categories[value.toInt()],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _currencyFormat.format(value),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            categoryTotals.entries.map((entry) {
              final index = categoryTotals.keys.toList().indexOf(entry.key);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: Colors.blue,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPieChart(
    List<Expense> expenses,
    List<GroupExpense> groupExpenses,
  ) {
    final categoryTotals = <String, double>{};

    // Add individual expenses
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Add group expenses
    for (final expense in groupExpenses) {
      categoryTotals['Group Expenses'] =
          (categoryTotals['Group Expenses'] ?? 0) + expense.totalAmount;
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections:
                  categoryTotals.entries.map((entry) {
                    final color =
                        Colors.primaries[categoryTotals.keys.toList().indexOf(
                              entry.key,
                            ) %
                            Colors.primaries.length];
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${_currencyFormat.format(entry.value)}',
                      color: color,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children:
              categoryTotals.entries.map((entry) {
                final color =
                    Colors.primaries[categoryTotals.keys.toList().indexOf(
                          entry.key,
                        ) %
                        Colors.primaries.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 16, height: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.key} (${_currencyFormat.format(entry.value)})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Date Range Selection and Reset Button
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date Range',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: Colors.red,
                        onPressed: _showResetConfirmation,
                        tooltip: 'Reset All Data',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${DateFormat('MMM d, y').format(_startDate)} - ${DateFormat('MMM d, y').format(_endDate)}',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chart Type Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Bar Chart'),
                  icon: Icon(Icons.bar_chart),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Pie Chart'),
                  icon: Icon(Icons.pie_chart),
                ),
              ],
              selected: {_showBarChart},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showBarChart = selection.first;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildChart(),
            ),
          ),
        ],
      ),
    );
  }
}
