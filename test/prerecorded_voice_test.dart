import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/services/prerecorded_voice.dart';

// Phase 14 pilot: every manifest entry must have its compressed clip
// bundled, and the (language + exact text) lookup must hit only for the
// recorded texts in ps/fa/ar.
void main() {
  group('prerecorded voice assets', () {
    test('manifest covers pilot 11 per language + full Pashto pack', () {
      expect(kPrerecordedVoice.keys, containsAll(<String>['ps', 'fa', 'ar']));
      // Pilot: 11 clips in each of ps/fa/ar. Full pack: +224 Pashto
      // clips (workspace/karyab/voice/full/ps-list.json).
      expect(kPrerecordedVoice['ps']!.length, 235,
          reason: 'ps should have 11 pilot + 224 full-pack clips');
      expect(kPrerecordedVoice['fa']!.length, 11,
          reason: 'fa should have 11 clips');
      expect(kPrerecordedVoice['ar']!.length, 11,
          reason: 'ar should have 11 clips');
      var total = 0;
      kPrerecordedVoice.forEach((lang, byText) {
        total += byText.length;
      });
      expect(total, 257);
    });

    test('every entry has its asset file present and larger than 1 KB', () {
      kPrerecordedVoice.forEach((lang, byText) {
        byText.forEach((text, asset) {
          final file = File('assets/$asset');
          expect(file.existsSync(), isTrue,
              reason: 'missing asset for $lang "$text": $asset');
          expect(file.lengthSync(), greaterThan(1024),
              reason: 'asset suspiciously small for $lang "$text": $asset');
        });
      });
    });

    test('every asset path follows assets/audio/<lang>/<key>.mp3', () {
      kPrerecordedVoice.forEach((lang, byText) {
        for (final asset in byText.values) {
          expect(asset, startsWith('audio/$lang/'));
          expect(asset, endsWith('.mp3'));
        }
      });
    });
  });

  group('prerecordedVoiceAsset lookup', () {
    test('hits for a known (language, exact text)', () {
      expect(
        prerecordedVoiceAsset('ps', 'ایا تاسو لوستل او لیکل کولی شئ؟'),
        'audio/ps/question.mp3',
      );
      expect(
        prerecordedVoiceAsset('fa', 'آیا می‌توانید بخوانید و بنویسید؟'),
        'audio/fa/question.mp3',
      );
      expect(
        prerecordedVoiceAsset('ar', 'هل تستطيع القراءة والكتابة؟'),
        'audio/ar/question.mp3',
      );
    });

    test('hits for full-pack Pashto texts (permissions, questionnaire, '
        'guides)', () {
      expect(
        prerecordedVoiceAsset('ps', 'دا تڼۍ کیمرې ته اجازه ورکوي'),
        'audio/ps/ps_permissions_camera.mp3',
      );
      expect(
        prerecordedVoiceAsset('ps', 'تاسو کوم مهارتونه لری؟'),
        'audio/ps/ps_questionnaire_q8_skills.mp3',
      );
      expect(
        prerecordedVoiceAsset('ps', "McDonald's"),
        'audio/ps/ps_questionnaire_employer_mcdonald_s.mp3',
      );
      expect(
        prerecordedVoiceAsset(
            'ps',
            'دا لارښودونه تاسو ته رسمي لار ښيي، ګام پر ګام. یو ګام پس له '
            'بله وکړئ، او کله چې یو ګام خلاص کړئ نو نښه یې کړئ. تاسو هر '
            'ګام اورېدلی شئ.'),
        'audio/ps/ps_guides_intro.mp3',
      );
    });

    test('hits despite surrounding whitespace (lookup trims)', () {
      expect(
        prerecordedVoiceAsset('ps', '  ایا تاسو لوستل او لیکل کولی شئ؟ \n'),
        'audio/ps/question.mp3',
      );
    });

    test('misses for a modified text', () {
      expect(
        prerecordedVoiceAsset('ps', 'ایا تاسو لوستل او لیکل کولی شئ'),
        isNull,
      );
      expect(
        prerecordedVoiceAsset('fa', 'آیا می‌توانید بخوانید و بنویسید'),
        isNull,
      );
      expect(prerecordedVoiceAsset('ps', ''), isNull);
    });

    test('misses for the right text in the wrong language', () {
      expect(
        prerecordedVoiceAsset('fa', 'ایا تاسو لوستل او لیکل کولی شئ؟'),
        isNull,
      );
    });

    test('misses for de and en (no pre-generated clips)', () {
      expect(
        prerecordedVoiceAsset('de', 'ایا تاسو لوستل او لیکل کولی شئ؟'),
        isNull,
      );
      expect(
        prerecordedVoiceAsset('en', 'Can you read and write?'),
        isNull,
      );
    });
  });
}
