import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/services/work_permit_letter.dart';
import 'package:karyab/services/work_permit_pdf.dart';

WorkPermitData _base({bool isAusbildung = false, String phone = '', String email = ''}) {
  return WorkPermitData(
    senderName: 'Ahmad Ahmadi',
    senderStreet: 'Musterstraße 12',
    senderCity: '10115 Berlin',
    dateOfBirth: '03.04.1995',
    nationality: 'Afghanistan',
    phone: phone,
    email: email,
    authorityName: 'Ausländerbehörde Berlin',
    authorityCity: 'Berlin',
    company: 'Beispiel GmbH',
    jobTitle: 'Lagerhelfer',
    isAusbildung: isAusbildung,
    startDate: '01.03.2027',
    today: '06.11.2026',
  );
}

void main() {
  group('work permit letter (Phase 8)', () {
    test('job letter carries subject, parties and request', () {
      final letter = buildWorkPermitLetter(_base());
      expect(letter, contains('Betreff: Antrag auf Erlaubnis zur Aufnahme '
          'einer Beschäftigung'));
      expect(letter, contains('Ahmad Ahmadi'));
      expect(letter, contains('Geburtsdatum: 03.04.1995'));
      expect(letter, contains('Staatsangehörigkeit: Afghanistan'));
      expect(letter, contains('Anschrift: Musterstraße 12, 10115 Berlin'));
      expect(letter, contains('Ausländerbehörde Berlin'));
      expect(letter, contains('Beispiel GmbH'));
      expect(letter, contains('01.03.2027'));
      expect(letter, contains('Lagerhelfer'));
      expect(letter, contains('Berlin, den 06.11.2026'));
      expect(letter, contains('Mit freundlichen Grüßen'));
      expect(letter.endsWith('Ahmad Ahmadi'), isTrue);
    });

    test('ausbildung variant switches subject and offer wording', () {
      final letter = buildWorkPermitLetter(_base(isAusbildung: true));
      expect(workPermitSubject(_base(isAusbildung: true)),
          'Antrag auf Erlaubnis zur Aufnahme einer Ausbildung');
      expect(letter, contains('Ausbildungsplatz als Lagerhelfer'));
      expect(letter, isNot(contains('Stellenangebot')));
    });

    test('missing phone and email leave no empty lines or placeholders', () {
      final letter = buildWorkPermitLetter(_base());
      expect(letter, isNot(contains('Telefon:')));
      expect(letter, isNot(contains('E-Mail:')));
      expect(letter, isNot(contains('null')));
      expect(letter, isNot(contains('{')));
      for (final line in letter.split('\n')) {
        // Optional contact rows are omitted entirely, never left as a
        // bare label. ('Zu meiner Person:' is a real section heading
        // followed by rows, so it is allowed.)
        expect(line.trim(), isNot('Telefon:'), reason: line);
        expect(line.trim(), isNot('E-Mail:'), reason: line);
        expect(line.trim(), isNot('Geburtsdatum:'), reason: line);
      }
    });

    test('phone and email appear when present', () {
      final letter =
          buildWorkPermitLetter(_base(phone: '0151 234', email: 'a@b.de'));
      expect(letter, contains('Telefon: 0151 234'));
      expect(letter, contains('E-Mail: a@b.de'));
    });

    test('no em-dash anywhere in letter or explanations', () {
      const emDash = '\u2014';
      expect(buildWorkPermitLetter(_base()), isNot(contains(emDash)));
      for (final lang in ['de', 'en', 'ps', 'fa']) {
        expect(workPermitExplanation(lang, _base()),
            isNot(contains(emDash)), reason: lang);
      }
    });

    test('explanations name the office, company and decision caveat', () {
      for (final lang in ['de', 'en', 'ps', 'fa']) {
        final text = workPermitExplanation(lang, _base());
        expect(text, contains('Ausländerbehörde Berlin'), reason: lang);
        expect(text, contains('Beispiel GmbH'), reason: lang);
        expect(text, contains('01.03.2027'), reason: lang);
        expect(text.length, greaterThan(100), reason: lang);
      }
    });

    test('payload marks the document kind for the letter library', () {
      final payload = _base().toPayload();
      expect(payload['docKind'], 'work_permit');
      expect(payload['company'], 'Beispiel GmbH');
      expect(payload['isAusbildung'], false);
    });

    test('date and place helpers', () {
      expect(formatGermanDate(DateTime(2026, 1, 5)), '05.01.2026');
      expect(workPermitPlaceName('10115 Berlin'), 'Berlin');
      expect(workPermitPlaceName('Berlin'), 'Berlin');
    });

    test('pdf file name is safe and derived from the sender', () {
      expect(workPermitPdfFileName('Ahmad Ahmadi'),
          'Arbeitserlaubnis_Ahmad_Ahmadi.pdf');
      expect(workPermitPdfFileName(''), 'Arbeitserlaubnis.pdf');
    });
  });
}
