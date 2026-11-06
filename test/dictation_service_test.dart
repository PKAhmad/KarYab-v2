import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/services/dictation_service.dart';
import 'package:karyab/services/dictation_strings.dart';
import 'package:karyab/ui/karyab_ui.dart';

class _FakeBackend implements DictationBackend {
  _FakeBackend({this.canInit = true, this.locales = const []});

  final bool canInit;
  final List<String> locales;
  String? listenedLocale;
  DictationResultCallback? _onResult;

  @override
  Future<bool> initialize() async => canInit;

  @override
  Future<List<String>> availableLocales() async => locales;

  @override
  Future<void> listen({
    required String localeId,
    required DictationResultCallback onResult,
  }) async {
    listenedLocale = localeId;
    _onResult = onResult;
  }

  void emit(String words, bool isFinal) => _onResult?.call(words, isFinal);

  @override
  Future<void> stop() async {}

  @override
  bool get isListening => listenedLocale != null;
}

void main() {
  group('DictationService locale matching (Phase 8)', () {
    test('matches by language subtag, both separators', () {
      expect(
        DictationService.matchLocale('de', ['en_US', 'de_DE']),
        'de_DE',
      );
      expect(
        DictationService.matchLocale('fa', ['fa-IR']),
        'fa-IR',
      );
      expect(
        DictationService.matchLocale('ps', ['ps_AF', 'en_US']),
        'ps_AF',
      );
    });

    test('returns null when the phone does not offer the language', () {
      // The common Pashto case on stock Android phones.
      expect(DictationService.matchLocale('ps', ['de_DE', 'en_US']), isNull);
      expect(DictationService.matchLocale('ps', const []), isNull);
      expect(DictationService.matchLocale('', ['de_DE']), isNull);
    });
  });

  group('DictationService.start', () {
    test('false when the recognizer cannot initialize', () async {
      final service = DictationService(_FakeBackend(canInit: false));
      final ok = await service.start(languageCode: 'de', onResult: (_, __) {});
      expect(ok, isFalse);
    });

    test('false when the language is not offered (graceful absence)',
        () async {
      final service =
          DictationService(_FakeBackend(locales: ['de_DE', 'en_US']));
      final ok = await service.start(languageCode: 'ps', onResult: (_, __) {});
      expect(ok, isFalse);
    });

    test('true and forwards results when the language is offered', () async {
      final backend = _FakeBackend(locales: ['fa_IR']);
      final service = DictationService(backend);
      final heard = <String>[];
      final ok = await service.start(
        languageCode: 'fa',
        onResult: (words, isFinal) => heard.add(words),
      );
      expect(ok, isTrue);
      expect(backend.listenedLocale, 'fa_IR');
      backend.emit('سلام دنیا', true);
      expect(heard, ['سلام دنیا']);
    });

    test('backend exceptions fold into false, never throw', () async {
      final service = DictationService(_ThrowingBackend());
      final ok = await service.start(languageCode: 'de', onResult: (_, __) {});
      expect(ok, isFalse);
    });
  });

  group('KDictationButton', () {
    testWidgets('unavailable dictation shows the localized message',
        (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KDictationButton(
              controller: controller,
              service: DictationService.unavailable(),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(KDictationButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // No LanguageProvider in this test tree, so the fallback is German.
      expect(find.text(DictationStrings.notAvailable('de')), findsOneWidget);
      expect(controller.text, isEmpty);
    });

    testWidgets('dictated words land in the field, appended to existing text',
        (tester) async {
      final backend = _FakeBackend(locales: ['de_DE']);
      final controller = TextEditingController(text: 'Hallo');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KDictationButton(
              controller: controller,
              service: DictationService(backend),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(KDictationButton));
      await tester.pump();
      expect(backend.listenedLocale, 'de_DE');
      backend.emit('Welt', false);
      expect(controller.text, 'Hallo Welt');
      backend.emit('Welt und mehr', true);
      expect(controller.text, 'Hallo Welt und mehr');
    });
  });
}

class _ThrowingBackend implements DictationBackend {
  @override
  Future<bool> initialize() async => throw StateError('no recognizer');

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
