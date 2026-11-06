import 'official_letter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OfficialLetterStrings - Phase 9 UI strings for the Behördenbriefe
// (official letters) flow, in the app's 4 languages, following the
// WorkPermitStrings pattern: one static lookup, German fallback for
// unknown language codes. Shared labels (your data, company, listen,
// confirm, save PDF, ...) are reused from WorkPermitStrings by the
// screen; this file carries only the module's own strings. The PS/FA
// strings are transcribed in the Phase 9 report for the CEO's
// proofread. No em-dashes in any string.
// ─────────────────────────────────────────────────────────────────────────────

class OfficialLetterStrings {
  const OfficialLetterStrings._();

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

  /// Module title: home card, More sheet entry and screen title.
  static String title(String lang) => _s(
    lang,
    'Official letters',
    'Behördenbriefe',
    'رسمي لیکونه',
    'نامه‌های رسمی',
  );

  /// Subtitle of the home dashboard card.
  static String homeCardSub(String lang) => _s(
    lang,
    'Write to an office, attach your papers, send the letter as PDF',
    'An ein Amt schreiben, Unterlagen anhängen, Brief als PDF senden',
    'یوه دفتر ته لیک ولیکئ، خپل کاغذونه ورسره ونښلوئ او لیک د PDF په '
        'بڼه واستوئ',
    'به یک اداره نامه بنویسید، مدارک خود را پیوست کنید و نامه را به '
        'صورت PDF بفرستید',
  );

  /// What the module does and who sends the letter.
  static String intro(String lang) => _s(
    lang,
    'Sometimes you must write to an office: for a work permission, '
        'an appointment, an integration course, or to send '
        'documents. Here you choose the office and what you need, '
        'and KarYab writes a correct German letter with your data. '
        'You can attach your papers, for example the forms of the '
        'Agentur für Arbeit. You read the letter, and you send it '
        'yourself from your own email.',
    'Manchmal müssen Sie an ein Amt schreiben: für eine '
        'Arbeitserlaubnis, einen Termin, einen Integrationskurs '
        'oder um Unterlagen zu senden. Hier wählen Sie das Amt und '
        'Ihr Anliegen, und KarYab schreibt einen korrekten '
        'deutschen Brief mit Ihren Daten. Sie können Ihre '
        'Unterlagen anhängen, zum Beispiel die Formulare der '
        'Agentur für Arbeit. Sie lesen den Brief und senden ihn '
        'selbst aus Ihrer eigenen E-Mail.',
    'کله کله باید یوه دفتر ته لیک ولیکئ: د کار د اجازې لپاره، د '
        'وخت لپاره، د ادغام کورس لپاره، یا د سندونو د استولو '
        'لپاره. دلته تاسو دفتر او خپله اړتیا ټاکئ، او KarYab ستاسو '
        'په معلوماتو یو سم الماني لیک لیکي. تاسو کولای شئ خپل '
        'کاغذونه ورسره ونښلوئ، لکه د کار ادارې (Agentur für Arbeit) '
        'فورمې. تاسو لیک لولئ او پخپله یې له خپل برېښنالیک څخه '
        'استوئ.',
    'گاهی باید به یک اداره نامه بنویسید: برای اجازه کار، یک قرار، '
        'دوره ادغام، یا برای فرستادن مدارک. اینجا اداره و نیاز '
        'خود را انتخاب می‌کنید و KarYab یک نامه درست آلمانی با '
        'اطلاعات شما می‌نویسد. می‌توانید مدارک خود را پیوست کنید، '
        'مثلاً فرم‌های اداره کار (Agentur für Arbeit). نامه را '
        'می‌خوانید و خودتان از ایمیل خودتان می‌فرستید.',
  );

  static String stepOf(String lang, int step, int total) => _s(
    lang,
    'Step $step of $total',
    'Schritt $step von $total',
    'ګام $step له $total څخه',
    'مرحله $step از $total',
  );

  static String stepOffice(String lang) =>
      _s(lang, 'Office', 'Amt', 'دفتر', 'اداره');

  static String stepPurpose(String lang) =>
      _s(lang, 'Purpose', 'Anliegen', 'موخه', 'هدف');

  static String stepAttachments(String lang) =>
      _s(lang, 'Attachments', 'Anlagen', 'ضمیمې', 'پیوست‌ها');

  static String stepReview(String lang) => _s(
    lang,
    'Check and send',
    'Prüfen und senden',
    'کتنه او استول',
    'بررسی و ارسال',
  );

  static String back(String lang) =>
      _s(lang, 'Back', 'Zurück', 'شاته', 'برگشت');

  static String continueLabel(String lang) =>
      _s(lang, 'Continue', 'Weiter', 'مخکې', 'ادامه');

  // ── Office step ──────────────────────────────────────────────────────

  static String whichOffice(String lang) =>
      _s(lang, 'Which office?', 'Welches Amt?', 'کوم دفتر؟', 'کدام اداره؟');

  static String officeType(String lang, OfficeType type) {
    switch (type) {
      case OfficeType.auslaenderbehoerde:
        return _s(
          lang,
          'Ausländerbehörde (foreigners office)',
          'Ausländerbehörde',
          'د بهرنیانو دفتر (Ausländerbehörde)',
          'اداره اتباع خارجی (Ausländerbehörde)',
        );
      case OfficeType.buergerbuero:
        return _s(
          lang,
          'Bürgerbüro (citizens office)',
          'Bürgerbüro',
          'د ښاریانو دفتر (Bürgerbüro)',
          'دفتر شهروندان (Bürgerbüro)',
        );
      case OfficeType.jobcenter:
        return 'Jobcenter';
      case OfficeType.agentur:
        return _s(
          lang,
          'Agentur für Arbeit (job agency)',
          'Agentur für Arbeit',
          'د کار اداره (Agentur für Arbeit)',
          'اداره کار (Agentur für Arbeit)',
        );
      case OfficeType.other:
        return _s(
          lang,
          'Another office',
          'Anderes Amt',
          'بل دفتر',
          'اداره دیگر',
        );
    }
  }

  static String officeName(String lang) => _s(
    lang,
    'Name of the office',
    'Name des Amtes',
    'د دفتر نوم',
    'نام اداره',
  );

  static String officeNameHint(String lang) => _s(
    lang,
    'For example: Ausländerbehörde Berlin',
    'Zum Beispiel: Ausländerbehörde Berlin',
    'د بېلګې په توګه: Ausländerbehörde Berlin',
    'برای مثال: Ausländerbehörde Berlin',
  );

  static String officeEmail(String lang) => _s(
    lang,
    'Email address of the office',
    'E-Mail-Adresse des Amtes',
    'د دفتر برېښنالیک پته',
    'آدرس ایمیل اداره',
  );

  static String officeEmailHint(String lang) => _s(
    lang,
    'For example: poststelle@amt-berlin.de',
    'Zum Beispiel: poststelle@amt-berlin.de',
    'د بېلګې په توګه: poststelle@amt-berlin.de',
    'برای مثال: poststelle@amt-berlin.de',
  );

  static String emailInvalid(String lang) => _s(
    lang,
    'Please enter a correct email address.',
    'Bitte geben Sie eine richtige E-Mail-Adresse ein.',
    'مهرباني وکړئ سم برېښنالیک ولیکئ.',
    'لطفا یک آدرس ایمیل درست وارد کنید.',
  );

  static String officeStreet(String lang) => _s(
    lang,
    'Street and house number of the office',
    'Straße und Hausnummer des Amtes',
    'د دفتر سړک او د کور شمېره',
    'خیابان و شماره پلاک اداره',
  );

  static String officeCity(String lang) => _s(
    lang,
    'Postcode and city of the office',
    'Postleitzahl und Ort des Amtes',
    'د دفتر پوستي کوډ او ښار',
    'کد پستی و شهر اداره',
  );

  static String officePostalOptional(String lang) => _s(
    lang,
    'The address is in the letter. You can leave it empty if you '
        'only send the letter by email.',
    'Die Anschrift steht im Brief. Sie können sie leer lassen, '
        'wenn Sie den Brief nur per E-Mail senden.',
    'پته په لیک کې لیکل کېږي. که تاسو لیک یوازې په برېښنالیک '
        'استوئ، کولای شئ هغه خالي پرېږدئ.',
    'نشانی در نامه نوشته می‌شود. اگر نامه را فقط با ایمیل '
        'می‌فرستید، می‌توانید آن را خالی بگذارید.',
  );

  static String fillOfficeFirst(String lang) => _s(
    lang,
    'Please fill in the name of the office and a correct email '
        'address first.',
    'Bitte füllen Sie zuerst den Namen des Amtes und eine '
        'richtige E-Mail-Adresse aus.',
    'مهرباني وکړئ لومړی د دفتر نوم او سم برېښنالیک ډک کړئ.',
    'لطفا ابتدا نام اداره و یک آدرس ایمیل درست را وارد کنید.',
  );

  // ── Purpose step ─────────────────────────────────────────────────────

  static String purposeTitle(String lang) => _s(
    lang,
    'What do you need?',
    'Was brauchen Sie?',
    'تاسو څه ته اړتیا لرئ؟',
    'چه چیزی نیاز دارید؟',
  );

  static String purposeName(String lang, OfficialPurpose purpose) {
    switch (purpose) {
      case OfficialPurpose.workPermit:
        return _s(
          lang,
          'Work permission',
          'Erlaubnis zum Arbeiten',
          'د کار اجازه',
          'اجازه کار',
        );
      case OfficialPurpose.integrationCourse:
        return _s(
          lang,
          'Integration course permission',
          'Berechtigung für einen Integrationskurs',
          'د ادغام کورس اجازه',
          'اجازه دوره ادغام',
        );
      case OfficialPurpose.permitExtension:
        return _s(
          lang,
          'Appointment: extend residence permit',
          'Termin: Aufenthaltstitel verlängern',
          'وخت: د اوسېدو اجازه غځول',
          'قرار: تمدید اجازه اقامت',
        );
      case OfficialPurpose.appointmentGeneral:
        return _s(
          lang,
          'Appointment at an office',
          'Termin bei einem Amt',
          'په یوه دفتر کې وخت',
          'قرار در یک اداره',
        );
      case OfficialPurpose.appointmentRegistration:
        return _s(
          lang,
          'Appointment: register your home',
          'Termin: Wohnung anmelden',
          'وخت: د کور پته ثبتول',
          'قرار: ثبت نشانی خانه',
        );
      case OfficialPurpose.appointmentJob:
        return _s(
          lang,
          'Appointment: Jobcenter or job agency',
          'Termin: Jobcenter oder Agentur für Arbeit',
          'وخت: Jobcenter یا د کار اداره',
          'قرار: Jobcenter یا اداره کار',
        );
      case OfficialPurpose.submitDocuments:
        return _s(
          lang,
          'Send documents to an office',
          'Unterlagen an ein Amt senden',
          'یوه دفتر ته سندونه استول',
          'ارسال مدارک به یک اداره',
        );
      case OfficialPurpose.question:
        return _s(
          lang,
          'Ask a question or another problem',
          'Eine Frage stellen oder ein anderes Anliegen',
          'پوښتنه وکړئ یا بله ستونزه',
          'یک سؤال بپرسید یا مشکل دیگری',
        );
    }
  }

  static String courseProvider(String lang) => _s(
    lang,
    'Course provider (optional, if you know one)',
    'Kursträger (optional, wenn Sie einen kennen)',
    'د کورس چلوونکی (اختیاري، که یې پېژنئ)',
    'برگزارکننده دوره (اختیاری، اگر می‌شناسید)',
  );

  static String courseStart(String lang) => _s(
    lang,
    'Wished course start (optional)',
    'Gewünschter Kursbeginn (optional)',
    'د کورس د پیل ټاکلې نېټه (اختیاري)',
    'شروع دلخواه دوره (اختیاری)',
  );

  static String germanLevel(String lang) => _s(
    lang,
    'Your German level (optional)',
    'Ihr Deutschniveau (optional)',
    'ستاسو د الماني ژبې کچه (اختیاري)',
    'سطح زبان آلمانی شما (اختیاری)',
  );

  static String germanLevelHint(String lang) => _s(
    lang,
    'For example: A1, A2, B1',
    'Zum Beispiel: A1, A2, B1',
    'د بېلګې په توګه: A1، A2، B1',
    'برای مثال: A1، A2، B1',
  );

  static String permitExpiry(String lang) => _s(
    lang,
    'Your residence permit is valid until',
    'Ihr Aufenthaltstitel ist gültig bis',
    'ستاسو د اوسېدو اجازه تر دې نېټې پورې اعتبار لري',
    'اجازه اقامت شما تا این تاریخ اعتبار دارد',
  );

  static String terminReason(String lang) => _s(
    lang,
    'Your concern in one line',
    'Ihr Anliegen in einem Satz',
    'ستاسو موضوع په یوه کرښه کې',
    'موضوع شما در یک خط',
  );

  static String newAddress(String lang) => _s(
    lang,
    'Your new address (street, postcode, city)',
    'Ihre neue Anschrift (Straße, Postleitzahl, Ort)',
    'ستاسو نوی پته (سړک، پوستي کوډ، ښار)',
    'نشانی جدید شما (خیابان، کد پستی، شهر)',
  );

  static String moveInDate(String lang) => _s(
    lang,
    'Move-in date',
    'Einzugsdatum',
    'د کډه کېدو نېټه',
    'تاریخ اسباب‌کشی',
  );

  static String terminTopic(String lang) => _s(
    lang,
    'What do you want to talk about?',
    'Worüber möchten Sie sprechen?',
    'تاسو د څه په اړه خبرې کول غواړئ؟',
    'می‌خواهید درباره چه چیزی صحبت کنید؟',
  );

  static String documentNames(String lang) => _s(
    lang,
    'Names of the documents, one per line',
    'Namen der Unterlagen, eine pro Zeile',
    'د سندونو نومونه، په هره کرښه کې یو',
    'نام مدارک، در هر خط یکی',
  );

  static String documentNamesHint(String lang) => _s(
    lang,
    'For example:\nPassport\nWork contract',
    'Zum Beispiel:\nReisepass\nArbeitsvertrag',
    'د بېلګې په توګه:\nپاسپورت\nد کار تړون',
    'برای مثال:\nگذرنامه\nقرارداد کار',
  );

  static String questionSubject(String lang) => _s(
    lang,
    'Subject line for your letter',
    'Betreff für Ihren Brief',
    'ستاسو د لیک سرلیک',
    'عنوان نامه شما',
  );

  static String questionText(String lang) => _s(
    lang,
    'Write your question or problem in your own words',
    'Schreiben Sie Ihre Frage oder Ihr Problem in Ihren eigenen '
        'Worten',
    'خپله پوښتنه یا ستونزه په خپلو ټکو ولیکئ',
    'سؤال یا مشکل خود را با کلمات خودتان بنویسید',
  );

  static String fillPurposeFirst(String lang) => _s(
    lang,
    'Please fill in the missing fields first.',
    'Bitte füllen Sie zuerst die fehlenden Felder aus.',
    'مهرباني وکړئ لومړی ورکې برخې ډکې کړئ.',
    'لطفا ابتدا قسمت‌های خالی را پر کنید.',
  );

  static String docsNeeded(String lang) => _s(
    lang,
    'Please name at least one document, or add a file in the '
        'next step.',
    'Bitte nennen Sie mindestens eine Unterlage, oder fügen Sie '
        'im nächsten Schritt eine Datei hinzu.',
    'مهرباني وکړئ لږ تر لږه یو سند و نوموئ، یا په بل ګام کې یو '
        'فایل ورزیات کړئ.',
    'لطفا حداقل نام یک مدرک را بنویسید، یا در مرحله بعد یک فایل '
        'اضافه کنید.',
  );

  // ── Attachments step ─────────────────────────────────────────────────

  static String attachmentsTitle(String lang) =>
      _s(lang, 'Attachments', 'Anlagen', 'ضمیمې', 'پیوست‌ها');

  static String attachmentsIntro(String lang) => _s(
    lang,
    'Add the papers for this letter. For a work permission, '
        'attach the forms of the Agentur für Arbeit that your '
        'employer filled in, for example the paper about your '
        'job. The files become pages at the end of your letter '
        'PDF, and their names are written in the letter.',
    'Fügen Sie die Unterlagen für diesen Brief hinzu. Für eine '
        'Arbeitserlaubnis hängen Sie die Formulare der Agentur '
        'für Arbeit an, die Ihr Arbeitgeber ausgefüllt hat, zum '
        'Beispiel die Erklärung zum Beschäftigungsverhältnis. '
        'Die Dateien werden Seiten am Ende Ihres Brief-PDFs, und '
        'ihre Namen stehen im Brief.',
    'د دې لیک لپاره کاغذونه ورزیات کړئ. د کار د اجازې لپاره د '
        'کار ادارې (Agentur für Arbeit) هغه فورمې ونښلوئ چې '
        'ستاسو کارورکوونکي ډکې کړې دي، لکه د دندې په اړه فورمه. '
        'فایلونه ستاسو د لیک PDF په پای کې مخونه ګرځي، او '
        'نومونه یې په لیک کې لیکل کېږي.',
    'مدارک این نامه را اضافه کنید. برای اجازه کار، فرم‌های '
        'اداره کار (Agentur für Arbeit) را که کارفرمای شما پر '
        'کرده است پیوست کنید، مثلاً فرم مربوط به شغل شما. '
        'فایل‌ها در پایان PDF نامه شما به صورت صفحه می‌آیند و '
        'نام آن‌ها در نامه نوشته می‌شود.',
  );

  static String attachButton(String lang) => _s(
    lang,
    'Add files',
    'Dateien hinzufügen',
    'فایلونه ورزیات کړئ',
    'افزودن فایل‌ها',
  );

  static String attachLimitNote(String lang) => _s(
    lang,
    'At most 6 files, each at most 10 MB. PDF files and photos '
        '(JPG, PNG) are possible. You can also continue without '
        'files.',
    'Höchstens 6 Dateien, jede höchstens 10 MB. PDF-Dateien und '
        'Fotos (JPG, PNG) sind möglich. Sie können auch ohne '
        'Dateien weitergehen.',
    'تر ټولو زیات ۶ فایلونه، هر یو تر ټولو زیات ۱۰ MB. PDF '
        'فایلونه او عکسونه (JPG، PNG) کېدای شي. تاسو پرته له '
        'فایلونو هم مخکې تللای شئ.',
    'حداکثر ۶ فایل، هر کدام حداکثر ۱۰ مگابایت. فایل‌های PDF و '
        'عکس‌ها (JPG، PNG) ممکن است. می‌توانید بدون فایل هم '
        'ادامه دهید.',
  );

  static String attachRemove(String lang) =>
      _s(lang, 'Remove', 'Entfernen', 'لرې کړئ', 'حذف');

  static String attachTooMany(String lang) => _s(
    lang,
    'You can add at most 6 files.',
    'Sie können höchstens 6 Dateien hinzufügen.',
    'تاسو تر ټولو زیات ۶ فایلونه ورزیات کولای شئ.',
    'حداکثر می‌توانید ۶ فایل اضافه کنید.',
  );

  static String attachTooBig(String lang) => _s(
    lang,
    'This file is too big. One file can be at most 10 MB.',
    'Diese Datei ist zu groß. Eine Datei darf höchstens 10 MB '
        'haben.',
    'دا فایل ډېر لوی دی. یو فایل تر ټولو زیات ۱۰ MB کېدای شي.',
    'این فایل خیلی بزرگ است. یک فایل حداکثر می‌تواند ۱۰ '
        'مگابایت باشد.',
  );

  static String attachSkippedPdf(String lang) => _s(
    lang,
    'One PDF file could not be put into the letter PDF. The '
        'letter was still made without it.',
    'Eine PDF-Datei konnte nicht in das Brief-PDF eingefügt '
        'werden. Der Brief wurde trotzdem ohne sie erstellt.',
    'یو PDF فایل د لیک په PDF کې نه شو اېښودل کېدای. لیک بیا '
        'هم بې له هغه جوړ شو.',
    'یک فایل PDF نتوانست در PDF نامه قرار گیرد. نامه باز هم '
        'بدون آن ساخته شد.',
  );

  // ── Review / send ────────────────────────────────────────────────────

  /// Shown under the explanation: the template is help, not advice.
  static String legalNote(String lang) => _s(
    lang,
    'Note: This letter is a template and not legal advice. The '
        'office decides about your request.',
    'Hinweis: Dieser Brief ist eine Vorlage und keine '
        'Rechtsberatung. Das Amt entscheidet über Ihren Antrag.',
    'یادونه: دا لیک یوه بېلګه ده او قانوني مشوره نه ده. ستاسو '
        'د غوښتنې په اړه پرېکړه دفتر کوي.',
    'توجه: این نامه یک نمونه است و مشاوره حقوقی نیست. اداره '
        'درباره درخواست شما تصمیم می‌گیرد.',
  );

  static String sendEmail(String lang) => _s(
    lang,
    'Send by email',
    'Per E-Mail senden',
    'په برېښنالیک واستوئ',
    'ارسال با ایمیل',
  );

  static String sendEmailNote(String lang) => _s(
    lang,
    'Your email app opens with the letter text and the PDF. '
        'Check everything there and press Send in your email app.',
    'Ihre E-Mail-App öffnet sich mit dem Brieftext und dem PDF. '
        'Prüfen Sie dort alles und tippen Sie in Ihrer E-Mail-App '
        'auf Senden.',
    'ستاسو د برېښنالیک اپ د لیک په متن او PDF سره پرانستل '
        'کېږي. هر څه هلته وګورئ او په خپل برېښنالیک اپ کې '
        '«استول» کېکاږئ.',
    'برنامه ایمیل شما با متن نامه و PDF باز می‌شود. همه چیز را '
        'آنجا بررسی کنید و در برنامه ایمیل خود «ارسال» را بزنید.',
  );

  static String fallbackTitle(String lang) => _s(
    lang,
    'Send in two steps',
    'Senden in zwei Schritten',
    'په دوو پړاوونو کې استول',
    'ارسال در دو مرحله',
  );

  static String fallbackBody(String lang) => _s(
    lang,
    'Your email app does not take the PDF by itself. Step 1: '
        'your email app opens with the letter text. Step 2: the '
        'PDF opens in the share view, choose your email app '
        'there too, so the PDF comes into the same email. Check '
        'that the PDF is attached before you send.',
    'Ihre E-Mail-App übernimmt das PDF nicht von selbst. '
        'Schritt 1: Ihre E-Mail-App öffnet sich mit dem '
        'Brieftext. Schritt 2: Das PDF öffnet sich in der '
        'Teilen-Ansicht, wählen Sie dort auch Ihre E-Mail-App, '
        'damit das PDF in dieselbe E-Mail kommt. Prüfen Sie vor '
        'dem Senden, ob das PDF angehängt ist.',
    'ستاسو د برېښنالیک اپ PDF پخپله نه اخلي. لومړی ګام: ستاسو '
        'د برېښنالیک اپ د لیک په متن سره پرانستل کېږي. دوهم '
        'ګام: PDF د شریکولو په کړکۍ کې پرانستل کېږي، هلته هم '
        'خپل د برېښنالیک اپ وټاکئ، تر څو PDF هماغه برېښنالیک '
        'ته راشي. له استولو مخکې وګورئ چې PDF نښلول شوی دی.',
    'برنامه ایمیل شما PDF را خودش نمی‌گیرد. مرحله ۱: برنامه '
        'ایمیل شما با متن نامه باز می‌شود. مرحله ۲: PDF در '
        'نمای اشتراک‌گذاری باز می‌شود، آنجا هم برنامه ایمیل '
        'خود را انتخاب کنید تا PDF به همان ایمیل بیاید. قبل '
        'از ارسال بررسی کنید که PDF پیوست شده باشد.',
  );

  static String fallbackGo(String lang) => _s(
    lang,
    'Start step 1',
    'Schritt 1 starten',
    'لومړی ګام پیل کړئ',
    'شروع مرحله ۱',
  );

  static String emailOpened(String lang) => _s(
    lang,
    'Your email app is open. Do not forget to press Send there.',
    'Ihre E-Mail-App ist offen. Vergessen Sie nicht, dort auf '
        'Senden zu tippen.',
    'ستاسو د برېښنالیک اپ پرانستی دی. مه هېروئ چې هلته '
        '«استول» کېکاږئ.',
    'برنامه ایمیل شما باز است. فراموش نکنید آنجا «ارسال» را '
        'بزنید.',
  );
}
