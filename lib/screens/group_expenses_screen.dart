import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/group_expense.dart';

class GroupExpensesScreen extends StatefulWidget {
  const GroupExpensesScreen({super.key});

  @override
  State<GroupExpensesScreen> createState() => _GroupExpensesScreenState();
}

class _GroupExpensesScreenState extends State<GroupExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _percentageControllers = [];
  bool _isEqualShare = true;
  final _currencyFormat = NumberFormat.currency(symbol: '₹');
  List<GroupPerson>? _currentSplit;

  @override
  void initState() {
    super.initState();
    _addPerson();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    for (final controller in _percentageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPerson() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _percentageControllers.add(TextEditingController());
    });
  }

  void _removePerson(int index) {
    setState(() {
      _nameControllers[index].dispose();
      _percentageControllers[index].dispose();
      _nameControllers.removeAt(index);
      _percentageControllers.removeAt(index);
    });
  }

  void _showSplitDetails() {
    if (!_formKey.currentState!.validate()) return;

    final totalAmount = double.parse(_amountController.text);
    final people = <GroupPerson>[];

    // Calculate shares
    for (int i = 0; i < _nameControllers.length; i++) {
      final name = _nameControllers[i].text;
      double amount;

      if (_isEqualShare) {
        amount = totalAmount / _nameControllers.length;
      } else {
        final percentage = double.parse(_percentageControllers[i].text);
        amount = totalAmount * (percentage / 100);
      }

      people.add(GroupPerson(name: name, amount: amount));
    }

    setState(() {
      _currentSplit = people;
    });
  }

  void _clearSplit() {
    setState(() {
      _currentSplit = null;
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final totalAmount = double.parse(_amountController.text);
    final people = <GroupPerson>[];

    // Calculate shares
    for (int i = 0; i < _nameControllers.length; i++) {
      final name = _nameControllers[i].text;
      double amount;

      if (_isEqualShare) {
        amount = totalAmount / _nameControllers.length;
      } else {
        final percentage = double.parse(_percentageControllers[i].text);
        amount = totalAmount * (percentage / 100);
      }

      people.add(GroupPerson(name: name, amount: amount));
    }

    final groupExpense = GroupExpense(
      description: _descriptionController.text,
      totalAmount: totalAmount,
      people: people,
      date: DateTime.now(),
    );

    context.read<ExpenseProvider>().addGroupExpense(groupExpense);

    // Reset form
    _descriptionController.clear();
    _amountController.clear();
    for (final controller in _nameControllers) {
      controller.clear();
    }
    for (final controller in _percentageControllers) {
      controller.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Group expense added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Description
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

              // Total Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Amount',
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
              const SizedBox(height: 24),

              // Share Type Toggle
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Equal Share'),
                    icon: Icon(Icons.equalizer),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Custom Share'),
                    icon: Icon(Icons.edit),
                  ),
                ],
                selected: {_isEqualShare},
                onSelectionChanged: (Set<bool> selection) {
                  setState(() {
                    _isEqualShare = selection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // People List
              ...List.generate(_nameControllers.length, (index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Person ${index + 1}',
                                  prefixIcon: const Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (!_isEqualShare) ...[
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: _percentageControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Percentage',
                                    suffixText: '%',
                                  ),
                                  validator: (value) {
                                    if (!_isEqualShare) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final percentage = double.tryParse(value);
                                      if (percentage == null ||
                                          percentage < 0 ||
                                          percentage > 100) {
                                        return 'Invalid %';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                            if (_nameControllers.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                                onPressed: () => _removePerson(index),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Add Person Button
              OutlinedButton.icon(
                onPressed: _addPerson,
                icon: const Icon(Icons.add),
                label: const Text('Add Person'),
              ),
              const SizedBox(height: 24),

              // Preview Split Button
              OutlinedButton.icon(
                onPressed: _showSplitDetails,
                icon: const Icon(Icons.calculate),
                label: const Text('Preview Split'),
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add Group Expense'),
              ),
              const SizedBox(height: 24),

              // Split Details Section
              if (_currentSplit != null) ...[
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
                              'Split Details',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _clearSplit,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total Amount: ${_currencyFormat.format(double.parse(_amountController.text))}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ..._currentSplit!.map(
                          (person) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  person.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  _currencyFormat.format(person.amount),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
