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
import 'package:karyab/widgets/home_dashboard.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 9 widget tests: the home dashboard entry card (the CEO could
// not find the Phase 8 entry, so visibility is tested, not assumed)
// and the official-letters flow itself: office step with email
// validation, purpose step with the profile prefilled, attachments
// step, and the review with the finished letter and the send button
// gated by the read confirmation.
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeDashboard official letters card (Phase 9)', () {
    testWidgets('renders in English, fires on tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeDashboard(
                language: 'en',
                profilePercent: 60,
                onMinijobs: () {},
                onOfficialLetters: () => taps++,
                day: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Official letters'), findsOneWidget);
      await tester.tap(find.text('Official letters'));
      expect(taps, 1);
    });

    testWidgets('renders the Pashto title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeDashboard(
                language: 'ps',
                profilePercent: 60,
                onMinijobs: () {},
                onOfficialLetters: () {},
                day: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('رسمي لیکونه'), findsOneWidget);
    });

    testWidgets('no card without the callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeDashboard(
                language: 'en',
                profilePercent: 60,
                onMinijobs: () {},
                day: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Official letters'), findsNothing);
    });
  });

  group('OfficialLettersScreen flow (Phase 9)', () {
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

    Widget app(Widget home) {
      return ChangeNotifierProvider(
        create: (_) => LanguageProvider(language: 'en'),
        child: MaterialApp(
          // disableAnimations freezes the LiquidBackground drift, so
          // pumpAndSettle can settle.
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: home,
          ),
        ),
      );
    }

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        app(const OfficialLettersScreen(language: 'en', voiceMode: false)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('walks office, purpose and attachments to the review', (
      tester,
    ) async {
      await pumpScreen(tester);

      // Step 1: office, name prefilled, email gate blocks empty email.
      expect(find.textContaining('Step 1 of 4'), findsOneWidget);
      expect(find.text('Which office?'), findsOneWidget);
      expect(find.text('Ausländerbehörde'), findsWidgets);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Please fill in the name of the office and a correct '
          'email address first.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Step 1 of 4'), findsOneWidget);

      // Let the error snackbar (4 s) leave; it floats over the
      // Continue button while visible.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Email address of the office'),
        'post@auslaenderbehoerde-berlin.de',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2: purposes + the profile data, prefilled read-only.
      expect(find.textContaining('Step 2 of 4'), findsOneWidget);
      expect(find.text('What do you need?'), findsOneWidget);
      expect(find.text('Work permission'), findsOneWidget);
      expect(find.text('Ahmad Ahmadi'), findsOneWidget);
      expect(find.text('Musterstraße 12, 10115 Berlin'), findsOneWidget);

      // Work permit fields (default purpose): company, job, start date.
      await tester.enterText(
        find.widgetWithText(TextField, 'Company'),
        'Beispiel GmbH',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Job title or Ausbildung occupation'),
        'Lagerhelfer',
      );
      await tester.ensureVisible(find.text('Choose date').first);
      await tester.tap(find.text('Choose date').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 3: attachments (empty is fine for a work permit).
      expect(find.textContaining('Step 3 of 4'), findsOneWidget);
      expect(find.text('Add files'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 4: review with the finished German letter, the
      // explanation, the legal note, and the gated send button.
      expect(find.textContaining('Step 4 of 4'), findsOneWidget);
      expect(
        find.textContaining(
          'Betreff: Antrag auf Erlaubnis zur Aufnahme einer '
          'Beschäftigung',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Beispiel GmbH'), findsWidgets);
      expect(find.text('Send by email'), findsOneWidget);
      expect(find.textContaining('not legal advice'), findsOneWidget);

      // Without the read confirmation the send button stays inert:
      // tapping it opens nothing.
      await tester.tap(find.text('Send by email'));
      await tester.pumpAndSettle();
      expect(find.text('Send in two steps'), findsNothing);
      expect(find.textContaining('Step 4 of 4'), findsOneWidget);

      // Tick the confirmation. Nothing is saved before an action.
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      final docs = await KaryabData.documents!.listLetterDocuments();
      expect(docs, isEmpty);

      // Send: in the test environment the mail plugin cannot compose
      // (no platform channel), so the explained two-step fallback
      // dialog must appear, and the letter must have been saved with
      // the official_letter payload shape. The send path loads the
      // real font assets for the PDF, which needs the real async
      // zone (runAsync) inside a widget test.
      await tester.runAsync(() async {
        await tester.tap(find.text('Send by email'));
        await Future<void>.delayed(const Duration(seconds: 3));
      });
      await tester.pumpAndSettle();
      expect(find.text('Send in two steps'), findsOneWidget);
      final saved = await KaryabData.documents!.listLetterDocuments();
      expect(saved, hasLength(1));
      expect(saved.single.payload['docKind'], 'official_letter');
      expect(saved.single.payload['purpose'], 'work_permit');
      expect(
        saved.single.payload['officeEmail'],
        'post@auslaenderbehoerde-berlin.de',
      );
      expect(
        saved.single.payload['letterText'],
        contains('Antrag auf Erlaubnis'),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Back'),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('question purpose asks for subject and own words', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(const OfficialLettersScreen(language: 'en', voiceMode: false)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Email address of the office'),
        'info@buergeramt-berlin.de',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text('Ask a question or another problem'),
      );
      await tester.tap(find.text('Ask a question or another problem'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(TextField, 'Subject line for your letter'),
      );
      expect(find.text('Subject line for your letter'), findsOneWidget);
      expect(
        find.text('Write your question or problem in your own words'),
        findsOneWidget,
      );
      // The dictation button rides on both free-text fields (idle
      // state shows the mic_none icon).
      expect(find.byIcon(Icons.mic_none_rounded), findsWidgets);
    });
  });
}
