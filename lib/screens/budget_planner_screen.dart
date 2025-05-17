import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(symbol: '₹');
  final List<BudgetCategory> _selectedCategories = [];
  bool _showIndividualExpenses = true;
  bool _showGroupExpenses = true;
  final _categoryNameController = TextEditingController();
  final _categoryAmountController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    _categoryNameController.dispose();
    _categoryAmountController.dispose();
    super.dispose();
  }

  void _handleSetBudget() {
    if (!_formKey.currentState!.validate()) return;

    final budget = double.parse(_budgetController.text);
    context.read<ExpenseProvider>().setBudget(budget);

    _budgetController.clear();
    setState(() {
      _selectedCategories.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budget set successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addCategory() {
    _categoryNameController.clear();
    _categoryAmountController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Budget Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _categoryNameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Budget Amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_categoryNameController.text.isNotEmpty &&
                      _categoryAmountController.text.isNotEmpty) {
                    final amount = double.tryParse(
                      _categoryAmountController.text,
                    );
                    if (amount != null) {
                      setState(() {
                        _selectedCategories.add(
                          BudgetCategory(
                            name: _categoryNameController.text,
                            amount: amount,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final budget = provider.budget;
        final totalBudgetedAmount = _selectedCategories.fold<double>(
          0,
          (sum, category) => sum + category.amount,
        );
        final remainingBudget = budget - totalBudgetedAmount;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Budget Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Budget',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currencyFormat.format(budget),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: (totalBudgetedAmount / budget).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            totalBudgetedAmount > budget
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${((totalBudgetedAmount / budget) * 100).toStringAsFixed(1)}% of budget allocated',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Budget Categories
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget Categories',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addCategory,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_selectedCategories.isEmpty)
                          const Center(child: Text('No categories added yet'))
                        else
                          ..._selectedCategories.map(
                            (category) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(category.name),
                                subtitle: Text(
                                  _currencyFormat.format(category.amount),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _selectedCategories.remove(category);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Budget Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow('Total Budget', budget, Colors.blue),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Total Allocated',
                          totalBudgetedAmount,
                          Colors.green,
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          remainingBudget >= 0
                              ? 'Remaining Budget'
                              : 'Amount Needed',
                          remainingBudget.abs(),
                          remainingBudget >= 0 ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Set Budget Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Set New Budget',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Budget Amount',
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a budget amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _handleSetBudget,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Set Budget'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          _currencyFormat.format(amount),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class BudgetCategory {
  final String name;
  final double amount;

  BudgetCategory({required this.name, required this.amount});
}
