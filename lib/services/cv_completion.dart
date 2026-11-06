// ─────────────────────────────────────────────────────────────────────────────
// CV completion + wizard bookkeeping (Phase 3) - pure functions over the
// flat payload map a CV document carries (same shape as the shared profile
// map). Used by the My CVs library (completion % / resume), the wizard
// shells in both questionnaires (step <-> section mapping) and the ATS
// checker (which sections will be omitted from the PDF).
//
// Wizard progress is stored inside the payload itself under two reserved
// keys so it travels with the document and needs no schema change:
//   '_wizardStep' - the step the user last saw (string, like all values)
//   '_wizardDone' - 'true' once the user finished the wizard via Create
// Documents without '_wizardStep' (everything created before Phase 3,
// including the Phase 2 migration seeds) count as finished.
// ─────────────────────────────────────────────────────────────────────────────

const String kWizardStepKey = '_wizardStep';
const String kWizardDoneKey = '_wizardDone';
const String kProfileSummaryKey = 'profileSummary';
const String kProfileThemesKey = 'profileSummaryThemes';
const String kProfileSectorsKey = 'profileSummarySectors';

String _val(Map<String, dynamic> payload, String key) =>
    (payload[key] as String? ?? '').trim();

bool _filled(Map<String, dynamic> payload, String key) =>
    _val(payload, key).isNotEmpty;

/// Section keys per CV kind, in the order the PDF presents them.
List<String> cvSectionKeys(String kind) {
  if (kind == 'ausbildung') {
    return const [
      'experience',
      'education',
      'languages',
      'toolsIt',
      'esco',
      'profil',
    ];
  }
  return const [
    'education',
    'skills',
    'experience',
    'employers',
    'toolsIt',
    'languages',
    'availability',
    'profil',
  ];
}

bool cvSectionFilled(Map<String, dynamic> payload, String kind, String section) {
  switch (section) {
    case 'education':
      return kind == 'ausbildung'
          ? _filled(payload, 'ausbildungEduInstitutions') ||
              _filled(payload, 'schulabschluss')
          : _filled(payload, 'educationLevel');
    case 'skills':
      return _filled(payload, 'skill');
    case 'experience':
      return kind == 'ausbildung'
          ? _filled(payload, 'previousEmployers')
          : _filled(payload, 'workExperience');
    case 'employers':
      return _filled(payload, 'previousEmployers');
    case 'toolsIt':
      return _filled(payload, 'sharedItSkills') || _filled(payload, 'tools');
    case 'languages':
      return _filled(payload, 'languages');
    case 'availability':
      return _filled(payload, 'availability') || _filled(payload, 'startDate');
    case 'esco':
      return _filled(payload, 'ausbildungEscoSkills') ||
          _filled(payload, 'ausbildungTargetOccupation');
    case 'profil':
      return _filled(payload, kProfileSummaryKey);
    default:
      return false;
  }
}

/// 0..100, share of sections with content.
int cvCompletionPercent(Map<String, dynamic> payload, String kind) {
  final sections = cvSectionKeys(kind);
  if (sections.isEmpty) return 0;
  final done =
      sections.where((s) => cvSectionFilled(payload, kind, s)).length;
  return (done * 100 / sections.length).round();
}

/// True when the document is not a wizard draft: either finished via the
/// wizard, or created before wizard bookkeeping existed.
bool cvDocumentFinished(Map<String, dynamic> payload) {
  if (!payload.containsKey(kWizardStepKey)) return true;
  return payload[kWizardDoneKey] == 'true';
}

/// The wizard step to reopen a draft on (0 when unknown).
int cvResumeStep(Map<String, dynamic> payload) {
  final step = int.tryParse(_val(payload, kWizardStepKey)) ?? 0;
  return step < 0 ? 0 : step;
}

// ── Wizard step <-> section mapping ─────────────────────────────────────────
// The step lists mirror the step containers built into the two questionnaire
// screens. Job CV steps differ between the educated (chips) and uneducated
// (big cards) variants of questionnaire_screen.dart, exactly like the
// underlying question sets do.

List<String> wizardStepSections(String kind, {required bool educated}) {
  if (kind == 'ausbildung') {
    return const [
      'experience',
      'education',
      'languages',
      'toolsIt',
      'esco',
      'profil',
    ];
  }
  if (educated) {
    return const [
      'education',
      'skills',
      'experience',
      'toolsIt',
      'languages',
      'availability',
      'profil',
    ];
  }
  return const [
    'skills',
    'experience',
    'toolsIt',
    'languages',
    'availability',
    'profil',
  ];
}

/// Step index for [section], or -1 when the wizard has no such step.
int wizardStepForSection(
  String kind, {
  required bool educated,
  required String section,
}) {
  // 'employers' lives inside the experience step in both questionnaires.
  final effective = section == 'employers' ? 'experience' : section;
  return wizardStepSections(kind, educated: educated).indexOf(effective);
}

/// Sections the wizard treats as required before finishing. Mirrors the
/// pre-Phase-3 Create validation in questionnaire_screen.dart (skills,
/// work experience, languages) - Ausbildung has no hard requirement.
bool wizardSectionRequired(String kind, String section) {
  if (kind == 'ausbildung') return false;
  return section == 'skills' ||
      section == 'experience' ||
      section == 'languages';
}
