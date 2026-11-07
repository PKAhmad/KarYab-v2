import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karyab/models/cv_style.dart';
import 'package:karyab/widgets/cv_style_editor.dart';

// Regression test (Phase 10): the CV Design sheet opened from the
// View/Download My CV screens (CvStyleRow -> showCvStyleEditor) used to
// be a plain non-scrolling Column. On shorter viewports and at larger
// accessibility text scales it threw "A RenderFlex overflowed by ... on
// the bottom" (yellow-black stripes on the phone). The sheet is now
// height-capped and scrollable; these pumps assert no exception at
// small sizes in English and Pashto, including the sizes/scales that
// overflowed before the fix (360x568, and 360x640 at text scale 1.3).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openSheet(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    required String language,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (ctx) => Center(
            child: ElevatedButton(
              onPressed: () => showCvStyleEditor(
                ctx,
                language: language,
                current: CvCustomisation.defaults,
                onChanged: (_) {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(milliseconds: 400));
  }

  for (final lang in ['en', 'ps']) {
    testWidgets('design sheet does not overflow at 360x640 ($lang)',
        (tester) async {
      await openSheet(
        tester,
        size: const Size(360, 640),
        textScale: 1.0,
        language: lang,
      );
      expect(tester.takeException(), isNull);
      // The Done action must stay reachable: scroll it into view (the
      // sheet content scrolls now) and close the sheet with it.
      final doneLabel = lang == 'ps' ? 'بشپړ شو' : 'Done';
      await tester.ensureVisible(find.text(doneLabel));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(doneLabel));
      await tester.pumpAndSettle();
      expect(find.text(doneLabel), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('design sheet does not overflow at 360x568 ($lang)',
        (tester) async {
      await openSheet(
        tester,
        size: const Size(360, 568),
        textScale: 1.0,
        language: lang,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('design sheet does not overflow at 360x640, text 1.3 ($lang)',
        (tester) async {
      await openSheet(
        tester,
        size: const Size(360, 640),
        textScale: 1.3,
        language: lang,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
