import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/widgets/cv_wizard.dart';
import 'package:karyab/widgets/profile_summary_step.dart';

void main() {
  testWidgets('WizardStepHeader shows step, percent and preview action',
      (tester) async {
    var previews = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WizardStepHeader(
            language: 'en',
            section: 'skills',
            stepIndex: 1,
            stepCount: 7,
            percent: 42,
            onPreview: () => previews++,
          ),
        ),
      ),
    );
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Step 2 of 7 · 42% done'), findsOneWidget);
    await tester.tap(find.text('Preview'));
    expect(previews, 1);
  });

  testWidgets('WizardBottomBar fires back, skip and continue',
      (tester) async {
    final fired = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WizardBottomBar(
            language: 'en',
            showSkip: true,
            onBack: () => fired.add('back'),
            onSkip: () => fired.add('skip'),
            onContinue: () => fired.add('continue'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Back'));
    await tester.tap(find.text('Skip'));
    await tester.tap(find.text('Continue'));
    expect(fired, ['back', 'skip', 'continue']);
  });

  testWidgets('Profil step composes German text from ticked chips',
      (tester) async {
    String lastText = '';
    Set<String> lastThemes = {};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileSummaryStep(
              language: 'en',
              isAusbildung: false,
              workExperience: 'more2',
              onChanged: (themes, sectors, text) {
                lastThemes = themes;
                lastText = text;
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Reliable'));
    await tester.pump();
    expect(lastThemes, contains('reliable'));
    expect(lastText, contains('zuverlässig'));
    expect(lastText, contains('mehr als zwei Jahre'));
    // The composed text lands in the editable field.
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, contains('zuverlässig'));
  });

  testWidgets('Profil step does not overwrite hand edits on chip change',
      (tester) async {
    String lastText = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileSummaryStep(
              language: 'en',
              isAusbildung: false,
              initialText: 'Mein eigener Text.',
              onChanged: (themes, sectors, text) => lastText = text,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Team player'));
    await tester.pump();
    // Hand-written text survives; the "update from selection" action shows.
    expect(lastText, 'Mein eigener Text.');
    expect(find.text('Update text from my selection'), findsOneWidget);
    await tester.tap(find.text('Update text from my selection'));
    await tester.pump();
    expect(lastText, contains('Team'));
  });
}
