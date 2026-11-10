// ─────────────────────────────────────────────────────────────────────────────
// DictationStrings - Phase 8 strings for voice dictation, in the app's 4
// languages, following the JobsStrings / AccountStrings pattern (German
// fallback). Transcribed in the Phase 8 report for the CEO's proofread.
// ─────────────────────────────────────────────────────────────────────────────

class DictationStrings {
  const DictationStrings._();

  static String _s(String lang, String en, String de, String ps, String fa, String ar) {
    switch (lang) {
      case 'en':
        return en;
      case 'ps':
        return ps;
      case 'fa':
        return fa;
      case 'ar':
        return ar;
      case 'de':
      default:
        return de;
    }
  }

  /// Shown when the phone cannot recognize speech in the app language.
  /// This is a normal situation, especially for Pashto: many phones only
  /// carry a few recognition languages. Never an error, never a crash.
  static String notAvailable(String lang) => _s(
        lang,
        'Dictation is not available for this language on this phone. '
            'Please type instead.',
        'Diktieren ist auf diesem Telefon für diese Sprache nicht '
            'verfügbar. Bitte tippen Sie den Text ein.',
        'په دې ټېلېفون کې په دې ژبه د غږ لیکل شتون نه لري. مهرباني '
            'وکړئ متن ولیکئ.',
        'در این تلفن، گفتار به این زبان در دسترس نیست. لطفا متن را '
            'تایپ کنید.',
        'الإملاء الصوتي غير متاح لهذه اللغة على هذا '
            'الهاتف. يرجى الكتابة بدلا من ذلك.',
      );

  /// Tooltip / accessibility label for the microphone button.
  static String dictate(String lang) => _s(
        lang,
        'Dictate',
        'Diktieren',
        'په غږ ولیکئ',
        'با صدا بنویسید',
        'الكتابة بالصوت',
      );
}
