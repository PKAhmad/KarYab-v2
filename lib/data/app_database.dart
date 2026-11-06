import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KarYab v2 local database (Drift / SQLite).
//
// Phase 2 of the v2 build: this replaces SharedPreferences as the storage
// for the profile/documents data domain. The v1 storage shape is preserved
// exactly - the shared profile is still the same flat Map<String, String>
// the questionnaire screens have always merged into (see
// models/user_profile.dart) - only the backend changes, plus three new
// document tables that make multiple CVs / letters possible.
//
// Tables:
//   profile          - single row (id = 1) with one column per known
//                      'saved_profile' key, plus [ProfileEntries.extraData]
//                      holding any unknown/future keys as JSON so a write
//                      can never silently drop a key this version does not
//                      know about yet.
//   cv_documents     - one row per saved CV (Job or Ausbildung).
//   letter_documents - one row per saved Anschreiben/Deckblatt letter.
//   certificates     - the user's document/certificate list (feeds the
//                      Deckblatt "Unterlagen" list in a later phase).
//   app_meta         - key/value store for the small document-domain flags
//                      and paths that v1 kept as loose SharedPreferences
//                      keys ('cv_created', 'cv_type', template selections,
//                      'temp_cv_path', the 'user_*' mirrors, ...).
// ─────────────────────────────────────────────────────────────────────────────

/// The one-row profile table. Column names are pinned to the exact v1
/// 'saved_profile' keys via [TableColumn.named] so a profile map round-trips
/// key-for-key with zero translation tables.
class ProfileEntries extends Table {
  @override
  String get tableName => 'profile';

  IntColumn get id => integer()();

  TextColumn get fullName => text().named('fullName').nullable()();
  TextColumn get dobDay => text().named('dobDay').nullable()();
  TextColumn get dobMonth => text().named('dobMonth').nullable()();
  TextColumn get dobYear => text().named('dobYear').nullable()();
  TextColumn get country => text().named('country').nullable()();
  TextColumn get phone => text().named('phone').nullable()();
  TextColumn get email => text().named('email').nullable()();
  TextColumn get street => text().named('street').nullable()();
  TextColumn get city => text().named('city').nullable()();
  TextColumn get photoPath => text().named('photoPath').nullable()();
  TextColumn get skill => text().named('skill').nullable()();
  TextColumn get workExperience => text().named('workExperience').nullable()();
  TextColumn get workType => text().named('workType').nullable()();
  TextColumn get tools => text().named('tools').nullable()();
  TextColumn get drivingLicense => text().named('drivingLicense').nullable()();
  TextColumn get languages => text().named('languages').nullable()();
  TextColumn get languageProficiency =>
      text().named('languageProficiency').nullable()();
  TextColumn get availability => text().named('availability').nullable()();
  TextColumn get startDate => text().named('startDate').nullable()();
  TextColumn get educationLevel => text().named('educationLevel').nullable()();
  TextColumn get educationOrt => text().named('educationOrt').nullable()();
  TextColumn get educationDuration =>
      text().named('educationDuration').nullable()();
  TextColumn get reference => text().named('reference').nullable()();
  TextColumn get refName => text().named('refName').nullable()();
  TextColumn get refPhone => text().named('refPhone').nullable()();
  TextColumn get previousEmployers =>
      text().named('previousEmployers').nullable()();
  TextColumn get previousJobTitles =>
      text().named('previousJobTitles').nullable()();
  TextColumn get previousJobDurations =>
      text().named('previousJobDurations').nullable()();
  TextColumn get sharedWorkOrts => text().named('sharedWorkOrts').nullable()();
  TextColumn get sharedWorkTypes =>
      text().named('sharedWorkTypes').nullable()();
  TextColumn get sharedItSkills => text().named('sharedItSkills').nullable()();
  TextColumn get ausbildungEduInstitutions =>
      text().named('ausbildungEduInstitutions').nullable()();
  TextColumn get ausbildungEduOrts =>
      text().named('ausbildungEduOrts').nullable()();
  TextColumn get ausbildungEduTypes =>
      text().named('ausbildungEduTypes').nullable()();
  TextColumn get ausbildungEduAbschluss =>
      text().named('ausbildungEduAbschluss').nullable()();
  TextColumn get ausbildungEduDurations =>
      text().named('ausbildungEduDurations').nullable()();
  TextColumn get ausbildungEduGrades =>
      text().named('ausbildungEduGrades').nullable()();
  TextColumn get ausbildungEscoSkills =>
      text().named('ausbildungEscoSkills').nullable()();
  TextColumn get ausbildungTargetOccupation =>
      text().named('ausbildungTargetOccupation').nullable()();
  TextColumn get ausbildungTargetOccupationUri =>
      text().named('ausbildungTargetOccupationUri').nullable()();
  TextColumn get schulabschluss => text().named('schulabschluss').nullable()();
  TextColumn get schulabschlussNote =>
      text().named('schulabschlussNote').nullable()();

  /// JSON object with every profile-map key that has no dedicated column
  /// above (older or future keys). Merged back into the map on read, with
  /// dedicated columns winning on a collision.
  TextColumn get extraData => text().named('extraData').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Every 'saved_profile' key that has a dedicated column in [ProfileEntries].
/// Used by the map <-> row conversion so the column list exists exactly once.
const List<String> kProfileColumnKeys = [
  'fullName',
  'dobDay',
  'dobMonth',
  'dobYear',
  'country',
  'phone',
  'email',
  'street',
  'city',
  'photoPath',
  'skill',
  'workExperience',
  'workType',
  'tools',
  'drivingLicense',
  'languages',
  'languageProficiency',
  'availability',
  'startDate',
  'educationLevel',
  'educationOrt',
  'educationDuration',
  'reference',
  'refName',
  'refPhone',
  'previousEmployers',
  'previousJobTitles',
  'previousJobDurations',
  'sharedWorkOrts',
  'sharedWorkTypes',
  'sharedItSkills',
  'ausbildungEduInstitutions',
  'ausbildungEduOrts',
  'ausbildungEduTypes',
  'ausbildungEduAbschluss',
  'ausbildungEduDurations',
  'ausbildungEduGrades',
  'ausbildungEscoSkills',
  'ausbildungTargetOccupation',
  'ausbildungTargetOccupationUri',
  'schulabschluss',
  'schulabschlussNote',
];

/// Converts a v1 profile map to the JSON shape [ProfileEntry.fromJson]
/// expects: known keys stay at the top level, unknown keys are collected
/// into 'extraData' (itself a JSON string, matching the text column).
Map<String, dynamic> profileMapToRowJson(Map<String, dynamic> map) {
  final row = <String, dynamic>{};
  final extra = <String, dynamic>{};
  for (final entry in map.entries) {
    if (kProfileColumnKeys.contains(entry.key)) {
      row[entry.key] = entry.value?.toString();
    } else {
      extra[entry.key] = entry.value;
    }
  }
  row['extraData'] = extra.isEmpty ? null : jsonEncode(extra);
  return row;
}

/// Inverse of [profileMapToRowJson] for a row produced by
/// [ProfileEntry.toJson]: drops null columns, unfolds 'extraData', and
/// drops the row id. Dedicated columns win over extraData on collision,
/// mirroring the merge order the v1 screens used (later writes win).
Map<String, dynamic> profileRowJsonToMap(Map<String, dynamic> rowJson) {
  final map = <String, dynamic>{};
  final extraRaw = rowJson['extraData'];
  if (extraRaw is String && extraRaw.isNotEmpty) {
    try {
      final extra = jsonDecode(extraRaw);
      if (extra is Map<String, dynamic>) map.addAll(extra);
    } catch (_) {
      // A corrupt extraData blob must never lose the column data below.
    }
  }
  for (final key in kProfileColumnKeys) {
    final value = rowJson[key];
    if (value != null) map[key] = value;
  }
  return map;
}

class CvDocuments extends Table {
  @override
  String get tableName => 'cv_documents';

  IntColumn get id => integer().autoIncrement()();

  /// 'job' or 'ausbildung'.
  TextColumn get kind => text()();
  TextColumn get name => text()();

  /// DocumentTemplate.storageKey of the chosen template, when set.
  TextColumn get templateId => text().named('template_id').nullable()();

  // Template customisation (v2 wizard phase writes these; nullable until
  // then so a document can exist without any customisation).
  TextColumn get accentColor => text().named('accent_color').nullable()();
  TextColumn get fontSize => text().named('font_size').nullable()();
  TextColumn get spacing => text().nullable()();
  BoolColumn get showPhoto => boolean().named('show_photo').nullable()();

  /// JSON of the per-CV answers (the questionnaire fields for this CV, in
  /// the same flat string-map shape the v1 profile used).
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}

class LetterDocuments extends Table {
  @override
  String get tableName => 'letter_documents';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get company => text().nullable()();
  TextColumn get jobTitle => text().named('job_title').nullable()();

  /// JSON: block texts + phrase choices for this letter (v2 letter phase
  /// defines the inner shape; the v1 migration stores the Unterlagen
  /// selection here, see data/legacy_migration.dart).
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}

class Certificates extends Table {
  @override
  String get tableName => 'certificates';

  IntColumn get id => integer().autoIncrement()();

  /// Display label as shown in the Unterlagen list (e.g. 'Sprachzertifikat
  /// B1').
  TextColumn get label => text()();

  /// Free-form kind: 'language', 'school', 'recognition', 'licence',
  /// 'custom', ... (the v1 Unterlagen list only knew plain labels).
  TextColumn get kind => text()();

  /// Path of an attached scan/file, when the user added one.
  TextColumn get filePath => text().named('file_path').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
}

class AppMeta extends Table {
  @override
  String get tableName => 'app_meta';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ── Phase 7 job-side tables (schema v2) ────────────────────────────────────

/// One bookmarked job posting. The posting's reference number is the
/// identity (the Bundesagentur API is the only source, and its refnr is
/// stable), so it is the primary key and saving the same job twice is a
/// no-op replace. [payload] keeps the full posting JSON so a saved job
/// can be reopened (detail / apply flow) even after it leaves the live
/// search results.
class SavedJobs extends Table {
  @override
  String get tableName => 'saved_jobs';

  TextColumn get refnr => text()();
  TextColumn get title => text()();
  TextColumn get company => text()();
  TextColumn get location => text()();

  /// Which surface saved it: 'jobs', 'ausbildung' or 'minijob'.
  TextColumn get source => text()();
  DateTimeColumn get savedAt => dateTime().named('saved_at')();
  TextColumn get payload => text()();

  @override
  Set<Column> get primaryKey => {refnr};
}

/// One saved search. [params] is the JSON of a JobQuery (see
/// services/job_search_service.dart). [lastTopRefnr] is the refnr of the
/// newest result when the search was last viewed (or saved), which is
/// what the "new since last visit" count is computed against.
@DataClassName('SavedSearch')
class SavedSearches extends Table {
  @override
  String get tableName => 'saved_searches';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
  TextColumn get params => text()();
  DateTimeColumn get lastRunAt => dateTime().named('last_run_at').nullable()();
  TextColumn get lastTopRefnr =>
      text().named('last_top_refnr').nullable()();
}

/// One tracked application (see services/tracker logic in
/// data/repositories.dart). Status flow:
/// saved -> applied -> invited -> answered.
/// The CV / letter links are plain ids (no FK) so deleting a document
/// never cascades into the tracker; the UI treats a missing document as
/// "no longer available".
class Applications extends Table {
  @override
  String get tableName => 'applications';

  IntColumn get id => integer().autoIncrement()();

  /// Bundesagentur reference number of the posting, when the application
  /// came from a posting inside the app. Null for manual entries.
  TextColumn get refnr => text().nullable()();
  TextColumn get company => text()();
  TextColumn get jobTitle => text().named('job_title')();
  TextColumn get status => text()();
  IntColumn get cvDocumentId =>
      integer().named('cv_document_id').nullable()();
  IntColumn get letterDocumentId =>
      integer().named('letter_document_id').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}

/// Offline cache for job search results and opened job details.
/// Keys are namespaced: 'search:<query json>' for result lists and
/// 'detail:<refnr>' for single postings. Eviction is handled by the
/// repository (newest ~20 search entries, newest ~50 details).
class JobCache extends Table {
  @override
  String get tableName => 'job_cache';

  TextColumn get cacheKey => text().named('cache_key')();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime().named('fetched_at')();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

@DriftDatabase(
  tables: [
    ProfileEntries,
    CvDocuments,
    LetterDocuments,
    Certificates,
    AppMeta,
    SavedJobs,
    SavedSearches,
    Applications,
    JobCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The on-device database used by the running app.
  factory AppDatabase.production() {
    return AppDatabase(driftDatabase(
      name: 'karyab_v2',
      native: const DriftNativeOptions(
        // Share the database file across isolates (PDF generation etc.).
        shareAcrossIsolates: true,
      ),
    ));
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v1 -> v2 (Phase 7): four purely additive job-side tables.
          // No existing table changes shape, so nothing else is needed
          // and no v1 data can be lost by this migration.
          if (from < 2) {
            await m.createTable(savedJobs);
            await m.createTable(savedSearches);
            await m.createTable(applications);
            await m.createTable(jobCache);
          }
        },
      );
}
