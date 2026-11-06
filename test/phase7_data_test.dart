import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karyab/data/app_database.dart';
import 'package:karyab/data/repositories.dart';

import 'generated/schema.dart';

// Phase 7 data layer: Drift schema v1 -> v2 migration and the
// JobsRepository (saved jobs, saved searches, application tracker,
// offline job cache). All tests run in-memory / on the drift schema
// verifier, no device needed.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('schema migration v1 -> v2', () {
    test('validates and preserves v1 data, new tables usable', () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(1);

      // Seed v1-shaped data with raw SQL (the generated v1 helper has
      // no data classes): one profile row, one app_meta flag and one
      // v1 CV document.
      schema.rawDatabase.execute(
        "INSERT INTO profile (id, \"fullName\", city) "
        "VALUES (1, 'Ahmad Ahmadi', '10115 Berlin')",
      );
      schema.rawDatabase.execute(
        "INSERT INTO app_meta (key, value) VALUES ('cv_created', 'true')",
      );
      schema.rawDatabase.execute(
        'INSERT INTO cv_documents '
        '(kind, name, template_id, payload, created_at, updated_at) '
        "VALUES ('job', 'Lebenslauf', NULL, '{}', 1700000000, 1700000000)",
      );

      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 2);

      // v1 data survived the migration.
      final profile = await db.select(db.profileEntries).getSingle();
      expect(profile.fullName, 'Ahmad Ahmadi');
      expect(profile.city, '10115 Berlin');
      final meta = await db.select(db.appMeta).get();
      expect(meta.single.value, 'true');
      final cvs = await db.select(db.cvDocuments).get();
      expect(cvs, hasLength(1));
      expect(cvs.single.name, 'Lebenslauf');

      // The four new tables exist and work through the repository.
      final jobs = JobsRepository(db);
      await jobs.saveJob(
        refnr: '123-456',
        title: 'Lagerhelfer',
        company: 'DHL',
        location: '10115 Berlin',
        source: 'jobs',
        payload: const {'referenznummer': '123-456'},
      );
      expect(await jobs.isJobSaved('123-456'), isTrue);
      final appId = await jobs.createApplication(
        refnr: '123-456',
        company: 'DHL',
        jobTitle: 'Lagerhelfer',
      );
      expect(appId, greaterThan(0));

      await db.close();
      schema.close();
    });
  });

  group('JobsRepository on a fresh v2 database', () {
    late AppDatabase db;
    late JobsRepository jobs;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      jobs = JobsRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('saved jobs: save, list, dedupe by refnr, unsave', () async {
      await jobs.saveJob(
        refnr: 'A1',
        title: 'Packer',
        company: 'Amazon',
        location: 'Berlin',
        source: 'jobs',
        payload: const {'referenznummer': 'A1'},
      );
      await jobs.saveJob(
        refnr: 'A2',
        title: 'Fahrer',
        company: 'DHL',
        location: 'Bonn',
        source: 'minijob',
        payload: const {'referenznummer': 'A2'},
      );
      // Saving the same refnr again replaces, never duplicates.
      await jobs.saveJob(
        refnr: 'A1',
        title: 'Packer (updated)',
        company: 'Amazon',
        location: 'Berlin',
        source: 'jobs',
        payload: const {'referenznummer': 'A1'},
      );

      var saved = await jobs.listSavedJobs();
      expect(saved, hasLength(2));
      expect(saved.map((j) => j.refnr).toSet(), {'A1', 'A2'});
      expect(
        saved.firstWhere((j) => j.refnr == 'A1').title,
        'Packer (updated)',
      );
      expect(await jobs.savedRefnrs(), {'A1', 'A2'});

      await jobs.unsaveJob('A1');
      saved = await jobs.listSavedJobs();
      expect(saved, hasLength(1));
      expect(await jobs.isJobSaved('A1'), isFalse);
    });

    test('saved searches: save, list, mark viewed, delete', () async {
      final id = await jobs.saveSearch(
        label: 'Lagerhelfer, Berlin',
        params: const {'mode': 'jobs', 'was': 'Lagerhelfer'},
        topRefnr: 'TOP1',
      );
      var searches = await jobs.listSavedSearches();
      expect(searches, hasLength(1));
      expect(searches.single.label, 'Lagerhelfer, Berlin');
      expect(searches.single.lastTopRefnr, 'TOP1');
      expect(searches.single.lastRunAt, isNotNull);

      await jobs.markSearchViewed(id, topRefnr: 'TOP2');
      searches = await jobs.listSavedSearches();
      expect(searches.single.lastTopRefnr, 'TOP2');

      await jobs.deleteSavedSearch(id);
      expect(await jobs.listSavedSearches(), isEmpty);
    });

    test('applications: status flow advances in order and stops at end',
        () async {
      final id = await jobs.createApplication(
        refnr: 'R1',
        company: 'DHL',
        jobTitle: 'Fahrer',
      );
      var apps = await jobs.listApplications();
      expect(apps.single.status, ApplicationStatus.saved);

      expect(await jobs.advanceApplicationStatus(id),
          ApplicationStatus.applied);
      expect(await jobs.advanceApplicationStatus(id),
          ApplicationStatus.invited);
      expect(await jobs.advanceApplicationStatus(id),
          ApplicationStatus.answered);
      // Last step: no further advance, status unchanged.
      expect(await jobs.advanceApplicationStatus(id), isNull);
      apps = await jobs.listApplications();
      expect(apps.single.status, ApplicationStatus.answered);

      final byRef = await jobs.applicationByRefnr('R1');
      expect(byRef?.id, id);
      expect(await jobs.applicationByRefnr(''), isNull);
      expect(await jobs.applicationByRefnr('nope'), isNull);
    });

    test('applications: document links can be set and cleared', () async {
      final docs = DocumentRepository(db);
      final cvId = await docs.createCvDocument(
        kind: 'job',
        name: 'CV Lager',
        payload: const {},
      );
      final letterId = await docs.createLetterDocument(
        name: 'Letter DHL',
        payload: const {},
      );
      final id = await jobs.createApplication(
        company: 'DHL',
        jobTitle: 'Fahrer',
      );
      await jobs.linkApplicationDocuments(
        id,
        cvDocumentId: cvId,
        setCv: true,
        letterDocumentId: letterId,
        setLetter: true,
      );
      var app = (await jobs.listApplications()).single;
      expect(app.cvDocumentId, cvId);
      expect(app.letterDocumentId, letterId);

      await jobs.linkApplicationDocuments(id, setCv: true);
      app = (await jobs.listApplications()).single;
      expect(app.cvDocumentId, isNull);
      expect(app.letterDocumentId, letterId);

      await jobs.deleteApplication(id);
      expect(await jobs.listApplications(), isEmpty);
    });

    test('job cache: round trip and eviction caps', () async {
      // 22 search entries: the oldest 2 must be evicted (cap 20).
      for (var i = 0; i < 22; i++) {
        await jobs.putCache(
          JobsRepository.searchCacheKey('q$i'),
          '{"n":$i}',
        );
      }
      expect(await jobs.getCache(JobsRepository.searchCacheKey('q0')),
          isNull);
      expect(await jobs.getCache(JobsRepository.searchCacheKey('q1')),
          isNull);
      final newest =
          await jobs.getCache(JobsRepository.searchCacheKey('q21'));
      expect(newest?.payload, '{"n":21}');

      // Details are keyed separately and do not eat the search budget.
      await jobs.putCache(JobsRepository.detailCacheKey('R9'), '{"d":1}');
      final detail = await jobs.getCache(JobsRepository.detailCacheKey('R9'));
      expect(detail?.payload, '{"d":1}');
      expect(await jobs.getCache(JobsRepository.searchCacheKey('q21')),
          isNotNull);
    });
  });
}
