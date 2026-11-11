// ─────────────────────────────────────────────────────────────────────────────
// WorkPermitStrings - Phase 8 UI strings for the Ausländerbehörde
// work-permission letter flow, in the app's 4 languages, following the
// JobsStrings / AccountStrings pattern: one static lookup, German fallback
// for unknown language codes. The PS/FA strings are transcribed in the
// Phase 8 report for the CEO's proofread. No em-dashes in any string.
// ─────────────────────────────────────────────────────────────────────────────

class WorkPermitStrings {
  const WorkPermitStrings._();

  static String _s(String lang, String en, String de, String ps, String fa, String ar, String ur) {
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

  /// More-sheet entry + screen title.
  static String title(String lang) => _s(
        lang,
        'Work permit letter',
        'Brief: Arbeitserlaubnis',
        'د کار اجازې لیک',
        'نامه اجازه کار',
        'رسالة تصريح العمل',
        'کام کی اجازت کا خط',
      );

  /// What this letter is and who decides. Shown at the top of the flow.
  static String intro(String lang) => _s(
        lang,
        'If you have a job or Ausbildung offer, but your residence permit '
            'does not allow you to work yet, the Ausländerbehörde '
            '(foreigners office) must agree first. This letter asks the '
            'office for that permission. KarYab does not send the letter '
            'for you. You read it, check your data, and send it yourself.',
        'Wenn Sie ein Angebot für einen Job oder eine Ausbildung haben, '
            'Ihr Aufenthaltstitel Ihnen das Arbeiten aber noch nicht '
            'erlaubt, muss zuerst die Ausländerbehörde zustimmen. Dieser '
            'Brief bittet die Behörde um diese Erlaubnis. KarYab sendet '
            'den Brief nicht für Sie. Sie lesen ihn, prüfen Ihre Daten '
            'und senden ihn selbst.',
        'که تاسو د کار یا روزنې وړاندیز لرئ، خو ستاسو د اوسېدو اجازه لا '
            'کار ته اجازه نه درکوي، نو لومړی باید د بهرنیانو دفتر '
            '(Ausländerbehörde) موافقه وکړي. دا لیک له دفتر څخه د همدې '
            'اجازې غوښتنه کوي. KarYab دا لیک ستاسو لپاره نه استوي. تاسو '
            'یې لولئ، خپل معلومات ګورئ او پخپله یې استوئ.',
        'اگر پیشنهاد کار یا آموزش دارید، اما اجازه اقامت شما هنوز اجازه '
            'کار نمی‌دهد، ابتدا اداره اتباع خارجی (Ausländerbehörde) '
            'باید موافقت کند. این نامه از اداره همین اجازه را درخواست '
            'می‌کند. KarYab نامه را برای شما نمی‌فرستد. شما آن را '
            'می‌خوانید، اطلاعات خود را بررسی می‌کنید و خودتان می‌فرستید.',
        'إذا كان لديك عرض عمل أو Ausbildung، لكن تصريح '
            'إقامتك لا يسمح لك بالعمل بعد، يجب أن توافق '
            'Ausländerbehörde (مكتب الأجانب) أولا. تطلب هذه '
            'الرسالة من المكتب هذا التصريح. KarYab لا يرسل '
            'الرسالة عنك. أنت تقرأها وتتحقق من بياناتك '
            'وترسلها بنفسك.',
        'اگر آپ کے پاس نوکری یا Ausbildung کی پیشکش ہے، لیکن آپ کے '
            'رہائشی اجازت نامے سے آپ کو ابھی کام کرنے کی اجازت نہیں ہے، '
            'تو پہلے Ausländerbehörde (غیر ملکیوں کا دفتر) کو راضی ہونا '
            'چاہیے۔ یہ خط دفتر سے اسی اجازت کی درخواست کرتا ہے۔ KarYab '
            'یہ خط آپ کے لیے نہیں بھیجتا۔ آپ اسے پڑھتے ہیں، اپنا ڈیٹا '
            'دیکھتے ہیں اور خود بھیجتے ہیں۔',
      );

  static String yourDataTitle(String lang) => _s(
        lang,
        'Your data (from your profile)',
        'Ihre Daten (aus Ihrem Profil)',
        'ستاسو معلومات (ستاسو له پروفایل څخه)',
        'اطلاعات شما (از پروفایل شما)',
        'بياناتك (من ملفك)',
        'آپ کا ڈیٹا (آپ کے پروفائل سے)',
      );

  static String needProfile(String lang) => _s(
        lang,
        'Please save your name, address and date of birth in your '
            'profile first. The letter needs them.',
        'Bitte speichern Sie zuerst Ihren Namen, Ihre Adresse und Ihr '
            'Geburtsdatum in Ihrem Profil. Der Brief braucht diese Daten.',
        'مهرباني وکړئ لومړی خپل نوم، پته او د زېږېدنې نېټه په پروفایل '
            'کې خوندي کړئ. لیک دې معلوماتو ته اړتیا لري.',
        'لطفا ابتدا نام، نشانی و تاریخ تولد خود را در پروفایل ذخیره '
            'کنید. نامه به این اطلاعات نیاز دارد.',
        'يرجى حفظ اسمك وعنوانك وتاريخ ميلادك في ملفك '
            'أولا. الرسالة تحتاج إلى هذه البيانات.',
        'براہ کرم پہلے اپنا نام، پتہ اور تاریخ پیدائش اپنے پروفائل میں محفوظ کریں۔ خط کو ان کی ضرورت ہے۔',
      );

  static String authorityName(String lang) => _s(
        lang,
        'Name of the office',
        'Name der Ausländerbehörde',
        'د دفتر نوم',
        'نام اداره',
        'اسم المكتب',
        'دفتر کا نام',
      );

  static String authorityNameHint(String lang) => _s(
        lang,
        'For example: Ausländerbehörde Berlin',
        'Zum Beispiel: Ausländerbehörde Berlin',
        'د بېلګې په توګه: Ausländerbehörde Berlin',
        'برای مثال: Ausländerbehörde Berlin',
        'على سبيل المثال: Ausländerbehörde Berlin',
        'مثال: Ausländerbehörde Berlin',
      );

  static String authorityCity(String lang) => _s(
        lang,
        'City of the office',
        'Stadt der Behörde',
        'د دفتر ښار',
        'شهر اداره',
        'مدينة المكتب',
        'دفتر کا شہر',
      );

  static String savedOffer(String lang) => _s(
        lang,
        'Use a saved job or application (optional)',
        'Gespeicherten Job oder Bewerbung nutzen (optional)',
        'خوندي شوی کار یا غوښتنلیک وکاروئ (اختیاري)',
        'استفاده از کار یا درخواست ذخیره شده (اختیاری)',
        'استخدام وظيفة أو طلب محفوظ (اختياري)',
        'محفوظ شدہ نوکری یا درخواست استعمال کریں (اختیاری)',
      );

  static String enterManually(String lang) => _s(
        lang,
        'Enter it myself',
        'Selbst eingeben',
        'پخپله یې ولیکم',
        'خودم وارد می‌کنم',
        'سأدخله بنفسي',
        'میں خود لکھوں گا',
      );

  static String jobTitle(String lang) => _s(
        lang,
        'Job title or Ausbildung occupation',
        'Stellenbezeichnung oder Ausbildungsberuf',
        'دندې نوم یا د روزنې مسلک',
        'عنوان شغل یا حرفه آموزشی',
        'المسمى الوظيفي أو مهنة Ausbildung',
        'نوکری کا عنوان یا Ausbildung کا پیشہ',
      );

  static String company(String lang) => _s(
        lang,
        'Company',
        'Firma',
        'شرکت',
        'شرکت',
        'الشركة',
        'کمپنی',
      );

  static String isAusbildung(String lang) => _s(
        lang,
        'This is an Ausbildung place',
        'Das ist ein Ausbildungsplatz',
        'دا د روزنې ځای دی',
        'این یک جای آموزشی (Ausbildung) است',
        'هذا مكان Ausbildung',
        'یہ ایک Ausbildung کی جگہ ہے',
      );

  static String startDate(String lang) => _s(
        lang,
        'Intended start date',
        'Gewünschter Starttermin',
        'د پیل ټاکلې نېټه',
        'تاریخ شروع مورد نظر',
        'تاريخ البدء المطلوب',
        'شروع کرنے کی مطلوبہ تاریخ',
      );

  static String pickDate(String lang) => _s(
        lang,
        'Choose date',
        'Datum wählen',
        'نېټه وټاکئ',
        'انتخاب تاریخ',
        'اختيار التاريخ',
        'تاریخ منتخب کریں',
      );

  static String letterTitle(String lang) => _s(
        lang,
        'Your letter (German)',
        'Ihr Brief (Deutsch)',
        'ستاسو لیک (په الماني)',
        'نامه شما (به آلمانی)',
        'رسالتك (بالألمانية)',
        'آپ کا خط (جرمن میں)',
      );

  static String explanationTitle(String lang) => _s(
        lang,
        'What this letter says',
        'Was in diesem Brief steht',
        'په دې لیک کې څه لیکل شوي دي',
        'در این نامه چه نوشته شده است',
        'ما هو مكتوب في هذه الرسالة',
        'اس خط میں کیا لکھا ہے',
      );

  static String listen(String lang) => _s(
        lang,
        'Listen',
        'Anhören',
        'واورئ',
        'گوش دادن',
        'الاستماع',
        'سنیں',
      );

  static String confirmRead(String lang) => _s(
        lang,
        'I have read the letter and the explanation, and I have checked '
            'that my data is correct.',
        'Ich habe den Brief und die Erklärung gelesen und geprüft, dass '
            'meine Daten richtig sind.',
        'ما لیک او تشریح ولوستل او ومې کتل چې زما معلومات سم دي.',
        'نامه و توضیح را خوانده‌ام و بررسی کرده‌ام که اطلاعاتم درست است.',
        'لقد قرأت الرسالة والشرح وتحققت من أن '
            'بياناتي صحيحة.',
        'میں نے خط اور وضاحت پڑھ لی ہے اور دیکھ لیا ہے کہ میرا ڈیٹا درست ہے۔',
      );

  static String sendShare(String lang) => _s(
        lang,
        'Send or share the letter',
        'Brief senden oder teilen',
        'لیک واستوئ یا یې شریک کړئ',
        'نامه را بفرستید یا به اشتراک بگذارید',
        'إرسال الرسالة أو مشاركتها',
        'خط بھیجیں یا شیئر کریں',
      );

  static String openInEmail(String lang) => _s(
        lang,
        'Open in email app',
        'In E-Mail-App öffnen',
        'په برېښنالیک اپ کې پرانیزئ',
        'باز کردن در برنامه ایمیل',
        'الفتح في تطبيق البريد الإلكتروني',
        'ای میل ایپ میں کھولیں',
      );

  static String savePdf(String lang) => _s(
        lang,
        'Save as PDF',
        'Als PDF speichern',
        'د PDF په توګه خوندي کړئ',
        'ذخیره به صورت PDF',
        'الحفظ كملف PDF',
        'PDF کے طور پر محفوظ کریں',
      );

  static String savedNote(String lang) => _s(
        lang,
        'A copy is saved with your letters.',
        'Eine Kopie ist bei Ihren Briefen gespeichert.',
        'یوه کاپي ستاسو له لیکونو سره خوندي شوه.',
        'یک نسخه نزد نامه‌های شما ذخیره شد.',
        'تم حفظ نسخة مع رسائلك.',
        'ایک کاپی آپ کے خطوط کے ساتھ محفوظ ہو گئی ہے۔',
      );

  static String pdfSaved(String lang) => _s(
        lang,
        'PDF saved in Downloads.',
        'PDF in Downloads gespeichert.',
        'PDF په ډاونلوډونو کې خوندي شو.',
        'PDF در دانلودها ذخیره شد.',
        'تم حفظ PDF في التنزيلات.',
        'PDF ڈاؤن لوڈز میں محفوظ ہو گئی۔',
      );

  static String fillFirst(String lang) => _s(
        lang,
        'Please fill in the office, the company, the job and the start '
            'date first.',
        'Bitte füllen Sie zuerst Behörde, Firma, Stelle und Starttermin '
            'aus.',
        'مهرباني وکړئ لومړی دفتر، شرکت، دنده او د پیل نېټه ډک کړئ.',
        'لطفا ابتدا اداره، شرکت، شغل و تاریخ شروع را وارد کنید.',
        'يرجى ملء المكتب والشركة والوظيفة وتاريخ '
            'البدء أولا.',
        'براہ کرم پہلے دفتر، کمپنی، نوکری اور شروع کی تاریخ بھریں۔',
      );
}
