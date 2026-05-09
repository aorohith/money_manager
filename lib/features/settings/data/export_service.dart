import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../transactions/data/models/category_model.dart';
import '../../transactions/data/models/transaction_model.dart';
import '../../transactions/data/repositories/transaction_repository.dart';

/// Builds CSV/PDF exports of the ledger.
///
/// All PDF rendering happens in an isolate via [compute] so a long ledger
/// doesn't freeze the UI when the user taps "Share".
class ExportService {
  static const String _notoSansRegularPath =
      'assets/fonts/NotoSans-Regular.ttf';
  static const String _notoSansBoldPath = 'assets/fonts/NotoSans-Bold.ttf';

  ExportService(this._txRepo, this._categories, {this.currencySymbol = r'$'});

  final TransactionRepository _txRepo;
  final List<CategoryModel> _categories;

  /// Currency symbol used inside generated reports. Defaults to `$` for
  /// callers that don't yet plumb the user's selected currency through.
  final String currencySymbol;

  Map<int, CategoryModel> get _catMap => {for (final c in _categories) c.id: c};

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<String> exportCsv() async {
    final txs = await _txRepo.getAll();
    final csv = const ListToCsvConverter().convert(buildCsvRows(txs));
    final file = await _newExportFile('csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> exportPdf() async {
    final txs = await _txRepo.getAll();
    final catMap = _catMap;
    final fmt = DateFormat('yyyy-MM-dd');
    final regularFontBytes = await rootBundle.load(_notoSansRegularPath);
    final boldFontBytes = await rootBundle.load(_notoSansBoldPath);

    final rows = txs
        .map(
          (tx) => _PdfRowDto(
            date: fmt.format(tx.date),
            type: tx.isIncome ? 'Income' : 'Expense',
            category: _sanitizePdfText(
              catMap[tx.categoryId]?.name ?? 'Unknown',
            ),
            amount: tx.amount,
            note: _sanitizePdfText(tx.note ?? ''),
          ),
        )
        .toList(growable: false);

    double totalIncome = 0, totalExpense = 0;
    for (final tx in txs) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    // Render the (CPU-heavy) PDF document in a background isolate so a
    // multi-thousand-row ledger doesn't freeze the share sheet animation.
    final bytes = await compute(
      _buildPdfBytes,
      _PdfBuildArgs(
        rows: rows,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        generatedOn: fmt.format(DateTime.now()),
        currencySymbol: currencySymbol,
        regularFontBytes: regularFontBytes.buffer.asUint8List(),
        boldFontBytes: boldFontBytes.buffer.asUint8List(),
      ),
    );

    final file = await _newExportFile('pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Best-effort cleanup of an export file produced by this service. Call
  /// after [Share.shareXFiles] resolves so we don't leave private financial
  /// data in the OS cache directory after the user has dismissed the sheet.
  static Future<void> deleteExportFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Swallow — the OS will reclaim the cache dir eventually.
    }
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

  /// Returns a unique [File] inside the OS cache dir. Uses [getApplicationCacheDirectory]
  /// in preference to `getTemporaryDirectory()` so the file participates in
  /// the platform's normal cache-eviction policy. The filename embeds a
  /// microsecond timestamp to avoid same-day collisions when the user
  /// re-exports.
  Future<File> _newExportFile(String extension) async {
    Directory dir;
    try {
      dir = await getApplicationCacheDirectory();
    } catch (_) {
      dir = await getTemporaryDirectory();
    }
    final fmt = DateFormat('yyyyMMdd_HHmmss');
    final stamp =
        '${fmt.format(DateTime.now())}_'
        '${DateTime.now().microsecondsSinceEpoch.remainder(1000000)}';
    return File('${dir.path}/transactions_$stamp.$extension');
  }

  List<dynamic> _csvRow(
    TransactionModel tx,
    Map<int, CategoryModel> catMap,
    DateFormat fmt,
  ) => [
    fmt.format(tx.date),
    tx.isIncome ? 'Income' : 'Expense',
    catMap[tx.categoryId]?.name ?? 'Unknown',
    tx.amount.toStringAsFixed(2),
    tx.note ?? '',
  ];

  /// Removes astral-plane glyphs (mostly emoji), which default PDF fonts
  /// cannot render reliably without a dedicated emoji fallback font.
  static String _sanitizePdfText(String input) {
    if (input.isEmpty) return input;
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune <= 0xFFFF) {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}

// ── Top-level isolate entrypoint ─────────────────────────────────────────────

@immutable
class _PdfRowDto {
  const _PdfRowDto({
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    required this.note,
  });

  final String date;
  final String type;
  final String category;
  final double amount;
  final String note;
}

@immutable
class _PdfBuildArgs {
  const _PdfBuildArgs({
    required this.rows,
    required this.totalIncome,
    required this.totalExpense,
    required this.generatedOn,
    required this.currencySymbol,
    required this.regularFontBytes,
    required this.boldFontBytes,
  });

  final List<_PdfRowDto> rows;
  final double totalIncome;
  final double totalExpense;
  final String generatedOn;
  final String currencySymbol;
  final Uint8List regularFontBytes;
  final Uint8List boldFontBytes;
}

/// Top-level so it can be hopped onto a background isolate via [compute].
Future<List<int>> _buildPdfBytes(_PdfBuildArgs args) async {
  final pdf = pw.Document();
  String money(double v) => '${args.currencySymbol}${v.toStringAsFixed(2)}';
  final baseFont = pw.Font.ttf(args.regularFontBytes.buffer.asByteData());
  final boldFont = pw.Font.ttf(args.boldFontBytes.buffer.asByteData());

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      maxPages: 1000,
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text(
            'Money Manager Report',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Paragraph(text: 'Generated on ${args.generatedOn}'),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Income: ${money(args.totalIncome)}'),
            pw.Text('Total Expense: ${money(args.totalExpense)}'),
            pw.Text('Net: ${money(args.totalIncome - args.totalExpense)}'),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
          ),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headers: ['Date', 'Type', 'Category', 'Amount', 'Note'],
          data: args.rows
              .map((r) => [r.date, r.type, r.category, money(r.amount), r.note])
              .toList(growable: false),
        ),
      ],
    ),
  );

  return pdf.save();
}
