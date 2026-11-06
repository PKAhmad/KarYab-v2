// ─────────────────────────────────────────────────────────────────────────────
// JobsStrings - Phase 7 UI strings (saved jobs/searches, application
// tracker, offline banner, feedback) in the app's 4 languages, following
// the AccountStrings pattern from Phase 6: one static lookup, German
// fallback for unknown language codes. PS/FA strings are listed in the
// Phase 7 report for the CEO's proofread.
// ─────────────────────────────────────────────────────────────────────────────

class JobsStrings {
  const JobsStrings._();

  static String _s(String lang, String en, String de, String ps, String fa) {
    switch (lang) {
      case 'en':
        return en;
      case 'ps':
        return ps;
      case 'fa':
        return fa;
      case 'de':
      default:
        return de;
    }
  }

  // Navigation / entries
  static String savedJobs(String lang) => _s(lang, 'Saved jobs',
      'Gespeicherte Jobs', 'خوندي شوي کارونه', 'کارهای ذخیره شده');
  static String savedSearches(String lang) => _s(lang, 'Saved searches',
      'Gespeicherte Suchen', 'خوندي شوې لټونې', 'جستجوهای ذخیره شده');
  static String myApplications(String lang) => _s(lang, 'My applications',
      'Meine Bewerbungen', 'زما غوښتنلیکونه', 'درخواست‌های من');
  static String sendFeedback(String lang) => _s(
      lang, 'Send feedback', 'Feedback senden', 'نظر واستوئ', 'ارسال بازخورد');

  // Saved jobs
  static String saveJob(String lang) =>
      _s(lang, 'Save job', 'Job speichern', 'کار خوندي کړئ', 'ذخیره کار');
  static String savedLabel(String lang) =>
      _s(lang, 'Saved', 'Gespeichert', 'خوندي شو', 'ذخیره شد');
  static String remove(String lang) =>
      _s(lang, 'Remove', 'Entfernen', 'لرې کړئ', 'حذف');
  static String emptySavedJobs(String lang) => _s(
      lang,
      'No saved jobs yet. Tap the bookmark on a job to save it here.',
      'Noch keine gespeicherten Jobs. Tippe auf das Lesezeichen bei einer Stelle, um sie hier zu speichern.',
      'تر اوسه هیڅ کار نه دی خوندي شوی. په کار کې د نښې په ټکولو سره یې دلته خوندي کړئ.',
      'هنوز کاری ذخیره نشده است. با زدن نشانه روی یک کار، آن را اینجا ذخیره کنید.');
  static String emptySavedSearches(String lang) => _s(
      lang,
      'No saved searches yet.',
      'Noch keine gespeicherten Suchen.',
      'تر اوسه هیڅ لټون نه دی خوندي شوی.',
      'هنوز جستجویی ذخیره نشده است.');
  static String saveSearch(String lang) => _s(
      lang, 'Save search', 'Suche speichern', 'لټون خوندي کړئ', 'ذخیره جستجو');
  static String searchSaved(String lang) => _s(
      lang, 'Search saved', 'Suche gespeichert', 'لټون خوندي شو',
      'جستجو ذخیره شد');
  static String newCount(String lang, int n) =>
      _s(lang, '$n new', '$n neu', '$n نوي', '$n جدید');
  static String showResults(String lang) => _s(lang, 'Show results',
      'Ergebnisse zeigen', 'پایلې وګورئ', 'نمایش نتایج');
  static String results(String lang) =>
      _s(lang, 'Results', 'Ergebnisse', 'پایلې', 'نتایج');
  static String resultsCount(String lang, int n) => _s(lang, '$n results',
      '$n Ergebnisse', '$n پایلې', '$n نتیجه');
  static String apply(String lang) =>
      _s(lang, 'Apply', 'Bewerben', 'غوښتنلیک', 'ثبت نام');
  static String delete(String lang) =>
      _s(lang, 'Delete', 'Löschen', 'ړنګ کړئ', 'حذف کنید');
  static String cancel(String lang) =>
      _s(lang, 'Cancel', 'Abbrechen', 'لغوه', 'لغو');
  static String ok(String lang) => _s(lang, 'OK', 'OK', 'سم دی', 'باشد');

  // Application tracker
  static String trackApplication(String lang) => _s(lang, 'Track application',
      'Bewerbung verfolgen', 'غوښتنلیک تعقیب کړئ', 'پیگیری درخواست');
  static String addedToTracker(String lang) => _s(
      lang,
      'Added to your applications',
      'Zu deinen Bewerbungen hinzugefügt',
      'ستاسو غوښتنلیکونو ته اضافه شو',
      'به درخواست‌های شما اضافه شد');
  static String alreadyTracked(String lang) => _s(
      lang,
      'Already in your applications',
      'Bereits in deinen Bewerbungen',
      'پخوا ستاسو په غوښتنلیکونو کې شته',
      'قبلا در درخواست‌های شما وجود دارد');
  static String open(String lang) =>
      _s(lang, 'Open', 'Öffnen', 'پرانیستل', 'باز کردن');
  static String emptyApplications(String lang) => _s(
      lang,
      'No applications yet. Open a job and tap Track application.',
      'Noch keine Bewerbungen. Öffne eine Stelle und tippe auf Bewerbung verfolgen.',
      'تر اوسه هیڅ غوښتنلیک نشته. یو کار پرانیزئ او غوښتنلیک تعقیب کړئ ټک کړئ.',
      'هنوز درخواستی وجود ندارد. یک کار را باز کنید و پیگیری درخواست را بزنید.');
  static String statusName(String lang, String status) {
    return _s(
      lang,
      switch (status) {
        'applied' => 'Applied',
        'invited' => 'Invited',
        'answered' => 'Answer received',
        _ => 'Saved',
      },
      switch (status) {
        'applied' => 'Beworben',
        'invited' => 'Eingeladen',
        'answered' => 'Antwort erhalten',
        _ => 'Gespeichert',
      },
      switch (status) {
        'applied' => 'غوښتنلیک استول شوی',
        'invited' => 'بلنه ترلاسه شوې',
        'answered' => 'ځواب ترلاسه شو',
        _ => 'خوندي شوی',
      },
      switch (status) {
        'applied' => 'درخواست فرستاده شده',
        'invited' => 'دعوت شده',
        'answered' => 'پاسخ دریافت شده',
        _ => 'ذخیره شده',
      },
    );
  }

  static String markAs(String lang, String nextStatus) {
    return _s(
      lang,
      switch (nextStatus) {
        'applied' => 'Mark as applied',
        'invited' => 'Mark as invited',
        _ => 'Mark answer received',
      },
      switch (nextStatus) {
        'applied' => 'Als beworben markieren',
        'invited' => 'Als eingeladen markieren',
        _ => 'Als beantwortet markieren',
      },
      switch (nextStatus) {
        'applied' => 'د استول شوي په توګه نښه کړئ',
        'invited' => 'د بلنې په توګه نښه کړئ',
        _ => 'ځواب ترلاسه شو نښه کړئ',
      },
      switch (nextStatus) {
        'applied' => 'علامت‌گذاری به عنوان فرستاده شده',
        'invited' => 'علامت‌گذاری به عنوان دعوت شده',
        _ => 'علامت‌گذاری پاسخ دریافت شده',
      },
    );
  }

  static String linkDocuments(String lang) => _s(
      lang,
      'Link CV / letter',
      'Lebenslauf / Anschreiben verknüpfen',
      'CV / لیک ونښلوئ',
      'پیوند CV / نامه');
  static String noLinkedDocs(String lang) => _s(
      lang,
      'No CV or letter linked',
      'Kein Lebenslauf oder Anschreiben verknüpft',
      'هیڅ CV یا لیک نه دی نښلول شوی',
      'هیچ CV یا نامه‌ای پیوند نشده است');
  static String yourCvs(String lang) =>
      _s(lang, 'Your CVs', 'Deine Lebensläufe', 'ستاسو CV ګانې', 'CV های شما');
  static String yourLetters(String lang) => _s(lang, 'Your letters',
      'Deine Anschreiben', 'ستاسو لیکونه', 'نامه‌های شما');
  static String noneOption(String lang) =>
      _s(lang, 'None', 'Keine', 'هیڅ یو نه', 'هیچکدام');

  // Letter editor hook (Phase 4 -> tracker)
  static String letterAppliedBody(String lang) => _s(
      lang,
      'This letter is for a job posting. Mark this job as applied in your tracker?',
      'Dieses Anschreiben ist für eine Stellenanzeige. Diese Stelle in deinem Verlauf als beworben markieren?',
      'دا لیک د یوې دندې لپاره دی. دا دنده په تعقیب کې د استول شوې په توګه نښه کړئ؟',
      'این نامه برای یک آگهی شغلی است. این شغل را در پیگیری خود به عنوان درخواست فرستاده شده علامت بزنید؟');
  static String yes(String lang) => _s(lang, 'Yes', 'Ja', 'هو', 'بله');
  static String notNow(String lang) =>
      _s(lang, 'Not now', 'Nicht jetzt', 'اوس نه', 'حالا نه');

  /// "dd.MM.yyyy HH:mm" for the offline banner (kept dependency-free
  /// on purpose: package:intl is only a transitive dependency here).
  static String cacheTime(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.day)}.${two(t.month)}.${t.year} ${two(t.hour)}:${two(t.minute)}';
  }

  // Offline banner
  static String offlineBanner(String lang, String time) => _s(
      lang,
      'Offline. Showing saved results from $time.',
      'Offline. Gespeicherte Ergebnisse von $time werden gezeigt.',
      'افلاین. د $time خوندي شوې پایلې ښودل کیږي.',
      'آفلاین. نتایج ذخیره شده از $time نمایش داده می‌شود.');

  // Feedback
  static String feedbackHint(String lang) => _s(lang, 'What can we do better?',
      'Was können wir besser machen?', 'موږ څه ښه کولی شو؟',
      'چه کاری را می‌توانیم بهتر انجام دهیم؟');
  static String send(String lang) =>
      _s(lang, 'Send', 'Senden', 'استول', 'ارسال');
  static String feedbackThanks(String lang) => _s(
      lang,
      'Thank you for your feedback.',
      'Danke für dein Feedback.',
      'ستاسو له نظر څخه مننه.',
      'از بازخورد شما سپاسگزاریم.');
  static String feedbackUnavailable(String lang) => _s(
      lang,
      'Feedback is not available yet.',
      'Feedback ist noch nicht verfügbar.',
      'نظر استول لا شتون نه لري.',
      'ارسال بازخورد هنوز در دسترس نیست.');
  static String feedbackShareInstead(String lang) => _s(lang, 'Share instead',
      'Stattdessen teilen', 'پرځای یې شریک کړئ', 'به جای آن اشتراک‌گذاری کنید');
  static String feedbackFailed(String lang) => _s(
      lang,
      'Sending did not work. Please try again or share your text instead.',
      'Das Senden hat nicht funktioniert. Bitte versuche es erneut oder teile deinen Text stattdessen.',
      'استول ونه شول. بیا هڅه وکړئ یا خپل متن پرځای شریک کړئ.',
      'ارسال انجام نشد. لطفا دوباره تلاش کنید یا متن خود را به جای آن به اشتراک بگذارید.');
  static String feedbackEmpty(String lang) => _s(
      lang,
      'Please write something first.',
      'Bitte schreibe zuerst etwas.',
      'مهرباني وکړئ لومړی څه ولیکئ.',
      'لطفا ابتدا چیزی بنویسید.');
}
