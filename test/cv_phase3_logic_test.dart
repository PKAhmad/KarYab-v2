import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/models/cv_style.dart';
import 'package:karyab/models/document_template.dart';
import 'package:karyab/models/user_profile.dart';
import 'package:karyab/services/ats_checker.dart';
import 'package:karyab/services/cv_completion.dart';
import 'package:karyab/services/cv_pdf_generator.dart';
import 'package:karyab/services/profile_summary_bank.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CvCustomisation', () {
    test('defaults are the pre-Phase-3 look', () {
      const c = CvCustomisation.defaults;
      expect(c.isDefault, isTrue);
      expect(c.fontScale, 1.0);
      expect(c.spacingScale, 1.0);
      expect(c.showPhoto, isTrue);
      expect(c.accentColorHex, isNull);
    });

    test('scales follow the size keys', () {
      expect(const CvCustomisation(fontSize: 'compact').fontScale,
          lessThan(1.0));
      expect(
          const CvCustomisation(fontSize: 'large').fontScale, greaterThan(1.0));
      expect(const CvCustomisation(spacing: 'compact').spacingScale,
          lessThan(1.0));
    });

    test('map round trip and document columns', () {
      const c = CvCustomisation(
        accentColorHex: '#7A2230',
        fontSize: 'large',
        spacing: 'compact',
        showPhoto: false,
      );
      expect(CvCustomisation.fromMap(c.toMap()), c);
      final fromColumns = CvCustomisation.fromColumns(
        accentColor: '#7A2230',
        fontSize: 'large',
        spacing: 'compact',
        showPhoto: false,
      );
      expect(fromColumns, c);
      expect(
          CvCustomisation.fromColumns(
              accentColor: null, fontSize: null, spacing: null, showPhoto: null),
          CvCustomisation.defaults);
    });

    test('palette has 6 print-safe colours', () {
      expect(kCvAccentPalette.length, 6);
      for (final o in kCvAccentPalette) {
        expect(o.hex, matches(RegExp(r'^#[0-9A-Fa-f]{6}$')));
      }
    });
  });

  group('cv completion', () {
    final fullJob = <String, dynamic>{
      'educationLevel': 'vocational',
      'skill': 'cleaning',
      'workExperience': 'more2',
      'previousEmployers': 'Muster GmbH',
      'sharedItSkills': 'Microsoft Word',
      'languages': 'Deutsch',
      'availability': 'fulltime',
      'profileSummary': 'Ich arbeite zuverlässig.',
    };

    test('percent counts filled sections', () {
      expect(cvCompletionPercent(fullJob, 'job'), 100);
      expect(cvCompletionPercent(const {}, 'job'), 0);
      final half = <String, dynamic>{
        'educationLevel': 'vocational',
        'skill': 'cleaning',
        'workExperience': 'more2',
        'languages': 'Deutsch',
      };
      // 4 of 8 job sections (employers/toolsIt/availability/profil empty).
      expect(cvCompletionPercent(half, 'job'), 50);
    });

    test('ausbildung sections use ausbildung keys', () {
      final payload = <String, dynamic>{
        'previousEmployers': 'Praxis GmbH',
        'ausbildungEduInstitutions': 'Berufsschule Berlin',
        'languages': 'Deutsch',
        'sharedItSkills': 'Microsoft Excel',
        'ausbildungEscoSkills': 'Pflege',
        'profileSummary': 'Text',
      };
      expect(cvCompletionPercent(payload, 'ausbildung'), 100);
      expect(cvSectionFilled(payload, 'ausbildung', 'education'), isTrue);
      expect(cvSectionFilled(payload, 'job', 'education'), isFalse);
    });

    test('wizard bookkeeping: finished and resume step', () {
      expect(cvDocumentFinished(const {}), isTrue); // legacy document
      expect(cvDocumentFinished(const {'_wizardStep': '2'}), isFalse);
      expect(
          cvDocumentFinished(
              const {'_wizardStep': '2', '_wizardDone': 'true'}),
          isTrue);
      expect(cvResumeStep(const {'_wizardStep': '3'}), 3);
      expect(cvResumeStep(const {}), 0);
      expect(cvResumeStep(const {'_wizardStep': 'abc'}), 0);
    });

    test('step mapping differs for educated and uneducated job wizards', () {
      expect(
          wizardStepSections('job', educated: true),
          [
            'education',
            'skills',
            'experience',
            'toolsIt',
            'languages',
            'availability',
            'profil'
          ]);
      expect(wizardStepSections('job', educated: false).first, 'skills');
      expect(
          wizardStepForSection('job',
              educated: true, section: 'employers'),
          wizardStepForSection('job',
              educated: true, section: 'experience'));
      expect(
          wizardStepForSection('ausbildung',
              educated: true, section: 'esco'),
          4);
      expect(
          wizardStepForSection('job', educated: false, section: 'education'),
          -1);
    });
  });

  group('profile summary bank', () {
    test('empty selection composes nothing', () {
      expect(
          composeProfileSummary(
              themeKeys: const {}, sectorKeys: const {}, isAusbildung: false),
          '');
    });

    test('sentences come in bank order and are capped at 5', () {
      final text = composeProfileSummary(
        themeKeys: {'friendly', 'reliable', 'team', 'physical'},
        sectorKeys: {'cleaning', 'warehouse'},
        isAusbildung: false,
        workExperience: 'more2',
      );
      final sentences =
          text.split('. ').where((s) => s.trim().isNotEmpty).toList();
      expect(sentences.length, 5);
      expect(text.indexOf('mehr als zwei Jahre'),
          lessThan(text.indexOf('Im Lager')));
      expect(text.indexOf('Im Lager'), lessThan(text.indexOf('Gebäudereinigung')));
      expect(text.indexOf('Gebäudereinigung'),
          lessThan(text.indexOf('zuverlässig')));
    });

    test('ausbildung opener replaces the experience opener', () {
      final text = composeProfileSummary(
        themeKeys: const {'fastLearner'},
        sectorKeys: const {},
        isAusbildung: true,
        workExperience: 'more2',
      );
      expect(text, startsWith('Ich suche einen Ausbildungsplatz'));
      expect(text, isNot(contains('zwei Jahre')));
    });

    test('bank has at least 12 patterns and no em-dashes', () {
      final all = [
        ...kProfileThemes.map((t) => t.sentenceDe),
        ...kProfileSectors.map((t) => t.sentenceDe),
        kProfileOpenerAusbildung,
        ...kProfileOpenersByExperience.values,
      ];
      expect(all.length, greaterThanOrEqualTo(12));
      for (final s in all) {
        expect(s.contains('—'), isFalse, reason: s);
      }
    });

    test('sector suggestions come only from entered data', () {
      expect(suggestedProfileSectors(const {}), isEmpty);
      expect(
          suggestedProfileSectors(const {'workType': 'cleaning'}),
          contains('cleaning'));
      expect(
          suggestedProfileSectors(const {'sharedItSkills': 'Microsoft Word'}),
          contains('office'));
      expect(
          suggestedProfileSectors(
              const {'ausbildungTargetOccupation': 'Lagerlogistik Fachkraft'}),
          contains('warehouse'));
    });
  });

  group('ats checker', () {
    const full = UserProfile(
      fullName: 'Ahmad Rahimi',
      phone: '+49 151 23456789',
      email: 'ahmad@example.com',
      street: 'Musterstraße 12',
      city: '12345 Berlin',
      languages: ['german'],
      photoPath: '/tmp/photo.png',
    );
    const bare = UserProfile(
      fullName: 'Sara Ahmadi',
      phone: '',
      email: '',
      street: '',
      city: '',
      languages: [],
    );
    final fullPayload = <String, dynamic>{
      'skill': 'cleaning',
      'languages': 'Deutsch',
      'workExperience': 'more2',
    };

    test('atsBlue template passes the template check', () {
      final items = runAtsChecks(
        profile: full,
        template: DocumentTemplate.atsBlue,
        payload: fullPayload,
        kind: 'job',
        showPhoto: true,
        pageCount: 1,
      );
      expect(items.firstWhere((i) => i.key == 'pages').level, AtsLevel.ok);
      expect(items.firstWhere((i) => i.key == 'templateAts').level,
          AtsLevel.ok);
      expect(items.where((i) => i.level == AtsLevel.problem), isEmpty);
    });

    test('photo sidebar template with a photo warns', () {
      final items = runAtsChecks(
        profile: full,
        template: DocumentTemplate.darkSidebar,
        payload: fullPayload,
        kind: 'job',
        showPhoto: true,
        pageCount: 4,
      );
      expect(items.firstWhere((i) => i.key == 'templateLayoutPhoto').level,
          AtsLevel.warn);
      expect(items.firstWhere((i) => i.key == 'pages').level, AtsLevel.warn);
      // Hiding the photo removes the warning.
      final noPhoto = runAtsChecks(
        profile: full,
        template: DocumentTemplate.darkSidebar,
        payload: fullPayload,
        kind: 'job',
        showPhoto: false,
        pageCount: 1,
      );
      expect(noPhoto.any((i) => i.key == 'templateLayoutPhoto'), isFalse);
    });

    test('missing contact data is a problem with a fix location', () {
      final items = runAtsChecks(
        profile: bare,
        template: DocumentTemplate.atsBlue,
        payload: const {},
        kind: 'job',
        showPhoto: true,
      );
      final email = items.firstWhere((i) => i.key == 'email');
      expect(email.level, AtsLevel.problem);
      expect(email.section, 'personal');
      expect(items.firstWhere((i) => i.key == 'languages').level,
          AtsLevel.warn);
      expect(items.any((i) => i.key == 'sectionOmitted'), isTrue);
    });
  });

  group('countPdfPages', () {
    test('counts page objects in synthetic bytes', () {
      final fake = latin1.encode(
          '1 0 obj << /Type /Pages /Kids [2 0 R 3 0 R 4 0 R] >> endobj '
          '2 0 obj << /Type /Page >> endobj '
          '3 0 obj << /Type/Page >> endobj '
          '4 0 obj << /Type /Page >> endobj');
      expect(countPdfPages(Uint8List.fromList(fake)), 3);
      expect(countPdfPages(Uint8List(0)), 0);
    });

    test('counts a real generated CV', () async {
      const minimal = UserProfile(
        fullName: 'Sara Ahmadi',
        phone: '',
        email: '',
        street: '',
        city: '',
        languages: [],
      );
      final bytes = await generateCv(minimal, DocumentTemplate.atsBlue);
      expect(countPdfPages(bytes), 1);
    });
  });
}
