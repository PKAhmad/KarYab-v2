import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/data/app_database.dart';
import 'package:karyab/data/karyab_data.dart';
import 'package:karyab/data/profile_store.dart';
import 'package:karyab/data/repositories.dart';
import 'package:karyab/providers/language_provider.dart';
import 'package:karyab/screens/guides_screen.dart';
import 'package:karyab/services/guides/guides.dart';
import 'package:karyab/widgets/home_dashboard.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 11 widget tests: the home dashboard guides card, the guides
// home and one full step page, pumped in English and Pashto at a
// small size (360 px wide, text scale 1.3) with no overflow, and the
// check-off flow writing through to the Drift repository.
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    KaryabData.debugUseStore(
      DriftProfileStore(db),
      database: db,
      documents: DocumentRepository(db),
      jobs: JobsRepository(db),
      guides: GuidesRepository(db),
    );
  });

  tearDown(() async {
    KaryabData.debugReset();
    await db.close();
  });

  Widget app(Widget home, {String lang = 'en', double textScale = 1.0}) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(language: lang),
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            disableAnimations: true,
            textScaler: TextScaler.linear(textScale),
          ),
          child: home,
        ),
      ),
    );
  }

  void smallScreen(WidgetTester tester) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.reset);
  }

  group('HomeDashboard guides card (Phase 11)', () {
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
                onGuides: () => taps++,
                day: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Guides'), findsOneWidget);
      expect(
        find.text('Step by step: the German exam and Ausbildung from abroad'),
        findsOneWidget,
      );
      await tester.tap(find.text('Guides'));
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
                onGuides: () {},
                day: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('لارښودونه'), findsOneWidget);
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
      expect(find.text('Guides'), findsNothing);
    });
  });

  group('GuidesScreen', () {
    testWidgets('shows both tracks with progress, EN, small size', (
      tester,
    ) async {
      smallScreen(tester);
      await tester.pumpWidget(
        app(
          const GuidesScreen(language: 'en', voiceMode: false),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Guides'), findsOneWidget);
      expect(find.text('German exam, step by step'), findsOneWidget);
      expect(find.text('Ausbildung from abroad, step by step'), findsOneWidget);
      expect(find.text('0 of 7 steps done'), findsNWidgets(2));
      expect(
        find.text(
          'Guides explain the official process. Rules and amounts can '
          'change. Always check the official pages.',
        ),
        findsOneWidget,
      );
      expect(find.text('Last checked: November 2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows both tracks in Pashto, small size', (tester) async {
      smallScreen(tester);
      await tester.pumpWidget(
        app(
          const GuidesScreen(language: 'ps', voiceMode: false),
          lang: 'ps',
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('د الماني ژبې ازموینه، ګام پر ګام'), findsOneWidget);
      expect(find.text('له بهر څخه Ausbildung، ګام پر ګام'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('check-off in the track list persists and shows at home', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(const GuidesScreen(language: 'en', voiceMode: false)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('German exam, step by step'));
      await tester.pumpAndSettle();

      // The full step list is there.
      for (final title in [
        'Which exam do I need?',
        'Know your level',
        'Register the official way',
        'Prepare well',
        'On the exam day',
        'Results and your certificate',
        'If you do not pass',
      ]) {
        await tester.scrollUntilVisible(find.text(title), 120);
        expect(find.text(title), findsOneWidget);
      }
      expect(find.text('0 of 7 steps done'), findsOneWidget);

      // Mark step 1 done via its check circle (the "1" badge).
      await tester.scrollUntilVisible(find.text('Which exam do I need?'), 120);
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 7 steps done'), findsOneWidget);

      // The repository really holds it (Drift, not just screen state).
      expect(await KaryabData.guides!.isStepDone('exam', 'which_exam'), isTrue);

      // The step row opens the step page.
      await tester.tap(find.text('Which exam do I need?'));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 7'), findsOneWidget);
      expect(
        find.textContaining('There are different German exams'),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.text('1 of 7 steps done'), findsOneWidget);

      // Back home, the exam track now shows the same progress.
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.text('1 of 7 steps done'), findsOneWidget);
      expect(find.text('0 of 7 steps done'), findsOneWidget);
    });
  });

  group('GuideStepScreen', () {
    testWidgets('money step shows documents, warning and figures, EN', (
      tester,
    ) async {
      smallScreen(tester);
      final track = guidesForLanguage('en')[1];
      await tester.pumpWidget(
        app(
          GuideStepScreen(
            language: 'en',
            voiceMode: false,
            track: track,
            step: track.stepById('money')!,
          ),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step 5 of 7'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Documents you need'), 160);
      expect(find.text('Documents you need'), findsOneWidget);
      expect(find.textContaining('€822 net'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Warning'), 160);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.textContaining('Never pay an agency'), findsOneWidget);

      // Mark finished from the step page and see it stick.
      await tester.scrollUntilVisible(find.text('Mark as finished'), 160);
      await tester.tap(find.text('Mark as finished'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Finished'), findsWidgets);
      expect(
        await KaryabData.guides!.isStepDone('ausbildung', 'money'),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('register step shows its warning in Pashto', (tester) async {
      smallScreen(tester);
      final track = guidesForLanguage('ps')[0];
      await tester.pumpWidget(
        app(
          GuideStepScreen(
            language: 'ps',
            voiceMode: false,
            track: track,
            step: track.stepById('register')!,
          ),
          lang: 'ps',
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('خبرداری'), 160);
      expect(find.text('خبرداری'), findsOneWidget);
      expect(find.textContaining('300'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
