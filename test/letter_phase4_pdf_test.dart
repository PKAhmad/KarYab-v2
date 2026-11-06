import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/data/repositories.dart';
import 'package:karyab/models/user_profile.dart';
import 'package:karyab/services/ats_checker.dart';
import 'package:karyab/services/letter_model.dart';
import 'package:karyab/services/letter_pdf.dart';
import 'package:karyab/services/pdf_merge.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> _docWithPages(double width, int pages, String title) async {
  final doc = pw.Document(title: title);
  for (var i = 0; i < pages; i++) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(width, 500),
        build: (c) => pw.Text('$title page $i'),
      ),
    );
  }
  return doc.save();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('pdf merge', () {
    test('merges in part order and keeps the total page count', () async {
      final a = await _docWithPages(300, 1, 'AlphaDoc');
      final b = await _docWithPages(400, 2, 'BetaDoc');
      final c = await _docWithPages(500, 1, 'GammaDoc');
      final merged = mergePdfDocuments([a, b, c], title: 'Merged')!;
      expect(countPdfPages(merged), 4);
      final text = latin1.decode(merged);
      // dart_pdf writes whole-point sizes as plain integers.
      final aAt = text.indexOf('/MediaBox[0 0 300 500]');
      final bAt = text.indexOf('/MediaBox[0 0 400 500]');
      final cAt = text.indexOf('/MediaBox[0 0 500 500]');
      expect(aAt, greaterThanOrEqualTo(0));
      expect(bAt, greaterThan(aAt), reason: 'Beta pages follow Alpha');
      expect(cAt, greaterThan(bAt), reason: 'Gamma pages follow Beta');
      expect(text.startsWith('%PDF-'), isTrue);
      expect(text.contains('%%EOF'), isTrue);
    });

    test('a single document merges with itself structurally intact', () async {
      final a = await _docWithPages(300, 2, 'Solo');
      final merged = mergePdfDocuments([a])!;
      expect(countPdfPages(merged), 2);
    });

    test('garbage input is rejected, not merged', () {
      expect(
        mergePdfDocuments([
          Uint8List.fromList([1, 2, 3]),
        ]),
        isNull,
      );
      expect(mergePdfDocuments(const []), isNull);
    });
  });

  group('letter pdf', () {
    const profile = UserProfile(
      fullName: 'Ahmad Rahimi',
      phone: '+49 151 23456789',
      email: 'ahmad@example.com',
      street: 'Musterstraße 12',
      city: '12345 Berlin',
      languages: ['pashto', 'german'],
      skill: 'forklift,packing',
      previousEmployers: ['Amazon'],
      previousJobTitles: ['Lagerhelfer'],
    );

    test('composed letter renders to exactly one page', () async {
      final (:data, reasons: _) = composeNewLetter(
        letterContextFromProfile(
          profile: profile,
          profileMap: const {},
          jobTitle: 'Lagerhelfer',
          companyName: 'DHL Paket GmbH',
          companyCity: 'Berlin',
          anlagenItems: const ['Lebenslauf'],
        ),
        now: DateTime(2026, 11, 6),
      );
      final bytes = await generateLetterPdf(profile, data);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(countPdfPages(bytes), 1);
    });

    test('filename is sanitised', () {
      expect(
        bewerbungFileName('Ahmad Rahimi', 'DHL Paket GmbH'),
        'Bewerbung_Ahmad_Rahimi_DHL_Paket_GmbH.pdf',
      );
      expect(
        bewerbungFileName('Ahmad Rahimi', ''),
        'Bewerbung_Ahmad_Rahimi.pdf',
      );
      expect(
        bewerbungFileName('A/B: C', 'Firma (Neu)'),
        'Bewerbung_A_B_C_Firma_Neu.pdf',
      );
    });
  });

  group('bewerbungsmappe', () {
    const profile = UserProfile(
      fullName: 'Ahmad Rahimi',
      phone: '+49 151 23456789',
      email: 'ahmad@example.com',
      street: 'Musterstraße 12',
      city: '12345 Berlin',
      languages: ['pashto', 'german'],
      skill: 'forklift,packing',
      previousEmployers: ['Amazon'],
      previousJobTitles: ['Lagerhelfer'],
    );

    // Small valid 4x4 PNG (the classic 1x1 snippet is not decodable by
    // the pdf package's image decoder).
    final pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAIAAAAmkwkpAAAAEElEQVR4nGM4'
      'oaEBRwzEcQDRQxGBSNLB6wAAAABJRU5ErkJggg==',
    );

    test('order Deckblatt, Anschreiben, Lebenslauf, then embeddable certs; '
        'non-embeddable certs are only reported', () async {
      final dir = await Directory.systemTemp.createTemp('mappe_test');
      addTearDown(() => dir.delete(recursive: true));
      final imgFile = File('${dir.path}/zeugnis.png');
      await imgFile.writeAsBytes(pngBytes);
      final fakePdf = File('${dir.path}/zeugnis.pdf');
      await fakePdf.writeAsBytes([1, 2, 3, 4]);

      final (:data, reasons: _) = composeNewLetter(
        letterContextFromProfile(
          profile: profile,
          profileMap: const {},
          jobTitle: 'Lagerhelfer',
          companyName: 'DHL Paket GmbH',
          companyCity: 'Berlin',
          anlagenItems: const ['Lebenslauf', 'Zeugnisse', 'Sprachzertifikat'],
        ),
        now: DateTime(2026, 11, 6),
      );

      final now = DateTime(2026, 11, 6);
      final certs = [
        CertificateRecord(
          id: 1,
          label: 'Zeugnisse',
          kind: 'zeugnisse',
          filePath: imgFile.path,
          createdAt: now,
        ),
        CertificateRecord(
          id: 2,
          label: 'Sprachzertifikat',
          kind: 'sprachzertifikat',
          filePath: fakePdf.path,
          createdAt: now,
        ),
        CertificateRecord(
          id: 3,
          label: 'Führerschein',
          kind: 'fuehrerschein',
          createdAt: now,
        ),
      ];

      final result = await buildBewerbungsmappe(
        profile: profile,
        letter: data,
        certificates: certs,
      );
      expect(result, isNotNull);
      final pages = countPdfPages(result!.bytes);
      // Deckblatt (1) + Anschreiben (1) + Lebenslauf (>=1) + image (1).
      expect(pages, greaterThanOrEqualTo(4));
      expect(result.embedded, ['Zeugnisse']);
      expect(
        result.notEmbedded,
        containsAll(['Sprachzertifikat', 'Führerschein']),
      );
      // Without the image certificate the mappe would have one page less.
      final noCerts = await buildBewerbungsmappe(
        profile: profile,
        letter: data,
        certificates: const [],
      );
      expect(countPdfPages(noCerts!.bytes), pages - 1);
    });
  });
}
