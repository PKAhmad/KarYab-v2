// GENERATED FILE - do not hand-edit the texts in this file.
//
// Generated from the voice manifest
// (workspace/karyab/voice/pilot/manifest.json) by the Phase 14
// generation step. Each entry maps one exact spoken text in
// Pashto (ps), Persian (fa) or Arabic (ar) to its pre-generated
// ElevenLabs clip bundled in the app under
// assets/audio/<lang>/<key>.mp3 (mono, 32 kbps).
//
// To add screens: extend the manifest, generate + compress the
// new clips into assets/audio/<lang>/, then regenerate this file
// from the manifest. Texts that are not in this map (dynamic
// texts, de/en, future screens) keep using the live Azure path.

/// Pre-generated voice clips, keyed by language, then by the exact
/// text passed to TtsService.speak (compared after trimming).
const Map<String, Map<String, String>> kPrerecordedVoice = {
  'ps': {
    'ایا تاسو لوستل او لیکل کولی شئ؟': 'audio/ps/question.mp3',
    'زه لوستل او لیکل نشم کولی،یعنی زه تعلیم نه لرم': 'audio/ps/answer_no.mp3',
    'آیا غواړی چی د ځان لپاره یوه نوی سییوی جوړ کړي؟': 'audio/ps/new_cv_q.mp3',
    'غواړي چی نژدي کارونه پیدا کړي؟': 'audio/ps/find_jobs_q.mp3',
    'زه خپله سییوی لرم': 'audio/ps/have_cv.mp3',
    'د زده کړې کار ومومئ': 'audio/ps/ausbildung.mp3',
    'آلمانی زده کړئ': 'audio/ps/learn_german.mp3',
    'د خپل ښار نژدي کارونه پیدا کړئ': 'audio/ps/jobs_near_city.mp3',
    'نوی سییوی جوړ کړئ': 'audio/ps/new_cv.mp3',
    'زما جوړه شوی سییوی ښکاره کړی': 'audio/ps/view_cv.mp3',
    'خپله سییوی اپلوډ کړئ': 'audio/ps/upload_cv.mp3',
  },
  'fa': {
    'آیا می‌توانید بخوانید و بنویسید؟': 'audio/fa/question.mp3',
    'نه، نمی‌توانم بخوانم یا بنویسم': 'audio/fa/answer_no.mp3',
    'سییوی نو بسازید و کار پیدا کنید': 'audio/fa/new_cv_q.mp3',
    'کارهای نزدیک من را پیدا کنید': 'audio/fa/find_jobs_q.mp3',
    'من قبلاً سییوی دارم': 'audio/fa/have_cv.mp3',
    'کارآموزی پیدا کنید': 'audio/fa/ausbildung.mp3',
    'آلمانی یاد بگیرید': 'audio/fa/learn_german.mp3',
    'کارهای نزدیک را پیدا کنید': 'audio/fa/jobs_near_city.mp3',
    'ایجاد CV جدید': 'audio/fa/new_cv.mp3',
    'سییوی من را ببینید': 'audio/fa/view_cv.mp3',
    'سییوی خود را اپلوډ کنید': 'audio/fa/upload_cv.mp3',
  },
  'ar': {
    'هل تستطيع القراءة والكتابة؟': 'audio/ar/question.mp3',
    'لا، لا أستطيع القراءة أو الكتابة': 'audio/ar/answer_no.mp3',
    'هل تريد إنشاء CV جديد لنفسك؟': 'audio/ar/new_cv_q.mp3',
    'هل تريد البحث عن وظائف قريبة؟': 'audio/ar/find_jobs_q.mp3',
    'عندي CV من قبل': 'audio/ar/have_cv.mp3',
    'ابحث عن مكان Ausbildung': 'audio/ar/ausbildung.mp3',
    'تعلم اللغة الألمانية': 'audio/ar/learn_german.mp3',
    'ابحث عن وظائف قريبة من مدينتك': 'audio/ar/jobs_near_city.mp3',
    'أنشئ CV جديدا': 'audio/ar/new_cv.mp3',
    'شاهد CV الخاص بي': 'audio/ar/view_cv.mp3',
    'حمّل CV الخاص بك': 'audio/ar/upload_cv.mp3',
  },
};

/// Returns the bundled asset path for [text] in [language] when a
/// pre-generated clip exists for that exact text, otherwise null.
/// Only ps/fa/ar have clips; every other language returns null.
String? prerecordedVoiceAsset(String language, String text) {
  final byText = kPrerecordedVoice[language];
  if (byText == null) return null;
  return byText[text.trim()];
}
