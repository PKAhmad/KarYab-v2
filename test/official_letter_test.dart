import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/services/official_letter.dart';

OfficialLetterData _base({
  OfficialPurpose purpose = OfficialPurpose.integrationCourse,
  String phone = '',
  String email = '',
  String dateOfBirth = '03.04.1995',
  String officeStreet = 'Friedrichstraße 219',
  String officeCity = '10969 Berlin',
  List<String> attachmentNames = const [],
  Map<String, String> extra = const {},
}) {
  return OfficialLetterData(
    senderName: 'Ahmad Ahmadi',
    senderStreet: 'Musterstraße 12',
    senderCity: '10115 Berlin',
    dateOfBirth: dateOfBirth,
    nationality: 'Afghanistan',
    phone: phone,
    email: email,
    officeType: OfficeType.auslaenderbehoerde,
    officeName: extra['officeName'] ?? 'Ausländerbehörde Berlin',
    officeStreet: officeStreet,
    officeCity: officeCity,
    officeEmail: 'post@auslaenderbehoerde-berlin.de',
    purpose: purpose,
    today: '06.11.2026',
    company: extra['company'] ?? '',
    jobTitle: extra['jobTitle'] ?? '',
    isAusbildung: extra['isAusbildung'] == 'true',
    startDate: extra['startDate'] ?? '',
    courseProvider: extra['courseProvider'] ?? '',
    courseStart: extra['courseStart'] ?? '',
    germanLevel: extra['germanLevel'] ?? '',
    permitExpiry: extra['permitExpiry'] ?? '',
    terminReason: extra['terminReason'] ?? '',
    newAddress: extra['newAddress'] ?? '',
    moveInDate: extra['moveInDate'] ?? '',
    terminTopic: extra['terminTopic'] ?? '',
    documentNames: extra['documentNames']?.split('|') ?? const [],
    questionSubject: extra['questionSubject'] ?? '',
    questionText: extra['questionText'] ?? '',
    attachmentNames: attachmentNames,
  );
}

void _expectCleanLetter(String letter) {
  const emDash = '\u2014';
  expect(letter, isNot(contains(emDash)));
  expect(letter, isNot(contains('null')));
  expect(letter, isNot(contains('«')));
  for (final line in letter.split('\n')) {
    final t = line.trim();
    // No bare labels of omitted optional lines.
    expect(t, isNot('Telefon:'), reason: line);
    expect(t, isNot('E-Mail:'), reason: line);
    expect(t, isNot('Geburtsdatum:'), reason: line);
    expect(t, isNot('Staatsangehörigkeit:'), reason: line);
    // ('Anlagen:' alone is a real section heading followed by the list,
    // so it is allowed like 'Zu meiner Person:'.)
  }
}

void main() {
  group('official letter templates (Phase 9)', () {
    test('work permit purpose reuses the Phase 8 template', () {
      final letter = buildOfficialLetter(
        _base(
          purpose: OfficialPurpose.workPermit,
          extra: {
            'company': 'Beispiel GmbH',
            'jobTitle': 'Lagerhelfer',
            'startDate': '01.03.2027',
          },
        ),
      );
      expect(
        letter,
        contains(
          'Betreff: Antrag auf Erlaubnis zur Aufnahme einer '
          'Beschäftigung',
        ),
      );
      expect(
        letter,
        contains(
          'Die Firma Beispiel GmbH möchte mich ab '
          'dem 01.03.2027 als Lagerhelfer einstellen.',
        ),
      );
      expect(letter, contains('Ausländerbehörde Berlin'));
      _expectCleanLetter(letter);
    });

    test('integration course letter with all optional data', () {
      final letter = buildOfficialLetter(
        _base(
          extra: {
            'courseProvider': 'Volkshochschule Berlin',
            'courseStart': '12.01.2027',
            'germanLevel': 'A2',
          },
        ),
      );
      expect(
        letter,
        contains(
          'Betreff: Antrag auf Berechtigung zur Teilnahme an '
          'einem Integrationskurs',
        ),
      );
      expect(letter, contains('ab dem 12.01.2027 beginnen'));
      expect(letter, contains('Volkshochschule Berlin'));
      expect(letter, contains('Sprachniveau ist A2'));
      expect(letter, contains('Friedrichstraße 219'));
      expect(letter, contains('Berlin, den 06.11.2026'));
      _expectCleanLetter(letter);
    });

    test('integration course letter omits empty optional sentences', () {
      final letter = buildOfficialLetter(_base());
      expect(letter, isNot(contains('Kursträger')));
      expect(letter, isNot(contains('Sprachniveau')));
      expect(letter, isNot(contains('beginnen')));
      _expectCleanLetter(letter);
    });

    test('permit extension with and without expiry date', () {
      final withDate = buildOfficialLetter(
        _base(
          purpose: OfficialPurpose.permitExtension,
          extra: {'permitExpiry': '31.01.2027'},
        ),
      );
      expect(
        withDate,
        contains('Mein Aufenthaltstitel läuft am 31.01.2027 ab.'),
      );
      expect(withDate, contains('Verlängerung meines Aufenthaltstitels'));
      final without = buildOfficialLetter(
        _base(purpose: OfficialPurpose.permitExtension),
      );
      expect(without, contains('läuft bald ab'));
      _expectCleanLetter(withDate);
      _expectCleanLetter(without);
    });

    test('general appointment carries the one-line reason', () {
      final letter = buildOfficialLetter(
        _base(
          purpose: OfficialPurpose.appointmentGeneral,
          extra: {'terminReason': 'Ich brauche eine Meldebescheinigung.'},
        ),
      );
      expect(letter, contains('Betreff: Terminanfrage'));
      expect(
        letter,
        contains('Mein Anliegen: Ich brauche eine Meldebescheinigung.'),
      );
      _expectCleanLetter(letter);
    });

    test('registration appointment names the new address', () {
      final letter = buildOfficialLetter(
        _base(
          purpose: OfficialPurpose.appointmentRegistration,
          extra: {
            'newAddress': 'Torstraße 5, 10119 Berlin',
            'moveInDate': '01.11.2026',
          },
        ),
      );
      expect(
        letter,
        contains(
          'Betreff: Bitte um einen Termin zur '
          'Anmeldung einer Wohnung',
        ),
      );
      expect(
        letter,
        contains(
          'am 01.11.2026 in eine neue Wohnung '
          'gezogen',
        ),
      );
      expect(
        letter,
        contains(
          'Meine neue Anschrift lautet: Torstraße 5, 10119 '
          'Berlin',
        ),
      );
      _expectCleanLetter(letter);
    });

    test('job appointment carries the topic', () {
      final letter = buildOfficialLetter(
        _base(
          purpose: OfficialPurpose.appointmentJob,
          extra: {'terminTopic': 'Ich suche eine Ausbildung als Koch.'},
        ),
      );
      expect(letter, contains('Terminanfrage: Arbeit und Ausbildung'));
      expect(letter, contains('Beratungsgespräch'));
      expect(letter, contains('Ich suche eine Ausbildung als Koch.'));
      _expectCleanLetter(letter);
    });

    test('submit documents lists documents in body and Anlagen', () {
      final letter = buildOfficialLetter(
        _base(
          purpose: OfficialPurpose.submitDocuments,
          extra: {'documentNames': 'Reisepass|Aufenthaltstitel'},
          attachmentNames: ['pass.pdf'],
        ),
      );
      expect(letter, contains('Betreff: Einreichung von Unterlagen'));
      expect(letter, contains('- Reisepass'));
      expect(letter, contains('- Aufenthaltstitel'));
      expect(letter, contains('Anlagen:'));
      expect(letter, contains('- pass.pdf'));
      _expectCleanLetter(letter);
    });

    test('submit documents without any names stays generic', () {
      final letter = buildOfficialLetter(
        _base(purpose: OfficialPurpose.submitDocuments),
      );
      expect(letter, contains('die angeforderten Unterlagen ein'));
      expect(letter, isNot(contains('Anlagen:')));
      _expectCleanLetter(letter);
    });

    test('question letter uses the user subject and his own words', () {
      final letter = buildOfficialLetter(
        _base(
          purpose: OfficialPurpose.question,
          extra: {
            'questionSubject': 'Frage zu meinem Bescheid',
            'questionText':
                'Ich habe einen Brief bekommen und verstehe '
                'den letzten Satz nicht.',
          },
        ),
      );
      expect(letter, contains('Betreff: Frage zu meinem Bescheid'));
      expect(letter, contains('verstehe den letzten Satz nicht.'));
      _expectCleanLetter(letter);
    });

    test('missing phone, email and DOB leave no empty lines', () {
      final letter = buildOfficialLetter(_base(dateOfBirth: ''));
      expect(letter, isNot(contains('Telefon:')));
      expect(letter, isNot(contains('E-Mail:')));
      expect(letter, isNot(contains('Geburtsdatum:')));
      expect(
        letter,
        contains(
          'Ich danke Ihnen für Ihre Zeit und Ihre '
          'Unterstützung.',
        ),
      );
      expect(letter, isNot(contains('Telefonnummer')));
      expect(letter, isNot(contains('E-Mail-Adresse')));
      _expectCleanLetter(letter);
    });

    test('contact sentence matches the contact data present', () {
      final phoneOnly = buildOfficialLetter(_base(phone: '0151 234'));
      expect(phoneOnly, contains('Telefon: 0151 234'));
      expect(phoneOnly, contains('genannten Telefonnummer.'));
      final mailOnly = buildOfficialLetter(_base(email: 'a@b.de'));
      expect(mailOnly, contains('E-Mail: a@b.de'));
      expect(mailOnly, contains('genannten E-Mail-Adresse.'));
      final both = buildOfficialLetter(
        _base(phone: '0151 234', email: 'a@b.de'),
      );
      expect(both, contains('Telefonnummer oder per E-Mail.'));
    });

    test('office street and city lines are omitted when empty', () {
      final letter = buildOfficialLetter(
        _base(officeStreet: '', officeCity: ''),
      );
      final lines = letter.split('\n');
      // Sender block (3) + blank + office name + blank + date line.
      expect(lines[4], 'Ausländerbehörde Berlin');
      expect(lines[5], '');
      expect(lines[6], contains('Berlin, den 06.11.2026'));
      _expectCleanLetter(letter);
    });

    test('attachments become the Anlagen list on every purpose', () {
      for (final p in OfficialPurpose.values) {
        final letter = buildOfficialLetter(
          _base(
            purpose: p,
            attachmentNames: ['vertrag.pdf', 'foto.jpg'],
            extra: {
              'company': 'Beispiel GmbH',
              'jobTitle': 'Lagerhelfer',
              'startDate': '01.03.2027',
              'questionSubject': 'Frage',
              'questionText': 'Meine Frage.',
            },
          ),
        );
        expect(letter, contains('Anlagen:'), reason: '$p');
        expect(letter, contains('- vertrag.pdf'), reason: '$p');
        expect(letter, contains('- foto.jpg'), reason: '$p');
        expect(letter.trimRight().endsWith('- foto.jpg'), isTrue, reason: '$p');
      }
    });

    test('no attachments means no Anlagen block', () {
      final letter = buildOfficialLetter(_base());
      expect(letter, isNot(contains('Anlagen:')));
    });

    test('subjects per purpose', () {
      expect(
        officialLetterSubject(_base(purpose: OfficialPurpose.permitExtension)),
        'Bitte um einen Termin zur Verlängerung meines '
        'Aufenthaltstitels',
      );
      expect(
        officialLetterSubject(
          _base(
            purpose: OfficialPurpose.question,
            extra: {'questionSubject': 'Mein Betreff'},
          ),
        ),
        'Mein Betreff',
      );
      expect(
        officialLetterSubject(_base(purpose: OfficialPurpose.submitDocuments)),
        'Einreichung von Unterlagen',
      );
    });

    test('email validation', () {
      expect(isValidOfficeEmail('post@amt-berlin.de'), isTrue);
      expect(isValidOfficeEmail('a.b+tag@sub.domain.org'), isTrue);
      expect(isValidOfficeEmail(''), isFalse);
      expect(isValidOfficeEmail('keine-email'), isFalse);
      expect(isValidOfficeEmail('a@b'), isFalse);
      expect(isValidOfficeEmail('a@b.d'), isFalse);
      expect(isValidOfficeEmail('a b@c.de'), isFalse);
      expect(isValidOfficeEmail('a@c.d e'), isFalse);
      expect(isValidOfficeEmail('@c.de'), isFalse);
    });

    test('attachment classification and limits', () {
      expect(const OfficialAttachment(name: 'x.PDF').isPdf, isTrue);
      expect(const OfficialAttachment(name: 'x.Jpeg').isImage, isTrue);
      expect(const OfficialAttachment(name: 'x.png').isImage, isTrue);
      expect(const OfficialAttachment(name: 'x.docx').isImage, isFalse);
      expect(const OfficialAttachment(name: 'x.docx').isPdf, isFalse);
      expect(kMaxOfficialAttachments, 6);
      expect(kMaxOfficialAttachmentBytes, 10 * 1024 * 1024);
    });

    test('anlagen names combine documents and files without duplicates', () {
      final d = _base(
        purpose: OfficialPurpose.submitDocuments,
        extra: {'documentNames': 'Pass|Pass|Bescheid'},
        attachmentNames: ['Pass', 'foto.jpg'],
      );
      expect(officialAnlagenNames(d), ['Pass', 'Bescheid', 'foto.jpg']);
      final other = _base(attachmentNames: ['a.pdf']);
      expect(officialAnlagenNames(other), ['a.pdf']);
    });

    test('payload marks official_letter with purpose and office data', () {
      final p = _base(
        purpose: OfficialPurpose.appointmentJob,
        attachmentNames: ['a.pdf'],
        extra: {'terminTopic': 'Ausbildung'},
      ).toPayload();
      expect(p['docKind'], 'official_letter');
      expect(p['purpose'], 'appointment_job');
      expect(p['officeType'], 'auslaenderbehoerde');
      expect(p['officeEmail'], 'post@auslaenderbehoerde-berlin.de');
      expect(p['terminTopic'], 'Ausbildung');
      expect(p['attachmentNames'], ['a.pdf']);
    });

    test('explanations exist per purpose and name the office', () {
      for (final purpose in OfficialPurpose.values) {
        for (final lang in ['de', 'en', 'ps', 'fa']) {
          final text = officialLetterExplanation(
            lang,
            _base(
              purpose: purpose,
              extra: {
                'company': 'Beispiel GmbH',
                'jobTitle': 'Lagerhelfer',
                'startDate': '01.03.2027',
              },
            ),
          );
          expect(
            text,
            contains('Ausländerbehörde Berlin'),
            reason: '$purpose/$lang',
          );
          expect(text.length, greaterThan(60), reason: '$purpose/$lang');
          expect(text, isNot(contains('\u2014')), reason: '$purpose/$lang');
        }
      }
    });

    test('purpose and office keys are stable', () {
      expect(OfficialPurpose.workPermit.key, 'work_permit');
      expect(OfficialPurpose.question.key, 'question');
      expect(OfficeType.agentur.key, 'agentur_fuer_arbeit');
      expect(OfficeType.agentur.germanLabel, 'Agentur für Arbeit');
      expect(OfficeType.other.germanLabel, '');
    });
  });
}
