import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExportService {
  static Future<void> exportToCSV(List<Expense> expenses) async {
    try {
      // Create CSV content
      final csvContent = _createCSVContent(expenses);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd').format(DateTime.now());
      final file = File('${directory.path}/expenses_export_$timestamp.csv');

      // Write CSV content to file
      await file.writeAsString(csvContent);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Expense Tracker Export',
        subject: 'Expense Tracker Export - $timestamp',
      );
    } catch (e) {
      rethrow;
    }
  }

  static String _createCSVContent(List<Expense> expenses) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    // Create CSV header
    final header = 'Description,Category,Amount,Date\n';

    // Create CSV rows
    final rows = expenses
        .map((expense) {
          return [
            _escapeCSV(expense.description),
            expense.category.name,
            currencyFormat.format(expense.amount),
            dateFormat.format(expense.date),
          ].join(',');
        })
        .join('\n');

    return header + rows;
  }

  static String _escapeCSV(String field) {
    // Escape quotes and wrap in quotes if contains comma or quote
    if (field.contains(',') || field.contains('"')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
