import 'package:speech_to_text/speech_to_text.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DictationService (Phase 8, blueprint §2.1) - voice input for free-text
// fields, behind an injectable backend in the AuthService style, so the
// UI kit component and tests never touch the platform plugin directly.
//
// Language support is whatever the PHONE offers: the backend asks the
// platform recognizer for its locales and matches the app language
// (ps / fa / de / en). Pashto is missing on most phones; in that case
// [start] returns false and the caller shows the localized "dictation
// not available for this language on this phone" message. Every platform
// failure is folded into that same graceful answer, never an exception.
// ─────────────────────────────────────────────────────────────────────────────

typedef DictationResultCallback = void Function(String words, bool isFinal);

abstract class DictationBackend {
  /// True when a speech recognizer exists and permission was granted.
  Future<bool> initialize();

  /// Locale ids the recognizer offers, e.g. ['de_DE', 'en_US', 'fa_IR'].
  Future<List<String>> availableLocales();

  Future<void> listen({
    required String localeId,
    required DictationResultCallback onResult,
  });

  Future<void> stop();

  bool get isListening;
}

class SpeechToTextBackend implements DictationBackend {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  @override
  Future<List<String>> availableLocales() async {
    final locales = await _speech.locales();
    return [for (final l in locales) l.localeId];
  }

  @override
  Future<void> listen({
    required String localeId,
    required DictationResultCallback onResult,
  }) {
    return _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (result) =>
          onResult(result.recognizedWords, result.finalResult),
    );
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  bool get isListening => _speech.isListening;
}

/// A backend that never recognizes anything. Used when the speech
/// plugin is absent (documented fallback) and in widget tests that
/// exercise the unavailable path.
class UnavailableDictationBackend implements DictationBackend {
  @override
  Future<bool> initialize() async => false;

  @override
  Future<List<String>> availableLocales() async => const [];

  @override
  Future<void> listen({
    required String localeId,
    required DictationResultCallback onResult,
  }) async {}

  @override
  Future<void> stop() async {}

  @override
  bool get isListening => false;
}

class DictationService {
  final DictationBackend _backend;

  DictationService([DictationBackend? backend])
      : _backend = backend ?? SpeechToTextBackend();

  /// Service whose recognizer is permanently absent (graceful absence).
  factory DictationService.unavailable() =>
      DictationService(UnavailableDictationBackend());

  static final DictationService instance = DictationService();

  bool get isListening => _backend.isListening;

  /// The recognizer locale id for [languageCode] ('ps', 'fa', 'de',
  /// 'en'), or null when the phone cannot recognize that language.
  /// Pure matching rule, split out so tests can pin it: the first
  /// offered locale whose language subtag equals the requested code.
  static String? matchLocale(String languageCode, List<String> offered) {
    final wanted = languageCode.trim().toLowerCase();
    if (wanted.isEmpty) return null;
    for (final id in offered) {
      final subtag = id.toLowerCase().split(RegExp('[_-]')).first;
      if (subtag == wanted) return id;
    }
    return null;
  }

  /// Starts dictation in [languageCode]. Returns false when dictation
  /// is unavailable (no recognizer, permission denied, or the language
  /// is not offered on this phone); the caller then shows the localized
  /// not-available message. Never throws.
  Future<bool> start({
    required String languageCode,
    required DictationResultCallback onResult,
  }) async {
    try {
      if (!await _backend.initialize()) return false;
      final locale =
          matchLocale(languageCode, await _backend.availableLocales());
      if (locale == null) return false;
      await _backend.listen(localeId: locale, onResult: onResult);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _backend.stop();
    } catch (_) {
      // Stopping must never surface an error to the user.
    }
  }
}
