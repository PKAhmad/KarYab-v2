import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/data/app_database.dart';
import 'package:karyab/data/karyab_data.dart';
import 'package:karyab/data/profile_store.dart';
import 'package:karyab/data/repositories.dart';
import 'package:karyab/models/user_profile.dart';
import 'package:karyab/providers/language_provider.dart';
import 'package:karyab/screens/official_letters_screen.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 13 regression tests for the CEO's phone report: in Official
// Letters, after picking one or two options and tapping Continue, the
// button "did not go further". Reproduction of the dead button: a
// failed Continue tap (office email still empty) answered with a
// floating SnackBar that renders on top of the Continue button and
// swallows every following tap for its whole 4 second life (and stacks
// on repeated taps), while the empty email field showed no inline
// error at all. So on the phone the button looked and acted dead even
// after the user typed a correct email and tapped again at once.
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfficialLettersScreen Continue regression (Phase 13)', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      KaryabData.debugUseStore(
        DriftProfileStore(db),
        database: db,
        documents: DocumentRepository(db),
        jobs: JobsRepository(db),
      );
      await KaryabData.profile.saveProfile(
        const UserProfile(
          fullName: 'Ahmad Ahmadi',
          phone: '0151 234567',
          email: 'ahmad@example.com',
          street: 'Musterstraße 12',
          city: '10115 Berlin',
          languages: ['Paschtu'],
          dobDay: 3,
          dobMonth: 4,
          dobYear: 1995,
          country: 'Afghanistan',
        ),
      );
    });

    tearDown(() async {
      await db.close();
      KaryabData.debugReset();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(language: 'en'),
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: true),
              child: OfficialLettersScreen(
                language: 'en',
                voiceMode: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Continue advances right after a failed attempt, no waiting',
      (tester) async {
        await pumpScreen(tester);
        expect(find.textContaining('Step 1 of 4'), findsOneWidget);

        // One option selection, exactly what the CEO described: pick
        // an office, then tap Continue with the email still empty.
        await tester.tap(find.text('Jobcenter'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Step 1 of 4'), findsOneWidget);

        // The user now types a correct email and taps Continue again
        // AT ONCE, without waiting for anything to disappear. Before
        // the fix this tap landed on the error SnackBar floating over
        // the button and the flow stayed on step 1: the dead button.
        await tester.enterText(
          find.widgetWithText(TextField, 'Email address of the office'),
          'post@jobcenter-berlin.de',
        );
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Step 2 of 4'), findsOneWidget);
      },
    );

    testWidgets('failed Continue marks the empty email field inline', (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      // Before the fix an EMPTY email produced no inline error (the
      // error text only appeared for a non-empty invalid address), so
      // nothing on screen said what was missing.
      expect(
        find.text('Please enter a correct email address.'),
        findsOneWidget,
      );
    });
  });
}
