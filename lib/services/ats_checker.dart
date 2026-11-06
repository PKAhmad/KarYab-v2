import 'dart:convert';
import 'dart:typed_data';

import '../models/document_template.dart';
import '../models/user_profile.dart';
import 'cv_completion.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ATS checker (Phase 3) - pure logic, run on the preview screens.
//
// Produces traffic-light items about how the generated CV will fare with
// applicant tracking systems and human readers. It NEVER blocks the
// export: every item is advice, and most items know the wizard section
// they belong to so the UI can jump straight to the fix.
//
// German spellcheck is deliberately NOT part of this checker: there is no
// offline German dictionary available to the app, and adding a network
// spellcheck service is a product decision for the CEO (needs a provider
// and keys). See PHASE3-CV-REPORT.md, deferred items.
// ─────────────────────────────────────────────────────────────────────────────

enum AtsLevel { ok, warn, problem }

class AtsCheckItem {
  /// Stable message key - the UI maps it to a localised string.
  final String key;
  final AtsLevel level;

  /// Wizard section this item belongs to ('skills', 'languages', ...),
  /// 'personal' for personal-data fields, or null when it has no fix
  /// location (e.g. page count).
  final String? section;

  /// Extra payload for the message (section key for 'sectionOmitted',
  /// page count for 'pages').
  final String detail;

  const AtsCheckItem(
    this.key,
    this.level, {
    this.section,
    this.detail = '',
  });
}

/// Counts the pages of a generated PDF. The `pdf` package writes plain
/// object headers, so page objects can be counted in the raw bytes
/// ('/Type /Page' not followed by 's', which would be the '/Pages' tree).
/// Returns 0 when nothing plausible was found.
int countPdfPages(Uint8List bytes) {
  if (bytes.isEmpty) return 0;
  final text = latin1.decode(bytes, allowInvalid: true);
  final matches = RegExp(r'/Type\s*/Page(?![\w])').allMatches(text).length;
  if (matches > 0) return matches;
  return RegExp(r'/Type\s*/Pages(?![\w])').allMatches(text).isNotEmpty ? 1 : 0;
}

List<AtsCheckItem> runAtsChecks({
  required UserProfile profile,
  required DocumentTemplate template,
  required Map<String, dynamic> payload,
  required String kind,
  required bool showPhoto,
  int? pageCount,
}) {
  final items = <AtsCheckItem>[];

  // Page count: German CVs are expected to be 1 to 2 pages.
  if (pageCount != null && pageCount > 0) {
    items.add(AtsCheckItem(
      'pages',
      pageCount <= 2 ? AtsLevel.ok : AtsLevel.warn,
      detail: pageCount.toString(),
    ));
  }

  // Template shape: atsBlue is the single-column, no-photo ATS layout.
  final hasPhoto =
      showPhoto && (profile.photoPath?.trim().isNotEmpty ?? false);
  if (template == DocumentTemplate.atsBlue) {
    items.add(const AtsCheckItem('templateAts', AtsLevel.ok));
  } else if (hasPhoto) {
    items.add(const AtsCheckItem('templateLayoutPhoto', AtsLevel.warn));
  } else {
    items.add(const AtsCheckItem('templateLayout', AtsLevel.ok));
  }

  // Contact data is what an ATS (and a recruiter) matches on first.
  if (profile.email.trim().isEmpty) {
    items.add(const AtsCheckItem('email', AtsLevel.problem,
        section: 'personal'));
  } else {
    items.add(const AtsCheckItem('email', AtsLevel.ok, section: 'personal'));
  }
  if (profile.phone.trim().isEmpty) {
    items.add(const AtsCheckItem('phone', AtsLevel.problem,
        section: 'personal'));
  } else {
    items.add(const AtsCheckItem('phone', AtsLevel.ok, section: 'personal'));
  }

  // Skills and languages are the two sections keyword matching relies on.
  if (!cvSectionFilled(payload, kind, 'skills') &&
      kind != 'ausbildung') {
    items.add(const AtsCheckItem('skills', AtsLevel.warn, section: 'skills'));
  }
  if (kind == 'ausbildung' &&
      !cvSectionFilled(payload, kind, 'esco')) {
    items.add(const AtsCheckItem('skills', AtsLevel.warn, section: 'esco'));
  }
  if (!cvSectionFilled(payload, kind, 'languages')) {
    items.add(const AtsCheckItem('languages', AtsLevel.warn,
        section: 'languages'));
  } else {
    items.add(const AtsCheckItem('languages', AtsLevel.ok,
        section: 'languages'));
  }

  // Every remaining empty section will simply be omitted from the PDF -
  // listed so the user knows what the document will NOT contain.
  for (final section in cvSectionKeys(kind)) {
    if (section == 'skills' || section == 'esco' || section == 'languages') {
      continue; // already covered above
    }
    if (!cvSectionFilled(payload, kind, section)) {
      items.add(AtsCheckItem('sectionOmitted', AtsLevel.ok,
          section: section, detail: section));
    }
  }

  return items;
}
