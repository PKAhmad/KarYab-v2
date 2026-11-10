// ignore_for_file: depend_on_referenced_packages
import 'package:drift/native.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/data/app_database.dart';
import 'package:karyab/data/karyab_data.dart';
import 'package:karyab/data/profile_store.dart';
import 'package:karyab/data/repositories.dart';
import 'package:karyab/providers/language_provider.dart';
import 'package:karyab/screens/guides_screen.dart';
import 'package:karyab/screens/introduction_screen.dart';
import 'package:karyab/screens/official_letters_screen.dart';
import 'package:karyab/ui/karyab_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 13 home-top tests, from the CEO's phone pass:
//  1. The Karyab name box is the FIRST element of the home page. No
//     box and no button renders above it; the language pill and the
//     sound toggle sit below it.
//  2. The top two cards (official letters, guides, in the state a
//     fresh install shows) are real glass buttons (KGlassCard with a
//     tap action, the kit's button widget) and still navigate.
//  3. No overflow at 360px width and text scale 1.3, EN and PS.
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    // Analytics calls from the home screen's initState must complete.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/firebase_analytics'),
          (call) async => null,
        );
  });

  group('Home top layout (Phase 13)', () {
    late AppDatabase db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
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
      await db.close();
      KaryabData.debugReset();
    });

    Future<void> pumpHome(
      WidgetTester tester,
      String lang, {
      bool small = false,
    }) async {
      if (small) {
        tester.view.physicalSize = const Size(360 * 3, 640 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);
      }
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(language: lang),
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                disableAnimations: true,
                textScaler: small
                    ? const TextScaler.linear(1.3)
                    : TextScaler.noScaling,
              ),
              child: IntroductionScreen(language: lang, voiceMode: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    double topOf(WidgetTester tester, Finder finder) =>
        tester.getTopLeft(finder).dy;

    testWidgets('name box is first, cards are glass buttons, taps navigate', (
      tester,
    ) async {
      await pumpHome(tester, 'en');

      // The name box (the big Kar / Yab hero) is the topmost element:
      // above the language pill, the sound toggle and both cards.
      final nameTop = topOf(tester, find.text('Kar'));
      expect(nameTop, lessThan(topOf(tester, find.text('EN'))));
      expect(
        nameTop,
        lessThan(topOf(tester, find.byIcon(Icons.volume_up_rounded))),
      );
      expect(nameTop, lessThan(topOf(tester, find.text('Official letters'))));
      expect(nameTop, lessThan(topOf(tester, find.text('Guides'))));

      // Both top cards are KGlassCard buttons with a real tap action.
      for (final title in ['Official letters', 'Guides']) {
        final card = tester.widget<KGlassCard>(
          find
              .ancestor(
                of: find.text(title),
                matching: find.byType(KGlassCard),
              )
              .first,
        );
        expect(card.onTap, isNotNull, reason: '$title must be a button');
      }

      // And they still navigate to their modules.
      await tester.tap(find.text('Official letters'));
      await tester.pumpAndSettle();
      expect(find.byType(OfficialLettersScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(IntroductionScreen), findsOneWidget);

      await tester.tap(find.text('Guides'));
      await tester.pumpAndSettle();
      expect(find.byType(GuidesScreen), findsOneWidget);
    });

    testWidgets('EN at 360px, text scale 1.3: name box first, no overflow', (
      tester,
    ) async {
      await pumpHome(tester, 'en', small: true);
      expect(tester.takeException(), isNull);
      final nameTop = topOf(tester, find.text('Kar'));
      expect(nameTop, lessThan(topOf(tester, find.text('EN'))));
      expect(nameTop, lessThan(topOf(tester, find.text('Official letters'))));
    });

    testWidgets('PS at 360px, text scale 1.3: name box first, no overflow', (
      tester,
    ) async {
      await pumpHome(tester, 'ps', small: true);
      expect(tester.takeException(), isNull);
      final nameTop = topOf(tester, find.text('Kar'));
      expect(nameTop, lessThan(topOf(tester, find.text('PS'))));
      expect(nameTop, lessThan(topOf(tester, find.text('رسمي لیکونه'))));
    });
  });
}
