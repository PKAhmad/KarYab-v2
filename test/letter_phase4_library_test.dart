import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/data/app_database.dart';
import 'package:karyab/data/karyab_data.dart';
import 'package:karyab/data/profile_store.dart';
import 'package:karyab/data/repositories.dart';
import 'package:karyab/screens/letter_editor_screen.dart';
import 'package:karyab/screens/my_letters_screen.dart';
import 'package:karyab/services/letter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Widget-level Phase 4 checks on an in-memory database:
//  - the library lists v2 letters and the seeded legacy letter,
//  - library CRUD through the repository (create/list/update/delete),
//  - opening a letter in the editor shows the FROZEN saved texts and
//    leaves the stored payload untouched (no recomposition on open).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DocumentRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    repo = DocumentRepository(db);
    KaryabData.debugUseStore(
      DriftProfileStore(db),
      database: db,
      documents: repo,
    );
  });

  tearDown(() async {
    await db.close();
    KaryabData.debugReset();
  });

  Future<int> seedV2Letter() {
    final (:data, reasons: _) = composeNewLetter(
      const LetterContext(
        jobTitle: 'Lagerhelfer',
        companyName: 'DHL Paket GmbH',
        companyCity: 'Berlin',
        skills: ['Gabelstapler fahren'],
        experience: 'Lagerhelfer bei Amazon',
      ),
      now: DateTime(2026, 11, 6),
    );
    return repo.createLetterDocument(
      name: 'Lagerhelfer · DHL Paket GmbH',
      payload: data.toPayload(),
      company: data.companyName,
      jobTitle: data.jobTitle,
    );
  }

  testWidgets('library lists the v2 letter and the seeded legacy letter', (
    tester,
  ) async {
    await seedV2Letter();
    await repo.createLetterDocument(
      name: 'Anschreiben (old)',
      payload: const {'source': 'v1-migration'},
    );
    await tester.pumpWidget(
      const MaterialApp(home: MyLettersScreen(language: 'en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lagerhelfer · DHL Paket GmbH'), findsWidgets);
    expect(find.text('Anschreiben (old)'), findsOneWidget);
    expect(find.text('Old version'), findsOneWidget);
  });

  testWidgets('editor opens a frozen letter without changing its payload', (
    tester,
  ) async {
    final id = await seedV2Letter();
    final before = (await repo.getLetterDocument(id))!.payload;
    await tester.pumpWidget(
      MaterialApp(
        home: LetterEditorScreen(language: 'en', recordId: id),
      ),
    );
    await tester.pumpAndSettle();
    // The composed (frozen) Betreff and a body paragraph are visible.
    expect(find.textContaining('Bewerbung als Lagerhelfer'), findsWidgets);
    final after = (await repo.getLetterDocument(id))!.payload;
    expect(after, before, reason: 'opening must never recompose the letter');
  });

  testWidgets('editor without a record starts in the job setup form', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LetterEditorScreen(language: 'en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('New letter'), findsOneWidget);
    expect(find.text('Company'), findsOneWidget);
    expect(find.text('Job title'), findsOneWidget);
  });

  test('repository CRUD for letters', () async {
    final id = await seedV2Letter();
    var all = await repo.listLetterDocuments();
    expect(all.length, 1);
    expect(all.single.company, 'DHL Paket GmbH');
    await repo.updateLetterDocument(id, name: 'Umbenannt');
    expect((await repo.getLetterDocument(id))!.name, 'Umbenannt');
    await repo.deleteLetterDocument(id);
    all = await repo.listLetterDocuments();
    expect(all, isEmpty);
  });
}
