import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flchart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_form.dart';
import '../widgets/expense_list.dart';
import '../widgets/savings_input.dart';
import '../widgets/totals_display.dart';
import '../widgets/expense_charts.dart';
import '../services/export_service.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  Future<void> _handleExport(
    BuildContext context,
    List<Expense> expenses,
  ) async {
    try {
      await ExportService.exportToCSV(expenses);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expenses exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export expenses: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.expenses.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _handleExport(context, expenseProvider.expenses),
            icon: const Icon(Icons.file_download),
            label: const Text('Export CSV'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          );
        },
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SavingsInput(
                  initialSavings: expenseProvider.savings,
                  onSavingsChanged:
                      (value) => expenseProvider.setSavings(value),
                ),
                const SizedBox(height: 24),
                TotalsDisplay(
                  totalExpenses: expenseProvider.totalExpenses,
                  remainingSavings: expenseProvider.remainingSavings,
                  initialSavings: expenseProvider.savings,
                ),
                const SizedBox(height: 24),
                ExpenseCharts(
                  categoryTotals: expenseProvider.getCategoryTotals(),
                  remainingSavings: expenseProvider.remainingSavings,
                  initialSavings: expenseProvider.savings,
                ),
                const SizedBox(height: 24),
                const ExpenseForm(),
                const SizedBox(height: 24),
                ExpenseList(
                  expenses: expenseProvider.expenses,
                  onDelete: (id) => expenseProvider.deleteExpense(id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
