import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/data/app_database.dart';
import 'package:karyab/data/karyab_data.dart';
import 'package:karyab/data/profile_store.dart';
import 'package:karyab/data/repositories.dart';
import 'package:karyab/providers/language_provider.dart';
import 'package:karyab/screens/guides_screen.dart';
import 'package:karyab/services/account_strings.dart';
import 'package:karyab/services/dictation_service.dart';
import 'package:karyab/services/dictation_strings.dart';
import 'package:karyab/services/guides/guides.dart';
import 'package:karyab/services/jobs_strings.dart';
import 'package:karyab/services/letter_phrase_bank.dart';
import 'package:karyab/services/official_letter.dart';
import 'package:karyab/services/official_letter_strings.dart';
import 'package:karyab/services/work_permit_strings.dart';
import 'package:karyab/ui/karyab_ui.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 12 (Arabic pack): 'ar' is a full fifth UI language. These
// tests pin the parity contract: every sampled string accessor
// returns real Arabic for 'ar' (never an English fallback leak),
// the letter phrase bank carries Arabic templates with the same
// tokens as the German originals, the official-letter explanations
// exist in Arabic for all 8 purposes, dictation matches Arabic
// locales, RTL/font helpers treat Arabic like Pashto/Dari, and the
// guides home + a step page render in Arabic at 360 px / text
// scale 1.3 with RTL direction and no overflow. Guide CONTENT
// integrity for 'ar' (every step, figures, no em-dash) is covered
// by guides_content_test.dart via kGuideLanguages.
// ─────────────────────────────────────────────────────────────────────────────

final RegExp _arabicScript = RegExp(r'[\u0600-\u06FF]');

void _expectArabic(String label, String ar, String en) {
  expect(ar.trim(), isNotEmpty, reason: '$label is empty in Arabic');
  expect(ar, isNot(contains('—')), reason: '$label has an em-dash');
  expect(ar, isNot(equals(en)), reason: '$label leaked English for ar');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RTL and font helpers treat Arabic as RTL', () {
    test('karyabIsRtl', () {
      expect(karyabIsRtl('ar'), isTrue);
      expect(karyabIsRtl('ps'), isTrue);
      expect(karyabIsRtl('fa'), isTrue);
      expect(karyabIsRtl('en'), isFalse);
      expect(karyabIsRtl('de'), isFalse);
    });

    test('font family and fallback for Arabic', () {
      expect(karyabFontFamily('ar'), 'NotoNaskhArabic');
      expect(karyabFontFallback('ar'), ['Roboto']);
    });
  });

  group('UI string parity for Arabic (no English leaks)', () {
    test('AccountStrings', () {
      final samples = <String, List<String>>{
        'account': [AccountStrings.account('ar'), AccountStrings.account('en')],
        'signIn': [AccountStrings.signIn('ar'), AccountStrings.signIn('en')],
        'createAccount': [
          AccountStrings.createAccount('ar'),
          AccountStrings.createAccount('en'),
        ],
        'continueWithGoogle': [
          AccountStrings.continueWithGoogle('ar'),
          AccountStrings.continueWithGoogle('en'),
        ],
        'continueWithoutAccount': [
          AccountStrings.continueWithoutAccount('ar'),
          AccountStrings.continueWithoutAccount('en'),
        ],
        'email': [AccountStrings.email('ar'), AccountStrings.email('en')],
        'password': [
          AccountStrings.password('ar'),
          AccountStrings.password('en'),
        ],
        'forgotPassword': [
          AccountStrings.forgotPassword('ar'),
          AccountStrings.forgotPassword('en'),
        ],
        'passwordResetSent': [
          AccountStrings.passwordResetSent('ar'),
          AccountStrings.passwordResetSent('en'),
        ],
        'loginBenefit': [
          AccountStrings.loginBenefit('ar'),
          AccountStrings.loginBenefit('en'),
        ],
        'noAccountNeeded': [
          AccountStrings.noAccountNeeded('ar'),
          AccountStrings.noAccountNeeded('en'),
        ],
        'signOut': [AccountStrings.signOut('ar'), AccountStrings.signOut('en')],
        'downloadMyData': [
          AccountStrings.downloadMyData('ar'),
          AccountStrings.downloadMyData('en'),
        ],
        'deleteAccount': [
          AccountStrings.deleteAccount('ar'),
          AccountStrings.deleteAccount('en'),
        ],
        'deleteAccountBody': [
          AccountStrings.deleteAccountBody('ar'),
          AccountStrings.deleteAccountBody('en'),
        ],
        'cloudBackup': [
          AccountStrings.cloudBackup('ar'),
          AccountStrings.cloudBackup('en'),
        ],
        'backupConsent': [
          AccountStrings.backupConsent('ar'),
          AccountStrings.backupConsent('en'),
        ],
        'backupNow': [
          AccountStrings.backupNow('ar'),
          AccountStrings.backupNow('en'),
        ],
        'restore': [
          AccountStrings.restore('ar'),
          AccountStrings.restore('en'),
        ],
        'restoreFoundBody': [
          AccountStrings.restoreFoundBody('ar', '01.01.2026'),
          AccountStrings.restoreFoundBody('en', '01.01.2026'),
        ],
        'privacyNote': [
          AccountStrings.privacyNote('ar'),
          AccountStrings.privacyNote('en'),
        ],
        'cancel': [AccountStrings.cancel('ar'), AccountStrings.cancel('en')],
        'delete': [AccountStrings.delete('ar'), AccountStrings.delete('en')],
        'notNow': [AccountStrings.notNow('ar'), AccountStrings.notNow('en')],
      };
      samples.forEach((label, pair) {
        _expectArabic('AccountStrings.$label', pair[0], pair[1]);
      });
      // Long-form strings must actually be Arabic script, not Latin.
      expect(
        AccountStrings.loginBenefit('ar'),
        matches(_arabicScript),
        reason: 'loginBenefit not in Arabic script',
      );
      expect(
        AccountStrings.backupConsent('ar'),
        matches(_arabicScript),
        reason: 'backupConsent not in Arabic script',
      );
    });

    test('JobsStrings', () {
      final samples = <String, List<String>>{
        'savedJobs': [JobsStrings.savedJobs('ar'), JobsStrings.savedJobs('en')],
        'savedSearches': [
          JobsStrings.savedSearches('ar'),
          JobsStrings.savedSearches('en'),
        ],
        'myApplications': [
          JobsStrings.myApplications('ar'),
          JobsStrings.myApplications('en'),
        ],
        'saveJob': [JobsStrings.saveJob('ar'), JobsStrings.saveJob('en')],
        'remove': [JobsStrings.remove('ar'), JobsStrings.remove('en')],
        'emptySavedJobs': [
          JobsStrings.emptySavedJobs('ar'),
          JobsStrings.emptySavedJobs('en'),
        ],
        'saveSearch': [
          JobsStrings.saveSearch('ar'),
          JobsStrings.saveSearch('en'),
        ],
        'newCount': [
          JobsStrings.newCount('ar', 3),
          JobsStrings.newCount('en', 3),
        ],
        'showResults': [
          JobsStrings.showResults('ar'),
          JobsStrings.showResults('en'),
        ],
        'resultsCount': [
          JobsStrings.resultsCount('ar', 5),
          JobsStrings.resultsCount('en', 5),
        ],
        'apply': [JobsStrings.apply('ar'), JobsStrings.apply('en')],
        'trackApplication': [
          JobsStrings.trackApplication('ar'),
          JobsStrings.trackApplication('en'),
        ],
        'emptyApplications': [
          JobsStrings.emptyApplications('ar'),
          JobsStrings.emptyApplications('en'),
        ],
        'offlineBanner': [
          JobsStrings.offlineBanner('ar', '12:00'),
          JobsStrings.offlineBanner('en', '12:00'),
        ],
        'feedbackHint': [
          JobsStrings.feedbackHint('ar'),
          JobsStrings.feedbackHint('en'),
        ],
      };
      samples.forEach((label, pair) {
        _expectArabic('JobsStrings.$label', pair[0], pair[1]);
      });
    });

    test('WorkPermitStrings', () {
      final samples = <String, List<String>>{
        'title': [
          WorkPermitStrings.title('ar'),
          WorkPermitStrings.title('en'),
        ],
        'intro': [
          WorkPermitStrings.intro('ar'),
          WorkPermitStrings.intro('en'),
        ],
        'yourDataTitle': [
          WorkPermitStrings.yourDataTitle('ar'),
          WorkPermitStrings.yourDataTitle('en'),
        ],
        'needProfile': [
          WorkPermitStrings.needProfile('ar'),
          WorkPermitStrings.needProfile('en'),
        ],
        'authorityName': [
          WorkPermitStrings.authorityName('ar'),
          WorkPermitStrings.authorityName('en'),
        ],
        'letterTitle': [
          WorkPermitStrings.letterTitle('ar'),
          WorkPermitStrings.letterTitle('en'),
        ],
        'explanationTitle': [
          WorkPermitStrings.explanationTitle('ar'),
          WorkPermitStrings.explanationTitle('en'),
        ],
        'confirmRead': [
          WorkPermitStrings.confirmRead('ar'),
          WorkPermitStrings.confirmRead('en'),
        ],
        'fillFirst': [
          WorkPermitStrings.fillFirst('ar'),
          WorkPermitStrings.fillFirst('en'),
        ],
      };
      samples.forEach((label, pair) {
        _expectArabic('WorkPermitStrings.$label', pair[0], pair[1]);
      });
      expect(
        WorkPermitStrings.intro('ar'),
        matches(_arabicScript),
        reason: 'work permit intro not in Arabic script',
      );
    });

    test('OfficialLetterStrings', () {
      final samples = <String, List<String>>{
        'title': [
          OfficialLetterStrings.title('ar'),
          OfficialLetterStrings.title('en'),
        ],
        'homeCardSub': [
          OfficialLetterStrings.homeCardSub('ar'),
          OfficialLetterStrings.homeCardSub('en'),
        ],
        'intro': [
          OfficialLetterStrings.intro('ar'),
          OfficialLetterStrings.intro('en'),
        ],
        'stepOf': [
          OfficialLetterStrings.stepOf('ar', 2, 4),
          OfficialLetterStrings.stepOf('en', 2, 4),
        ],
        'stepOffice': [
          OfficialLetterStrings.stepOffice('ar'),
          OfficialLetterStrings.stepOffice('en'),
        ],
        'stepPurpose': [
          OfficialLetterStrings.stepPurpose('ar'),
          OfficialLetterStrings.stepPurpose('en'),
        ],
        'stepAttachments': [
          OfficialLetterStrings.stepAttachments('ar'),
          OfficialLetterStrings.stepAttachments('en'),
        ],
        'stepReview': [
          OfficialLetterStrings.stepReview('ar'),
          OfficialLetterStrings.stepReview('en'),
        ],
        'back': [
          OfficialLetterStrings.back('ar'),
          OfficialLetterStrings.back('en'),
        ],
        'continueLabel': [
          OfficialLetterStrings.continueLabel('ar'),
          OfficialLetterStrings.continueLabel('en'),
        ],
        'whichOffice': [
          OfficialLetterStrings.whichOffice('ar'),
          OfficialLetterStrings.whichOffice('en'),
        ],
        'legalNote': [
          OfficialLetterStrings.legalNote('ar'),
          OfficialLetterStrings.legalNote('en'),
        ],
        'sendEmailNote': [
          OfficialLetterStrings.sendEmailNote('ar'),
          OfficialLetterStrings.sendEmailNote('en'),
        ],
        'attachLimitNote': [
          OfficialLetterStrings.attachLimitNote('ar'),
          OfficialLetterStrings.attachLimitNote('en'),
        ],
      };
      samples.forEach((label, pair) {
        _expectArabic('OfficialLetterStrings.$label', pair[0], pair[1]);
      });
      expect(
        OfficialLetterStrings.intro('ar'),
        matches(_arabicScript),
        reason: 'official letters intro not in Arabic script',
      );
    });

    test('DictationStrings', () {
      _expectArabic(
        'DictationStrings.notAvailable',
        DictationStrings.notAvailable('ar'),
        DictationStrings.notAvailable('en'),
      );
      _expectArabic(
        'DictationStrings.dictate',
        DictationStrings.dictate('ar'),
        DictationStrings.dictate('en'),
      );
    });

    test('GuideStrings chrome', () {
      expect(GuideStrings.title('ar'), 'الأدلة');
      _expectArabic(
        'GuideStrings.intro',
        GuideStrings.intro('ar'),
        GuideStrings.intro('en'),
      );
      _expectArabic(
        'GuideStrings.homeCardSub',
        GuideStrings.homeCardSub('ar'),
        GuideStrings.homeCardSub('en'),
      );
      for (final a in GuideAction.values) {
        final ar = GuideStrings.actionLabel('ar', a);
        expect(ar.trim(), isNotEmpty, reason: 'action $a empty in Arabic');
        expect(ar, isNot(contains('—')), reason: 'action $a em-dash');
      }
    });
  });

  group('letter phrase bank Arabic templates', () {
    test('every phrase has Arabic with the same tokens as the German', () {
      expect(kLetterPhrases, isNotEmpty);
      for (final phrase in kLetterPhrases) {
        expect(
          phrase.ar.trim(),
          isNotEmpty,
          reason: 'phrase ${phrase.id} has no Arabic translation',
        );
        expect(
          phrase.ar,
          isNot(contains('—')),
          reason: 'phrase ${phrase.id} Arabic has an em-dash',
        );
        final deTokens = letterTokensIn(phrase.de)..sort();
        final arTokens = letterTokensIn(phrase.ar)..sort();
        expect(
          arTokens,
          deTokens,
          reason: 'phrase ${phrase.id} token mismatch de vs ar',
        );
        expect(phrase.translationFor('ar'), phrase.ar);
        expect(phrase.translationFor('ps'), phrase.ps);
        expect(phrase.translationFor('fa'), phrase.fa);
      }
    });
  });

  group('official letter explanations in Arabic', () {
    OfficialLetterData data(OfficialPurpose purpose) {
      return OfficialLetterData(
        senderName: 'Ahmad Ahmadi',
        senderStreet: 'Musterstraße 12',
        senderCity: '10115 Berlin',
        dateOfBirth: '03.04.1995',
        nationality: 'Syrien',
        phone: '',
        email: '',
        officeType: OfficeType.auslaenderbehoerde,
        officeName: 'Ausländerbehörde Berlin',
        officeStreet: 'Friedrichstraße 219',
        officeCity: '10969 Berlin',
        officeEmail: 'post@auslaenderbehoerde-berlin.de',
        purpose: purpose,
        today: '10.11.2026',
        company: 'Beispiel GmbH',
        jobTitle: 'Lagerhelfer',
        isAusbildung: false,
        startDate: '01.03.2027',
        courseProvider: '',
        courseStart: '',
        germanLevel: '',
        permitExpiry: '',
        terminReason: '',
        newAddress: '',
        moveInDate: '',
        terminTopic: '',
        documentNames: const [],
        questionSubject: '',
        questionText: '',
        attachmentNames: const [],
      );
    }

    test('all 8 purposes explain in Arabic and name the office', () {
      for (final purpose in OfficialPurpose.values) {
        final ar = officialLetterExplanation('ar', data(purpose));
        expect(ar.trim(), isNotEmpty, reason: '$purpose empty in Arabic');
        expect(
          ar,
          contains('Ausländerbehörde Berlin'),
          reason: '$purpose Arabic explanation does not name the office',
        );
        expect(ar.length, greaterThan(60), reason: '$purpose too short');
        expect(ar, isNot(contains('—')), reason: '$purpose em-dash');
        expect(
          ar,
          matches(_arabicScript),
          reason: '$purpose not in Arabic script',
        );
        expect(
          ar,
          isNot(equals(officialLetterExplanation('en', data(purpose)))),
          reason: '$purpose leaked the English explanation',
        );
      }
    });
  });

  group('dictation locale matching for Arabic', () {
    test('matches Arabic locales the phone offers', () {
      expect(DictationService.matchLocale('ar', ['ar_EG']), 'ar_EG');
      expect(
        DictationService.matchLocale('ar', ['de_DE', 'ar-SA']),
        'ar-SA',
      );
      expect(DictationService.matchLocale('ar', ['de_DE', 'en_US']), isNull);
    });
  });

  group('Arabic widget rendering', () {
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

    void smallScreen(WidgetTester tester) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.reset);
    }

    testWidgets('guides home in Arabic: RTL, both tracks, no overflow', (
      tester,
    ) async {
      smallScreen(tester);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(language: 'ar'),
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                disableAnimations: true,
                textScaler: TextScaler.linear(1.3),
              ),
              child: GuidesScreen(language: 'ar', voiceMode: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الأدلة'), findsOneWidget);
      expect(find.text('امتحان اللغة الألمانية، خطوة بخطوة'), findsOneWidget);
      expect(
        find.text('التدريب المهني (Ausbildung) من الخارج، خطوة بخطوة'),
        findsOneWidget,
      );
      expect(find.text('تم إنجاز 0 من 7 خطوات'), findsNWidgets(2));
      // The guides home wraps its content in RTL for Arabic.
      expect(
        Directionality.of(tester.element(find.text('الأدلة'))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('money step page in Arabic at small size, no overflow', (
      tester,
    ) async {
      smallScreen(tester);
      final track = guidesForLanguage('ar')[1];
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(language: 'ar'),
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                disableAnimations: true,
                textScaler: TextScaler.linear(1.3),
              ),
              child: GuideStepScreen(
                language: 'ar',
                voiceMode: false,
                track: track,
                step: track.stepById('money')!,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('الأوراق التي تحتاجها'), 160);
      expect(find.text('الأوراق التي تحتاجها'), findsOneWidget);
      expect(find.textContaining('822'), findsWidgets);
      await tester.scrollUntilVisible(find.text('تحذير'), 160);
      expect(find.text('تحذير'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
