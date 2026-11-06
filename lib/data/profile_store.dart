import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_database.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfileStore - the one interface through which the whole app now reads
// and writes the profile/documents data domain:
//
//   * the shared profile map (v1: the 'saved_profile' JSON string),
//   * the small document-domain keys that v1 scattered across
//     SharedPreferences ('cv_created', 'cv_type', template selections,
//     temp file paths, the 'user_*' mirrors, the Unterlagen selection, ...).
//
// Two implementations:
//   * [DriftProfileStore] - the v2 backend (SQLite via Drift), used by the
//     running app after KaryabData.init() has opened the database and run
//     the one-time legacy migration.
//   * [PrefsProfileStore] - the exact v1 backend. It is the default before
//     init (unit/widget tests, early startup) and the automatic fallback if
//     the database ever fails to open, so the app can never lose access to
//     the user's data because of a storage problem.
//
// Pure app *settings* are deliberately NOT part of this interface and stay
// in SharedPreferences exactly as in v1: 'app_language', 'voice_mode',
// 'sound_enabled', 'permissions_onboarding_shown', the Belgium-cleanup flag
// and the last-known-location cache (utils/location_helpers.dart).
// ─────────────────────────────────────────────────────────────────────────────

abstract class ProfileStore {
  /// The shared profile map, or null when no profile was ever saved.
  /// Values keep the v1 shape (flat string map, see UserProfile.fromMap).
  Future<Map<String, dynamic>?> loadProfileMap();

  /// Replaces the shared profile map with [map] (callers merge their
  /// changes into the loaded map first, exactly as the v1 screens did).
  Future<void> saveProfileMap(Map<String, dynamic> map);

  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool> getBool(String key, {bool defaultValue = false});
  Future<void> setBool(String key, bool value);
}

/// The v1 SharedPreferences key holding the shared profile JSON.
const String kLegacyProfileKey = 'saved_profile';

/// Read-only view of the legacy SharedPreferences store, used by the
/// one-time migration (data/legacy_migration.dart) and by
/// [PrefsProfileStore]. The migration never writes through this interface:
/// the v1 data is left untouched as a fallback.
abstract class LegacyKeyValueStore {
  Future<String?> getString(String key);
  Future<bool?> getBool(String key);
}

class SharedPreferencesLegacyStore implements LegacyKeyValueStore {
  const SharedPreferencesLegacyStore();

  @override
  Future<String?> getString(String key) async =>
      (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<bool?> getBool(String key) async =>
      (await SharedPreferences.getInstance()).getBool(key);
}

/// Exact v1 behaviour: profile map as a JSON string in SharedPreferences,
/// every other key stored natively alongside it.
class PrefsProfileStore implements ProfileStore {
  const PrefsProfileStore();

  @override
  Future<Map<String, dynamic>?> loadProfileMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kLegacyProfileKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  @override
  Future<void> saveProfileMap(Map<String, dynamic> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLegacyProfileKey, jsonEncode(map));
  }

  @override
  Future<String?> getString(String key) async =>
      (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<void> setString(String key, String value) async =>
      (await SharedPreferences.getInstance()).setString(key, value);

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async =>
      (await SharedPreferences.getInstance()).getBool(key) ?? defaultValue;

  @override
  Future<void> setBool(String key, bool value) async =>
      (await SharedPreferences.getInstance()).setBool(key, value);
}

/// v2 backend: profile map in the `profile` table (one row, id = 1),
/// document-domain keys in `app_meta` (bools stored as 'true'/'false').
class DriftProfileStore implements ProfileStore {
  DriftProfileStore(this._db);

  final AppDatabase _db;

  static const int profileRowId = 1;

  @override
  Future<Map<String, dynamic>?> loadProfileMap() async {
    final row = await (_db.select(_db.profileEntries)
          ..where((t) => t.id.equals(profileRowId)))
        .getSingleOrNull();
    if (row == null) return null;
    return profileRowJsonToMap(row.toJson());
  }

  @override
  Future<void> saveProfileMap(Map<String, dynamic> map) async {
    final entry = ProfileEntry.fromJson({
      'id': profileRowId,
      ...profileMapToRowJson(map),
    });
    await _db.into(_db.profileEntries).insertOnConflictUpdate(entry);
  }

  @override
  Future<String?> getString(String key) async {
    final row = await (_db.select(_db.appMeta)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> setString(String key, String value) async {
    await _db.into(_db.appMeta).insertOnConflictUpdate(
          AppMetaCompanion.insert(key: key, value: value),
        );
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final raw = await getString(key);
    if (raw == null) return defaultValue;
    return raw == 'true';
  }

  @override
  Future<void> setBool(String key, bool value) =>
      setString(key, value ? 'true' : 'false');
}
