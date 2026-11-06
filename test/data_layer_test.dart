import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:karyab/data/app_database.dart';
import 'package:karyab/data/karyab_data.dart';
import 'package:karyab/data/legacy_migration.dart';
import 'package:karyab/data/profile_store.dart';
import 'package:karyab/data/repositories.dart';
import 'package:karyab/models/user_profile.dart';

// Phase 2 data layer: Drift backend, v1 -> v2 migration, repositories.
// All tests run against an in-memory database and the SharedPreferences
// mock, so they exercise the exact production code paths with no device.

const Map<String, String> _v1ProfileMap = {
  'fullName': 'Ahmad Ahmadi',
  'dobDay': '3',
  'dobMonth': '7',
  'dobYear': '1998',
  'country': 'Afghanistan',
  'phone': '+49 170 1234567',
  'email': 'ahmad@example.com',
  'street': 'Musterstraße 12',
  'city': '10115 Berlin',
  'photoPath': '/data/photo.jpg',
  'skill': 'lifting,packing',
  'workExperience': 'more2',
  'workType': 'warehouse',
  'tools': 'forklift',
  'drivingLicense': 'B',
  'languages': 'Paschtu,Deutsch',
  'languageProficiency': 'Paschtu:Muttersprache,Deutsch:B1',
  'availability': 'fulltime',
  'startDate': 'immediately',
  'educationLevel': 'mittlere',
  'previousEmployers': 'DHL,Amazon',
  'previousJobTitles': 'Packer,Helper',
  'previousJobDurations': '2020-2022,2022-2024',
  'sharedWorkOrts': 'Berlin,Bonn',
  'sharedWorkTypes': 'job,praktikum',
  'sharedItSkills': 'Word,Excel',
  'ausbildungEduInstitutions': 'Berufsschule Berlin',
  'ausbildungEduOrts': 'Berlin',
  'ausbildungEduTypes': 'berufsschule',
  'ausbildungEduAbschluss': 'Abschluss',
  'ausbildungEduDurations': '2018-2021',
  'ausbildungEduGrades': '2,5',
  'ausbildungEscoSkills': 'Lagerlogistik',
  'ausbildungTargetOccupation': 'Fachlagerist/in',
  'ausbildungTargetOccupationUri': 'http://data.europa.eu/esco/occupation/x',
  'schulabschluss': 'realschule',
  'schulabschlussNote': '2',
  // A key this version has no column for: must survive via extraData.
  'futureUnknownKey': 'keep-me',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
    KaryabData.debugReset();
  });

  group('migration from a populated v1 SharedPreferences fixture', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'saved_profile': jsonEncode(_v1ProfileMap),
        'cv_created': true,
        'anschreiben_created': true,
        'cv_type': 'job',
        'user_name': 'Ahmad',
        'user_phone': '+49 170 1234567',
        'user_email': 'ahmad@example.com',
        'user_street': 'Musterstraße 12',
        'user_city': '10115 Berlin',
        'user_postal': '',
        'questionnaire_full_name': 'Ahmad Ahmadi',
        'selected_cv_template_regular': 'darkSidebar',
        'selected_cv_template_ausbildung': 'navyHeader',
        'deckblatt_unterlagen_selection': jsonEncode({
          'ticked': ['lebenslauf', 'zeugnisse', 'sprachzertifikat'],
          'custom': ['Arbeitszeugnis 2019'],
        }),
      });
    });

    test('imports profile, keys and seeded documents exactly once',
        () async {
      await migrateLegacyData(
        db: db,
        legacy: const SharedPreferencesLegacyStore(),
      );

      final store = DriftProfileStore(db);

      // Profile: every v1 key round-trips, including the unknown one.
      final map = await store.loadProfileMap();
      expect(map, isNotNull);
      for (final entry in _v1ProfileMap.entries) {
        expect(map![entry.key], entry.value, reason: 'key ${entry.key}');
      }

      // Document-domain keys and flags.
      expect(await store.getString('cv_type'), 'job');
      expect(await store.getString('user_email'), 'ahmad@example.com');
      expect(await store.getBool('cv_created'), isTrue);
      expect(await store.getBool('anschreiben_created'), isTrue);

      // Seeded documents: v1 had both a Job CV and an Ausbildung CV
      // (ausbildungEduInstitutions key present) plus an Anschreiben.
      final documents = DocumentRepository(db);
      final cvs = await documents.listCvDocuments();
      expect(cvs, hasLength(2));
      expect(cvs.map((c) => c.kind).toSet(),
          {CvDocumentKind.job, CvDocumentKind.ausbildung});
      final jobCv = cvs.firstWhere((c) => c.kind == CvDocumentKind.job);
      expect(jobCv.templateId, 'darkSidebar');
      expect(jobCv.payload['fullName'], 'Ahmad Ahmadi');
      final ausbildungCv =
          cvs.firstWhere((c) => c.kind == CvDocumentKind.ausbildung);
      expect(ausbildungCv.templateId, 'navyHeader');

      final letters = await documents.listLetterDocuments();
      expect(letters, hasLength(1));
      expect(letters.single.payload['source'], 'v1-migration');

      // Certificates: standard certificate entries + custom labels;
      // 'lebenslauf' is a document, not a certificate.
      final certificates = await documents.listCertificates();
      expect(
        certificates.map((c) => c.label).toSet(),
        {'Zeugnisse', 'Sprachzertifikat', 'Arbeitszeugnis 2019'},
      );

      // The v1 store is left completely untouched as a fallback.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('saved_profile'), jsonEncode(_v1ProfileMap));
      expect(prefs.getBool('cv_created'), isTrue);

      // Flag-guarded: a second run imports nothing again.
      await migrateLegacyData(
        db: db,
        legacy: const SharedPreferencesLegacyStore(),
      );
      expect(await documents.listCvDocuments(), hasLength(2));
      expect(await documents.listLetterDocuments(), hasLength(1));
      expect(await documents.listCertificates(), hasLength(3));
    });

    test('empty legacy store migrates to an empty database', () async {
      SharedPreferences.setMockInitialValues({});
      await migrateLegacyData(
        db: db,
        legacy: const SharedPreferencesLegacyStore(),
      );
      final store = DriftProfileStore(db);
      expect(await store.loadProfileMap(), isNull);
      expect(await DocumentRepository(db).listCvDocuments(), isEmpty);
      // The flag is still recorded so later launches skip the import.
      expect(await store.getString(kMigrationDoneKey), isNotNull);
    });
  });

  group('profile round-trip through the repository', () {
    const profile = UserProfile(
      fullName: 'Ahmad Ahmadi',
      phone: '+49 170 1234567',
      email: 'ahmad@example.com',
      street: 'Musterstraße 12',
      city: '10115 Berlin',
      languages: ['Paschtu', 'Deutsch'],
      dobDay: 3,
      dobMonth: 7,
      dobYear: 1998,
      country: 'Afghanistan',
      skill: 'lifting,packing',
      workExperience: 'more2',
      workType: 'warehouse',
      drivingLicense: 'B',
      languageProficiency: {'Paschtu': 'Muttersprache', 'Deutsch': 'B1'},
      previousEmployers: ['DHL', 'Amazon'],
      previousJobTitles: ['Packer', 'Helper'],
      refName: 'Herr Müller',
      refPhone: '030 123',
      schulabschluss: 'realschule',
    );

    void expectSameProfile(UserProfile? loaded) {
      expect(loaded, isNotNull);
      final p = loaded!;
      expect(p.fullName, profile.fullName);
      expect(p.phone, profile.phone);
      expect(p.email, profile.email);
      expect(p.street, profile.street);
      expect(p.city, profile.city);
      expect(p.languages, profile.languages);
      expect(p.dobDay, 3);
      expect(p.dobMonth, 7);
      expect(p.dobYear, 1998);
      expect(p.country, 'Afghanistan');
      expect(p.skill, 'lifting,packing');
      expect(p.workExperience, 'more2');
      expect(p.drivingLicense, 'B');
      expect(p.languageProficiency, profile.languageProficiency);
      expect(p.previousEmployers, ['DHL', 'Amazon']);
      expect(p.previousJobTitles, ['Packer', 'Helper']);
      expect(p.refName, 'Herr Müller');
      expect(p.schulabschluss, 'realschule');
    }

    test('Drift backend', () async {
      final repo = ProfileRepository(DriftProfileStore(db));
      await repo.saveProfile(profile);
      expectSameProfile(await repo.loadProfile());
    });

    test('v1 SharedPreferences backend (fallback path)', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = ProfileRepository(const PrefsProfileStore());
      await repo.saveProfile(profile);
      expectSameProfile(await repo.loadProfile());
    });

    test('key presence survives an empty-string value', () async {
      // introduction_screen treats the mere presence of
      // 'ausbildungEduInstitutions' as "an Ausbildung CV exists" - the
      // data layer must not drop the key when its value is ''.
      final repo = ProfileRepository(DriftProfileStore(db));
      await repo.saveProfileMap({'ausbildungEduInstitutions': ''});
      final map = await repo.loadProfileMap();
      expect(map, isNotNull);
      expect(map!.containsKey('ausbildungEduInstitutions'), isTrue);
      expect(map['ausbildungEduInstitutions'], '');
    });
  });

  group('multiple CV documents and letters', () {
    test('create, list by kind, update and delete', () async {
      final documents = DocumentRepository(db);

      final jobId = await documents.createCvDocument(
        kind: CvDocumentKind.job,
        name: 'Lebenslauf Lager',
        templateId: 'atsBlue',
        accentColor: 'navy',
        payload: const {'fullName': 'Ahmad Ahmadi', 'skill': 'lifting'},
      );
      final job2Id = await documents.createCvDocument(
        kind: CvDocumentKind.job,
        name: 'Lebenslauf Verkauf',
        payload: const {'fullName': 'Ahmad Ahmadi', 'skill': 'sales'},
      );
      final ausbildungId = await documents.createCvDocument(
        kind: CvDocumentKind.ausbildung,
        name: 'Lebenslauf Ausbildung Pflege',
        payload: const {'fullName': 'Ahmad Ahmadi'},
      );

      expect(await documents.listCvDocuments(), hasLength(3));
      final jobs =
          await documents.listCvDocuments(kind: CvDocumentKind.job);
      expect(jobs, hasLength(2));
      expect(jobs.map((c) => c.name).toSet(),
          {'Lebenslauf Lager', 'Lebenslauf Verkauf'});

      final created = await documents.getCvDocument(jobId);
      expect(created!.templateId, 'atsBlue');
      expect(created.accentColor, 'navy');
      expect(created.payload['skill'], 'lifting');

      await documents.updateCvDocument(
        jobId,
        name: 'Lebenslauf Lager (neu)',
        payload: const {'fullName': 'Ahmad Ahmadi', 'skill': 'forklift'},
      );
      final updated = await documents.getCvDocument(jobId);
      expect(updated!.name, 'Lebenslauf Lager (neu)');
      expect(updated.payload['skill'], 'forklift');
      expect(updated.updatedAt.isAfter(created.updatedAt) ||
          updated.updatedAt.isAtSameMomentAs(created.updatedAt), isTrue);

      await documents.deleteCvDocument(job2Id);
      expect(await documents.listCvDocuments(), hasLength(2));
      expect(await documents.getCvDocument(ausbildungId), isNotNull);

      // Letters: independent list with company/job title columns.
      final letterId = await documents.createLetterDocument(
        name: 'Anschreiben DHL',
        company: 'DHL Berlin',
        jobTitle: 'Lagermitarbeiter',
        payload: const {'betreff': 'Bewerbung als Lagermitarbeiter'},
      );
      await documents.createLetterDocument(
        name: 'Anschreiben Klinik',
        company: 'Klinik Mitte',
        payload: const {'betreff': 'Bewerbung Ausbildung Pflege'},
      );
      final letters = await documents.listLetterDocuments();
      expect(letters, hasLength(2));
      final letter = await documents.getLetterDocument(letterId);
      expect(letter!.company, 'DHL Berlin');
      expect(letter.jobTitle, 'Lagermitarbeiter');
      expect(letter.payload['betreff'], 'Bewerbung als Lagermitarbeiter');

      await documents.updateLetterDocument(letterId, company: 'DHL Bonn');
      expect((await documents.getLetterDocument(letterId))!.company,
          'DHL Bonn');

      await documents.deleteLetterDocument(letterId);
      expect(await documents.listLetterDocuments(), hasLength(1));
    });
  });

  group('KaryabData facade', () {
    test('defaults to the v1 backend before init', () async {
      SharedPreferences.setMockInitialValues({});
      await KaryabData.profile.saveProfileMap({'fullName': 'Test'});
      final map = await KaryabData.profile.loadProfileMap();
      expect(map!['fullName'], 'Test');
      // And it really went to SharedPreferences (the v1 store).
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('saved_profile'), contains('Test'));
    });
  });
}
