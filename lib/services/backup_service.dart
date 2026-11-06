import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/karyab_data.dart';
import '../data/repositories.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CloudBackupService - Phase 6 opt-in cloud backup.
//
// Default OFF. Nothing is uploaded until the user signs in AND turns the
// backup toggle on (with the consent text on the account screen). The
// backup is one versioned JSON snapshot at users/{uid}/backup/main in
// Firestore (rules: firestore.rules in the repo root; each user can only
// touch their own document).
//
// What goes up: the shared profile map, all CV documents, all letter
// documents, and certificate METADATA (label + kind only). Certificate
// files and photos themselves are NOT uploaded in this phase, and local
// file paths are deliberately excluded from the snapshot because they
// are meaningless on another device.
//
// Local data stays the source of truth. Restore is always an OFFER: on
// sign-in the account screen checks [restoreDecision] and asks the user;
// local data is never overwritten silently. Applying a restore writes
// the cloud profile and inserts cloud documents that are not already
// present locally (matched by kind/name/payload), so a restore can
// never duplicate or delete local documents.
// ─────────────────────────────────────────────────────────────────────────────

/// The raw cloud store seam (tests fake this).
abstract interface class BackupStore {
  Future<void> saveSnapshot(String uid, Map<String, dynamic> snapshot);
  Future<Map<String, dynamic>?> loadSnapshot(String uid);
  Future<void> deleteSnapshot(String uid);
}

/// The real store: Firestore, one document per user.
class FirestoreBackupStore implements BackupStore {
  FirestoreBackupStore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _firestore
      .collection('users')
      .doc(uid)
      .collection('backup')
      .doc('main');

  @override
  Future<void> saveSnapshot(String uid, Map<String, dynamic> snapshot) =>
      _doc(uid).set(snapshot);

  @override
  Future<Map<String, dynamic>?> loadSnapshot(String uid) async {
    final snap = await _doc(uid).get();
    return snap.data();
  }

  @override
  Future<void> deleteSnapshot(String uid) => _doc(uid).delete();
}

/// Local data access seam, so the service can be tested without Drift.
abstract interface class BackupDataSource {
  Future<Map<String, dynamic>?> loadProfileMap();
  Future<void> saveProfileMap(Map<String, dynamic> map);
  Future<List<CvDocumentRecord>> listCvDocuments();
  Future<List<LetterDocumentRecord>> listLetterDocuments();
  Future<List<CertificateRecord>> listCertificates();
  Future<int> createCvDocument(CvDocumentRecord record);
  Future<int> createLetterDocument(LetterDocumentRecord record);
  Future<int> createCertificate(CertificateRecord record);
}

/// The real data source: the Phase 2 data layer.
class KaryabBackupDataSource implements BackupDataSource {
  DocumentRepository get _docs {
    final docs = KaryabData.documents;
    if (docs == null) throw const BackupUnavailableException();
    return docs;
  }

  @override
  Future<Map<String, dynamic>?> loadProfileMap() =>
      KaryabData.profile.loadProfileMap();

  @override
  Future<void> saveProfileMap(Map<String, dynamic> map) =>
      KaryabData.profile.saveProfileMap(map);

  @override
  Future<List<CvDocumentRecord>> listCvDocuments() =>
      _docs.listCvDocuments();

  @override
  Future<List<LetterDocumentRecord>> listLetterDocuments() =>
      _docs.listLetterDocuments();

  @override
  Future<List<CertificateRecord>> listCertificates() =>
      _docs.listCertificates();

  @override
  Future<int> createCvDocument(CvDocumentRecord r) => _docs.createCvDocument(
        kind: r.kind,
        name: r.name,
        payload: r.payload,
        templateId: r.templateId,
        accentColor: r.accentColor,
        fontSize: r.fontSize,
        spacing: r.spacing,
        showPhoto: r.showPhoto,
      );

  @override
  Future<int> createLetterDocument(LetterDocumentRecord r) =>
      _docs.createLetterDocument(
        name: r.name,
        payload: r.payload,
        company: r.company,
        jobTitle: r.jobTitle,
      );

  @override
  Future<int> createCertificate(CertificateRecord r) =>
      _docs.createCertificate(label: r.label, kind: r.kind);
}

/// Thrown when the v2 data layer is in its degraded fallback mode and
/// document backup therefore has nothing safe to read.
class BackupUnavailableException implements Exception {
  const BackupUnavailableException();
}

enum RestoreDecision {
  /// No cloud backup exists for this user.
  noCloud,

  /// A restore should be offered (cloud is newer, or local is empty).
  offer,

  /// This exact cloud backup was already offered and decided on.
  alreadySeen,

  /// Local data is at least as new as the cloud backup.
  localNewerOrEqual,
}

/// Result of applying a restore.
class RestoreResult {
  final bool profileRestored;
  final int cvsAdded;
  final int lettersAdded;
  final int certificatesAdded;

  const RestoreResult({
    required this.profileRestored,
    required this.cvsAdded,
    required this.lettersAdded,
    required this.certificatesAdded,
  });
}

class CloudBackupService {
  CloudBackupService(this._store, {BackupDataSource? data})
      : _data = data ?? KaryabBackupDataSource();

  final BackupStore _store;
  final BackupDataSource _data;

  /// Current snapshot format version.
  static const int snapshotVersion = 1;

  // Local bookkeeping keys (Phase 2 profile KV, app_meta in Drift).
  static const String _enabledKey = 'backup_enabled';
  static const String _lastAtKey = 'backup_last_at';
  static const String _seenCloudAtKey = 'backup_seen_cloud_at';

  // ── Opt-in state ───────────────────────────────────────────────────────

  Future<bool> isEnabled() =>
      KaryabData.profile.getBool(_enabledKey, defaultValue: false);

  Future<void> setEnabled(bool value) =>
      KaryabData.profile.setBool(_enabledKey, value);

  Future<DateTime?> lastBackupAt() async {
    final raw = await KaryabData.profile.getString(_lastAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  // ── Snapshot building (pure, testable) ─────────────────────────────────

  static Map<String, dynamic> cvToJson(CvDocumentRecord r) => {
        'kind': r.kind,
        'name': r.name,
        'template_id': r.templateId,
        'accent_color': r.accentColor,
        'font_size': r.fontSize,
        'spacing': r.spacing,
        'show_photo': r.showPhoto,
        'payload': r.payload,
        'created_at': r.createdAt.toIso8601String(),
        'updated_at': r.updatedAt.toIso8601String(),
      };

  static Map<String, dynamic> letterToJson(LetterDocumentRecord r) => {
        'name': r.name,
        'company': r.company,
        'job_title': r.jobTitle,
        'payload': r.payload,
        'created_at': r.createdAt.toIso8601String(),
        'updated_at': r.updatedAt.toIso8601String(),
      };

  /// Certificate metadata only: label + kind. No file path, no file.
  static Map<String, dynamic> certificateToJson(CertificateRecord r) => {
        'label': r.label,
        'kind': r.kind,
        'created_at': r.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> buildSnapshot({
    required Map<String, dynamic>? profile,
    required List<CvDocumentRecord> cvs,
    required List<LetterDocumentRecord> letters,
    required List<CertificateRecord> certificates,
    required DateTime now,
  }) {
    return {
      'schema': snapshotVersion,
      'app': 'karyab-backup',
      'updated_at': now.toUtc().toIso8601String(),
      'profile': profile,
      'cv_documents': cvs.map(cvToJson).toList(),
      'letter_documents': letters.map(letterToJson).toList(),
      'certificates': certificates.map(certificateToJson).toList(),
    };
  }

  static DateTime? snapshotUpdatedAt(Map<String, dynamic>? snapshot) {
    final raw = snapshot?['updated_at'];
    return raw is String ? DateTime.tryParse(raw) : null;
  }

  /// The newest local document change (CVs + letters carry timestamps;
  /// the profile map has none).
  static DateTime? localLatestUpdate(
    List<CvDocumentRecord> cvs,
    List<LetterDocumentRecord> letters,
  ) {
    DateTime? latest;
    for (final t in [
      ...cvs.map((r) => r.updatedAt),
      ...letters.map((r) => r.updatedAt),
    ]) {
      if (latest == null || t.isAfter(latest)) latest = t;
    }
    return latest;
  }

  static bool snapshotHasData(Map<String, dynamic> snapshot) {
    if (snapshot['profile'] != null) return true;
    for (final key in ['cv_documents', 'letter_documents', 'certificates']) {
      final list = snapshot[key];
      if (list is List && list.isNotEmpty) return true;
    }
    return false;
  }

  // ── Restore decision (pure, testable) ──────────────────────────────────

  static RestoreDecision decideRestore({
    required DateTime? cloudUpdatedAt,
    required bool localHasData,
    required DateTime? localLatestUpdate,
    required DateTime? seenCloudUpdatedAt,
  }) {
    if (cloudUpdatedAt == null) return RestoreDecision.noCloud;
    if (seenCloudUpdatedAt != null &&
        seenCloudUpdatedAt.isAtSameMomentAs(cloudUpdatedAt)) {
      return RestoreDecision.alreadySeen;
    }
    if (!localHasData) return RestoreDecision.offer;
    // Local has only a profile (no timestamped documents): we cannot
    // prove local is newer, so offer and let the user decide.
    if (localLatestUpdate == null) return RestoreDecision.offer;
    return cloudUpdatedAt.isAfter(localLatestUpdate)
        ? RestoreDecision.offer
        : RestoreDecision.localNewerOrEqual;
  }

  // ── Operations ─────────────────────────────────────────────────────────

  /// Builds the snapshot from local data and uploads it for [uid].
  /// Returns the snapshot that was written (also used for
  /// "Download my data", which shares the same shape).
  Future<Map<String, dynamic>> buildLocalSnapshot() async {
    final profile = await _data.loadProfileMap();
    final cvs = await _data.listCvDocuments();
    final letters = await _data.listLetterDocuments();
    final certificates = await _data.listCertificates();
    return buildSnapshot(
      profile: profile,
      cvs: cvs,
      letters: letters,
      certificates: certificates,
      now: DateTime.now(),
    );
  }

  Future<DateTime> backupNow(String uid) async {
    final snapshot = await buildLocalSnapshot();
    await _store.saveSnapshot(uid, snapshot);
    final at = snapshotUpdatedAt(snapshot) ?? DateTime.now().toUtc();
    await KaryabData.profile.setString(
      _lastAtKey,
      at.toIso8601String(),
    );
    return at;
  }

  Future<Map<String, dynamic>?> fetchCloudSnapshot(String uid) =>
      _store.loadSnapshot(uid);

  Future<void> deleteCloudBackup(String uid) async {
    await _store.deleteSnapshot(uid);
    await setEnabled(false);
  }

  /// Evaluates whether a restore should be offered to [uid] right now.
  Future<({RestoreDecision decision, DateTime? cloudUpdatedAt})>
      restoreOffer(String uid) async {
    final cloud = await _store.loadSnapshot(uid);
    final cloudAt = snapshotUpdatedAt(cloud);
    if (cloud == null || cloudAt == null) {
      return (decision: RestoreDecision.noCloud, cloudUpdatedAt: null);
    }
    final profile = await _data.loadProfileMap();
    final cvs = await _data.listCvDocuments();
    final letters = await _data.listLetterDocuments();
    final certificates = await _data.listCertificates();
    final localHasData = profile != null ||
        cvs.isNotEmpty ||
        letters.isNotEmpty ||
        certificates.isNotEmpty;
    final seenRaw = await KaryabData.profile.getString(_seenCloudAtKey);
    return (
      decision: decideRestore(
        cloudUpdatedAt: cloudAt,
        localHasData: localHasData,
        localLatestUpdate: localLatestUpdate(cvs, letters),
        seenCloudUpdatedAt:
            seenRaw == null ? null : DateTime.tryParse(seenRaw),
      ),
      cloudUpdatedAt: cloudAt,
    );
  }

  /// Records that the cloud backup dated [cloudUpdatedAt] was offered,
  /// so the same backup is not offered again on every sign-in.
  Future<void> markRestoreSeen(DateTime cloudUpdatedAt) =>
      KaryabData.profile.setString(
        _seenCloudAtKey,
        cloudUpdatedAt.toIso8601String(),
      );

  /// Applies a confirmed restore: writes the cloud profile and inserts
  /// cloud documents that are not already present locally. Never
  /// deletes or overwrites a local document.
  Future<RestoreResult> applyRestore(Map<String, dynamic> snapshot) async {
    var profileRestored = false;
    final rawProfile = snapshot['profile'];
    if (rawProfile is Map) {
      await _data.saveProfileMap(Map<String, dynamic>.from(rawProfile));
      profileRestored = true;
    }

    final existingCvs = await _data.listCvDocuments();
    String cvKey(String kind, String name, Map<String, dynamic> payload) =>
        '$kind|$name|${jsonEncode(payload)}';
    final localCvKeys = {
      for (final r in existingCvs) cvKey(r.kind, r.name, r.payload),
    };
    var cvsAdded = 0;
    final rawCvs = snapshot['cv_documents'];
    if (rawCvs is List) {
      for (final raw in rawCvs) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final payload = map['payload'] is Map
            ? Map<String, dynamic>.from(map['payload'] as Map)
            : <String, dynamic>{};
        final kind = map['kind']?.toString() ?? CvDocumentKind.job;
        final name = map['name']?.toString() ?? '';
        if (name.isEmpty || localCvKeys.contains(cvKey(kind, name, payload))) {
          continue;
        }
        await _data.createCvDocument(
          CvDocumentRecord(
            id: 0,
            kind: kind,
            name: name,
            payload: payload,
            templateId: map['template_id']?.toString(),
            accentColor: map['accent_color']?.toString(),
            fontSize: map['font_size']?.toString(),
            spacing: map['spacing']?.toString(),
            showPhoto: map['show_photo'] is bool
                ? map['show_photo'] as bool
                : null,
            createdAt: DateTime.tryParse('${map['created_at']}') ??
                DateTime.now(),
            updatedAt: DateTime.tryParse('${map['updated_at']}') ??
                DateTime.now(),
          ),
        );
        cvsAdded++;
      }
    }

    final existingLetters = await _data.listLetterDocuments();
    String letterKey(String name, Map<String, dynamic> payload) =>
        '$name|${jsonEncode(payload)}';
    final localLetterKeys = {
      for (final r in existingLetters) letterKey(r.name, r.payload),
    };
    var lettersAdded = 0;
    final rawLetters = snapshot['letter_documents'];
    if (rawLetters is List) {
      for (final raw in rawLetters) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final payload = map['payload'] is Map
            ? Map<String, dynamic>.from(map['payload'] as Map)
            : <String, dynamic>{};
        final name = map['name']?.toString() ?? '';
        if (name.isEmpty ||
            localLetterKeys.contains(letterKey(name, payload))) {
          continue;
        }
        await _data.createLetterDocument(
          LetterDocumentRecord(
            id: 0,
            name: name,
            payload: payload,
            company: map['company']?.toString(),
            jobTitle: map['job_title']?.toString(),
            createdAt: DateTime.tryParse('${map['created_at']}') ??
                DateTime.now(),
            updatedAt: DateTime.tryParse('${map['updated_at']}') ??
                DateTime.now(),
          ),
        );
        lettersAdded++;
      }
    }

    final existingCerts = await _data.listCertificates();
    final localCertKeys = {
      for (final r in existingCerts) '${r.label}|${r.kind}',
    };
    var certsAdded = 0;
    final rawCerts = snapshot['certificates'];
    if (rawCerts is List) {
      for (final raw in rawCerts) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final label = map['label']?.toString() ?? '';
        final kind = map['kind']?.toString() ?? 'other';
        if (label.isEmpty || localCertKeys.contains('$label|$kind')) {
          continue;
        }
        await _data.createCertificate(
          CertificateRecord(
            id: 0,
            label: label,
            kind: kind,
            createdAt: DateTime.tryParse('${map['created_at']}') ??
                DateTime.now(),
          ),
        );
        certsAdded++;
      }
    }

    return RestoreResult(
      profileRestored: profileRestored,
      cvsAdded: cvsAdded,
      lettersAdded: lettersAdded,
      certificatesAdded: certsAdded,
    );
  }
}

/// The app-wide backup service (lazily built, same pattern as
/// [karyabAuth] in auth_service.dart).
CloudBackupService? _karyabBackupInstance;

CloudBackupService get karyabBackup =>
    _karyabBackupInstance ??= CloudBackupService(FirestoreBackupStore());

/// Test seam for the app-wide backup service.
void debugSetKaryabBackup(CloudBackupService? service) {
  _karyabBackupInstance = service;
}
