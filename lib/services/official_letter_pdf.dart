import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'official_letter.dart';
import 'pdf_merge.dart';
import 'work_permit_letter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PDF export of an official letter (Phase 9). The letter itself is one
// plain A4 flow (same font approach as the Phase 8 work-permit PDF:
// Roboto primary, Noto Naskh Arabic fallback). Image attachments are
// appended as full pages; PDF attachments are appended afterwards by
// merging with the Phase 4 object-level merger. A PDF attachment the
// merger cannot read is counted in [OfficialPdfResult.skippedPdfs]
// instead of breaking the export.
// ─────────────────────────────────────────────────────────────────────────────

Future<({pw.Font regular, pw.Font bold, pw.Font arabic, pw.Font arabicBold})>?
_fontsFuture;

Future<({pw.Font regular, pw.Font bold, pw.Font arabic, pw.Font arabicBold})>
_loadFonts() {
  return _fontsFuture ??= () async {
    final regular = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final arabic = await rootBundle.load(
      'assets/fonts/NotoNaskhArabic-Regular.ttf',
    );
    final arabicBold = await rootBundle.load(
      'assets/fonts/NotoNaskhArabic-Bold.ttf',
    );
    return (
      regular: pw.Font.ttf(regular),
      bold: pw.Font.ttf(bold),
      arabic: pw.Font.ttf(arabic),
      arabicBold: pw.Font.ttf(arabicBold),
    );
  }();
}

class OfficialPdfResult {
  final Uint8List bytes;

  /// PDF attachments that could not be embedded (unsupported internal
  /// structure). The letter PDF is still complete without them.
  final int skippedPdfs;

  const OfficialPdfResult(this.bytes, this.skippedPdfs);
}

Future<OfficialPdfResult> buildOfficialLetterPdf(
  OfficialLetterData d,
  List<OfficialAttachment> attachments,
) async {
  final fonts = await _loadFonts();
  final theme = pw.ThemeData.withFont(
    base: fonts.regular,
    bold: fonts.bold,
    fontFallback: [fonts.arabic, fonts.arabicBold],
  );
  final doc = pw.Document(theme: theme);
  final bodyStyle = pw.TextStyle(font: fonts.regular, fontSize: 11);
  final boldStyle = pw.TextStyle(font: fonts.bold, fontSize: 11);

  final letter = buildOfficialLetter(d);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(56, 64, 56, 64),
      build: (context) => [
        for (final line in letter.split('\n'))
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

  // Image attachments become full pages after the letter.
  for (final a in attachments) {
    final bytes = a.bytes;
    if (!a.isImage || bytes == null) continue;
    final image = pw.MemoryImage(bytes);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(a.name, style: boldStyle),
            pw.SizedBox(height: 12),
            pw.Expanded(
              child: pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
            ),
          ],
        ),
      ),
    );
  }

  var bytes = await doc.save();

  // PDF attachments are appended by merging finished PDFs.
  final pdfParts = <Uint8List>[
    for (final a in attachments)
      if (a.isPdf && a.bytes != null) a.bytes!,
  ];
  var skipped = 0;
  if (pdfParts.isNotEmpty) {
    final merged = mergePdfDocuments([
      bytes,
      ...pdfParts,
    ], title: 'Behördenbrief');
    if (merged != null) {
      bytes = merged;
    } else {
      skipped = pdfParts.length;
    }
  }
  return OfficialPdfResult(bytes, skipped);
}

/// File stem per purpose, so the Downloads folder stays readable.
String _pdfStem(OfficialPurpose purpose) => switch (purpose) {
  OfficialPurpose.workPermit => 'Arbeitserlaubnis',
  OfficialPurpose.integrationCourse => 'Integrationskurs',
  OfficialPurpose.permitExtension => 'Termin_Verlaengerung',
  OfficialPurpose.appointmentGeneral => 'Termin',
  OfficialPurpose.appointmentRegistration => 'Termin_Anmeldung',
  OfficialPurpose.appointmentJob => 'Termin_Beratung',
  OfficialPurpose.submitDocuments => 'Unterlagen_Einreichung',
  OfficialPurpose.question => 'Behoerdenbrief',
};

/// File name for the exported letter PDF, e.g.
/// Unterlagen_Einreichung_Ahmad_Ahmadi.pdf.
String officialLetterPdfFileName(OfficialLetterData d) {
  final cleaned = d.senderName
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9ÄÖÜäöüß]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  final stem = _pdfStem(d.purpose);
  return cleaned.isEmpty ? '$stem.pdf' : '${stem}_$cleaned.pdf';
}

/// The letter date line reuses the Phase 8 helper export so the two
/// modules can never drift apart on format.
String officialLetterToday() => formatGermanDate(DateTime.now());
