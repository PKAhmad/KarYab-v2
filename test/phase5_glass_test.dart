import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karyab/ui/karyab_ui.dart';
import 'package:karyab/widgets/home_dashboard.dart';

// Phase 5 (Liquid Glass v2): dock interaction, reduced-motion behaviour
// of the liquid backdrop, glass panel guardrail (no BackdropFilter in
// lists), device-tier blur halving, font selection, and the home
// dashboard rendering real fixture data.
void main() {
  tearDown(() {
    KDeviceTier.debugOverride = null;
  });

  group('font selection', () {
    test('Pashto and Dari use Noto Naskh Arabic, others Roboto', () {
      expect(karyabFontFamily('ps'), 'NotoNaskhArabic');
      expect(karyabFontFamily('fa'), 'NotoNaskhArabic');
      expect(karyabFontFamily('en'), 'Roboto');
      expect(karyabFontFamily('de'), 'Roboto');
      expect(karyabFontFallback('ps'), ['Roboto']);
      expect(karyabFontFallback('en'), ['NotoNaskhArabic']);
    });
  });

  group('KGlassDock', () {
    Widget host({required ValueChanged<int> onTap, int index = 0}) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: KGlassDock(
                items: const [
                  KDockItem(icon: Icons.home_rounded, label: 'Home'),
                  KDockItem(icon: Icons.work_rounded, label: 'Jobs'),
                  KDockItem(icon: Icons.school_rounded, label: 'Ausbildung'),
                  KDockItem(icon: Icons.folder_rounded, label: 'My CVs'),
                  KDockItem(icon: Icons.more_horiz_rounded, label: 'More'),
                ],
                currentIndex: index,
                onTap: onTap,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('tapping an item reports its index', (tester) async {
      int? tapped;
      await tester.pumpWidget(host(onTap: (i) => tapped = i));
      await tester.pump();
      await tester.tap(find.text('Jobs'));
      expect(tapped, 1);
      await tester.tap(find.text('More'));
      expect(tapped, 4);
    });

    testWidgets('active pill is present and animates positionally',
        (tester) async {
      await tester.pumpWidget(host(onTap: (_) {}, index: 2));
      await tester.pump();
      expect(find.byType(AnimatedPositionedDirectional), findsOneWidget);
      expect(find.text('Ausbildung'), findsOneWidget);
    });
  });

  group('LiquidBackground motion', () {
    testWidgets('reduced motion renders a static backdrop (no AnimatedBuilder)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: LiquidBackground(child: SizedBox.expand()),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(LiquidBackground),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );
      expect(find.byType(LiquidBackground), findsOneWidget);
    });

    testWidgets('standard tier animates the colour fields', (tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: LiquidBackground(child: SizedBox.expand()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.descendant(
          of: find.byType(LiquidBackground),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );
    });
  });

  group('glass guardrails', () {
    testWidgets('KGlassPanel in a list has no BackdropFilter',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KGlassPanel(
              inList: true,
              child: Text('row'),
            ),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('row'), findsOneWidget);
    });

    testWidgets('KGlassPanel as a static surface does blur',
        (tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KGlassPanel(
              level: KGlassLevel.l2,
              child: Text('hero'),
            ),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('low tier halves the blur sigma', (tester) async {
      KDeviceTier.debugOverride = true;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: KGlassPanel(child: Text('x'))),
        ),
      );
      final filter = tester.widget<BackdropFilter>(
        find.byType(BackdropFilter),
      );
      // L1 base blur is 18, halved on low tier.
      expect(filter.filter.toString(), contains('9.0'));
    });
  });

  group('HomeDashboard', () {
    testWidgets('renders fixture data and fires callbacks', (tester) async {
      var continued = 0;
      var minijobs = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeDashboard(
                language: 'en',
                profilePercent: 60,
                continueName: 'CV Lager',
                continuePercent: 40,
                onContinue: () => continued++,
                onMinijobs: () => minijobs++,
                day: DateTime(2026, 1, 1),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Your profile'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('Continue your CV'), findsOneWidget);
      expect(find.text('CV Lager'), findsOneWidget);
      expect(find.text('Minijobs near you'), findsOneWidget);
      // Day 1 of the year -> first tip in the rotation.
      expect(find.textContaining('Send your CV as a PDF'), findsOneWidget);

      await tester.tap(find.text('Minijobs near you'));
      expect(minijobs, 1);
      await tester.tap(find.text('Continue your CV'));
      expect(continued, 1);
    });

    testWidgets('without an unfinished CV there is no continue card',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeDashboard(
              language: 'ps',
              profilePercent: 25,
              onMinijobs: () {},
              day: DateTime(2026, 1, 2),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      // Pashto profile heading renders (in the bundled Arabic font).
      expect(find.text('ستاسو پروفایل'), findsOneWidget);
      expect(find.text('CV ته دوام ورکړئ'), findsNothing);
    });
  });

  group('KLiquidProgressBar', () {
    testWidgets('fill aligns to the directional start (RTL safe)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SizedBox(
                width: 200,
                child: KLiquidProgressBar(value: 0.5),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, AlignmentDirectional.centerStart);
    });
  });
}
