import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'work_permit_letter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PDF export of the Ausländerbehörde work-permission letter (Phase 8).
// One plain A4 letter page flow, no template. Fonts follow the letter
// generator's approach (Phase 5): Roboto primary, Noto Naskh Arabic as
// fallback so Arabic-script names in the sender data keep their glyphs.
// ─────────────────────────────────────────────────────────────────────────────

Future<
    ({
      pw.Font regular,
      pw.Font bold,
      pw.Font italic,
      pw.Font arabic,
      pw.Font arabicBold
    })>? _fontsFuture;

Future<
    ({
      pw.Font regular,
      pw.Font bold,
      pw.Font italic,
      pw.Font arabic,
      pw.Font arabicBold
    })> _loadFonts() {
  return _fontsFuture ??= () async {
    final regular = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final arabic =
        await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
    final arabicBold =
        await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf');
    return (
      regular: pw.Font.ttf(regular),
      bold: pw.Font.ttf(bold),
      italic: pw.Font.ttf(regular),
      arabic: pw.Font.ttf(arabic),
      arabicBold: pw.Font.ttf(arabicBold),
    );
  }();
}

Future<Uint8List> buildWorkPermitPdf(WorkPermitData d) async {
  final fonts = await _loadFonts();
  final theme = pw.ThemeData.withFont(
    base: fonts.regular,
    bold: fonts.bold,
    italic: fonts.italic,
    fontFallback: [fonts.arabic, fonts.arabicBold],
  );
  final doc = pw.Document(theme: theme);
  final bodyStyle = pw.TextStyle(font: fonts.regular, fontSize: 11);
  final boldStyle = pw.TextStyle(font: fonts.bold, fontSize: 11);

  final paragraphs = buildWorkPermitLetter(d).split('\n');
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(56, 64, 56, 64),
      build: (context) => [
        for (final line in paragraphs)
          if (line.startsWith('Betreff:'))
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(line, style: boldStyle),
            )
          else
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(line, style: bodyStyle),
            ),
      ],
    ),
  );
  return doc.save();
}

/// File name for the exported letter PDF, e.g.
/// Arbeitserlaubnis_Ahmad_Ahmadi.pdf (umlauts kept, specials folded).
String workPermitPdfFileName(String senderName) {
  final cleaned = senderName
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9ÄÖÜäöüß]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return cleaned.isEmpty
      ? 'Arbeitserlaubnis.pdf'
      : 'Arbeitserlaubnis_$cleaned.pdf';
}
