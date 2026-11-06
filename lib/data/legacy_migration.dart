import 'dart:convert';

import 'app_database.dart';
import 'profile_store.dart';
import 'repositories.dart';

// ─────────────────────────────────────────────────────────────────────────────
// One-time v1 -> v2 migration.
//
// On the first v2 launch the Drift database is empty while the user's real
// data still sits in SharedPreferences (the v1 store). This migration
// imports it:
//
//   * 'saved_profile'              -> the single `profile` row,
//   * the document-domain keys     -> `app_meta` (list below),
//   * a created v1 CV              -> seeded rows in `cv_documents`
//                                     (Job and/or Ausbildung, mirroring
//                                     the exact signals v1 itself used),
//   * a created v1 Anschreiben     -> one seeded `letter_documents` row,
//   * the Deckblatt Unterlagen     -> `certificates` rows (the standard
//     selection's certificate-like    entries and the user's custom labels;
//     entries                          'Lebenslauf'/'Anschreiben' are
//                                     documents, not certificates).
//
// Safety properties:
//   * Flag-guarded ('migration_v2_done' in app_meta): runs at most once.
//   * Import-only: SharedPreferences is read, never written or deleted, so
//     the complete v1 data remains on the device as a fallback.
//   * Every step is best-effort: a corrupt legacy value skips that step
//     instead of failing the migration (or the app start).
// ─────────────────────────────────────────────────────────────────────────────

/// app_meta key recording that the migration has run.
const String kMigrationDoneKey = 'migration_v2_done';

/// Document-domain string keys imported from SharedPreferences to app_meta.
const List<String> kMigratedStringKeys = [
  'user_name',
  'user_phone',
  'user_email',
  'user_street',
  'user_city',
  'user_postal',
  'questionnaire_full_name',
  'cv_type',
  'uploaded_cv_path',
  'temp_cv_path',
  'temp_cv_timestamp',
  'temp_cover_path',
  'selected_cv_template_regular',
  'selected_cv_template_ausbildung',
  'selected_anschreiben_template',
  'selected_deckblatt_template',
  'deckblatt_unterlagen_selection',
];

/// Document-domain bool keys imported from SharedPreferences to app_meta.
const List<String> kMigratedBoolKeys = [
  'cv_created',
  'anschreiben_created',
];

/// The standard Deckblatt Unterlagen entries that are certificates /
/// documents in their own right (key -> German label, mirroring
/// letter_document_screen.dart's _kStdUnterlagen minus the CV and the
/// cover letter themselves).
const Map<String, String> kUnterlagenCertificates = {
  'zeugnisse': 'Zeugnisse',
  'sprachzertifikat': 'Sprachzertifikat',
  'fuehrerschein': 'Führerschein',
  'praktikum': 'Praktikumsbescheinigung',
};

Future<void> migrateLegacyData({
  required AppDatabase db,
  required LegacyKeyValueStore legacy,
}) async {
  final store = DriftProfileStore(db);
  if (await store.getString(kMigrationDoneKey) != null) return;

  Map<String, dynamic>? profileMap;

  // 1. The shared profile.
  try {
    final raw = await legacy.getString(kLegacyProfileKey);
    if (raw != null && raw.isNotEmpty && await store.loadProfileMap() == null) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        profileMap = decoded;
        await store.saveProfileMap(decoded);
      }
    }
  } catch (_) {
    // Corrupt legacy profile: skip it; the v1 copy stays untouched.
  }
  profileMap ??= await store.loadProfileMap();

  // 2. Document-domain keys -> app_meta (only where the DB has no value).
  for (final key in kMigratedStringKeys) {
    try {
      if (await store.getString(key) != null) continue;
      final value = await legacy.getString(key);
      if (value != null) await store.setString(key, value);
    } catch (_) {}
  }
  for (final key in kMigratedBoolKeys) {
    try {
      if (await store.getString(key) != null) continue;
      final value = await legacy.getBool(key);
      if (value != null) await store.setBool(key, value);
    } catch (_) {}
  }

  // 3. Seed documents for whatever the user had already created in v1.
  final documents = DocumentRepository(db);
  try {
    final cvCreated = await legacy.getBool('cv_created') ?? false;
    if (cvCreated && profileMap != null && profileMap.isNotEmpty) {
      final existing = await documents.listCvDocuments();
      if (existing.isEmpty) {
        await documents.createCvDocument(
          kind: CvDocumentKind.job,
          name: 'Lebenslauf',
          templateId: await legacy.getString('selected_cv_template_regular'),
          payload: profileMap,
        );
        // The exact "an Ausbildung CV exists" signal introduction_screen
        // used in v1: the Ausbildung questionnaire writes this key on
        // every submit, even when Bildung was left blank.
        if (profileMap.containsKey('ausbildungEduInstitutions')) {
          await documents.createCvDocument(
            kind: CvDocumentKind.ausbildung,
            name: 'Ausbildung Lebenslauf',
            templateId:
                await legacy.getString('selected_cv_template_ausbildung'),
            payload: profileMap,
          );
        }
      }
    }
  } catch (_) {}

  try {
    final anschreibenCreated =
        await legacy.getBool('anschreiben_created') ?? false;
    if (anschreibenCreated && (await documents.listLetterDocuments()).isEmpty) {
      await documents.createLetterDocument(
        name: 'Anschreiben',
        payload: {
          'source': 'v1-migration',
          'unterlagenSelection':
              await legacy.getString('deckblatt_unterlagen_selection'),
        },
      );
    }
  } catch (_) {}

  // 4. Certificates from the Deckblatt Unterlagen selection.
  try {
    final raw = await legacy.getString('deckblatt_unterlagen_selection');
    if (raw != null && raw.isNotEmpty && (await documents.listCertificates()).isEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        for (final key in (decoded['ticked'] as List<dynamic>? ?? [])) {
          final label = kUnterlagenCertificates[key];
          if (label != null) {
            await documents.createCertificate(label: label, kind: key as String);
          }
        }
        for (final custom in (decoded['custom'] as List<dynamic>? ?? [])) {
          final label = (custom as String).trim();
          if (label.isNotEmpty) {
            await documents.createCertificate(label: label, kind: 'custom');
          }
        }
      }
    }
  } catch (_) {}

  await store.setString(kMigrationDoneKey, DateTime.now().toIso8601String());
}
