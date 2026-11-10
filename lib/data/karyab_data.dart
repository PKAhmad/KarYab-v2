import 'app_database.dart';
import 'legacy_migration.dart';
import 'profile_store.dart';
import 'repositories.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KaryabData - the app-wide entry point to the v2 data layer.
//
// Before [init] runs (unit/widget tests, the very first frames), [profile]
// is backed by the exact v1 SharedPreferences store, so every caller behaves
// precisely as the pre-v2 app did. main() calls [init] before runApp():
// it opens the Drift database, runs the one-time legacy migration, and
// swaps the store to Drift. If anything in that sequence fails, the app
// silently keeps the v1 backend - storage trouble must never lock a user
// out of their own CV data.
// ─────────────────────────────────────────────────────────────────────────────

abstract final class KaryabData {
  static ProfileStore _store = const PrefsProfileStore();
  static AppDatabase? _database;
  static DocumentRepository? _documents;
  static JobsRepository? _jobs;
  static GuidesRepository? _guides;
  static bool _initialised = false;

  /// Profile + document-domain key/value access. Always safe to call.
  static ProfileRepository get profile => ProfileRepository(_store);

  /// The store behind [profile] (exposed for tests and diagnostics).
  static ProfileStore get store => _store;

  /// Multiple-CV / letter / certificate storage. Null until [init] has
  /// opened the database (and in the degraded fallback mode).
  static DocumentRepository? get documents => _documents;

  /// Phase 7 job-side storage (saved jobs/searches, tracker, job
  /// cache). Null until [init], same contract as [documents].
  static JobsRepository? get jobs => _jobs;

  /// Phase 11 guide step check-offs. Null until [init], same
  /// contract as [documents].
  static GuidesRepository? get guides => _guides;

  static AppDatabase? get database => _database;

  static bool get isInitialised => _initialised;

  /// Opens the Drift database, migrates the v1 SharedPreferences data into
  /// it (first launch only) and switches [profile] to the Drift backend.
  /// Idempotent; never throws.
  static Future<void> init() async {
    if (_initialised) return;
    _initialised = true;
    try {
      final db = AppDatabase.production();
      // Force the database open now so a broken database is detected here
      // (and falls back) instead of on the first user-facing read.
      await db.select(db.appMeta).get();
      await migrateLegacyData(
        db: db,
        legacy: const SharedPreferencesLegacyStore(),
      );
      _database = db;
      _documents = DocumentRepository(db);
      _jobs = JobsRepository(db);
      _guides = GuidesRepository(db);
      _store = DriftProfileStore(db);
    } catch (_) {
      // Degraded mode: _store stays the v1 SharedPreferences backend.
      _database = null;
      _documents = null;
      _jobs = null;
      _guides = null;
    }
  }

  /// Test seam: replace the active store/database (e.g. with an in-memory
  /// Drift database) or restore the default v1 backend with
  /// `debugReset()`.
  static void debugUseStore(
    ProfileStore store, {
    AppDatabase? database,
    DocumentRepository? documents,
    JobsRepository? jobs,
    GuidesRepository? guides,
  }) {
    _store = store;
    _database = database;
    _documents = documents;
    _jobs = jobs;
    _guides = guides;
    _initialised = true;
  }

  static void debugReset() {
    _store = const PrefsProfileStore();
    _database = null;
    _documents = null;
    _jobs = null;
    _guides = null;
    _initialised = false;
  }
}
