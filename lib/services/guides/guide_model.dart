import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Guides content model (Phase 11).
//
// The guides are fully data-driven: every track, step, paragraph,
// document list, warning and link lives in the per-language content
// files (guides_en.dart, guides_de.dart, guides_ps.dart, guides_fa.dart)
// and the widgets only render this model. Adding a language later
// (Arabic is planned as the next pack) means adding one content file
// and one case in guides.dart - no widget changes.
//
// Facts policy (CEO rule: no invented data): every figure in the
// content was checked against an official source in November 2026
// (make-it-in-germany.com, anerkennung-in-deutschland.de). Amounts
// that change yearly are always paired with a "check the official
// page" sentence. No em-dashes anywhere in the content.
// ─────────────────────────────────────────────────────────────────────────────

/// An in-app jump target a step can offer as a button. The labels come
/// from GuideStrings so the button text follows the UI language.
enum GuideAction {
  /// The app's Ausbildung search (route '/ausbildung').
  ausbildungSearch,

  /// The CV type chooser, entry into the CV builder (route
  /// '/choose-cv-type').
  cvBuilder,

  /// The saved cover letters screen, entry into the letter builder.
  coverLetter,

  /// The Official Letters module (Phase 9 screen).
  officialLetters,

  /// The German courses screen (route '/deutsch-courses').
  deutschCourses,

  /// The exam track of the guides themselves.
  examGuide,
}

/// A link to an official page outside the app. The label is part of
/// the per-language content, so it is written in the content language.
class GuideLink {
  final String url;
  final String label;

  const GuideLink({required this.url, required this.label});
}

/// One step of a guide track.
class GuideStep {
  /// Stable id, unique inside its track ('which_exam', 'money', ...).
  /// Progress is stored against '<trackId>:<stepId>', so ids must
  /// never be renamed once shipped.
  final String id;
  final IconData icon;
  final String title;

  /// The explanation, as short paragraphs for low-literacy readers.
  /// Every paragraph is one or two short sentences.
  final List<String> paragraphs;

  /// "Documents you need" list; empty when the step needs no papers.
  final List<String> documents;

  /// Scam / danger warning; null when the step has none.
  final String? warning;

  /// In-app jump buttons (may be empty).
  final List<GuideAction> actions;

  /// Official external pages (may be empty).
  final List<GuideLink> links;

  const GuideStep({
    required this.id,
    required this.icon,
    required this.title,
    required this.paragraphs,
    this.documents = const [],
    this.warning,
    this.actions = const [],
    this.links = const [],
  });

  /// Everything the listen button speaks: title, explanation,
  /// documents and warning, in reading order.
  String spokenText(String documentsHeading, String warningHeading) {
    final parts = <String>[title, ...paragraphs];
    if (documents.isNotEmpty) {
      parts.add(documentsHeading);
      parts.addAll(documents);
    }
    final w = warning;
    if (w != null) {
      parts.add(warningHeading);
      parts.add(w);
    }
    return parts.join('. ');
  }
}

/// One guide track: an ordered list of steps towards one goal.
class GuideTrack {
  /// Stable id ('exam' or 'ausbildung'); used in the progress keys.
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<GuideStep> steps;

  const GuideTrack({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  GuideStep? stepById(String stepId) {
    for (final s in steps) {
      if (s.id == stepId) return s;
    }
    return null;
  }
}
