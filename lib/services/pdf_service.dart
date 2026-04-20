import 'dart:typed_data';

import 'package:flutter_demo_ui/data/item_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<Uint8List> generateItemPdf(ItemModel item) async {
    final document = pw.Document();
    final rarityColor = _getRarityColor(item.rarity);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(12),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: const PdfColor(0.96, 0.90, 0.78),
              border: pw.Border.all(
                color: const PdfColor(0.54, 0.42, 0.24),
                width: 1.5,
              ),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item.name,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor(0.29, 0.20, 0.08),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  '${item.type} - ${item.rarity}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: rarityColor,
                  ),
                ),
                if (item.attunement) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Requires Attunement',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      color: const PdfColor(0.37, 0.24, 0.13),
                    ),
                  ),
                ],
                if (item.charges != null) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Charges: ${item.charges}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor(0.29, 0.20, 0.08),
                    ),
                  ),
                ],
                pw.SizedBox(height: 10),
                pw.Text(
                  item.description,
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColor(0.24, 0.17, 0.11),
                    lineSpacing: 2,
                  ),
                ),
                if (item.flavorText != null &&
                    item.flavorText!.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 10),
                  pw.Text(
                    '"${item.flavorText!.trim()}"',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColor(0.42, 0.35, 0.27),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

    return document.save();
  }

  Future<void> printItem(ItemModel item) async {
    final pdfData = await generateItemPdf(item);
    await Printing.layoutPdf(
      onLayout: (format) async => pdfData,
    );
  }

  Future<void> saveItemPdf(ItemModel item) async {
    final pdfData = await generateItemPdf(item);
    final filename = _buildFilename(item);

    await Printing.sharePdf(
      bytes: pdfData,
      filename: filename,
    );
  }

  PdfColor _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return PdfColors.grey700;
      case 'uncommon':
        return PdfColors.green700;
      case 'rare':
        return PdfColors.blue700;
      case 'epic':
      case 'very rare':
        return PdfColors.purple700;
      case 'legendary':
        return PdfColors.orange800;
      default:
        return PdfColors.brown700;
    }
  }

  String _buildFilename(ItemModel item) {
    final sanitized = item.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return sanitized.isEmpty ? 'dnd_item.pdf' : '${sanitized}.pdf';
  }
}
