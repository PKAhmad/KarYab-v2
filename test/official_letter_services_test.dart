import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:karyab/services/official_letter.dart';
import 'package:karyab/services/official_letter_pdf.dart';
import 'package:karyab/services/official_letter_send.dart';
import 'package:pdf/widgets.dart' as pw;

OfficialLetterData _data() => const OfficialLetterData(
  senderName: 'Ahmad Ahmadi',
  senderStreet: 'Musterstraße 12',
  senderCity: '10115 Berlin',
  officeType: OfficeType.jobcenter,
  officeName: 'Jobcenter Berlin Mitte',
  officeEmail: 'post@jobcenter-berlin.de',
  purpose: OfficialPurpose.appointmentJob,
  terminTopic: 'Ausbildung',
  today: '06.11.2026',
);

// A 1x1 transparent PNG.
final Uint8List _pngBytes = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfficialLetterMailer (Phase 9)', () {
    test(
      'composes with recipient, subject, body and the PDF attached',
      () async {
        Email? captured;
        final dir = await Directory.systemTemp.createTemp('ol_mailer');
        final mailer = OfficialLetterMailer(
          tempDirFn: () async => dir,
          sendFn: (email) async => captured = email,
        );
        final outcome = await mailer.composeWithPdf(
          data: _data(),
          letter: 'Sehr geehrte Damen und Herren, ...',
          pdfBytes: Uint8List.fromList([1, 2, 3]),
          pdfFileName: 'Termin_Beratung_Ahmad_Ahmadi.pdf',
        );
        expect(outcome, OfficialSendOutcome.composed);
        expect(captured, isNotNull);
        expect(captured!.recipients, ['post@jobcenter-berlin.de']);
        expect(captured!.subject, 'Terminanfrage: Arbeit und Ausbildung');
        expect(captured!.body, contains('Sehr geehrte Damen und Herren'));
        expect(captured!.isHTML, isFalse);
        expect(captured!.attachmentPaths, hasLength(1));
        final written = File(captured!.attachmentPaths!.single);
        expect(await written.exists(), isTrue);
        expect(await written.readAsBytes(), [1, 2, 3]);
        await dir.delete(recursive: true);
      },
    );

    test('plugin failure becomes the fallback outcome', () async {
      final mailer = OfficialLetterMailer(
        tempDirFn: () async => Directory.systemTemp,
        sendFn: (email) async => throw StateError('no mail app'),
      );
      final outcome = await mailer.composeWithPdf(
        data: _data(),
        letter: 'Brief',
        pdfBytes: Uint8List.fromList([1]),
        pdfFileName: 'x.pdf',
      );
      expect(outcome, OfficialSendOutcome.fallback);
    });

    test('temp dir failure becomes the fallback outcome', () async {
      final mailer = OfficialLetterMailer(
        tempDirFn: () async => throw StateError('no tmp'),
        sendFn: (email) async {},
      );
      final outcome = await mailer.composeWithPdf(
        data: _data(),
        letter: 'Brief',
        pdfBytes: Uint8List.fromList([1]),
        pdfFileName: 'x.pdf',
      );
      expect(outcome, OfficialSendOutcome.fallback);
    });
  });

  group('official letter PDF (Phase 9)', () {
    test('file name carries the purpose stem and the sender', () {
      expect(
        officialLetterPdfFileName(_data()),
        'Termin_Beratung_Ahmad_Ahmadi.pdf',
      );
      const noName = OfficialLetterData(
        senderName: '',
        senderStreet: '',
        senderCity: '',
        officeType: OfficeType.other,
        officeName: 'Amt',
        officeEmail: 'a@b.de',
        purpose: OfficialPurpose.submitDocuments,
        today: '06.11.2026',
      );
      expect(officialLetterPdfFileName(noName), 'Unterlagen_Einreichung.pdf');
    });

    test('letter only: a valid PDF, nothing skipped', () async {
      final result = await buildOfficialLetterPdf(_data(), const []);
      expect(result.skippedPdfs, 0);
      expect(String.fromCharCodes(result.bytes.take(5)), '%PDF-');
      expect(result.bytes.length, greaterThan(2000));
    });

    test('an image attachment becomes a page in the same PDF', () async {
      final plain = await buildOfficialLetterPdf(_data(), const []);
      final withImage = await buildOfficialLetterPdf(_data(), [
        OfficialAttachment(
          name: 'bescheid.jpg',
          bytes: _pngBytes,
          sizeBytes: 67,
        ),
      ]);
      expect(withImage.skippedPdfs, 0);
      expect(withImage.bytes.length, greaterThan(plain.bytes.length));
    });

    test('a readable PDF attachment is merged in', () async {
      final extra = pw.Document();
      extra.addPage(pw.Page(build: (c) => pw.Text('Anhang')));
      final extraBytes = await extra.save();
      final result = await buildOfficialLetterPdf(_data(), [
        OfficialAttachment(
          name: 'vertrag.pdf',
          bytes: extraBytes,
          sizeBytes: extraBytes.length,
        ),
      ]);
      expect(result.skippedPdfs, 0);
      expect(String.fromCharCodes(result.bytes.take(5)), '%PDF-');
    });

    test('an unreadable PDF attachment is skipped, letter survives', () async {
      final result = await buildOfficialLetterPdf(_data(), [
        OfficialAttachment(
          name: 'kaputt.pdf',
          bytes: Uint8List.fromList('kein pdf'.codeUnits),
          sizeBytes: 8,
        ),
      ]);
      expect(result.skippedPdfs, 1);
      expect(String.fromCharCodes(result.bytes.take(5)), '%PDF-');
    });
  });
}
