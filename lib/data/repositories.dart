import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/user_profile.dart';
import 'app_database.dart';
import 'profile_store.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repositories - the API screens use for profile and document data.
//
// [ProfileRepository] is backed by a [ProfileStore] (Drift in the running
// app, SharedPreferences before init / as fallback - see profile_store.dart)
// so it can be used from anywhere without knowing the backend.
//
// [DocumentRepository] is Drift-only: multiple CVs, letters and the
// certificate list are new in v2 and have no v1 equivalent to fall back to.
// ─────────────────────────────────────────────────────────────────────────────

class ProfileRepository {
  ProfileRepository(this._store);

  final ProfileStore _store;

  /// The shared profile as a [UserProfile], or null when none was saved.
  Future<UserProfile?> loadProfile() async {
    final map = await _store.loadProfileMap();
    return map == null ? null : UserProfile.fromMap(map);
  }

  Future<void> saveProfile(UserProfile profile) =>
      _store.saveProfileMap(profile.toMap());

  /// Raw shared profile map - the shape every questionnaire screen merges
  /// its answers into (identical semantics to v1's 'saved_profile').
  Future<Map<String, dynamic>?> loadProfileMap() => _store.loadProfileMap();

  Future<void> saveProfileMap(Map<String, dynamic> map) =>
      _store.saveProfileMap(map);

  // Document-domain key/value access (template selections, temp paths,
  // 'user_*' mirrors, Unterlagen selection, creation flags, ...).
  Future<String?> getString(String key) => _store.getString(key);
  Future<void> setString(String key, String value) =>
      _store.setString(key, value);
  Future<bool> getBool(String key, {bool defaultValue = false}) =>
      _store.getBool(key, defaultValue: defaultValue);
  Future<void> setBool(String key, bool value) => _store.setBool(key, value);
}

/// One saved CV document (see [CvDocuments]).
class CvDocumentRecord {
  final int id;

  /// 'job' or 'ausbildung' ([CvDocumentKind]).
  final String kind;
  final String name;
  final String? templateId;
  final String? accentColor;
  final String? fontSize;
  final String? spacing;
  final bool? showPhoto;

  /// The per-CV answers as a flat map (same shape as the profile map).
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CvDocumentRecord({
    required this.id,
    required this.kind,
    required this.name,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
    this.templateId,
    this.accentColor,
    this.fontSize,
    this.spacing,
    this.showPhoto,
  });
}

/// One saved letter (Anschreiben / Deckblatt flow, see [LetterDocuments]).
class LetterDocumentRecord {
  final int id;
  final String name;
  final String? company;
  final String? jobTitle;

  /// Block texts + phrase choices for this letter.
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LetterDocumentRecord({
    required this.id,
    required this.name,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
    this.company,
    this.jobTitle,
  });
}

/// One certificate / document entry (see [Certificates]).
class CertificateRecord {
  final int id;
  final String label;
  final String kind;
  final String? filePath;
  final DateTime createdAt;

  const CertificateRecord({
    required this.id,
    required this.label,
    required this.kind,
    required this.createdAt,
    this.filePath,
  });
}

abstract final class CvDocumentKind {
  static const String job = 'job';
  static const String ausbildung = 'ausbildung';
}

class DocumentRepository {
  DocumentRepository(this._db);

  final AppDatabase _db;

  // ── CV documents ─────────────────────────────────────────────────────────

  Future<int> createCvDocument({
    required String kind,
    required String name,
    required Map<String, dynamic> payload,
    String? templateId,
    String? accentColor,
    String? fontSize,
    String? spacing,
    bool? showPhoto,
  }) {
    final now = DateTime.now();
    return _db.into(_db.cvDocuments).insert(
          CvDocumentsCompanion.insert(
            kind: kind,
            name: name,
            templateId: Value(templateId),
            accentColor: Value(accentColor),
            fontSize: Value(fontSize),
            spacing: Value(spacing),
            showPhoto: Value(showPhoto),
            payload: jsonEncode(payload),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<List<CvDocumentRecord>> listCvDocuments({String? kind}) async {
    final query = _db.select(_db.cvDocuments);
    if (kind != null) {
      query.where((t) => t.kind.equals(kind));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    final rows = await query.get();
    return rows.map(_cvFromRow).toList();
  }

  Future<CvDocumentRecord?> getCvDocument(int id) async {
    final row = await (_db.select(_db.cvDocuments)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _cvFromRow(row);
  }

  Future<void> updateCvDocument(
    int id, {
    String? name,
    Map<String, dynamic>? payload,
    String? templateId,
    String? accentColor,
    String? fontSize,
    String? spacing,
    bool? showPhoto,
  }) async {
    await (_db.update(_db.cvDocuments)..where((t) => t.id.equals(id))).write(
      CvDocumentsCompanion(
        name: name == null ? const Value.absent() : Value(name),
        payload:
            payload == null ? const Value.absent() : Value(jsonEncode(payload)),
        templateId:
            templateId == null ? const Value.absent() : Value(templateId),
        accentColor:
            accentColor == null ? const Value.absent() : Value(accentColor),
        fontSize: fontSize == null ? const Value.absent() : Value(fontSize),
        spacing: spacing == null ? const Value.absent() : Value(spacing),
        showPhoto: showPhoto == null ? const Value.absent() : Value(showPhoto),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteCvDocument(int id) async {
    await (_db.delete(_db.cvDocuments)..where((t) => t.id.equals(id))).go();
  }

  CvDocumentRecord _cvFromRow(CvDocument row) => CvDocumentRecord(
        id: row.id,
        kind: row.kind,
        name: row.name,
        templateId: row.templateId,
        accentColor: row.accentColor,
        fontSize: row.fontSize,
        spacing: row.spacing,
        showPhoto: row.showPhoto,
        payload: _decodePayload(row.payload),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  // ── Letter documents ─────────────────────────────────────────────────────

  Future<int> createLetterDocument({
    required String name,
    required Map<String, dynamic> payload,
    String? company,
    String? jobTitle,
  }) {
    final now = DateTime.now();
    return _db.into(_db.letterDocuments).insert(
          LetterDocumentsCompanion.insert(
            name: name,
            company: Value(company),
            jobTitle: Value(jobTitle),
            payload: jsonEncode(payload),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<List<LetterDocumentRecord>> listLetterDocuments() async {
    final rows = await (_db.select(_db.letterDocuments)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    return rows.map(_letterFromRow).toList();
  }

  Future<LetterDocumentRecord?> getLetterDocument(int id) async {
    final row = await (_db.select(_db.letterDocuments)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _letterFromRow(row);
  }

  Future<void> updateLetterDocument(
    int id, {
    String? name,
    String? company,
    String? jobTitle,
    Map<String, dynamic>? payload,
  }) async {
    await (_db.update(_db.letterDocuments)..where((t) => t.id.equals(id)))
        .write(
      LetterDocumentsCompanion(
        name: name == null ? const Value.absent() : Value(name),
        company: company == null ? const Value.absent() : Value(company),
        jobTitle: jobTitle == null ? const Value.absent() : Value(jobTitle),
        payload:
            payload == null ? const Value.absent() : Value(jsonEncode(payload)),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteLetterDocument(int id) async {
    await (_db.delete(_db.letterDocuments)..where((t) => t.id.equals(id))).go();
  }

  LetterDocumentRecord _letterFromRow(LetterDocument row) =>
      LetterDocumentRecord(
        id: row.id,
        name: row.name,
        company: row.company,
        jobTitle: row.jobTitle,
        payload: _decodePayload(row.payload),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  // ── Certificates ─────────────────────────────────────────────────────────

  Future<int> createCertificate({
    required String label,
    required String kind,
    String? filePath,
  }) {
    return _db.into(_db.certificates).insert(
          CertificatesCompanion.insert(
            label: label,
            kind: kind,
            filePath: Value(filePath),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<List<CertificateRecord>> listCertificates() async {
    final rows = await (_db.select(_db.certificates)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return rows
        .map((row) => CertificateRecord(
              id: row.id,
              label: row.label,
              kind: row.kind,
              filePath: row.filePath,
              createdAt: row.createdAt,
            ))
        .toList();
  }

  Future<void> deleteCertificate(int id) async {
    await (_db.delete(_db.certificates)..where((t) => t.id.equals(id))).go();
  }

  static Map<String, dynamic> _decodePayload(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
