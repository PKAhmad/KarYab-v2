import 'guide_model.dart';
import 'guides_ar.dart';
import 'guides_de.dart';
import 'guides_en.dart';
import 'guides_fa.dart';
import 'guides_ps.dart';
import 'guides_ur.dart';

export 'guide_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Guides (Phase 11): lookup + UI strings.
//
// [guidesForLanguage] returns the two tracks in the requested
// language; unknown codes fall back to German, the app's standard
// fallback (see OfficialLetterStrings). GuideStrings carries only the
// module's chrome (titles, buttons, footer); the track content itself
// lives in the per-language files. The PS/FA strings are transcribed
// in the Phase 11 report for the CEO's proofread. No em-dashes.
// ─────────────────────────────────────────────────────────────────────────────

/// The two guide tracks in [lang] ('en', 'de', 'ps', 'fa', 'ar', 'ur').
/// Track order is fixed: exam first, then Ausbildung.
List<GuideTrack> guidesForLanguage(String lang) {
  switch (lang) {
    case 'en':
      return kGuidesEn;
    case 'ps':
      return kGuidesPs;
    case 'fa':
      return kGuidesFa;
    case 'ar':
      return kGuidesAr;
    case 'ur':
      return kGuidesUr;
    case 'de':
    default:
      return kGuidesDe;
  }
}

/// One track by its stable id, in [lang]; null for unknown ids.
GuideTrack? guideTrackFor(String lang, String trackId) {
  for (final t in guidesForLanguage(lang)) {
    if (t.id == trackId) return t;
  }
  return null;
}

/// Every language the guides ship in (content integrity tests use it).
const List<String> kGuideLanguages = ['en', 'de', 'ps', 'fa', 'ar', 'ur'];

/// Month the guide content was last checked against the official
/// sources. Shown in the footer of the guides home.
const String kGuidesLastCheckedEn = 'November 2026';

class GuideStrings {
  const GuideStrings._();

  static String _s(
    String lang,
    String en,
    String de,
    String ps,
    String fa,
    String ar,
    String ur,
  ) {
    switch (lang) {
      case 'en':
        return en;
      case 'ps':
        return ps;
      case 'fa':
        return fa;
      case 'ar':
        return ar;
      case 'ur':
        return ur;
      case 'de':
      default:
        return de;
    }
  }

  /// Module title: home card, More sheet entry and screen title.
  static String title(String lang) =>
      _s(lang, 'Guides', 'Wegweiser', 'لارښودونه', 'راهنماها', 'الأدلة', 'رہنمائیں');

  /// Subtitle of the home dashboard card.
  static String homeCardSub(String lang) => _s(
    lang,
    'Step by step: the German exam and Ausbildung from abroad',
    'Schritt für Schritt: die Deutschprüfung und die Ausbildung aus dem Ausland',
    'ګام پر ګام: د الماني ژبې ازموینه او له بهر څخه Ausbildung',
    'گام به گام: امتحان آلمانی و Ausbildung از خارج',
    'خطوة بخطوة: امتحان اللغة الألمانية والتدريب المهني (Ausbildung) من الخارج',
    'قدم بہ قدم: جرمن امتحان اور بیرون ملک سے Ausbildung',
  );

  /// What the guides are, at the top of the guides home.
  static String intro(String lang) => _s(
    lang,
    'These guides show you the official way, step by step. Do one '
        'step after the other, and mark a step when you are '
        'finished. You can listen to every step.',
    'Diese Wegweiser zeigen Ihnen den offiziellen Weg, Schritt '
        'für Schritt. Machen Sie einen Schritt nach dem anderen '
        'und markieren Sie einen Schritt, wenn Sie fertig sind. '
        'Sie können jeden Schritt anhören.',
    'دا لارښودونه تاسو ته رسمي لار ښيي، ګام پر ګام. یو ګام پس له '
        'بله وکړئ، او کله چې یو ګام خلاص کړئ نو نښه یې کړئ. تاسو '
        'هر ګام اورېدلی شئ.',
    'این راهنماها راه رسمی را به شما نشان می‌دهند، گام به گام. '
        'یک گام را بعد از دیگری انجام بدهید، و وقتی یک گام تمام '
        'شد آن را علامت بزنید. می‌توانید هر گام را بشنوید.',
    'هذه الأدلة تريك الطريق الرسمي، خطوة بخطوة. نفّذ خطوة بعد '
        'الأخرى، وعلّم الخطوة عندما تنتهي. يمكنك الاستماع إلى '
        'كل خطوة.',
    'یہ رہنمائیں آپ کو سرکاری راستہ دکھاتی ہیں، قدم بہ قدم۔ ایک '
        'قدم کے بعد دوسرا کریں، اور جب کوئی قدم مکمل ہو جائے تو '
        'اسے نشان زد کریں۔ آپ ہر قدم سن سکتے ہیں۔',
  );

  /// Progress line: how many steps of a track are done.
  static String stepsDone(String lang, int done, int total) => _s(
    lang,
    '$done of $total steps done',
    '$done von $total Schritten fertig',
    'له $total ګامونو څخه $done شوي دي',
    '$done از $total مرحله انجام شد',
    'تم إنجاز $done من $total خطوات',
    '$total مراحل میں سے $done مکمل',
  );

  /// Plain step count for small labels.
  static String stepsCount(String lang, int total) => _s(
    lang,
    '$total steps',
    '$total Schritte',
    '$total ګامونه',
    '$total مرحله',
    '$total خطوات',
    '$total مراحل',
  );

  /// Heading of the documents list on a step page.
  static String documentsTitle(String lang) => _s(
    lang,
    'Documents you need',
    'Diese Unterlagen brauchen Sie',
    'دا اسناد درته اړین دي',
    'این مدارک را لازم دارید',
    'الأوراق التي تحتاجها',
    'آپ کو درکار دستاویزات',
  );

  /// Heading of the warning box on a step page.
  static String warningTitle(String lang) =>
      _s(lang, 'Warning', 'Warnung', 'خبرداری', 'هشدار', 'تحذير', 'انتباہ');

  /// The done button on a step page, when the step is open.
  static String markDone(String lang) => _s(
    lang,
    'Mark as finished',
    'Als fertig markieren',
    'بشپړ یې وګڼه',
    'تمام شده علامت بزن',
    'علّم كمنتهية',
    'مکمل کے طور پر نشان زد کریں',
  );

  /// The same button, when the step is already done.
  static String markUndone(String lang) => _s(
    lang,
    'Finished. Tap to undo',
    'Fertig. Tippen zum Rückgängig machen',
    'بشپړ شو. د بېرته کولو لپاره ټپ کړئ',
    'تمام شد. برای برگرداندن بزنید',
    'انتهت. اضغط للتراجع',
    'مکمل ہو گیا۔ واپس کرنے کے لیے ٹیپ کریں',
  );

  /// Honest note at the bottom of the guides home.
  static String footerNote(String lang) => _s(
    lang,
    'Guides explain the official process. Rules and amounts can '
        'change. Always check the official pages.',
    'Die Wegweiser erklären den offiziellen Weg. Regeln und '
        'Beträge können sich ändern. Prüfen Sie immer die '
        'offiziellen Seiten.',
    'لارښودونه رسمي لاره تشریح کوي. قواعد او پیسې بدلېدلی شي. '
        'تل رسمي پاڼې وګورئ.',
    'راهنماها راه رسمی را توضیح می‌دهند. قوانین و مبلغ‌ها '
        'می‌توانند تغییر کنند. همیشه صفحه‌های رسمی را بررسی کنید.',
    'الأدلة تشرح الطريق الرسمي. القواعد والمبالغ يمكن أن '
        'تتغير. افحص دائمًا الصفحات الرسمية.',
    'رہنمائیں سرکاری عمل کی وضاحت کرتی ہیں۔ قوانین اور رقوم '
        'بدل سکتی ہیں۔ ہمیشہ سرکاری ویب سائٹس جانچیں۔',
  );

  /// The "last checked" line under the footer note.
  static String lastChecked(String lang) => _s(
    lang,
    'Last checked: $kGuidesLastCheckedEn',
    'Zuletzt geprüft: November 2026',
    'وروستی ځل کتل شوی: نومبر 2026',
    'آخرین بررسی: نوامبر 2026',
    'آخر فحص: نوفمبر 2026',
    'آخری جانچ: نومبر 2026',
  );

  /// Button label for an in-app jump action.
  static String actionLabel(String lang, GuideAction action) {
    switch (action) {
      case GuideAction.ausbildungSearch:
        return _s(
          lang,
          'Search Ausbildung places',
          'Ausbildungsplätze suchen',
          'د Ausbildung ځایونه ولټوئ',
          'جای Ausbildung را جستجو کنید',
          'ابحث عن أماكن تدريب مهني',
          'Ausbildung کی جگہیں تلاش کریں',
        );
      case GuideAction.cvBuilder:
        return _s(
          lang,
          'Build your CV',
          'Lebenslauf erstellen',
          'خپل CV جوړ کړئ',
          'CV خود را بسازید',
          'اصنع سيرتك الذاتية (CV)',
          'اپنا CV بنائیں',
        );
      case GuideAction.coverLetter:
        return _s(
          lang,
          'Write a cover letter',
          'Anschreiben schreiben',
          'پوښلیک ولیکئ',
          'نامه پوششی بنویسید',
          'اكتب رسالة تقديم',
          'کور لیٹر لکھیں',
        );
      case GuideAction.officialLetters:
        return _s(
          lang,
          'Open Official letters',
          'Behördenbriefe öffnen',
          'رسمي لیکونه پرانیزئ',
          'نامه‌های رسمی را باز کنید',
          'افتح الرسائل الرسمية',
          'سرکاری خطوط کھولیں',
        );
      case GuideAction.deutschCourses:
        return _s(
          lang,
          'Find a German course',
          'Deutschkurs finden',
          'د الماني کورس ومومئ',
          'دوره آلمانی پیدا کنید',
          'ابحث عن دورة لغة ألمانية',
          'جرمن کورس تلاش کریں',
        );
      case GuideAction.examGuide:
        return _s(
          lang,
          'Open the exam guide',
          'Zum Prüfungswegweiser',
          'د ازموینې لارښود پرانیزئ',
          'راهنمای امتحان را باز کنید',
          'افتح دليل الامتحان',
          'امتحان کی رہنما کھولیں',
        );
    }
  }
}
