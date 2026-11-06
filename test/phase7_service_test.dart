import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:karyab/services/job_search_service.dart';

// Phase 7 JobSearchService: Minijob merge/dedupe, sorting, new-count
// computation and the offline-cache fallback decision, all exercised
// with fixture BA API responses through a mock http client.

Map<String, dynamic> entry(
  String refnr, {
  String title = 'Stelle',
  String company = 'Firma',
  String ort = 'Berlin',
  double? distance,
  String? date,
}) {
  return {
    'stellenangebotsTitel': title,
    'firma': company,
    'referenznummer': refnr,
    if (date != null) 'veroeffentlichungsdatum': date,
    'stellenlokationen': [
      {
        if (distance != null) 'entfernung': distance,
        'adresse': {
          'ort': ort,
          'plz': '10115',
          'strasseHausnummer': 'Hauptstr. 1',
        },
      },
    ],
  };
}

String bodyOf(List<Map<String, dynamic>> items) =>
    jsonEncode({'ergebnisliste': items});

void main() {
  group('BaJob.fromJson', () {
    test('parses fields defensively, keeps raw payload', () {
      final job = BaJob.fromJson(entry('R1',
          title: 'Lagerhelfer', company: 'DHL', distance: 3.5, date: '2026-11-01'));
      expect(job.title, 'Lagerhelfer');
      expect(job.company, 'DHL');
      expect(job.locationDisplay, '10115 Berlin');
      expect(job.addressLine, 'Hauptstr. 1, 10115 Berlin');
      expect(job.distanceKm, 3.5);
      expect(job.publishedDate, '2026-11-01');
      expect(job.raw['referenznummer'], 'R1');
    });

    test('missing optional pieces degrade to empty/null', () {
      final job = BaJob.fromJson(const {});
      expect(job.title, '');
      expect(job.refnr, '');
      expect(job.distanceKm, isNull);
      expect(job.publishedDate, isNull);
    });
  });

  group('mergeJobs', () {
    test('dedupes by refnr and keeps the first copy', () {
      final merged = JobSearchService.mergeJobs([
        [BaJob.fromJson(entry('R1', title: 'Minijob A'))],
        [
          BaJob.fromJson(entry('R1', title: 'Duplicate')),
          BaJob.fromJson(entry('R2', title: 'Teilzeit B')),
        ],
      ]);
      expect(merged, hasLength(2));
      expect(merged.firstWhere((j) => j.refnr == 'R1').title, 'Minijob A');
    });

    test('sorts by distance when distances are present', () {
      final merged = JobSearchService.mergeJobs([
        [
          BaJob.fromJson(entry('R1', distance: 9.0)),
          BaJob.fromJson(entry('R2', distance: 1.5)),
          BaJob.fromJson(entry('R3')),
        ],
      ]);
      expect(merged.map((j) => j.refnr).toList(), ['R2', 'R1', 'R3']);
    });

    test('sorts by date, newest first, when no distances', () {
      final merged = JobSearchService.mergeJobs([
        [
          BaJob.fromJson(entry('R1', date: '2026-10-01')),
          BaJob.fromJson(entry('R2', date: '2026-11-05')),
          BaJob.fromJson(entry('R3')),
        ],
      ]);
      expect(merged.map((j) => j.refnr).toList(), ['R2', 'R1', 'R3']);
    });
  });

  group('runQuery - Minijob lane', () {
    test('fetches mj and tz, merges with dedupe, sends BA params', () async {
      final seenParams = <Map<String, String>>[];
      final client = MockClient((request) async {
        seenParams.add(request.url.queryParameters);
        final az = request.url.queryParameters['arbeitszeit'];
        if (az == 'mj') {
          return http.Response(
              bodyOf([entry('M1'), entry('SHARED', title: 'From MJ')]), 200);
        }
        if (az == 'tz') {
          return http.Response(
              bodyOf([entry('SHARED', title: 'From TZ'), entry('T1')]), 200);
        }
        return http.Response('{}', 400);
      });
      final service = JobSearchService(client: client);
      final query = JobQuery.minijob(wo: '10115 Berlin', umkreis: 25);
      final jobs = await service.runQuery(query);

      expect(jobs.map((j) => j.refnr).toSet(), {'M1', 'SHARED', 'T1'});
      expect(jobs.firstWhere((j) => j.refnr == 'SHARED').title, 'From MJ');
      expect(seenParams, hasLength(2));
      for (final p in seenParams) {
        expect(p['angebotsart'], '1');
        expect(p['wo'], '10115 Berlin');
        expect(p['umkreis'], '25');
        expect(p.containsKey('was'), isFalse,
            reason: 'broad lane must not send an empty keyword');
      }
      expect(seenParams.map((p) => p['arbeitszeit']).toSet(), {'mj', 'tz'});
    });

    test('keyword minijob search sends was to both queries', () async {
      final seen = <String?>[];
      final client = MockClient((request) async {
        seen.add(request.url.queryParameters['was']);
        return http.Response(bodyOf(const []), 200);
      });
      final service = JobSearchService(client: client);
      await service.runQuery(JobQuery.minijob(was: 'Reinigung', wo: 'Bonn'));
      expect(seen, ['Reinigung', 'Reinigung']);
    });

    test('HTTP error maps to unavailable, transport error to noConnection',
        () async {
      final failing = JobSearchService(
        client: MockClient((_) async => http.Response('x', 503)),
      );
      await expectLater(
        failing.runQuery(JobQuery.jobs(wo: 'Berlin')),
        throwsA(isA<BaJobsException>().having(
            (e) => e.kind, 'kind', BaJobsErrorKind.unavailable)),
      );

      final offline = JobSearchService(
        client: MockClient(
            (_) async => throw http.ClientException('no route')),
      );
      await expectLater(
        offline.runQuery(JobQuery.jobs(wo: 'Berlin')),
        throwsA(isA<BaJobsException>().having(
            (e) => e.kind, 'kind', BaJobsErrorKind.noConnection)),
      );
    });
  });

  group('countNewJobs', () {
    test('counts refnrs above the stored top', () {
      expect(
          JobSearchService.countNewJobs(
              ['N1', 'N2', 'OLD', 'X'], 'OLD'),
          2);
    });
    test('zero when the top is still the top', () {
      expect(JobSearchService.countNewJobs(['OLD', 'X'], 'OLD'), 0);
    });
    test('whole page counts when the stored top fell off the page', () {
      expect(JobSearchService.countNewJobs(['A', 'B', 'C'], 'GONE'), 3);
    });
    test('null baseline counts nothing (first check sets the base)', () {
      expect(JobSearchService.countNewJobs(['A', 'B'], null), 0);
      expect(JobSearchService.countNewJobs(['A', 'B'], ''), 0);
    });
  });

  group('shouldUseCachedResults', () {
    test('transport failures with a cache fall back', () {
      expect(
          JobSearchService.shouldUseCachedResults(
              BaJobsErrorKind.noConnection, true),
          isTrue);
      expect(
          JobSearchService.shouldUseCachedResults(
              BaJobsErrorKind.timeout, true),
          isTrue);
    });
    test('server errors never fall back, and no cache means no fallback',
        () {
      expect(
          JobSearchService.shouldUseCachedResults(
              BaJobsErrorKind.unavailable, true),
          isFalse);
      expect(
          JobSearchService.shouldUseCachedResults(
              BaJobsErrorKind.noConnection, false),
          isFalse);
    });
  });
}
