import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../transactions/data/models/category_model.dart';
import '../../transactions/data/models/transaction_model.dart';
import '../../transactions/data/repositories/transaction_repository.dart';

class ExportService {
  ExportService(this._txRepo, this._categories);

  final TransactionRepository _txRepo;
  final List<CategoryModel> _categories;

  Map<int, CategoryModel> get _catMap =>
      {for (final c in _categories) c.id: c};

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<String> exportCsv() async {
    final txs = await _txRepo.getAll();
    final csv = const ListToCsvConverter().convert(buildCsvRows(txs));
    final fmt = DateFormat('yyyy-MM-dd');
    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/transactions_${fmt.format(DateTime.now())}.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> exportPdf() async {
    final txs = await _txRepo.getAll();
    final catMap = _catMap;
    final fmt = DateFormat('yyyy-MM-dd');

    final pdf = pw.Document();

    double totalIncome = 0, totalExpense = 0;
    for (final tx in txs) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Money Manager Report',
              style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Paragraph(
              text: 'Generated on ${fmt.format(DateTime.now())}'),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                  'Total Income: \$${totalIncome.toStringAsFixed(2)}'),
              pw.Text(
                  'Total Expense: \$${totalExpense.toStringAsFixed(2)}'),
              pw.Text(
                  'Net: \$${(totalIncome - totalExpense).toStringAsFixed(2)}'),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: ['Date', 'Type', 'Category', 'Amount', 'Note'],
            data: txs.map((tx) => _pdfRow(tx, catMap, fmt)).toList(),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file =
        File('${dir.path}/transactions_${fmt.format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  // ── Pure helpers (unit-testable) ───────────────────────────────────────────

  /// Returns the full row list (header + data) for CSV conversion.
  ///
  /// Exposed for unit tests — no I/O involved.
  List<List<dynamic>> buildCsvRows(List<TransactionModel> txs) {
    final catMap = _catMap;
    final fmt = DateFormat('yyyy-MM-dd');
    return [
      ['Date', 'Type', 'Category', 'Amount', 'Note'],
      ...txs.map((tx) => _csvRow(tx, catMap, fmt)),
    ];
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  List<dynamic> _csvRow(
    TransactionModel tx,
    Map<int, CategoryModel> catMap,
    DateFormat fmt,
  ) =>
      [
        fmt.format(tx.date),
        tx.isIncome ? 'Income' : 'Expense',
        catMap[tx.categoryId]?.name ?? 'Unknown',
        tx.amount.toStringAsFixed(2),
        tx.note ?? '',
      ];

  List<dynamic> _pdfRow(
    TransactionModel tx,
    Map<int, CategoryModel> catMap,
    DateFormat fmt,
  ) =>
      [
        fmt.format(tx.date),
        tx.isIncome ? 'Income' : 'Expense',
        catMap[tx.categoryId]?.name ?? 'Unknown',
        '\$${tx.amount.toStringAsFixed(2)}',
        tx.note ?? '',
      ];
}
