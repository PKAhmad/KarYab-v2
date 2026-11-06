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
  }) {
    switch (lang) {
      case 'de':
        return de;
      case 'ps':
        return ps;
      case 'fa':
        return fa;
      default:
        return en;
    }
  }

  static String account(String l) => _s(l,
      en: 'Account',
      de: 'Konto',
      ps: 'حساب',
      fa: 'حساب');

  static String signIn(String l) => _s(l,
      en: 'Sign in',
      de: 'Anmelden',
      ps: 'ننوتل',
      fa: 'ورود');

  static String createAccount(String l) => _s(l,
      en: 'Create account',
      de: 'Konto erstellen',
      ps: 'حساب جوړ کړئ',
      fa: 'ساختن حساب');

  static String continueWithGoogle(String l) => _s(l,
      en: 'Continue with Google',
      de: 'Mit Google fortfahren',
      ps: 'د Google سره دوام ورکړئ',
      fa: 'ادامه با Google');

  static String continueWithoutAccount(String l) => _s(l,
      en: 'Continue without account',
      de: 'Ohne Konto fortfahren',
      ps: 'بې حسابه دوام ورکړئ',
      fa: 'ادامه بدون حساب');

  static String email(String l) => _s(l,
      en: 'Email',
      de: 'E-Mail',
      ps: 'برېښنالیک',
      fa: 'ایمیل');

  static String password(String l) => _s(l,
      en: 'Password',
      de: 'Passwort',
      ps: 'پټنوم',
      fa: 'رمز عبور');

  static String forgotPassword(String l) => _s(l,
      en: 'Forgot password?',
      de: 'Passwort vergessen?',
      ps: 'پټنوم مو هېر شوی؟',
      fa: 'رمز عبور را فراموش کرده‌اید؟');

  static String passwordResetSent(String l) => _s(l,
      en: 'We sent you an email to reset your password.',
      de: 'Wir haben dir eine E-Mail zum Zurücksetzen des Passworts geschickt.',
      ps: 'موږ تاسو ته د پټنوم بدلولو لپاره برېښنالیک واستاوه.',
      fa: 'برای تغییر رمز عبور به شما ایمیل فرستادیم.');

  static String orWithEmail(String l) => _s(l,
      en: 'or with email',
      de: 'oder mit E-Mail',
      ps: 'یا په برېښنالیک',
      fa: 'یا با ایمیل');

  static String loginBenefit(String l) => _s(l,
      en: 'Save your CV online so you do not lose it when you change phones.',
      de: 'Speichere deinen Lebenslauf online, damit du ihn beim Handywechsel nicht verlierst.',
      ps: 'خپل CV آنلاین خوندي کړئ، تر څو د ټېلېفون بدلولو پر مهال یې له لاسه ورنه کړئ.',
      fa: 'CV خود را آنلاین ذخیره کنید تا هنگام تعویض تلفن آن را از دست ندهید.');

  static String noAccountNeeded(String l) => _s(l,
      en: 'You do not need an account to use KarYab. Everything works without signing in.',
      de: 'Du brauchst kein Konto, um KarYab zu nutzen. Alles funktioniert auch ohne Anmeldung.',
      ps: 'د KarYab کارولو لپاره حساب ته اړتیا نشته. هر څه بې ننوتلو کار کوي.',
      fa: 'برای استفاده از KarYab به حساب نیاز ندارید. همه چیز بدون ورود کار می‌کند.');

  static String signOut(String l) => _s(l,
      en: 'Sign out',
      de: 'Abmelden',
      ps: 'وتل',
      fa: 'خروج');

  static String downloadMyData(String l) => _s(l,
      en: 'Download my data',
      de: 'Meine Daten herunterladen',
      ps: 'زما ډاټا ډاونلوډ کړئ',
      fa: 'دانلود داده‌های من');

  static String deleteAccount(String l) => _s(l,
      en: 'Delete my account',
      de: 'Mein Konto löschen',
      ps: 'زما حساب ړنګ کړئ',
      fa: 'حذف حساب من');

  static String deleteAccountBody(String l) => _s(l,
      en: 'This deletes your account and your cloud backup. Your CVs and letters on this phone stay, unless you delete them in the app.',
      de: 'Damit werden dein Konto und deine Cloud-Sicherung gelöscht. Deine Lebensläufe und Briefe auf diesem Handy bleiben, außer du löschst sie in der App.',
      ps: 'دا ستاسو حساب او کلاوډ بیک اپ ړنګوي. ستاسو سیوي او لیکونه په دې ټېلېفون کې پاتې کیږي، تر څو یې په اپ کې ړنګ نه کړئ.',
      fa: 'این کار حساب و نسخه پشتیبان ابری شما را حذف می‌کند. CV و نامه‌های شما در این تلفن باقی می‌مانند، مگر اینکه در برنامه حذفشان کنید.');

  static String enterPasswordConfirm(String l) => _s(l,
      en: 'Please enter your password to confirm.',
      de: 'Bitte gib dein Passwort zur Bestätigung ein.',
      ps: 'مهرباني وکړئ د تصدیق لپاره پټنوم ولیکئ.',
      fa: 'لطفا برای تأیید رمز عبور را وارد کنید.');

  static String accountDeleted(String l) => _s(l,
      en: 'Your account was deleted.',
      de: 'Dein Konto wurde gelöscht.',
      ps: 'ستاسو حساب ړنګ شو.',
      fa: 'حساب شما حذف شد.');

  static String cloudBackup(String l) => _s(l,
      en: 'Cloud backup',
      de: 'Cloud-Sicherung',
      ps: 'کلاوډ بیک اپ',
      fa: 'پشتیبان ابری');

  static String backupConsent(String l) => _s(l,
      en: 'If you turn this on, your profile, CVs and letters are saved in your private cloud backup, so you can restore them on a new phone. Files like photos and certificates are not uploaded. You can turn this off and delete the backup at any time.',
      de: 'Wenn du das einschaltest, werden dein Profil, deine Lebensläufe und Briefe in deiner privaten Cloud-Sicherung gespeichert, damit du sie auf einem neuen Handy wiederherstellen kannst. Dateien wie Fotos und Zeugnisse werden nicht hochgeladen. Du kannst das jederzeit ausschalten und die Sicherung löschen.',
      ps: 'که دا چالان کړئ، ستاسو پروفایل، سیوي او لیکونه ستاسو په خصوصي کلاوډ بیک اپ کې خوندي کیږي، تر څو یې په نوي ټېلېفون کې بیرته ترلاسه کړئ. فایلونه لکه عکسونه او سندونه نه اپلوډ کیږي. تاسو هر وخت دا بندولی او بیک اپ ړنګولی شئ.',
      fa: 'اگر این را روشن کنید، پروفایل، CVها و نامه‌های شما در پشتیبان ابری خصوصی شما ذخیره می‌شود تا در تلفن جدید بازیابی کنید. فایل‌هایی مانند عکس‌ها و مدارک بارگذاری نمی‌شوند. هر وقت می‌توانید آن را خاموش و پشتیبان را حذف کنید.');

  static String backupNow(String l) => _s(l,
      en: 'Back up now',
      de: 'Jetzt sichern',
      ps: 'اوس بیک اپ کړئ',
      fa: 'حالا پشتیبان بگیرید');

  static String lastBackup(String l) => _s(l,
      en: 'Last backup',
      de: 'Letzte Sicherung',
      ps: 'وروستی بیک اپ',
      fa: 'آخرین پشتیبان');

  static String never(String l) => _s(l,
      en: 'never',
      de: 'noch nie',
      ps: 'هیڅکله',
      fa: 'هرگز');

  static String backupDone(String l) => _s(l,
      en: 'Backup saved.',
      de: 'Sicherung gespeichert.',
      ps: 'بیک اپ خوندي شو.',
      fa: 'پشتیبان ذخیره شد.');

  static String backupFailed(String l) => _s(l,
      en: 'That did not work. Please check your connection and try again.',
      de: 'Das hat nicht funktioniert. Bitte prüfe deine Verbindung und versuche es erneut.',
      ps: 'دا کار ونه شو. خپل اتصال وګورئ او بیا هڅه وکړئ.',
      fa: 'این کار انجام نشد. اتصال خود را بررسی کنید و دوباره تلاش کنید.');

  static String restore(String l) => _s(l,
      en: 'Restore from backup',
      de: 'Aus Sicherung wiederherstellen',
      ps: 'له بیک اپه بیرته راولئ',
      fa: 'بازیابی از پشتیبان');

  static String restoreFoundTitle(String l) => _s(l,
      en: 'Backup found',
      de: 'Sicherung gefunden',
      ps: 'بیک اپ وموندل شو',
      fa: 'پشتیبان پیدا شد');

  static String restoreFoundBody(String l, String date) => _s(l,
      en: 'There is a cloud backup from $date. Do you want to restore it? Your data on this phone will not be deleted.',
      de: 'Es gibt eine Cloud-Sicherung vom $date. Möchtest du sie wiederherstellen? Deine Daten auf diesem Handy werden nicht gelöscht.',
      ps: 'د $date کلاوډ بیک اپ شته. غواړئ بیرته یې راولئ؟ ستاسو ډاټا په دې ټېلېفون کې نه ړنګیږي.',
      fa: 'یک پشتیبان ابری از $date وجود دارد. می‌خواهید آن را بازیابی کنید؟ داده‌های شما در این تلفن حذف نمی‌شود.');

  static String restoreDone(String l) => _s(l,
      en: 'Backup restored.',
      de: 'Sicherung wiederhergestellt.',
      ps: 'بیک اپ بیرته راوړل شو.',
      fa: 'پشتیبان بازیابی شد.');

  static String noBackupFound(String l) => _s(l,
      en: 'No cloud backup found.',
      de: 'Keine Cloud-Sicherung gefunden.',
      ps: 'کلاوډ بیک اپ ونه موندل شو.',
      fa: 'پشتیبان ابری پیدا نشد.');

  static String localNewer(String l) => _s(l,
      en: 'Your data on this phone is newer than the backup.',
      de: 'Deine Daten auf diesem Handy sind neuer als die Sicherung.',
      ps: 'ستاسو ډاټا په دې ټېلېفون کې تر بیک اپه نوې ده.',
      fa: 'داده‌های شما در این تلفن از نسخه پشتیبان جدیدتر است.');

  static String turnOn(String l) => _s(l,
      en: 'Turn on',
      de: 'Einschalten',
      ps: 'چالان کړئ',
      fa: 'روشن کنید');

  static String privacyNote(String l) => _s(l,
      en: 'Your data stays on your phone. Only if you sign in and turn on cloud backup, a copy is saved in your private account.',
      de: 'Deine Daten bleiben auf deinem Handy. Nur wenn du dich anmeldest und die Cloud-Sicherung einschaltest, wird eine Kopie in deinem privaten Konto gespeichert.',
      ps: 'ستاسو ډاټا ستاسو په ټېلېفون کې پاتې کیږي. یوازې که ننوځئ او کلاوډ بیک اپ چالان کړئ، یوه کاپي ستاسو په خصوصي حساب کې خوندي کیږي.',
      fa: 'داده‌های شما در تلفن شما می‌ماند. فقط اگر وارد شوید و پشتیبان ابری را روشن کنید، یک نسخه در حساب خصوصی شما ذخیره می‌شود.');

  static String cancel(String l) => _s(l,
      en: 'Cancel',
      de: 'Abbrechen',
      ps: 'لغوه',
      fa: 'لغو');

  static String delete(String l) => _s(l,
      en: 'Delete',
      de: 'Löschen',
      ps: 'ړنګ کړئ',
      fa: 'حذف');

  static String restoreAction(String l) => _s(l,
      en: 'Restore',
      de: 'Wiederherstellen',
      ps: 'بیرته راولئ',
      fa: 'بازیابی');

  static String notNow(String l) => _s(l,
      en: 'Not now',
      de: 'Nicht jetzt',
      ps: 'اوس نه',
      fa: 'حالا نه');
}
