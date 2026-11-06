import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/repositories.dart';
import '../models/cv_style.dart';
import '../models/document_template.dart';
import '../models/user_profile.dart';
import 'cv_pdf_generator.dart';
import 'letter_model.dart';
import 'pdf_merge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Anschreiben v2 rendering + Bewerbungsmappe (Phase 4).
//
// generateLetterPdf renders a FROZEN v2 letter (LetterData) exactly as
// stored: recipient lines, salutation, date and Anlagen all come from the
// saved payload, never recomposed and never placeholder-filled. The one
// design is deliberately close to the blauMinimal family so v2 letters
// sit naturally next to the v1 documents.
//
// buildBewerbungsmappe merges, in the German order employers expect:
//   Deckblatt -> Anschreiben -> Lebenslauf -> certificates.
// Certificates with an embeddable file (PDF in a supported structure, or
// an image) become pages; every certificate still appears in the
// Anschreiben's Anlagen list either way, and the result reports which
// ones could NOT be embedded so the UI can tell the user.
// ─────────────────────────────────────────────────────────────────────────────

Future<({pw.Font regular, pw.Font bold, pw.Font italic})>? _fontsFuture;

Future<({pw.Font regular, pw.Font bold, pw.Font italic})> _loadLetterFonts() {
  return _fontsFuture ??= () async {
    final regular = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final italic = await rootBundle.load('assets/fonts/Roboto-Italic.ttf');
    return (
      regular: pw.Font.ttf(regular),
      bold: pw.Font.ttf(bold),
      italic: pw.Font.ttf(italic),
    );
  }();
}

/// Place name for the date line: the profile city field may carry the
/// PLZ in front ('12345 Berlin'); the date line wants the place only.
String letterPlaceName(String cityField) {
  final t = cityField.trim();
  final m = RegExp(r'^\d{5}\s+(.+)$').firstMatch(t);
  return m != null ? m.group(1)!.trim() : t;
}

Future<Uint8List> generateLetterPdf(
  UserProfile profile,
  LetterData data,
) async {
  final fonts = await _loadLetterFonts();
  final navy = PdfColor.fromHex('#1A4A8A');
  const black = PdfColors.black;
  final doc = pw.Document(
    title: 'Anschreiben - ${profile.fullName}',
    author: 'KarYab',
  );
  final betreffLines = data.betreffText
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  final dateText = data.date.trim().isEmpty
      ? formatLetterDate(DateTime.now())
      : data.date.trim();
  final place = letterPlaceName(profile.city);
  final dateLine = place.isEmpty ? dateText : '$place, den $dateText';

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(48, 56, 48, 56),
      build: (context) => [
        // Sender block.
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              profile.fullName,
              style: pw.TextStyle(font: fonts.bold, fontSize: 13, color: navy),
            ),
            if (profile.fullAddress.trim().isNotEmpty &&
                profile.fullAddress.trim() != '—')
              pw.Text(
                profile.fullAddress,
                style: pw.TextStyle(font: fonts.regular, fontSize: 9.5),
              ),
            if (profile.phone.trim().isNotEmpty)
              pw.Text(
                profile.phone,
                style: pw.TextStyle(font: fonts.regular, fontSize: 9.5),
              ),
            if (profile.email.trim().isNotEmpty)
              pw.Text(
                profile.email,
                style: pw.TextStyle(font: fonts.regular, fontSize: 9.5),
              ),
          ],
        ),
        pw.SizedBox(height: 30),
        // Recipient block (only lines with real data).
        for (final line in data.recipientLines)
          pw.Text(
            line,
            style: pw.TextStyle(font: fonts.regular, fontSize: 10.5),
          ),
        pw.SizedBox(height: 24),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            dateLine,
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
        if (betreffLines.isNotEmpty) ...[
          pw.Text(
            betreffLines.first,
            style: pw.TextStyle(font: fonts.bold, fontSize: 11.5, color: navy),
          ),
          for (final extra in betreffLines.skip(1))
            pw.Text(
              extra,
              style: pw.TextStyle(font: fonts.regular, fontSize: 10),
            ),
          pw.SizedBox(height: 16),
        ],
        pw.Text(
          data.salutationLine,
          style: pw.TextStyle(font: fonts.regular, fontSize: 10.5),
        ),
        pw.SizedBox(height: 10),
        for (final para in data.bodyParagraphs) ...[
          pw.Text(
            para,
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
          pw.SizedBox(height: 10),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          'Mit freundlichen Grüßen',
          style: pw.TextStyle(
            font: fonts.regular,
            fontSize: 10.5,
            color: black,
          ),
        ),
        pw.SizedBox(height: 26),
        pw.Text(
          profile.fullName,
          style: pw.TextStyle(font: fonts.bold, fontSize: 11, color: navy),
        ),
        if (data.anlagenItems.isNotEmpty) ...[
          pw.SizedBox(height: 22),
          pw.Text(
            'Anlagen',
            style: pw.TextStyle(font: fonts.bold, fontSize: 10),
          ),
          pw.Text(
            data.anlagenItems.join(', '),
            style: pw.TextStyle(font: fonts.regular, fontSize: 10),
          ),
        ],
      ],
    ),
  );
  return doc.save();
}

/// One filename segment: letters, digits and a few safe characters only.
String sanitiseFileNamePart(String raw) {
  final cleaned = raw
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9ÄÖÜäöüß-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return cleaned;
}

/// Bewerbung_<Name>_<Company>.pdf (company segment omitted when empty).
String bewerbungFileName(String personName, String companyName) {
  final name = sanitiseFileNamePart(personName);
  final company = sanitiseFileNamePart(companyName);
  final buffer = StringBuffer('Bewerbung');
  if (name.isNotEmpty) buffer.write('_$name');
  if (company.isNotEmpty) buffer.write('_$company');
  buffer.write('.pdf');
  return buffer.toString();
}

class BewerbungsmappeResult {
  final Uint8List bytes;

  /// Certificate labels that appear in the Anlagen list but whose file
  /// could not be embedded as pages.
  final List<String> notEmbedded;

  /// Certificate labels whose file WAS embedded as pages.
  final List<String> embedded;

  const BewerbungsmappeResult({
    required this.bytes,
    required this.notEmbedded,
    required this.embedded,
  });
}

/// Renders one image file as a single-page PDF (for image certificates).
Future<Uint8List> _imageCertificatePdf(File file) async {
  final bytes = await file.readAsBytes();
  final image = pw.MemoryImage(bytes);
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) =>
          pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
    ),
  );
  return doc.save();
}

/// Builds the complete application folder as one PDF.
/// Returns null only when even the core three documents cannot be merged
/// (should not happen: all three are produced by the app's own generator).
Future<BewerbungsmappeResult?> buildBewerbungsmappe({
  required UserProfile profile,
  required LetterData letter,
  required List<CertificateRecord> certificates,
  CvDocumentRecord? cvDocument,
}) async {
  final deckblatt = await generateDeckblatt(
    profile,
    DeckblattTemplate.braunIconSet,
    isAusbildungCv: letter.isAusbildung,
    unterlagen: letter.anlagenItems,
  );
  final anschreiben = await generateLetterPdf(profile, letter);

  DocumentTemplate cvTemplate = DocumentTemplate.atsBlue;
  CvCustomisation? cvStyle;
  final cvDoc = cvDocument;
  if (cvDoc != null) {
    for (final t in DocumentTemplate.values) {
      if (t.name == cvDoc.templateId) cvTemplate = t;
    }
    cvStyle = CvCustomisation(
      accentColorHex: cvDoc.accentColor,
      fontSize: cvDoc.fontSize ?? 'normal',
      spacing: cvDoc.spacing ?? 'normal',
      showPhoto: cvDoc.showPhoto ?? true,
    );
  }
  final lebenslauf = await generateCv(
    profile,
    cvTemplate,
    isAusbildungCv: letter.isAusbildung,
    style: cvStyle,
  );

  final coreMerged = mergePdfDocuments([
    deckblatt,
    anschreiben,
    lebenslauf,
  ], title: bewerbungFileName(profile.fullName, letter.companyName));
  if (coreMerged == null) return null;
  Uint8List merged = coreMerged;

  final embedded = <String>[];
  final notEmbedded = <String>[];
  for (final cert in certificates) {
    final path = cert.filePath;
    if (path == null || path.trim().isEmpty) {
      notEmbedded.add(cert.label);
      continue;
    }
    try {
      final file = File(path);
      if (!await file.exists()) {
        notEmbedded.add(cert.label);
        continue;
      }
      final lower = path.toLowerCase();
      Uint8List? part;
      if (lower.endsWith('.pdf')) {
        part = await file.readAsBytes();
      } else if (lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png')) {
        part = await _imageCertificatePdf(file);
      }
      if (part == null) {
        notEmbedded.add(cert.label);
        continue;
      }
      final attempt = mergePdfDocuments([merged, part]);
      if (attempt == null) {
        notEmbedded.add(cert.label);
      } else {
        merged = attempt;
        embedded.add(cert.label);
      }
    } catch (_) {
      notEmbedded.add(cert.label);
    }
  }
  return BewerbungsmappeResult(
    bytes: merged,
    notEmbedded: notEmbedded,
    embedded: embedded,
  );
}
