import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<void> generateAndShareTestResults(
    List<Map<String, dynamic>> testResults,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Laporan Hasil Assessment',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Dicetak pada: ${dateFormat.format(now)}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(thickness: 2, color: PdfColors.blue900),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Tes', '${testResults.length}'),
                _buildSummaryItem('Selesai', '${testResults.length}'),
              ],
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Test Results
          pw.Text(
            'Hasil Assessment',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          
          pw.SizedBox(height: 16),
          
          ...testResults.map((result) => _buildTestResultCard(result)).toList(),
        ],
      ),
    );

    // Share or save PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Laporan_Assessment_${DateFormat('yyyyMMdd').format(now)}.pdf',
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTestResultCard(Map<String, dynamic> result) {
    final resultData = result['resultData'] as Map<String, dynamic>;
    final testTitle = result['testTitle'] as String;
    final date = DateTime.parse(result['date']);
    final formattedDate = DateFormat('dd MMM yyyy').format(date);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                testTitle,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'Selesai',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.green900,
                  ),
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 8),
          
          pw.Text(
            'Tanggal: $formattedDate',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 12),
          
          // Specific data based on test type
          if (testTitle.contains('BMI')) ...[
            _buildResultRow('BMI:', '${resultData['bmi']?.toStringAsFixed(1)}'),
            _buildResultRow('Kategori:', '${resultData['category']}'),
            _buildResultRow('Tinggi:', '${resultData['height']} cm'),
            _buildResultRow('Berat:', '${resultData['weight']} kg'),
          ] else if (testTitle.contains('Big Five')) ...[
            pw.Text(
              'Dimensi Kepribadian:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 8),
            if (resultData['dimensions'] != null) ...[
              ...((resultData['dimensions'] as Map<String, dynamic>).entries.map(
                (entry) => _buildResultRow(
                  _getDimensionLabel(entry.key),
                  '${(entry.value as double).toStringAsFixed(1)}/5.0',
                ),
              )),
            ],
          ] else if (testTitle.contains('Burnout')) ...[
            _buildResultRow('Skor Burnout:', '${resultData['burnoutScore']?.toStringAsFixed(1)}%'),
            _buildResultRow('Level:', '${resultData['level']}'),
          ],
          
          if (resultData['description'] != null) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Deskripsi:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '${resultData['description']}',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildResultRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  static String _getDimensionLabel(String key) {
    switch (key) {
      case 'openness':
        return 'Keterbukaan';
      case 'conscientiousness':
        return 'Kesadaran';
      case 'extraversion':
        return 'Ekstraversi';
      case 'agreeableness':
        return 'Keramahan';
      case 'neuroticism':
        return 'Neurotisisme';
      default:
        return key;
    }
  }
}
