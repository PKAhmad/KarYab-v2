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
// Phase 15 (Urdu pack): 'ur' is a full sixth UI language. These tests
// pin the parity contract, mirroring arabic_pack_test.dart: every
// sampled string accessor returns real Urdu for 'ur' (never an
// English fallback leak), the letter phrase bank carries Urdu
// templates with the same tokens as the German originals, the
// official-letter explanations exist in Urdu for all 8 purposes,
// dictation matches Urdu locales (ur-PK), RTL/font helpers treat
// Urdu like Pashto/Dari/Arabic, and the guides home + a step page
// render in Urdu at 360 px / text scale 1.3 with RTL direction and
// no overflow. Guide CONTENT integrity for 'ur' (every step,
// figures, no em-dash) is covered by guides_content_test.dart via
// kGuideLanguages.
// ─────────────────────────────────────────────────────────────────────────────

// Urdu is written in the Arabic script (with its own extra letters,
// all inside this block).
final RegExp _urduScript = RegExp(r'[؀-ۿ]');

void _expectUrdu(String label, String ur, String en) {
  expect(ur.trim(), isNotEmpty, reason: '$label is empty in Urdu');
  expect(ur, isNot(contains('—')), reason: '$label has an em-dash');
  expect(ur, isNot(equals(en)), reason: '$label leaked English for ur');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RTL and font helpers treat Urdu as RTL', () {
    test('karyabIsRtl', () {
      expect(karyabIsRtl('ur'), isTrue);
      expect(karyabIsRtl('ps'), isTrue);
      expect(karyabIsRtl('fa'), isTrue);
      expect(karyabIsRtl('ar'), isTrue);
      expect(karyabIsRtl('en'), isFalse);
      expect(karyabIsRtl('de'), isFalse);
    });

    test('font family and fallback for Urdu', () {
      expect(karyabFontFamily('ur'), 'NotoNaskhArabic');
      expect(karyabFontFallback('ur'), ['Roboto']);
    });
  });

  group('UI string parity for Urdu (no English leaks)', () {
    test('AccountStrings', () {
      final samples = <String, List<String>>{
        'account': [AccountStrings.account('ur'), AccountStrings.account('en')],
        'signIn': [AccountStrings.signIn('ur'), AccountStrings.signIn('en')],
        'createAccount': [
          AccountStrings.createAccount('ur'),
          AccountStrings.createAccount('en'),
        ],
        'continueWithGoogle': [
          AccountStrings.continueWithGoogle('ur'),
          AccountStrings.continueWithGoogle('en'),
        ],
        'continueWithoutAccount': [
          AccountStrings.continueWithoutAccount('ur'),
          AccountStrings.continueWithoutAccount('en'),
        ],
        'email': [AccountStrings.email('ur'), AccountStrings.email('en')],
        'password': [
          AccountStrings.password('ur'),
          AccountStrings.password('en'),
        ],
        'forgotPassword': [
          AccountStrings.forgotPassword('ur'),
          AccountStrings.forgotPassword('en'),
        ],
        'passwordResetSent': [
          AccountStrings.passwordResetSent('ur'),
          AccountStrings.passwordResetSent('en'),
        ],
        'loginBenefit': [
          AccountStrings.loginBenefit('ur'),
          AccountStrings.loginBenefit('en'),
        ],
        'noAccountNeeded': [
          AccountStrings.noAccountNeeded('ur'),
          AccountStrings.noAccountNeeded('en'),
        ],
        'signOut': [AccountStrings.signOut('ur'), AccountStrings.signOut('en')],
        'downloadMyData': [
          AccountStrings.downloadMyData('ur'),
          AccountStrings.downloadMyData('en'),
        ],
        'deleteAccount': [
          AccountStrings.deleteAccount('ur'),
          AccountStrings.deleteAccount('en'),
        ],
        'deleteAccountBody': [
          AccountStrings.deleteAccountBody('ur'),
          AccountStrings.deleteAccountBody('en'),
        ],
        'cloudBackup': [
          AccountStrings.cloudBackup('ur'),
          AccountStrings.cloudBackup('en'),
        ],
        'backupConsent': [
          AccountStrings.backupConsent('ur'),
          AccountStrings.backupConsent('en'),
        ],
        'backupNow': [
          AccountStrings.backupNow('ur'),
          AccountStrings.backupNow('en'),
        ],
        'restore': [AccountStrings.restore('ur'), AccountStrings.restore('en')],
        'restoreFoundBody': [
          AccountStrings.restoreFoundBody('ur', '01.01.2026'),
          AccountStrings.restoreFoundBody('en', '01.01.2026'),
        ],
        'privacyNote': [
          AccountStrings.privacyNote('ur'),
          AccountStrings.privacyNote('en'),
        ],
        'cancel': [AccountStrings.cancel('ur'), AccountStrings.cancel('en')],
        'delete': [AccountStrings.delete('ur'), AccountStrings.delete('en')],
        'notNow': [AccountStrings.notNow('ur'), AccountStrings.notNow('en')],
      };
      samples.forEach((label, pair) {
        _expectUrdu('AccountStrings.$label', pair[0], pair[1]);
      });
      // Long-form strings must actually be Urdu script, not Latin.
      expect(
        AccountStrings.loginBenefit('ur'),
        matches(_urduScript),
        reason: 'loginBenefit not in Urdu script',
      );
      expect(
        AccountStrings.backupConsent('ur'),
        matches(_urduScript),
        reason: 'backupConsent not in Urdu script',
      );
    });

    test('JobsStrings', () {
      final samples = <String, List<String>>{
        'savedJobs': [JobsStrings.savedJobs('ur'), JobsStrings.savedJobs('en')],
        'savedSearches': [
          JobsStrings.savedSearches('ur'),
          JobsStrings.savedSearches('en'),
        ],
        'myApplications': [
          JobsStrings.myApplications('ur'),
          JobsStrings.myApplications('en'),
        ],
        'saveJob': [JobsStrings.saveJob('ur'), JobsStrings.saveJob('en')],
        'remove': [JobsStrings.remove('ur'), JobsStrings.remove('en')],
        'emptySavedJobs': [
          JobsStrings.emptySavedJobs('ur'),
          JobsStrings.emptySavedJobs('en'),
        ],
        'saveSearch': [
          JobsStrings.saveSearch('ur'),
          JobsStrings.saveSearch('en'),
        ],
        'newCount': [
          JobsStrings.newCount('ur', 3),
          JobsStrings.newCount('en', 3),
        ],
        'showResults': [
          JobsStrings.showResults('ur'),
          JobsStrings.showResults('en'),
        ],
        'resultsCount': [
          JobsStrings.resultsCount('ur', 5),
          JobsStrings.resultsCount('en', 5),
        ],
        'apply': [JobsStrings.apply('ur'), JobsStrings.apply('en')],
        'trackApplication': [
          JobsStrings.trackApplication('ur'),
          JobsStrings.trackApplication('en'),
        ],
        'emptyApplications': [
          JobsStrings.emptyApplications('ur'),
          JobsStrings.emptyApplications('en'),
        ],
        'offlineBanner': [
          JobsStrings.offlineBanner('ur', '12:00'),
          JobsStrings.offlineBanner('en', '12:00'),
        ],
        'feedbackHint': [
          JobsStrings.feedbackHint('ur'),
          JobsStrings.feedbackHint('en'),
        ],
      };
      samples.forEach((label, pair) {
        _expectUrdu('JobsStrings.$label', pair[0], pair[1]);
      });
    });

    test('WorkPermitStrings', () {
      final samples = <String, List<String>>{
        'title': [
          WorkPermitStrings.title('ur'),
          WorkPermitStrings.title('en'),
        ],
        'intro': [
          WorkPermitStrings.intro('ur'),
          WorkPermitStrings.intro('en'),
        ],
        'yourDataTitle': [
          WorkPermitStrings.yourDataTitle('ur'),
          WorkPermitStrings.yourDataTitle('en'),
        ],
        'needProfile': [
          WorkPermitStrings.needProfile('ur'),
          WorkPermitStrings.needProfile('en'),
        ],
        'authorityName': [
          WorkPermitStrings.authorityName('ur'),
          WorkPermitStrings.authorityName('en'),
        ],
        'letterTitle': [
          WorkPermitStrings.letterTitle('ur'),
          WorkPermitStrings.letterTitle('en'),
        ],
        'explanationTitle': [
          WorkPermitStrings.explanationTitle('ur'),
          WorkPermitStrings.explanationTitle('en'),
        ],
        'confirmRead': [
          WorkPermitStrings.confirmRead('ur'),
          WorkPermitStrings.confirmRead('en'),
        ],
        'fillFirst': [
          WorkPermitStrings.fillFirst('ur'),
          WorkPermitStrings.fillFirst('en'),
        ],
      };
      samples.forEach((label, pair) {
        _expectUrdu('WorkPermitStrings.$label', pair[0], pair[1]);
      });
      expect(
        WorkPermitStrings.intro('ur'),
        matches(_urduScript),
        reason: 'work permit intro not in Urdu script',
      );
    });

    test('OfficialLetterStrings', () {
      final samples = <String, List<String>>{
        'title': [
          OfficialLetterStrings.title('ur'),
          OfficialLetterStrings.title('en'),
        ],
        'homeCardSub': [
          OfficialLetterStrings.homeCardSub('ur'),
          OfficialLetterStrings.homeCardSub('en'),
        ],
        'intro': [
          OfficialLetterStrings.intro('ur'),
          OfficialLetterStrings.intro('en'),
        ],
        'stepOf': [
          OfficialLetterStrings.stepOf('ur', 2, 4),
          OfficialLetterStrings.stepOf('en', 2, 4),
        ],
        'stepOffice': [
          OfficialLetterStrings.stepOffice('ur'),
          OfficialLetterStrings.stepOffice('en'),
        ],
        'stepPurpose': [
          OfficialLetterStrings.stepPurpose('ur'),
          OfficialLetterStrings.stepPurpose('en'),
        ],
        'stepAttachments': [
          OfficialLetterStrings.stepAttachments('ur'),
          OfficialLetterStrings.stepAttachments('en'),
        ],
        'stepReview': [
          OfficialLetterStrings.stepReview('ur'),
          OfficialLetterStrings.stepReview('en'),
        ],
        'back': [
          OfficialLetterStrings.back('ur'),
          OfficialLetterStrings.back('en'),
        ],
        'continueLabel': [
          OfficialLetterStrings.continueLabel('ur'),
          OfficialLetterStrings.continueLabel('en'),
        ],
        'whichOffice': [
          OfficialLetterStrings.whichOffice('ur'),
          OfficialLetterStrings.whichOffice('en'),
        ],
        'legalNote': [
          OfficialLetterStrings.legalNote('ur'),
          OfficialLetterStrings.legalNote('en'),
        ],
        'sendEmailNote': [
          OfficialLetterStrings.sendEmailNote('ur'),
          OfficialLetterStrings.sendEmailNote('en'),
        ],
        'attachLimitNote': [
          OfficialLetterStrings.attachLimitNote('ur'),
          OfficialLetterStrings.attachLimitNote('en'),
        ],
      };
      samples.forEach((label, pair) {
        _expectUrdu('OfficialLetterStrings.$label', pair[0], pair[1]);
      });
      expect(
        OfficialLetterStrings.intro('ur'),
        matches(_urduScript),
        reason: 'official letters intro not in Urdu script',
      );
    });

    test('DictationStrings', () {
      _expectUrdu(
        'DictationStrings.notAvailable',
        DictationStrings.notAvailable('ur'),
        DictationStrings.notAvailable('en'),
      );
      _expectUrdu(
        'DictationStrings.dictate',
        DictationStrings.dictate('ur'),
        DictationStrings.dictate('en'),
      );
    });

    test('GuideStrings chrome', () {
      expect(GuideStrings.title('ur'), 'رہنمائیں');
      _expectUrdu(
        'GuideStrings.intro',
        GuideStrings.intro('ur'),
        GuideStrings.intro('en'),
      );
      _expectUrdu(
        'GuideStrings.homeCardSub',
        GuideStrings.homeCardSub('ur'),
        GuideStrings.homeCardSub('en'),
      );
      for (final a in GuideAction.values) {
        final ur = GuideStrings.actionLabel('ur', a);
        expect(ur.trim(), isNotEmpty, reason: 'action $a empty in Urdu');
        expect(ur, isNot(contains('—')), reason: 'action $a em-dash');
      }
    });
  });

  group('letter phrase bank Urdu templates', () {
    test('every phrase has Urdu with the same tokens as the German', () {
      expect(kLetterPhrases, isNotEmpty);
      for (final phrase in kLetterPhrases) {
        expect(
          phrase.ur.trim(),
          isNotEmpty,
          reason: 'phrase ${phrase.id} has no Urdu translation',
        );
        expect(
          phrase.ur,
          isNot(contains('—')),
          reason: 'phrase ${phrase.id} Urdu has an em-dash',
        );
        final deTokens = letterTokensIn(phrase.de)..sort();
        final urTokens = letterTokensIn(phrase.ur)..sort();
        expect(
          urTokens,
          deTokens,
          reason: 'phrase ${phrase.id} token mismatch de vs ur',
        );
        expect(phrase.translationFor('ur'), phrase.ur);
        expect(phrase.translationFor('ps'), phrase.ps);
        expect(phrase.translationFor('fa'), phrase.fa);
        expect(phrase.translationFor('ar'), phrase.ar);
      }
    });
  });

  group('official letter explanations in Urdu', () {
    OfficialLetterData data(OfficialPurpose purpose) {
      return OfficialLetterData(
        senderName: 'Ahmad Ahmadi',
        senderStreet: 'Musterstraße 12',
        senderCity: '10115 Berlin',
        dateOfBirth: '03.04.1995',
        nationality: 'Pakistan',
        phone: '',
        email: '',
        officeType: OfficeType.auslaenderbehoerde,
        officeName: 'Ausländerbehörde Berlin',
        officeStreet: 'Friedrichstraße 219',
        officeCity: '10969 Berlin',
        officeEmail: 'post@auslaenderbehoerde-berlin.de',
        purpose: purpose,
        today: '11.11.2026',
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

    test('all 8 purposes explain in Urdu and name the office', () {
      for (final purpose in OfficialPurpose.values) {
        final ur = officialLetterExplanation('ur', data(purpose));
        expect(ur.trim(), isNotEmpty, reason: '$purpose empty in Urdu');
        expect(
          ur,
          contains('Ausländerbehörde Berlin'),
          reason: '$purpose Urdu explanation does not name the office',
        );
        expect(ur.length, greaterThan(60), reason: '$purpose too short');
        expect(ur, isNot(contains('—')), reason: '$purpose em-dash');
        expect(
          ur,
          matches(_urduScript),
          reason: '$purpose not in Urdu script',
        );
        expect(
          ur,
          isNot(equals(officialLetterExplanation('en', data(purpose)))),
          reason: '$purpose leaked the English explanation',
        );
      }
    });
  });

  group('dictation locale matching for Urdu', () {
    test('matches Urdu locales the phone offers (ur-PK)', () {
      expect(DictationService.matchLocale('ur', ['ur_PK']), 'ur_PK');
      expect(
        DictationService.matchLocale('ur', ['de_DE', 'ur-PK']),
        'ur-PK',
      );
      expect(DictationService.matchLocale('ur', ['de_DE', 'en_US']), isNull);
    });
  });

  group('Urdu widget rendering', () {
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

    testWidgets('guides home in Urdu: RTL, both tracks, no overflow', (
      tester,
    ) async {
      smallScreen(tester);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(language: 'ur'),
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                disableAnimations: true,
                textScaler: TextScaler.linear(1.3),
              ),
              child: GuidesScreen(language: 'ur', voiceMode: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('رہنمائیں'), findsOneWidget);
      expect(find.text('جرمن زبان کا امتحان، قدم بہ قدم'), findsOneWidget);
      expect(find.text('بیرون ملک سے Ausbildung، قدم بہ قدم'), findsOneWidget);
      expect(find.text('7 مراحل میں سے 0 مکمل'), findsNWidgets(2));
      // The guides home wraps its content in RTL for Urdu.
      expect(
        Directionality.of(tester.element(find.text('رہنمائیں'))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('money step page in Urdu at small size, no overflow', (
      tester,
    ) async {
      smallScreen(tester);
      final track = guidesForLanguage('ur')[1];
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(language: 'ur'),
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                disableAnimations: true,
                textScaler: TextScaler.linear(1.3),
              ),
              child: GuideStepScreen(
                language: 'ur',
                voiceMode: false,
                track: track,
                step: track.stepById('money')!,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('آپ کو درکار دستاویزات'), 160);
      expect(find.text('آپ کو درکار دستاویزات'), findsOneWidget);
      expect(find.textContaining('822'), findsWidgets);
      await tester.scrollUntilVisible(find.text('انتباہ'), 160);
      expect(find.text('انتباہ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
