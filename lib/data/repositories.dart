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

// ─────────────────────────────────────────────────────────────────────────────
// Phase 7 job-side repository: saved jobs, saved searches, the
// application tracker and the offline job cache. Drift-only, like
// [DocumentRepository] - none of this existed in v1.
// ─────────────────────────────────────────────────────────────────────────────

/// Tracker status values, in flow order (see [ApplicationStatus.advance]).
abstract final class ApplicationStatus {
  static const String saved = 'saved';
  static const String applied = 'applied';
  static const String invited = 'invited';
  static const String answered = 'answered';

  static const List<String> flow = [saved, applied, invited, answered];

  /// The next status in the flow, or null when [status] is the last one
  /// (or unknown).
  static String? next(String status) {
    final i = flow.indexOf(status);
    if (i < 0 || i >= flow.length - 1) return null;
    return flow[i + 1];
  }
}

/// One bookmarked posting (see [SavedJobs]).
class SavedJobRecord {
  final String refnr;
  final String title;
  final String company;
  final String location;

  /// 'jobs', 'ausbildung' or 'minijob'.
  final String source;
  final DateTime savedAt;

  /// The full posting JSON, so the job can be reopened offline.
  final Map<String, dynamic> payload;

  const SavedJobRecord({
    required this.refnr,
    required this.title,
    required this.company,
    required this.location,
    required this.source,
    required this.savedAt,
    required this.payload,
  });
}

/// One saved search (see [SavedSearches]).
class SavedSearchRecord {
  final int id;
  final String label;

  /// JobQuery JSON (services/job_search_service.dart).
  final Map<String, dynamic> params;
  final DateTime? lastRunAt;
  final String? lastTopRefnr;

  const SavedSearchRecord({
    required this.id,
    required this.label,
    required this.params,
    this.lastRunAt,
    this.lastTopRefnr,
  });
}

/// One tracked application (see [Applications]).
class ApplicationRecord {
  final int id;
  final String? refnr;
  final String company;
  final String jobTitle;
  final String status;
  final int? cvDocumentId;
  final int? letterDocumentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApplicationRecord({
    required this.id,
    required this.company,
    required this.jobTitle,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.refnr,
    this.cvDocumentId,
    this.letterDocumentId,
  });
}

/// One offline-cache entry (see [JobCache]).
class JobCacheRecord {
  final String cacheKey;
  final String payload;
  final DateTime fetchedAt;

  const JobCacheRecord({
    required this.cacheKey,
    required this.payload,
    required this.fetchedAt,
  });
}

class JobsRepository {
  JobsRepository(this._db);

  final AppDatabase _db;

  /// Cache caps (Phase 7): keep the newest search result lists and the
  /// newest opened job details; older entries are evicted on write.
  static const int maxSearchCacheEntries = 20;
  static const int maxDetailCacheEntries = 50;

  static String searchCacheKey(String queryKey) => 'search:$queryKey';
  static String detailCacheKey(String refnr) => 'detail:$refnr';

  // ── Saved jobs ───────────────────────────────────────────────────────────

  Future<void> saveJob({
    required String refnr,
    required String title,
    required String company,
    required String location,
    required String source,
    required Map<String, dynamic> payload,
  }) {
    return _db.into(_db.savedJobs).insertOnConflictUpdate(
          SavedJobsCompanion.insert(
            refnr: refnr,
            title: title,
            company: company,
            location: location,
            source: source,
            savedAt: DateTime.now(),
            payload: jsonEncode(payload),
          ),
        );
  }

  Future<void> unsaveJob(String refnr) async {
    await (_db.delete(_db.savedJobs)..where((t) => t.refnr.equals(refnr)))
        .go();
  }

  Future<bool> isJobSaved(String refnr) async {
    final row = await (_db.select(_db.savedJobs)
          ..where((t) => t.refnr.equals(refnr)))
        .getSingleOrNull();
    return row != null;
  }

  Future<Set<String>> savedRefnrs() async {
    final rows = await _db.select(_db.savedJobs).get();
    return rows.map((r) => r.refnr).toSet();
  }

  Future<List<SavedJobRecord>> listSavedJobs() async {
    final rows = await (_db.select(_db.savedJobs)
          ..orderBy([(t) => OrderingTerm.desc(t.savedAt)]))
        .get();
    return rows
        .map((row) => SavedJobRecord(
              refnr: row.refnr,
              title: row.title,
              company: row.company,
              location: row.location,
              source: row.source,
              savedAt: row.savedAt,
              payload: DocumentRepository._decodePayload(row.payload),
            ))
        .toList();
  }

  // ── Saved searches ───────────────────────────────────────────────────────

  Future<int> saveSearch({
    required String label,
    required Map<String, dynamic> params,
    String? topRefnr,
  }) {
    return _db.into(_db.savedSearches).insert(
          SavedSearchesCompanion.insert(
            label: label,
            params: jsonEncode(params),
            lastRunAt: Value(DateTime.now()),
            lastTopRefnr: Value(topRefnr),
          ),
        );
  }

  Future<List<SavedSearchRecord>> listSavedSearches() async {
    final rows = await (_db.select(_db.savedSearches)
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .get();
    return rows.map(_searchFromRow).toList();
  }

  Future<void> markSearchViewed(int id, {required String? topRefnr}) async {
    await (_db.update(_db.savedSearches)..where((t) => t.id.equals(id)))
        .write(
      SavedSearchesCompanion(
        lastRunAt: Value(DateTime.now()),
        lastTopRefnr: Value(topRefnr),
      ),
    );
  }

  Future<void> deleteSavedSearch(int id) async {
    await (_db.delete(_db.savedSearches)..where((t) => t.id.equals(id)))
        .go();
  }

  SavedSearchRecord _searchFromRow(SavedSearch row) => SavedSearchRecord(
        id: row.id,
        label: row.label,
        params: DocumentRepository._decodePayload(row.params),
        lastRunAt: row.lastRunAt,
        lastTopRefnr: row.lastTopRefnr,
      );

  // ── Application tracker ──────────────────────────────────────────────────

  Future<int> createApplication({
    String? refnr,
    required String company,
    required String jobTitle,
    String status = ApplicationStatus.saved,
    int? cvDocumentId,
    int? letterDocumentId,
  }) {
    final now = DateTime.now();
    return _db.into(_db.applications).insert(
          ApplicationsCompanion.insert(
            refnr: Value(refnr),
            company: company,
            jobTitle: jobTitle,
            status: status,
            cvDocumentId: Value(cvDocumentId),
            letterDocumentId: Value(letterDocumentId),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<List<ApplicationRecord>> listApplications() async {
    final rows = await (_db.select(_db.applications)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    return rows.map(_applicationFromRow).toList();
  }

  Future<ApplicationRecord?> applicationByRefnr(String refnr) async {
    if (refnr.isEmpty) return null;
    final row = await (_db.select(_db.applications)
          ..where((t) => t.refnr.equals(refnr))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _applicationFromRow(row);
  }

  Future<void> updateApplicationStatus(int id, String status) async {
    await (_db.update(_db.applications)..where((t) => t.id.equals(id)))
        .write(
      ApplicationsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Advances the application one step in the status flow. Returns the
  /// new status, or null when it was already at the last step.
  Future<String?> advanceApplicationStatus(int id) async {
    final row = await (_db.select(_db.applications)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final next = ApplicationStatus.next(row.status);
    if (next == null) return null;
    await updateApplicationStatus(id, next);
    return next;
  }

  Future<void> linkApplicationDocuments(
    int id, {
    int? cvDocumentId,
    int? letterDocumentId,
    bool setCv = false,
    bool setLetter = false,
  }) async {
    await (_db.update(_db.applications)..where((t) => t.id.equals(id)))
        .write(
      ApplicationsCompanion(
        cvDocumentId:
            setCv ? Value(cvDocumentId) : const Value.absent(),
        letterDocumentId:
            setLetter ? Value(letterDocumentId) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteApplication(int id) async {
    await (_db.delete(_db.applications)..where((t) => t.id.equals(id))).go();
  }

  ApplicationRecord _applicationFromRow(Application row) => ApplicationRecord(
        id: row.id,
        refnr: row.refnr,
        company: row.company,
        jobTitle: row.jobTitle,
        status: row.status,
        cvDocumentId: row.cvDocumentId,
        letterDocumentId: row.letterDocumentId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  // ── Offline job cache ────────────────────────────────────────────────────

  Future<void> putCache(String cacheKey, String payload) async {
    await _db.into(_db.jobCache).insertOnConflictUpdate(
          JobCacheCompanion.insert(
            cacheKey: cacheKey,
            payload: payload,
            fetchedAt: DateTime.now(),
          ),
        );
    await _evictCache();
  }

  Future<JobCacheRecord?> getCache(String cacheKey) async {
    final row = await (_db.select(_db.jobCache)
          ..where((t) => t.cacheKey.equals(cacheKey)))
        .getSingleOrNull();
    if (row == null) return null;
    return JobCacheRecord(
      cacheKey: row.cacheKey,
      payload: row.payload,
      fetchedAt: row.fetchedAt,
    );
  }

  Future<void> _evictCache() async {
    // fetched_at has second resolution, so several entries can share a
    // timestamp; rowid (insertion order) is the deterministic tiebreak
    // for "newest". insertOnConflictUpdate assigns a fresh rowid on
    // replace, which correctly makes a refreshed entry the newest.
    await _db.customStatement(
      'DELETE FROM job_cache WHERE cache_key LIKE ? AND rowid NOT IN '
      '(SELECT rowid FROM job_cache WHERE cache_key LIKE ? '
      'ORDER BY fetched_at DESC, rowid DESC LIMIT ?)',
      ['search:%', 'search:%', maxSearchCacheEntries],
    );
    await _db.customStatement(
      'DELETE FROM job_cache WHERE cache_key LIKE ? AND rowid NOT IN '
      '(SELECT rowid FROM job_cache WHERE cache_key LIKE ? '
      'ORDER BY fetched_at DESC, rowid DESC LIMIT ?)',
      ['detail:%', 'detail:%', maxDetailCacheEntries],
    );
  }
}
