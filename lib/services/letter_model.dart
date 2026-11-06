import 'dart:convert';

import '../data/karyab_data.dart';
import '../models/user_profile.dart';
import 'letter_phrase_bank.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Letter v2 data model + composer (Phase 4).
//
// A letter lives in the letter_documents table (Phase 2). Its payload is
// JSON with this shape (version 2):
//   isAusbildung, tone, templateId,
//   companyName, companyStreet, companyPlz, companyCity,
//   contactPerson, salutation ('frau' | 'herr' | 'none'),
//   jobTitle, jobLocation, referenceNumber,
//   date ('dd.mm.yyyy', frozen at creation),
//   blocks: [ {id, text, phraseId, edited, hidden} ] in print order,
//   anlagenItems: [ 'Lebenslauf', ... ] (labels listed under Anlagen)
//
// FREEZE RULE: once a letter is created, its block texts are only ever
// changed by the user (edit / swap phrase / reorder / hide). Reopening a
// letter loads the saved payload verbatim; nothing recomposes it. The
// composer below runs exactly once per new letter (and for the editable
// recommendation when the user swaps a phrase).
// ─────────────────────────────────────────────────────────────────────────────

class LetterBlockData {
  final String id;
  String text;
  String? phraseId;
  bool edited;
  bool hidden;

  LetterBlockData({
    required this.id,
    required this.text,
    this.phraseId,
    this.edited = false,
    this.hidden = false,
  });

  factory LetterBlockData.fromJson(Map<String, dynamic> j) => LetterBlockData(
    id: j['id'] as String? ?? '',
    text: j['text'] as String? ?? '',
    phraseId: j['phraseId'] as String?,
    edited: j['edited'] == true,
    hidden: j['hidden'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'phraseId': phraseId,
    'edited': edited,
    'hidden': hidden,
  };

  LetterBlockData copy() => LetterBlockData(
    id: id,
    text: text,
    phraseId: phraseId,
    edited: edited,
    hidden: hidden,
  );
}

class LetterData {
  bool isAusbildung;
  String tone;
  String? templateId;
  String companyName;
  String companyStreet;
  String companyPlz;
  String companyCity;
  String contactPerson;

  /// 'frau', 'herr' or 'none' (then the neutral salutation is used).
  String salutation;
  String jobTitle;
  String jobLocation;
  String referenceNumber;
  String date;
  List<LetterBlockData> blocks;
  List<String> anlagenItems;

  LetterData({
    this.isAusbildung = false,
    this.tone = LetterTone.formal,
    this.templateId,
    this.companyName = '',
    this.companyStreet = '',
    this.companyPlz = '',
    this.companyCity = '',
    this.contactPerson = '',
    this.salutation = 'none',
    this.jobTitle = '',
    this.jobLocation = '',
    this.referenceNumber = '',
    this.date = '',
    List<LetterBlockData>? blocks,
    List<String>? anlagenItems,
  }) : blocks = blocks ?? [],
       anlagenItems = anlagenItems ?? [];

  LetterBlockData? block(String id) {
    for (final b in blocks) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// German salutation line printed in the letter, from the user's own
  /// contact-person + salutation choice. Never guessed.
  String get salutationLine {
    final name = contactPerson.trim();
    if (name.isNotEmpty && salutation == 'frau') {
      return 'Sehr geehrte Frau $name,';
    }
    if (name.isNotEmpty && salutation == 'herr') {
      return 'Sehr geehrter Herr $name,';
    }
    return 'Sehr geehrte Damen und Herren,';
  }

  /// Recipient address lines for the PDF. Only lines with real data.
  List<String> get recipientLines {
    final lines = <String>[];
    if (companyName.trim().isNotEmpty) lines.add(companyName.trim());
    if (companyStreet.trim().isNotEmpty) lines.add(companyStreet.trim());
    final cityLine = [
      companyPlz.trim(),
      companyCity.trim(),
    ].where((s) => s.isNotEmpty).join(' ');
    if (cityLine.isNotEmpty) lines.add(cityLine);
    return lines;
  }

  /// Visible body paragraphs in print order (between Betreff and the
  /// closing greeting): every non-hidden, non-empty bank block, then the
  /// Schluss block. The Anlagen block is not a paragraph.
  List<String> get bodyParagraphs {
    final out = <String>[];
    for (final b in blocks) {
      if (b.id == LetterSection.betreff || b.id == LetterSection.anlagen) {
        continue;
      }
      if (b.hidden || b.text.trim().isEmpty) continue;
      out.add(b.text.trim());
    }
    return out;
  }

  String get betreffText => block(LetterSection.betreff)?.text.trim() ?? '';

  /// All placeholders still present in the visible letter texts and the
  /// company fields (the export guard blocks while this is non-empty).
  List<String> get unfilledPlaceholders {
    final found = <String>[];
    void scan(String s) {
      for (final p in findLetterPlaceholders(s)) {
        if (!found.contains(p)) found.add(p);
      }
    }

    for (final b in blocks) {
      if (!b.hidden) scan(b.text);
    }
    return found;
  }

  Map<String, dynamic> toPayload() => {
    'version': 2,
    'isAusbildung': isAusbildung,
    'tone': tone,
    'templateId': templateId,
    'companyName': companyName,
    'companyStreet': companyStreet,
    'companyPlz': companyPlz,
    'companyCity': companyCity,
    'contactPerson': contactPerson,
    'salutation': salutation,
    'jobTitle': jobTitle,
    'jobLocation': jobLocation,
    'referenceNumber': referenceNumber,
    'date': date,
    'blocks': blocks.map((b) => b.toJson()).toList(),
    'anlagenItems': anlagenItems,
  };

  /// Loads a v2 payload. Returns null for payloads that are not v2 letters
  /// (e.g. the minimal v1-migration seed, which only carries Unterlagen).
  static LetterData? fromPayload(Map<String, dynamic> payload) {
    if (payload['version'] != 2) return null;
    String s(String k) => payload[k] as String? ?? '';
    final rawBlocks = payload['blocks'];
    if (rawBlocks is! List) return null;
    return LetterData(
      isAusbildung: payload['isAusbildung'] == true,
      tone: s('tone').isEmpty ? LetterTone.formal : s('tone'),
      templateId: payload['templateId'] as String?,
      companyName: s('companyName'),
      companyStreet: s('companyStreet'),
      companyPlz: s('companyPlz'),
      companyCity: s('companyCity'),
      contactPerson: s('contactPerson'),
      salutation: s('salutation').isEmpty ? 'none' : s('salutation'),
      jobTitle: s('jobTitle'),
      jobLocation: s('jobLocation'),
      referenceNumber: s('referenceNumber'),
      date: s('date'),
      blocks: [
        for (final b in rawBlocks)
          if (b is Map<String, dynamic>) LetterBlockData.fromJson(b),
      ],
      anlagenItems: [
        for (final a in (payload['anlagenItems'] as List? ?? const []))
          if (a is String) a,
      ],
    );
  }

  LetterData deepCopy() => LetterData.fromPayload(toPayload())!;
}

/// Payload for "New letter like this one": block texts, tone, template
/// and Anlagen are kept; company, job title, reference and date are reset
/// so the user only fills the new job's data (Phase 4 item 1).
Map<String, dynamic> letterPayloadForNewJob(
  Map<String, dynamic> source, {
  DateTime? now,
}) {
  final data = LetterData.fromPayload(source);
  if (data == null) return Map<String, dynamic>.from(source);
  data.companyName = '';
  data.companyStreet = '';
  data.companyPlz = '';
  data.companyCity = '';
  data.contactPerson = '';
  data.salutation = 'none';
  data.jobTitle = '';
  data.jobLocation = '';
  data.referenceNumber = '';
  data.date = formatLetterDate(now ?? DateTime.now());
  // The Betreff names the old job; rebuild it empty-safe.
  final betreff = data.block(LetterSection.betreff);
  if (betreff != null) {
    betreff.text = '';
    betreff.phraseId = null;
    betreff.edited = false;
  }
  return data.toPayload();
}

String formatLetterDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String buildBetreff({
  required String jobTitle,
  required bool isAusbildung,
  String referenceNumber = '',
}) {
  final title = jobTitle.trim();
  final String main;
  if (title.isEmpty) {
    main = 'Bewerbung';
  } else if (isAusbildung) {
    main = 'Bewerbung um einen Ausbildungsplatz als $title';
  } else {
    main = 'Bewerbung als $title';
  }
  final ref = referenceNumber.trim();
  return ref.isEmpty ? main : '$main\nIhre Referenznummer: $ref';
}

// ── Composer ────────────────────────────────────────────────────────────────

/// Everything the composer may use. All of it is data the user entered
/// (profile) or data of the posting the user opened. Nothing else.
class LetterContext {
  final String jobTitle;
  final String companyName;
  final String companyStreet;
  final String companyPlz;
  final String companyCity;
  final String contactPerson;
  final String salutation;
  final String jobLocation;
  final String referenceNumber;
  final bool isAusbildung;
  final String tone;

  /// German skill labels, strongest first ({skill1}, {skill2}).
  final List<String> skills;

  /// Latest job as a German fragment, e.g. "Lagerhelfer bei DHL" ({experience}).
  final String experience;

  /// First school/institution name ({school}).
  final String school;

  /// User's stated start date / availability text ({startDate}).
  final String startDate;

  final List<String> anlagenItems;

  const LetterContext({
    this.jobTitle = '',
    this.companyName = '',
    this.companyStreet = '',
    this.companyPlz = '',
    this.companyCity = '',
    this.contactPerson = '',
    this.salutation = 'none',
    this.jobLocation = '',
    this.referenceNumber = '',
    this.isAusbildung = false,
    this.tone = LetterTone.formal,
    this.skills = const [],
    this.experience = '',
    this.school = '',
    this.startDate = '',
    this.anlagenItems = const [],
  });

  Map<String, String> get values => {
    'jobTitle': jobTitle.trim(),
    'company': companyName.trim(),
    'skill1': skills.isNotEmpty ? skills[0] : '',
    'skill2': skills.length > 1 ? skills[1] : '',
    'experience': experience.trim(),
    'school': school.trim(),
    'startDate': startDate.trim(),
    'city': companyCity.trim(),
  };

  String get sectorHint =>
      inferLetterSector(jobTitle: jobTitle, skills: skills);
}

/// Sector inference from the user's own job title / skills (German words).
String inferLetterSector({
  String jobTitle = '',
  List<String> skills = const [],
}) {
  final hay = '$jobTitle ${skills.join(' ')}'.toLowerCase();
  if (hay.contains('lager') || hay.contains('logistik')) return 'warehouse';
  if (hay.contains('pflege') || hay.contains('betreuung')) return 'care';
  if (hay.contains('küche') ||
      hay.contains('koch') ||
      hay.contains('gastronom') ||
      hay.contains('restaurant')) {
    return 'gastronomy';
  }
  if (hay.contains('verkauf') ||
      hay.contains('handel') ||
      hay.contains('kassier')) {
    return 'retail';
  }
  if (hay.contains('reinigung')) return 'cleaning';
  if (hay.contains('bau')) return 'construction';
  if (hay.contains('fahrer') ||
      hay.contains('transport') ||
      hay.contains('gabelstapler')) {
    return 'driving';
  }
  if (hay.contains('büro') || hay.contains('computer') || hay.contains('it-')) {
    return 'office';
  }
  return 'general';
}

/// Builds a brand-new letter: for every bank section the best-scoring
/// fillable phrase is pre-selected (deterministic, with its reason kept in
/// the returned map for the UI's reason chip).
({LetterData data, Map<String, LetterRecommendation> reasons}) composeNewLetter(
  LetterContext ctx, {
  DateTime? now,
}) {
  final values = ctx.values;
  final data = LetterData(
    isAusbildung: ctx.isAusbildung,
    tone: ctx.tone,
    companyName: ctx.companyName,
    companyStreet: ctx.companyStreet,
    companyPlz: ctx.companyPlz,
    companyCity: ctx.companyCity,
    contactPerson: ctx.contactPerson,
    salutation: ctx.salutation,
    jobTitle: ctx.jobTitle,
    jobLocation: ctx.jobLocation,
    referenceNumber: ctx.referenceNumber,
    date: formatLetterDate(now ?? DateTime.now()),
    anlagenItems: List<String>.from(ctx.anlagenItems),
  );
  final reasons = <String, LetterRecommendation>{};
  data.blocks.add(
    LetterBlockData(
      id: LetterSection.betreff,
      text: buildBetreff(
        jobTitle: ctx.jobTitle,
        isAusbildung: ctx.isAusbildung,
        referenceNumber: ctx.referenceNumber,
      ),
    ),
  );
  for (final section in const [
    LetterSection.einleitung,
    LetterSection.erfahrung,
    LetterSection.kenntnisse,
    LetterSection.warum,
    LetterSection.verfuegbarkeit,
    LetterSection.schluss,
  ]) {
    final ranked = rankLetterPhrases(
      section,
      values: values,
      sectorHint: ctx.sectorHint,
      tone: ctx.tone,
    );
    final best = ranked.isNotEmpty ? ranked.first : null;
    if (best != null) reasons[section] = best;
    data.blocks.add(
      LetterBlockData(
        id: section,
        text: best?.phrase.fill(values) ?? '',
        phraseId: best?.phrase.id,
      ),
    );
  }
  data.blocks.add(
    LetterBlockData(
      id: LetterSection.anlagen,
      text: data.anlagenItems.join(', '),
    ),
  );
  return (data: data, reasons: reasons);
}

/// Derives the composer context from the shared profile + profile map.
/// German skill labels mirror the generator's skill map (same source
/// options as the questionnaire); ESCO skills are already German labels.
LetterContext letterContextFromProfile({
  required UserProfile profile,
  required Map<String, dynamic> profileMap,
  String jobTitle = '',
  String companyName = '',
  String companyStreet = '',
  String companyPlz = '',
  String companyCity = '',
  String jobLocation = '',
  String referenceNumber = '',
  bool isAusbildung = false,
  String tone = LetterTone.formal,
  List<String> anlagenItems = const [],
}) {
  String mapStr(String k) => (profileMap[k] as String? ?? '').trim();
  final skills = <String>[];
  if (isAusbildung) {
    for (final s in mapStr('ausbildungEscoSkills').split(',')) {
      final t = s.trim();
      if (t.isNotEmpty) skills.add(t);
    }
  }
  if (skills.isEmpty) {
    for (final key in (profile.skill ?? '').split(',')) {
      final label = _skillLabelsDe[key.trim()];
      if (label != null && label.isNotEmpty) skills.add(label);
    }
  }
  var experience = '';
  if (profile.previousJobTitles.isNotEmpty ||
      profile.previousEmployers.isNotEmpty) {
    final title = profile.previousJobTitles.isNotEmpty
        ? profile.previousJobTitles.first
        : '';
    final company = profile.previousEmployers.isNotEmpty
        ? profile.previousEmployers.first
        : '';
    experience = title.isNotEmpty && company.isNotEmpty
        ? '$title bei $company'
        : (title.isNotEmpty ? title : company);
  }
  final schools = mapStr('ausbildungEduInstitutions').split(',');
  final school = schools.isNotEmpty ? schools.first.trim() : '';
  final resolvedTitle = jobTitle.trim().isNotEmpty
      ? jobTitle.trim()
      : (isAusbildung
            ? mapStr('ausbildungTargetOccupation')
            : _workTypeLabelsDe[profile.workType ?? ''] ?? '');
  return LetterContext(
    jobTitle: resolvedTitle,
    companyName: companyName,
    companyStreet: companyStreet,
    companyPlz: companyPlz,
    companyCity: companyCity,
    jobLocation: jobLocation,
    referenceNumber: referenceNumber,
    isAusbildung: isAusbildung,
    tone: tone,
    skills: skills,
    experience: experience,
    school: school,
    startDate: (profile.startDate ?? '').trim(),
    anlagenItems: anlagenItems,
  );
}

// Skill key -> German label. Same option set the questionnaire offers and
// the CV generator maps (kept here so the letter composer stays pure and
// testable without the generator's private helpers).
const Map<String, String> _skillLabelsDe = {
  'lifting': 'Schwere Lasten tragen',
  'cooking': 'Kochen',
  'driving': 'Fahren und Transport',
  'cleaning': 'Reinigung',
  'fixing': 'Reparatur und Instandhaltung',
  'packing': 'Packen und Lagerhaltung',
  'security': 'Sicherheitsdienst',
  'forklift': 'Gabelstapler fahren',
  'farming': 'Landwirtschaft',
  'sales': 'Verkauf und Handel',
  'sewing': 'Nähen und Schneiderei',
  'construction': 'Bauarbeiten',
  'mobile_repair': 'Handy-Reparatur',
  'amazon_packing': 'Lagerlogistik',
  'dhl': 'Paketdienst und Auslieferung',
};

const Map<String, String> _workTypeLabelsDe = {
  'construction': 'Fachkraft im Baugewerbe',
  'cleaning': 'Reinigungskraft',
  'kitchen': 'Küchenhilfe',
  'driving': 'Fahrer',
};

// ── Saved companies (presets) ───────────────────────────────────────────────
// Stored as a JSON list in app_meta through the profile KV (no new table
// needed; document-domain KV is exactly what app_meta is for).

const String kSavedCompaniesMetaKey = 'saved_companies_v1';

class CompanyPreset {
  final String name;
  final String street;
  final String plz;
  final String city;
  final String contactPerson;
  final String salutation;

  const CompanyPreset({
    required this.name,
    this.street = '',
    this.plz = '',
    this.city = '',
    this.contactPerson = '',
    this.salutation = 'none',
  });

  factory CompanyPreset.fromJson(Map<String, dynamic> j) => CompanyPreset(
    name: j['name'] as String? ?? '',
    street: j['street'] as String? ?? '',
    plz: j['plz'] as String? ?? '',
    city: j['city'] as String? ?? '',
    contactPerson: j['contactPerson'] as String? ?? '',
    salutation: j['salutation'] as String? ?? 'none',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'street': street,
    'plz': plz,
    'city': city,
    'contactPerson': contactPerson,
    'salutation': salutation,
  };
}

Future<List<CompanyPreset>> loadSavedCompanies() async {
  try {
    final raw = await KaryabData.profile.getString(kSavedCompaniesMetaKey);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return [
      for (final e in list)
        if (e is Map<String, dynamic>) CompanyPreset.fromJson(e),
    ];
  } catch (_) {
    return const [];
  }
}

/// Adds or updates (by company name) a preset; returns the stored list.
Future<List<CompanyPreset>> saveCompanyPreset(CompanyPreset preset) async {
  final existing = await loadSavedCompanies();
  final next = [
    for (final p in existing)
      if (p.name.toLowerCase() != preset.name.toLowerCase()) p,
    preset,
  ];
  try {
    await KaryabData.profile.setString(
      kSavedCompaniesMetaKey,
      jsonEncode(next.map((p) => p.toJson()).toList()),
    );
  } catch (_) {}
  return next;
}
