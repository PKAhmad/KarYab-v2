// ─────────────────────────────────────────────────────────────────────────────
// AccountStrings - Phase 6 UI strings (login + account screens).
//
// Same localisation pattern as the rest of the app: a static lookup with
// en/de/ps/fa; German is an explicit case here (accounts are a trust
// surface, German users should not fall back to English). New Pashto /
// Dari strings are transcribed in the Phase 6 report for CEO proofread.
// No em-dashes anywhere, per the app rules.
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AccountStrings {
  static String _s(
    String lang, {
    required String en,
    required String de,
    required String ps,
    required String fa,
    required String ar,
    required String ur,
  }) {
    switch (lang) {
      case 'de':
        return de;
      case 'ps':
        return ps;
      case 'fa':
        return fa;
      case 'ar':
        return ar;
      case 'ur':
        return ur;
      default:
        return en;
    }
  }

  static String account(String l) => _s(l,
      en: 'Account',
      de: 'Konto',
      ps: 'حساب',
      fa: 'حساب',
      ar: 'حساب',
      ur: 'اکاؤنٹ');

  static String signIn(String l) => _s(l,
      en: 'Sign in',
      de: 'Anmelden',
      ps: 'ننوتل',
      fa: 'ورود',
      ar: 'تسجيل الدخول',
      ur: 'سائن ان کریں');

  static String createAccount(String l) => _s(l,
      en: 'Create account',
      de: 'Konto erstellen',
      ps: 'حساب جوړ کړئ',
      fa: 'ساختن حساب',
      ar: 'إنشاء حساب',
      ur: 'اکاؤنٹ بنائیں');

  static String continueWithGoogle(String l) => _s(l,
      en: 'Continue with Google',
      de: 'Mit Google fortfahren',
      ps: 'د Google سره دوام ورکړئ',
      fa: 'ادامه با Google',
      ar: 'المتابعة مع Google',
      ur: 'Google کے ساتھ جاری رکھیں');

  static String continueWithoutAccount(String l) => _s(l,
      en: 'Continue without account',
      de: 'Ohne Konto fortfahren',
      ps: 'بې حسابه دوام ورکړئ',
      fa: 'ادامه بدون حساب',
      ar: 'المتابعة بدون حساب',
      ur: 'اکاؤنٹ کے بغیر جاری رکھیں');

  static String email(String l) => _s(l,
      en: 'Email',
      de: 'E-Mail',
      ps: 'برېښنالیک',
      fa: 'ایمیل',
      ar: 'البريد الإلكتروني',
      ur: 'ای میل');

  static String password(String l) => _s(l,
      en: 'Password',
      de: 'Passwort',
      ps: 'پټنوم',
      fa: 'رمز عبور',
      ar: 'كلمة المرور',
      ur: 'پاس ورڈ');

  static String forgotPassword(String l) => _s(l,
      en: 'Forgot password?',
      de: 'Passwort vergessen?',
      ps: 'پټنوم مو هېر شوی؟',
      fa: 'رمز عبور را فراموش کرده‌اید؟',
      ar: 'هل نسيت كلمة المرور؟',
      ur: 'پاس ورڈ بھول گئے؟');

  static String passwordResetSent(String l) => _s(l,
      en: 'We sent you an email to reset your password.',
      de: 'Wir haben dir eine E-Mail zum Zurücksetzen des Passworts geschickt.',
      ps: 'موږ تاسو ته د پټنوم بدلولو لپاره برېښنالیک واستاوه.',
      fa: 'برای تغییر رمز عبور به شما ایمیل فرستادیم.',
      ar: 'أرسلنا لك بريدا إلكترونيا لتغيير كلمة المرور.',
      ur: 'ہم نے آپ کو پاس ورڈ بدلنے کے لیے ای میل بھیجی ہے۔');

  static String orWithEmail(String l) => _s(l,
      en: 'or with email',
      de: 'oder mit E-Mail',
      ps: 'یا په برېښنالیک',
      fa: 'یا با ایمیل',
      ar: 'أو بالبريد الإلكتروني',
      ur: 'یا ای میل کے ساتھ');

  static String loginBenefit(String l) => _s(l,
      en: 'Save your CV online so you do not lose it when you change phones.',
      de: 'Speichere deinen Lebenslauf online, damit du ihn beim Handywechsel nicht verlierst.',
      ps: 'خپل CV آنلاین خوندي کړئ، تر څو د ټېلېفون بدلولو پر مهال یې له لاسه ورنه کړئ.',
      fa: 'CV خود را آنلاین ذخیره کنید تا هنگام تعویض تلفن آن را از دست ندهید.',
      ar: 'احفظ سيرتك الذاتية (CV) على الإنترنت حتى لا تفقدها عند تغيير الهاتف.',
      ur: 'اپنا CV آن لائن محفوظ کریں تاکہ فون بدلنے پر وہ ضائع نہ ہو۔');

  static String noAccountNeeded(String l) => _s(l,
      en: 'You do not need an account to use KarYab. Everything works without signing in.',
      de: 'Du brauchst kein Konto, um KarYab zu nutzen. Alles funktioniert auch ohne Anmeldung.',
      ps: 'د KarYab کارولو لپاره حساب ته اړتیا نشته. هر څه بې ننوتلو کار کوي.',
      fa: 'برای استفاده از KarYab به حساب نیاز ندارید. همه چیز بدون ورود کار می‌کند.',
      ar: 'لا تحتاج إلى حساب لاستخدام KarYab. كل شيء يعمل بدون تسجيل الدخول.',
      ur: 'KarYab استعمال کرنے کے لیے اکاؤنٹ کی ضرورت نہیں ہے۔ سائن ان کیے بغیر سب کچھ چلتا ہے۔');

  static String signOut(String l) => _s(l,
      en: 'Sign out',
      de: 'Abmelden',
      ps: 'وتل',
      fa: 'خروج',
      ar: 'تسجيل الخروج',
      ur: 'سائن آؤٹ کریں');

  static String downloadMyData(String l) => _s(l,
      en: 'Download my data',
      de: 'Meine Daten herunterladen',
      ps: 'زما ډاټا ډاونلوډ کړئ',
      fa: 'دانلود داده‌های من',
      ar: 'تنزيل بياناتي',
      ur: 'میرا ڈیٹا ڈاؤن لوڈ کریں');

  static String deleteAccount(String l) => _s(l,
      en: 'Delete my account',
      de: 'Mein Konto löschen',
      ps: 'زما حساب ړنګ کړئ',
      fa: 'حذف حساب من',
      ar: 'حذف حسابي',
      ur: 'میرا اکاؤنٹ حذف کریں');

  static String deleteAccountBody(String l) => _s(l,
      en: 'This deletes your account and your cloud backup. Your CVs and letters on this phone stay, unless you delete them in the app.',
      de: 'Damit werden dein Konto und deine Cloud-Sicherung gelöscht. Deine Lebensläufe und Briefe auf diesem Handy bleiben, außer du löschst sie in der App.',
      ps: 'دا ستاسو حساب او کلاوډ بیک اپ ړنګوي. ستاسو سیوي او لیکونه په دې ټېلېفون کې پاتې کیږي، تر څو یې په اپ کې ړنګ نه کړئ.',
      fa: 'این کار حساب و نسخه پشتیبان ابری شما را حذف می‌کند. CV و نامه‌های شما در این تلفن باقی می‌مانند، مگر اینکه در برنامه حذفشان کنید.',
      ar: 'هذا يحذف حسابك ونسختك الاحتياطية في السحابة. يبقى CV ورسائلك على هذا الهاتف، إلا إذا حذفتها في التطبيق.',
      ur: 'اس سے آپ کا اکاؤنٹ اور آپ کا کلاؤڈ بیک اپ حذف ہو جائے گا۔ اس فون پر آپ کے CV اور خطوط باقی رہیں گے، جب تک آپ انہیں ایپ میں حذف نہ کریں۔');

  static String enterPasswordConfirm(String l) => _s(l,
      en: 'Please enter your password to confirm.',
      de: 'Bitte gib dein Passwort zur Bestätigung ein.',
      ps: 'مهرباني وکړئ د تصدیق لپاره پټنوم ولیکئ.',
      fa: 'لطفا برای تأیید رمز عبور را وارد کنید.',
      ar: 'يرجى إدخال كلمة المرور للتأكيد.',
      ur: 'براہ کرم تصدیق کے لیے اپنا پاس ورڈ لکھیں۔');

  static String accountDeleted(String l) => _s(l,
      en: 'Your account was deleted.',
      de: 'Dein Konto wurde gelöscht.',
      ps: 'ستاسو حساب ړنګ شو.',
      fa: 'حساب شما حذف شد.',
      ar: 'تم حذف حسابك.',
      ur: 'آپ کا اکاؤنٹ حذف ہو گیا ہے۔');

  static String cloudBackup(String l) => _s(l,
      en: 'Cloud backup',
      de: 'Cloud-Sicherung',
      ps: 'کلاوډ بیک اپ',
      fa: 'پشتیبان ابری',
      ar: 'النسخة الاحتياطية السحابية',
      ur: 'کلاؤڈ بیک اپ');

  static String backupConsent(String l) => _s(l,
      en: 'If you turn this on, your profile, CVs and letters are saved in your private cloud backup, so you can restore them on a new phone. Files like photos and certificates are not uploaded. You can turn this off and delete the backup at any time.',
      de: 'Wenn du das einschaltest, werden dein Profil, deine Lebensläufe und Briefe in deiner privaten Cloud-Sicherung gespeichert, damit du sie auf einem neuen Handy wiederherstellen kannst. Dateien wie Fotos und Zeugnisse werden nicht hochgeladen. Du kannst das jederzeit ausschalten und die Sicherung löschen.',
      ps: 'که دا چالان کړئ، ستاسو پروفایل، سیوي او لیکونه ستاسو په خصوصي کلاوډ بیک اپ کې خوندي کیږي، تر څو یې په نوي ټېلېفون کې بیرته ترلاسه کړئ. فایلونه لکه عکسونه او سندونه نه اپلوډ کیږي. تاسو هر وخت دا بندولی او بیک اپ ړنګولی شئ.',
      fa: 'اگر این را روشن کنید، پروفایل، CVها و نامه‌های شما در پشتیبان ابری خصوصی شما ذخیره می‌شود تا در تلفن جدید بازیابی کنید. فایل‌هایی مانند عکس‌ها و مدارک بارگذاری نمی‌شوند. هر وقت می‌توانید آن را خاموش و پشتیبان را حذف کنید.',
      ar: 'إذا فعلت هذا، يتم حفظ ملفك وسيرك الذاتية ورسائلك في نسختك الاحتياطية السحابية الخاصة، حتى تتمكن من استعادتها على هاتف جديد. لا يتم رفع ملفات مثل الصور والشهادات. يمكنك إيقاف هذا وحذف النسخة الاحتياطية في أي وقت.',
      ur: 'اگر آپ اسے آن کریں تو آپ کا پروفائل، آپ کے CV اور خطوط آپ کے نجی کلاؤڈ بیک اپ میں محفوظ ہو جائیں گے، تاکہ آپ انہیں نئے فون پر واپس حاصل کر سکیں۔ تصاویر اور سرٹیفکیٹ جیسی فائلیں اپ لوڈ نہیں ہوتیں۔ آپ اسے کسی بھی وقت بند کر سکتے ہیں اور بیک اپ حذف کر سکتے ہیں۔');

  static String backupNow(String l) => _s(l,
      en: 'Back up now',
      de: 'Jetzt sichern',
      ps: 'اوس بیک اپ کړئ',
      fa: 'حالا پشتیبان بگیرید',
      ar: 'قم بالنسخ الاحتياطي الآن',
      ur: 'ابھی بیک اپ کریں');

  static String lastBackup(String l) => _s(l,
      en: 'Last backup',
      de: 'Letzte Sicherung',
      ps: 'وروستی بیک اپ',
      fa: 'آخرین پشتیبان',
      ar: 'آخر نسخة احتياطية',
      ur: 'آخری بیک اپ');

  static String never(String l) => _s(l,
      en: 'never',
      de: 'noch nie',
      ps: 'هیڅکله',
      fa: 'هرگز',
      ar: 'أبدا',
      ur: 'کبھی نہیں');

  static String backupDone(String l) => _s(l,
      en: 'Backup saved.',
      de: 'Sicherung gespeichert.',
      ps: 'بیک اپ خوندي شو.',
      fa: 'پشتیبان ذخیره شد.',
      ar: 'تم حفظ النسخة الاحتياطية.',
      ur: 'بیک اپ محفوظ ہو گیا۔');

  static String backupFailed(String l) => _s(l,
      en: 'That did not work. Please check your connection and try again.',
      de: 'Das hat nicht funktioniert. Bitte prüfe deine Verbindung und versuche es erneut.',
      ps: 'دا کار ونه شو. خپل اتصال وګورئ او بیا هڅه وکړئ.',
      fa: 'این کار انجام نشد. اتصال خود را بررسی کنید و دوباره تلاش کنید.',
      ar: 'لم ينجح ذلك. يرجى التحقق من اتصالك والمحاولة مرة أخرى.',
      ur: 'یہ کام نہیں ہوا۔ براہ کرم اپنا کنکشن دیکھیں اور دوبارہ کوشش کریں۔');

  static String restore(String l) => _s(l,
      en: 'Restore from backup',
      de: 'Aus Sicherung wiederherstellen',
      ps: 'له بیک اپه بیرته راولئ',
      fa: 'بازیابی از پشتیبان',
      ar: 'الاستعادة من النسخة الاحتياطية',
      ur: 'بیک اپ سے واپس حاصل کریں');

  static String restoreFoundTitle(String l) => _s(l,
      en: 'Backup found',
      de: 'Sicherung gefunden',
      ps: 'بیک اپ وموندل شو',
      fa: 'پشتیبان پیدا شد',
      ar: 'تم العثور على نسخة احتياطية',
      ur: 'بیک اپ مل گیا');

  static String restoreFoundBody(String l, String date) => _s(l,
      en: 'There is a cloud backup from $date. Do you want to restore it? Your data on this phone will not be deleted.',
      de: 'Es gibt eine Cloud-Sicherung vom $date. Möchtest du sie wiederherstellen? Deine Daten auf diesem Handy werden nicht gelöscht.',
      ps: 'د $date کلاوډ بیک اپ شته. غواړئ بیرته یې راولئ؟ ستاسو ډاټا په دې ټېلېفون کې نه ړنګیږي.',
      fa: 'یک پشتیبان ابری از $date وجود دارد. می‌خواهید آن را بازیابی کنید؟ داده‌های شما در این تلفن حذف نمی‌شود.',
      ar: 'توجد نسخة احتياطية سحابية من $date. هل تريد استعادتها؟ لن يتم حذف بياناتك على هذا الهاتف.',
      ur: '$date کا ایک کلاؤڈ بیک اپ موجود ہے۔ کیا آپ اسے واپس حاصل کرنا چاہتے ہیں؟ اس فون پر آپ کا ڈیٹا حذف نہیں ہوگا۔');

  static String restoreDone(String l) => _s(l,
      en: 'Backup restored.',
      de: 'Sicherung wiederhergestellt.',
      ps: 'بیک اپ بیرته راوړل شو.',
      fa: 'پشتیبان بازیابی شد.',
      ar: 'تمت استعادة النسخة الاحتياطية.',
      ur: 'بیک اپ واپس حاصل ہو گیا۔');

  static String noBackupFound(String l) => _s(l,
      en: 'No cloud backup found.',
      de: 'Keine Cloud-Sicherung gefunden.',
      ps: 'کلاوډ بیک اپ ونه موندل شو.',
      fa: 'پشتیبان ابری پیدا نشد.',
      ar: 'لم يتم العثور على نسخة احتياطية سحابية.',
      ur: 'کوئی کلاؤڈ بیک اپ نہیں ملا۔');

  static String localNewer(String l) => _s(l,
      en: 'Your data on this phone is newer than the backup.',
      de: 'Deine Daten auf diesem Handy sind neuer als die Sicherung.',
      ps: 'ستاسو ډاټا په دې ټېلېفون کې تر بیک اپه نوې ده.',
      fa: 'داده‌های شما در این تلفن از نسخه پشتیبان جدیدتر است.',
      ar: 'بياناتك على هذا الهاتف أحدث من النسخة الاحتياطية.',
      ur: 'اس فون پر آپ کا ڈیٹا بیک اپ سے نیا ہے۔');

  static String turnOn(String l) => _s(l,
      en: 'Turn on',
      de: 'Einschalten',
      ps: 'چالان کړئ',
      fa: 'روشن کنید',
      ar: 'تشغيل',
      ur: 'آن کریں');

  static String privacyNote(String l) => _s(l,
      en: 'Your data stays on your phone. Only if you sign in and turn on cloud backup, a copy is saved in your private account.',
      de: 'Deine Daten bleiben auf deinem Handy. Nur wenn du dich anmeldest und die Cloud-Sicherung einschaltest, wird eine Kopie in deinem privaten Konto gespeichert.',
      ps: 'ستاسو ډاټا ستاسو په ټېلېفون کې پاتې کیږي. یوازې که ننوځئ او کلاوډ بیک اپ چالان کړئ، یوه کاپي ستاسو په خصوصي حساب کې خوندي کیږي.',
      fa: 'داده‌های شما در تلفن شما می‌ماند. فقط اگر وارد شوید و پشتیبان ابری را روشن کنید، یک نسخه در حساب خصوصی شما ذخیره می‌شود.',
      ar: 'تبقى بياناتك على هاتفك. فقط إذا سجلت الدخول وفعلت النسخ الاحتياطي السحابي، يتم حفظ نسخة في حسابك الخاص.',
      ur: 'آپ کا ڈیٹا آپ کے فون پر ہی رہتا ہے۔ صرف اس صورت میں ایک کاپی آپ کے نجی اکاؤنٹ میں محفوظ ہوتی ہے جب آپ سائن ان کریں اور کلاؤڈ بیک اپ آن کریں۔');

  static String cancel(String l) => _s(l,
      en: 'Cancel',
      de: 'Abbrechen',
      ps: 'لغوه',
      fa: 'لغو',
      ar: 'إلغاء',
      ur: 'منسوخ کریں');

  static String delete(String l) => _s(l,
      en: 'Delete',
      de: 'Löschen',
      ps: 'ړنګ کړئ',
      fa: 'حذف',
      ar: 'حذف',
      ur: 'حذف کریں');

  static String restoreAction(String l) => _s(l,
      en: 'Restore',
      de: 'Wiederherstellen',
      ps: 'بیرته راولئ',
      fa: 'بازیابی',
      ar: 'استعادة',
      ur: 'واپس حاصل کریں');

  static String notNow(String l) => _s(l,
      en: 'Not now',
      de: 'Nicht jetzt',
      ps: 'اوس نه',
      fa: 'حالا نه',
      ar: 'ليس الآن',
      ur: 'ابھی نہیں');
}
