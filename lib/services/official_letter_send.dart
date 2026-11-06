import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

import 'official_letter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Email sending for official letters (Phase 9). The letter is NEVER
// sent silently by the app: flutter_email_sender opens the user's own
// mail app with recipient, subject, letter text and the merged PDF
// attached, and the user presses Send there. When the plugin cannot
// compose (no mail app, platform error), the caller falls back to the
// two-step flow: a mailto compose for the text, then the share sheet
// for the PDF, explained to the user before it starts.
//
// The plugin call and the temp directory sit behind injectable
// functions (same pattern as AuthService / DictationService), so the
// outcome logic is unit-testable without a device.
// ─────────────────────────────────────────────────────────────────────────────

typedef OfficialEmailSendFn = Future<void> Function(Email email);
typedef OfficialTempDirFn = Future<Directory> Function();

enum OfficialSendOutcome {
  /// The mail app opened with text + PDF attached.
  composed,

  /// The plugin could not compose; the caller runs the two-step
  /// fallback (mailto text + share the PDF).
  fallback,
}

class OfficialLetterMailer {
  final OfficialEmailSendFn _sendFn;
  final OfficialTempDirFn _tempDirFn;

  OfficialLetterMailer({
    OfficialEmailSendFn? sendFn,
    OfficialTempDirFn? tempDirFn,
  }) : _sendFn = sendFn ?? FlutterEmailSender.send,
       _tempDirFn = tempDirFn ?? getTemporaryDirectory;

  /// Writes the PDF to a temp file and asks the mail app to compose
  /// the email to the office. Any failure (temp write, missing mail
  /// app, plugin error) becomes [OfficialSendOutcome.fallback].
  Future<OfficialSendOutcome> composeWithPdf({
    required OfficialLetterData data,
    required String letter,
    required Uint8List pdfBytes,
    required String pdfFileName,
  }) async {
    File file;
    try {
      final dir = await _tempDirFn();
      file = File('${dir.path}/$pdfFileName');
      await file.writeAsBytes(pdfBytes, flush: true);
    } catch (_) {
      return OfficialSendOutcome.fallback;
    }
    try {
      await _sendFn(
        Email(
          body: letter,
          subject: officialLetterSubject(data),
          recipients: [data.officeEmail],
          attachmentPaths: [file.path],
          isHTML: false,
        ),
      );
      return OfficialSendOutcome.composed;
    } catch (_) {
      return OfficialSendOutcome.fallback;
    }
  }
}
