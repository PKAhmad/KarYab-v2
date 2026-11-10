import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/data/app_database.dart';
import 'package:karyab/data/repositories.dart';
import 'package:karyab/services/guides/guides.dart';

import 'generated/schema.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 11 guides: content integrity (every step exists in all four
// languages, nothing empty, NO em-dash anywhere in guide content or
// chrome strings), the verified money figures present in every
// language, guide progress persistence in Drift (including a real
// close/reopen "restart"), and the schema v2 -> v3 migration.
// ─────────────────────────────────────────────────────────────────────────────

const List<String> kExamStepIds = [
  'which_exam',
  'know_level',
  'register',
  'prepare',
  'exam_day',
  'results',
  'if_fail',
];

const List<String> kAusbildungStepIds = [
  'check_yourself',
  'recognition',
  'learn_german',
  'find_place',
  'money',
  'visa',
  'arrive',
];

/// Every user-visible string of one track, for the em-dash sweep.
Iterable<String> _trackStrings(GuideTrack track) sync* {
  yield track.title;
  yield track.subtitle;
  for (final step in track.steps) {
    yield step.title;
    yield* step.paragraphs;
    yield* step.documents;
    final w = step.warning;
    if (w != null) yield w;
    for (final link in step.links) {
      yield link.label;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('guides content integrity', () {
    for (final lang in kGuideLanguages) {
      group('language $lang', () {
        final tracks = guidesForLanguage(lang);

        test('two tracks, stable ids and order', () {
          expect(tracks.map((t) => t.id), ['exam', 'ausbildung']);
        });

        test('every step exists with the canonical ids', () {
          expect(tracks[0].steps.map((s) => s.id), kExamStepIds);
          expect(tracks[1].steps.map((s) => s.id), kAusbildungStepIds);
        });

        test('no empty strings anywhere', () {
          for (final track in tracks) {
            expect(track.title.trim(), isNotEmpty);
            expect(track.subtitle.trim(), isNotEmpty);
            for (final step in track.steps) {
              expect(
                step.title.trim(),
                isNotEmpty,
                reason: '${track.id}:${step.id} title',
              );
              expect(
                step.paragraphs,
                isNotEmpty,
                reason: '${track.id}:${step.id} paragraphs',
              );
              for (final p in step.paragraphs) {
                expect(
                  p.trim(),
                  isNotEmpty,
                  reason: '${track.id}:${step.id} paragraph',
                );
              }
              for (final d in step.documents) {
                expect(
                  d.trim(),
                  isNotEmpty,
                  reason: '${track.id}:${step.id} document',
                );
              }
              for (final link in step.links) {
                expect(link.label.trim(), isNotEmpty);
                expect(link.url, startsWith('https://'));
              }
            }
          }
        });

        test('scam warnings sit on the register, money and visa steps', () {
          final exam = tracks[0];
          final ausbildung = tracks[1];
          expect(exam.stepById('register')!.warning, isNotNull);
          expect(ausbildung.stepById('money')!.warning, isNotNull);
          expect(ausbildung.stepById('visa')!.warning, isNotNull);
        });

        test('verified 2026 money figures appear in every language', () {
          final money = tracks[1].stepById('money')!.paragraphs.join(' ');
          // make-it-in-germany, visa for vocational training (2026):
          // dual training livelihood threshold and school-based amount.
          expect(money, contains('822'));
          expect(money, contains('959'));
          expect(
            money.contains('1,048') || money.contains('1.048'),
            isTrue,
            reason: 'gross threshold (1,048) missing in $lang',
          );
          final visa = tracks[1].stepById('visa')!.paragraphs.join(' ');
          expect(visa, contains('75')); // the official visa fee
          final arrive = tracks[1].stepById('arrive')!.paragraphs.join(' ');
          expect(arrive, contains('14')); // Anmeldung deadline in days
        });
      });
    }

    test('no em-dash in any guide content or chrome string', () {
      const emDash = '—';
      for (final lang in kGuideLanguages) {
        for (final track in guidesForLanguage(lang)) {
          for (final s in _trackStrings(track)) {
            expect(
              s,
              isNot(contains(emDash)),
              reason: 'em-dash in $lang track ${track.id}: $s',
            );
          }
        }
        final chrome = <String>[
          GuideStrings.title(lang),
          GuideStrings.homeCardSub(lang),
          GuideStrings.intro(lang),
          GuideStrings.stepsDone(lang, 3, 7),
          GuideStrings.stepsCount(lang, 7),
          GuideStrings.documentsTitle(lang),
          GuideStrings.warningTitle(lang),
          GuideStrings.markDone(lang),
          GuideStrings.markUndone(lang),
          GuideStrings.footerNote(lang),
          GuideStrings.lastChecked(lang),
          for (final a in GuideAction.values) GuideStrings.actionLabel(lang, a),
        ];
        for (final s in chrome) {
          expect(
            s,
            isNot(contains(emDash)),
            reason: 'em-dash in $lang chrome: $s',
          );
          expect(s.trim(), isNotEmpty, reason: 'empty $lang chrome string');
        }
      }
    });

    test('step ids are identical across languages', () {
      final reference = guidesForLanguage('de');
      for (final lang in kGuideLanguages) {
        final tracks = guidesForLanguage(lang);
        for (var i = 0; i < reference.length; i++) {
          expect(
            tracks[i].steps.map((s) => s.id),
            reference[i].steps.map((s) => s.id),
            reason: '$lang track $i step ids differ from German',
          );
        }
      }
    });

    test('spoken text of a step contains title, body and warning', () {
      final step = guidesForLanguage('en')[0].stepById('register')!;
      final spoken = step.spokenText('Documents you need', 'Warning');
      expect(spoken, contains(step.title));
      expect(spoken, contains(step.paragraphs.first));
      expect(spoken, contains('Warning'));
      expect(spoken, contains(step.warning!));
    });
  });

  group('GuidesRepository persistence', () {
    test('done state survives a database close and reopen', () async {
      final dir = await Directory.systemTemp.createTemp('guides_repo');
      addTearDown(() async {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      });
      final file = File('${dir.path}/guides.sqlite');

      var db = AppDatabase(NativeDatabase(file));
      var repo = GuidesRepository(db);
      expect(await repo.loadDoneStepKeys(), isEmpty);
      expect(await repo.isStepDone('exam', 'register'), isFalse);

      await repo.setStepDone('exam', 'register', true);
      await repo.setStepDone('ausbildung', 'money', true);
      expect(await repo.isStepDone('exam', 'register'), isTrue);
      await db.close();

      // A fresh database instance on the same file: the app restart.
      db = AppDatabase(NativeDatabase(file));
      repo = GuidesRepository(db);
      expect(await repo.isStepDone('exam', 'register'), isTrue);
      expect(await repo.loadDoneStepKeys(), {
        'exam:register',
        'ausbildung:money',
      });

      // Un-marking works and also persists.
      await repo.setStepDone('exam', 'register', false);
      expect(await repo.isStepDone('exam', 'register'), isFalse);
      expect(await repo.loadDoneStepKeys(), {'ausbildung:money'});

      // doneCount ignores step ids that do not exist in the content.
      await repo.setStepDone('ausbildung', 'gone_step', true);
      expect(await repo.doneCount('ausbildung', kAusbildungStepIds), 1);
      await db.close();
    });
  });

  group('schema migration v2 -> v3', () {
    test('validates, preserves v2 data, guide table usable', () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(2);

      schema.rawDatabase.execute(
        "INSERT INTO profile (id, \"fullName\", city) "
        "VALUES (1, 'Ahmad Ahmadi', '10115 Berlin')",
      );
      schema.rawDatabase.execute(
        'INSERT INTO saved_jobs '
        '(refnr, title, company, location, source, saved_at, payload) '
        "VALUES ('123-456', 'Lagerhelfer', 'DHL', 'Berlin', 'jobs', "
        "1700000000, '{}')",
      );

      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 3);

      final profile = await db.select(db.profileEntries).getSingle();
      expect(profile.fullName, 'Ahmad Ahmadi');
      final jobs = await db.select(db.savedJobs).get();
      expect(jobs, hasLength(1));

      final guides = GuidesRepository(db);
      await guides.setStepDone('exam', 'which_exam', true);
      expect(await guides.isStepDone('exam', 'which_exam'), isTrue);

      await db.close();
      schema.close();
    });
  });
}
