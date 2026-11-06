import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// JobSearchService - Phase 7 shared client for the Bundesagentur für
// Arbeit job search API (the only job source; no scraping, no other
// provider). It factors out what job_finder_screen and
// ausbildung_screen each carried as a private copy, and adds the pieces
// Phase 7 needs in pure, testable form:
//
//   * JobQuery - one value object for every search the app can run
//     (normal jobs, Ausbildung, and the merged Minijob lane), with a
//     stable JSON shape that doubles as the saved-search payload and
//     the offline-cache key.
//   * The Minijob lane: arbeitszeit=mj AND arbeitszeit=tz fetched and
//     merged, deduped by refnr (audit §7 step 1: the BA database is
//     thin for Minijobs, and keyword/title conventions hide them).
//   * countNewJobs - the "new since last visit" computation.
//   * shouldUseCachedResults - the offline fallback decision.
// ─────────────────────────────────────────────────────────────────────────────

/// Why a job list request failed (mirrors the screens' private enum).
enum BaJobsErrorKind { noConnection, timeout, unavailable }

class BaJobsException implements Exception {
  final BaJobsErrorKind kind;
  const BaJobsException(this.kind);

  @override
  String toString() => 'BaJobsException($kind)';
}

/// One posting from the BA job search API.
class BaJob {
  final String title;
  final String company;
  final String ort;
  final String plz;
  final String strasseHausnummer;
  final String refnr;

  /// Distance in km, when the API location carries one (defensively
  /// parsed; the list response does not always include it).
  final double? distanceKm;

  /// Publication / start date string as delivered by the API, when
  /// present (defensively parsed from the known field spellings).
  final String? publishedDate;

  /// The raw posting JSON, kept so saved jobs and the offline cache can
  /// reopen a posting exactly as delivered.
  final Map<String, dynamic> raw;

  const BaJob({
    required this.title,
    required this.company,
    required this.ort,
    required this.plz,
    required this.strasseHausnummer,
    required this.refnr,
    required this.raw,
    this.distanceKm,
    this.publishedDate,
  });

  String get locationDisplay {
    if (plz.isNotEmpty && ort.isNotEmpty) return '$plz $ort';
    return ort;
  }

  String get addressLine {
    final parts = <String>[];
    if (strasseHausnummer.isNotEmpty) parts.add(strasseHausnummer);
    final city = [plz, ort].where((s) => s.isNotEmpty).join(' ');
    if (city.isNotEmpty) parts.add(city);
    return parts.join(', ');
  }

  factory BaJob.fromJson(Map<String, dynamic> j) {
    final locs = j['stellenlokationen'] as List<dynamic>? ?? [];
    final loc = locs.isNotEmpty ? locs.first as Map<String, dynamic> : {};
    final ao = loc['adresse'] as Map<String, dynamic>? ?? {};
    final distRaw = loc['entfernung'];
    String? date;
    for (final key in const [
      'aktuelleVeroeffentlichungsdatum',
      'veroeffentlichungsdatum',
      'eintrittsdatum',
    ]) {
      final v = j[key];
      if (v is String && v.isNotEmpty) {
        date = v;
        break;
      }
    }
    return BaJob(
      title: j['stellenangebotsTitel'] as String? ?? '',
      company: j['firma'] as String? ?? '',
      ort: ao['ort'] as String? ?? '',
      plz: ao['plz'] as String? ?? '',
      strasseHausnummer: ao['strasseHausnummer'] as String? ?? '',
      refnr: j['referenznummer'] as String? ?? '',
      distanceKm: distRaw is num ? distRaw.toDouble() : null,
      publishedDate: date,
      raw: j,
    );
  }

  Map<String, dynamic> toJson() => raw;
}

/// One runnable search. [mode] is 'jobs', 'ausbildung' or 'minijob'.
///
/// For 'minijob', [arbeitszeiten] holds ['mj', 'tz'] and each value is
/// fetched and merged; for the other modes it holds exactly one value
/// (or is empty for Ausbildung, which sends no arbeitszeit).
class JobQuery {
  final String mode;
  final String was;
  final String wo;
  final int umkreis;
  final String angebotsart;
  final List<String> arbeitszeiten;

  const JobQuery({
    required this.mode,
    this.was = '',
    required this.wo,
    this.umkreis = 25,
    required this.angebotsart,
    this.arbeitszeiten = const [],
  });

  factory JobQuery.jobs({
    String was = '',
    required String wo,
    int umkreis = 25,
    String arbeitszeit = 'vz',
  }) =>
      JobQuery(
        mode: 'jobs',
        was: was,
        wo: wo,
        umkreis: umkreis,
        angebotsart: '1',
        arbeitszeiten: [arbeitszeit],
      );

  factory JobQuery.ausbildung({
    String was = '',
    required String wo,
    int umkreis = 25,
  }) =>
      JobQuery(
        mode: 'ausbildung',
        was: was,
        wo: wo,
        umkreis: umkreis,
        angebotsart: '4',
      );

  factory JobQuery.minijob({
    String was = '',
    required String wo,
    int umkreis = 25,
  }) =>
      JobQuery(
        mode: 'minijob',
        was: was,
        wo: wo,
        umkreis: umkreis,
        angebotsart: '1',
        arbeitszeiten: const ['mj', 'tz'],
      );

  Map<String, String> paramsFor(String? arbeitszeit) {
    final params = <String, String>{
      'wo': wo,
      'umkreis': umkreis.toString(),
      'page': '1',
      'size': '25',
      'angebotsart': angebotsart,
      'pav': 'false',
    };
    if (was.isNotEmpty) params['was'] = was;
    if (arbeitszeit != null) params['arbeitszeit'] = arbeitszeit;
    return params;
  }

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'was': was,
        'wo': wo,
        'umkreis': umkreis,
        'angebotsart': angebotsart,
        'arbeitszeiten': arbeitszeiten,
      };

  factory JobQuery.fromJson(Map<String, dynamic> j) => JobQuery(
        mode: j['mode'] as String? ?? 'jobs',
        was: j['was'] as String? ?? '',
        wo: j['wo'] as String? ?? '',
        umkreis: (j['umkreis'] as num?)?.toInt() ?? 25,
        angebotsart: j['angebotsart'] as String? ?? '1',
        arbeitszeiten: (j['arbeitszeiten'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );

  /// Stable cache key for this exact query.
  String get cacheKey => jsonEncode(toJson());

  /// Auto label for a saved search: "<keyword>, <place>", or just the
  /// place for a broad search (the Minijob lane's normal shape).
  String get autoLabel {
    final what = was.trim();
    final where = wo.trim();
    if (what.isEmpty) return where;
    if (where.isEmpty) return what;
    return '$what, $where';
  }
}

class JobSearchService {
  JobSearchService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String apiKey = 'jobboerse-jobsuche';
  static const String baseUrl =
      'https://rest.arbeitsagentur.de/jobboerse/jobsuche-service/pc/v6/jobs';

  /// Runs a query: one request per arbeitszeit value (the Minijob lane
  /// has two), results merged and deduped. Throws [BaJobsException].
  Future<List<BaJob>> runQuery(JobQuery query) async {
    final times =
        query.arbeitszeiten.isEmpty ? <String?>[null] : query.arbeitszeiten;
    final lists = <List<BaJob>>[];
    for (final t in times) {
      lists.add(await _fetchPage(query.paramsFor(t)));
    }
    return mergeJobs(lists);
  }

  Future<List<BaJob>> _fetchPage(Map<String, String> params) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    try {
      final response = await _client
          .get(uri, headers: {'X-API-Key': apiKey})
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['ergebnisliste'] as List<dynamic>? ?? [];
        return items
            .map((j) => BaJob.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw const BaJobsException(BaJobsErrorKind.unavailable);
    } catch (e) {
      if (e is BaJobsException) rethrow;
      final kind = e is TimeoutException
          ? BaJobsErrorKind.timeout
          : (e is SocketException || e is http.ClientException)
              ? BaJobsErrorKind.noConnection
              : BaJobsErrorKind.unavailable;
      throw BaJobsException(kind);
    }
  }

  /// Merges result lists, dedupes by refnr (falling back to
  /// title/company/place for the rare posting without one) and sorts:
  /// by distance when any posting carries one (nearest first, unknown
  /// distance last), otherwise by publication date, newest first.
  static List<BaJob> mergeJobs(List<List<BaJob>> lists) {
    final seen = <String>{};
    final merged = <BaJob>[];
    for (final list in lists) {
      for (final job in list) {
        final key = job.refnr.isNotEmpty
            ? 'r:${job.refnr}'
            : 't:${job.title}|${job.company}|${job.ort}';
        if (seen.add(key)) merged.add(job);
      }
    }
    final anyDistance = merged.any((j) => j.distanceKm != null);
    int byDateDesc(BaJob a, BaJob b) {
      final da = a.publishedDate ?? '';
      final db = b.publishedDate ?? '';
      if (da.isEmpty && db.isEmpty) return 0;
      if (da.isEmpty) return 1;
      if (db.isEmpty) return -1;
      return db.compareTo(da);
    }

    merged.sort((a, b) {
      if (anyDistance) {
        final da = a.distanceKm;
        final db = b.distanceKm;
        if (da != null && db != null && da != db) return da.compareTo(db);
        if (da != null && db == null) return -1;
        if (da == null && db != null) return 1;
      }
      return byDateDesc(a, b);
    });
    return merged;
  }

  /// How many of the fresh head results are newer than the last viewed
  /// top result. When the stored top refnr no longer appears on the
  /// first page, every result on the page counts as new. A null baseline
  /// (search saved without results) counts nothing: the first check
  /// establishes the baseline instead of crying "25 new".
  static int countNewJobs(List<String> freshRefnrs, String? lastTopRefnr) {
    if (lastTopRefnr == null || lastTopRefnr.isEmpty) return 0;
    final idx = freshRefnrs.indexOf(lastTopRefnr);
    if (idx < 0) return freshRefnrs.length;
    return idx;
  }

  /// Offline fallback decision: transport failures (no connection, or
  /// the request timed out) fall back to the cache when one exists. A
  /// live "service unavailable" answer does NOT fall back - the server
  /// answered, and its error is the honest state to show.
  static bool shouldUseCachedResults(BaJobsErrorKind kind, bool hasCache) {
    if (!hasCache) return false;
    return kind == BaJobsErrorKind.noConnection ||
        kind == BaJobsErrorKind.timeout;
  }
}
