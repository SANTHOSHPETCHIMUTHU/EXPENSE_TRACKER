import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SavingsInput extends StatelessWidget {
  final double initialSavings;
  final Function(double) onSavingsChanged;

  const SavingsInput({
    super.key,
    required this.initialSavings,
    required this.onSavingsChanged,
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
              'Initial Savings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: initialSavings.toString(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.account_balance_wallet),
                hintText: 'Enter your initial savings',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  onSavingsChanged(double.parse(value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
