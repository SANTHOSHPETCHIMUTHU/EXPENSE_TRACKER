import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class IndividualExpensesScreen extends StatefulWidget {
  const IndividualExpensesScreen({super.key});

  @override
  State<IndividualExpensesScreen> createState() =>
      _IndividualExpensesScreenState();
}

class _IndividualExpensesScreenState extends State<IndividualExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  String _selectedCategory = 'Food';
  bool _showCustomCategory = false;
  bool _showBarChart = true;
  String _selectedTimeFrame = 'All';
  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills',
    'Other',
  ];
  final _currencyFormat = NumberFormat.currency(symbol: '₹');

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _handleCategoryChange(String? value) {
    if (value == null) return;
    setState(() {
      _selectedCategory = value;
      _showCustomCategory = value == 'Other';
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      category:
          _showCustomCategory
              ? _customCategoryController.text
              : _selectedCategory,
      date: DateTime.now(),
    );

    context.read<ExpenseProvider>().addExpense(expense);

    _descriptionController.clear();
    _amountController.clear();
    _customCategoryController.clear();
    setState(() {
      _selectedCategory = 'Food';
      _showCustomCategory = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<Expense> _getFilteredExpenses() {
    final expenses = context.read<ExpenseProvider>().expenses;
    final now = DateTime.now();

    switch (_selectedTimeFrame) {
      case 'Today':
        return expenses.where((e) {
          final date = e.date;
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return expenses.where((e) {
          final date = e.date;
          return date.isAfter(weekStart) &&
              date.isBefore(now.add(const Duration(days: 1)));
        }).toList();
      case 'This Month':
        return expenses.where((e) {
          final date = e.date;
          return date.year == now.year && date.month == now.month;
        }).toList();
      default:
        return expenses;
    }
  }

  Widget _buildChart() {
    final expenses = _getFilteredExpenses();
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses to display'));
    }

    if (_showBarChart) {
      return _buildBarChart(expenses);
    } else {
      return _buildPieChart(expenses);
    }
  }

  Widget _buildBarChart(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
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
                  value.toStringAsFixed(0),
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

  Widget _buildPieChart(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    double totalAmount = 0;

    // Calculate totals for each category
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
      totalAmount += expense.amount;
    }

    return Row(
      children: [
        // Pie Chart
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 150, // Reduced height
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
                        radius: 60, // Reduced radius
                        titleStyle: const TextStyle(
                          fontSize: 10, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 20, // Reduced center space
              ),
            ),
          ),
        ),
        // Legends
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  categoryTotals.entries.map((entry) {
                    final color =
                        Colors.primaries[categoryTotals.keys.toList().indexOf(
                              entry.key,
                            ) %
                            Colors.primaries.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
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
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${entry.key} (${_currencyFormat.format(entry.value)})',
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Time Frame Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'All', label: Text('All')),
                ButtonSegment(value: 'Today', label: Text('Today')),
                ButtonSegment(value: 'This Week', label: Text('This Week')),
                ButtonSegment(value: 'This Month', label: Text('This Month')),
              ],
              selected: {_selectedTimeFrame},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedTimeFrame = selection.first;
                });
              },
            ),
          ),

          // Chart Toggle
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

          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildChart(),
            ),
          ),

          // Expense Form
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items:
                          _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: _handleCategoryChange,
                    ),
                    if (_showCustomCategory) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Category',
                          prefixIcon: Icon(Icons.edit),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Add Expense'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
