import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/reports_entities.dart';

/// Generates professional PDF documents from reports data.
/// Used by datasources to implement generateReportPdf.
class ReportsPdfGenerator {
  /// Creates a PDF from [report] and saves it to ApplicationDocumentsDirectory.
  /// Returns the saved File. Filename format: report_<timestamp>.pdf
  Future<File> generate(ReportsData report) async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day}'
          '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}'
          '${now.second.toString().padLeft(2, '0')}';

      // Title page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Text(
              'Restaurant Reports - Main Branch',
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.grey700,
              ),
            ),
          ),
          footer: (context) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Restaurant Reports',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Generated: ${_formatDate(now)}',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 24),

            // Snapshot summary
            pw.Header(
              level: 1,
              child: pw.Text(
                report.snapshotBanner.title,
                style: const pw.TextStyle(fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              report.snapshotBanner.summary,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 24),

            // KPI Cards section
            pw.Header(
              level: 1,
              child: pw.Text(
                'Summary Totals',
                style: const pw.TextStyle(fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('Metric', isHeader: true),
                    _tableCell('Value', isHeader: true),
                    _tableCell('Change', isHeader: true),
                  ],
                ),
                ...report.kpiCards.map(
                  (kpi) => pw.TableRow(
                    children: [
                      _tableCell(kpi.label),
                      _tableCell(kpi.value),
                      _tableCell(kpi.delta),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Order funnel
            pw.Header(
              level: 1,
              child: pw.Text(
                'Order Funnel',
                style: const pw.TextStyle(fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('Stage', isHeader: true),
                    _tableCell('Value', isHeader: true),
                    _tableCell('Max', isHeader: true),
                  ],
                ),
                ...report.orderFunnel.map(
                  (stage) => pw.TableRow(
                    children: [
                      _tableCell(stage.label),
                      _tableCell(stage.value.toString()),
                      _tableCell(stage.max.toString()),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Top selling items
            pw.Header(
              level: 1,
              child: pw.Text(
                'Top Selling Items',
                style: const pw.TextStyle(fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('', isHeader: true),
                    _tableCell('Item', isHeader: true),
                    _tableCell('Revenue', isHeader: true),
                    _tableCell('Rank', isHeader: true),
                    _tableCell('Orders', isHeader: true),
                  ],
                ),
                ...report.topSellingItems.map(
                  (item) => pw.TableRow(
                    children: [
                      _tableCell(item.emoji),
                      _tableCell(item.name),
                      _tableCell(item.revenue),
                      _tableCell(item.rank),
                      _tableCell(item.orders),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Category sales
            pw.Header(
              level: 1,
              child: pw.Text(
                'Category Sales',
                style: const pw.TextStyle(fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('Category', isHeader: true),
                    _tableCell('Amount', isHeader: true),
                    _tableCell('%', isHeader: true),
                  ],
                ),
                ...report.categorySales.map(
                  (cat) => pw.TableRow(
                    children: [
                      _tableCell(cat.name),
                      _tableCell(cat.amount),
                      _tableCell(
                          '${(cat.percentage * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Staff performance
            pw.Header(
              level: 1,
              child: pw.Text(
                'Staff Performance',
                style: const pw.TextStyle(fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('Staff', isHeader: true),
                    _tableCell('Name', isHeader: true),
                    _tableCell('Orders', isHeader: true),
                    _tableCell('Upsells', isHeader: true),
                    _tableCell('Efficiency', isHeader: true),
                  ],
                ),
                ...report.staffPerformance.map(
                  (staff) => pw.TableRow(
                    children: [
                      _tableCell(staff.initial),
                      _tableCell(staff.name),
                      _tableCell(staff.orders),
                      _tableCell(staff.upsells),
                      _tableCell(staff.efficiency),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      // Use Downloads directory so the file is user-accessible
      final outputDir = await getDownloadsDirectory();
      final dirPath =
          outputDir?.path ?? (await getApplicationDocumentsDirectory()).path;
      final file = File('$dirPath/report_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
