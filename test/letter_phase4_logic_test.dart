import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/services/letter_model.dart';
import 'package:karyab/services/letter_phrase_bank.dart';

void main() {
  group('phrase bank shape', () {
    test('at least 6 variants per main section', () {
      for (final section in const [
        LetterSection.einleitung,
        LetterSection.erfahrung,
        LetterSection.kenntnisse,
        LetterSection.warum,
        LetterSection.verfuegbarkeit,
        LetterSection.schluss,
      ]) {
        final count = kLetterPhrases.where((p) => p.section == section).length;
        expect(count, greaterThanOrEqualTo(6), reason: section);
      }
    });

    test('every phrase has both translations and no em-dash', () {
      for (final p in kLetterPhrases) {
        expect(p.ps.trim(), isNotEmpty, reason: p.id);
        expect(p.fa.trim(), isNotEmpty, reason: p.id);
        expect(p.de.contains('—'), isFalse, reason: p.id);
        expect(p.ps.contains('—'), isFalse, reason: p.id);
        expect(p.fa.contains('—'), isFalse, reason: p.id);
        // Translation carries the same tokens as the German template.
        expect(
          letterTokensIn(p.ps)..sort(),
          letterTokensIn(p.de)..sort(),
          reason: '${p.id} ps tokens',
        );
        expect(
          letterTokensIn(p.fa)..sort(),
          letterTokensIn(p.de)..sort(),
          reason: '${p.id} fa tokens',
        );
      }
    });

    test('ids are unique', () {
      final ids = kLetterPhrases.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('recommendation scoring', () {
    const values = {
      'jobTitle': 'Lagerhelfer',
      'company': 'DHL Paket GmbH',
      'skill1': 'Gabelstapler fahren',
      'skill2': 'Lagerlogistik',
      'experience': 'Lagerhelfer bei Amazon',
      'school': '',
      'startDate': '',
      'city': 'Berlin',
    };

    test('sector match beats a generic phrase of the same tone', () {
      final ranked = rankLetterPhrases(
        LetterSection.kenntnisse,
        values: values,
        sectorHint: 'warehouse',
        tone: LetterTone.formal,
      );
      expect(ranked.first.phrase.id, 'kenntnisse_warehouse');
    });

    test('tone match wins when no sector phrase fits', () {
      final ranked = rankLetterPhrases(
        LetterSection.schluss,
        values: values,
        sectorHint: 'general',
        tone: LetterTone.friendly,
      );
      expect(ranked.first.phrase.tone, LetterTone.friendly);
    });

    test('phrases with unfillable tokens are never offered', () {
      // No school in values: the school erfahrung phrase must not appear.
      final ranked = rankLetterPhrases(
        LetterSection.erfahrung,
        values: values,
        sectorHint: 'general',
        tone: LetterTone.formal,
      );
      expect(
        ranked.map((r) => r.phrase.id),
        isNot(contains('erfahrung_formal_school')),
      );
      // No startDate: only the date-free verfuegbarkeit phrases appear.
      final verf = rankLetterPhrases(
        LetterSection.verfuegbarkeit,
        values: values,
        sectorHint: 'general',
        tone: LetterTone.formal,
      );
      expect(verf, isNotEmpty);
      for (final r in verf) {
        expect(r.phrase.tokens, isNot(contains('startDate')));
      }
    });

    test('reason is reported for the winner', () {
      final ranked = rankLetterPhrases(
        LetterSection.kenntnisse,
        values: values,
        sectorHint: 'warehouse',
        tone: LetterTone.formal,
      );
      expect(ranked.first.reasonKey, 'sector');
      expect(ranked.first.reasonValue, 'warehouse');
    });

    test('scoring is deterministic', () {
      final a = rankLetterPhrases(
        LetterSection.einleitung,
        values: values,
        sectorHint: 'warehouse',
        tone: LetterTone.formal,
      );
      final b = rankLetterPhrases(
        LetterSection.einleitung,
        values: values,
        sectorHint: 'warehouse',
        tone: LetterTone.formal,
      );
      expect(
        a.map((r) => r.phrase.id).toList(),
        b.map((r) => r.phrase.id).toList(),
      );
    });
  });

  group('composer and freeze', () {
    const ctx = LetterContext(
      jobTitle: 'Lagerhelfer',
      companyName: 'DHL Paket GmbH',
      companyCity: 'Berlin',
      referenceNumber: 'REF-123',
      skills: ['Gabelstapler fahren', 'Lagerlogistik'],
      experience: 'Lagerhelfer bei Amazon',
    );

    test('new letter has all blocks in default order with filled texts', () {
      final (:data, :reasons) = composeNewLetter(
        ctx,
        now: DateTime(2026, 11, 6),
      );
      expect(data.blocks.map((b) => b.id).toList(), LetterSection.defaultOrder);
      expect(data.betreffText, contains('Lagerhelfer'));
      expect(data.betreffText, contains('REF-123'));
      expect(data.date, '06.11.2026');
      for (final b in data.blocks) {
        if (b.id == LetterSection.anlagen) continue;
        expect(b.text.trim(), isNotEmpty, reason: b.id);
        expect(findLetterPlaceholders(b.text), isEmpty, reason: b.id);
      }
      expect(
        reasons[LetterSection.kenntnisse]?.phrase.id,
        'kenntnisse_warehouse',
      );
    });

    test('payload round-trip is frozen: reopening never recomposes', () {
      final (:data, reasons: _) = composeNewLetter(
        ctx,
        now: DateTime(2026, 11, 6),
      );
      // User edits a block by hand.
      data.block(LetterSection.einleitung)!.text = 'Mein eigener Anfang.';
      data.block(LetterSection.einleitung)!.edited = true;
      final payload = data.toPayload();
      final reopened = LetterData.fromPayload(payload)!;
      expect(
        reopened.block(LetterSection.einleitung)!.text,
        'Mein eigener Anfang.',
      );
      expect(reopened.block(LetterSection.einleitung)!.edited, isTrue);
      expect(reopened.toPayload(), payload);
      // A second compose with different "randomness" (there is none) would
      // produce the bank text, which must differ from the frozen edit.
      final fresh = composeNewLetter(ctx, now: DateTime(2026, 11, 6)).data;
      expect(
        fresh.block(LetterSection.einleitung)!.text,
        isNot('Mein eigener Anfang.'),
      );
    });

    test('compose is deterministic for the same context', () {
      final a = composeNewLetter(ctx, now: DateTime(2026, 1, 1)).data;
      final b = composeNewLetter(ctx, now: DateTime(2026, 1, 1)).data;
      expect(a.toPayload(), b.toPayload());
    });

    test(
      'duplicate for a new job resets company, title, date, betreff only',
      () {
        final (:data, reasons: _) = composeNewLetter(
          ctx,
          now: DateTime(2026, 11, 6),
        );
        final kenntnisse = data.block(LetterSection.kenntnisse)!.text;
        final copy = letterPayloadForNewJob(
          data.toPayload(),
          now: DateTime(2026, 12, 1),
        );
        final d = LetterData.fromPayload(copy)!;
        expect(d.companyName, '');
        expect(d.jobTitle, '');
        expect(d.referenceNumber, '');
        expect(d.date, '01.12.2026');
        expect(d.betreffText, '');
        expect(d.block(LetterSection.kenntnisse)!.text, kenntnisse);
      },
    );

    test('salutation follows the user choice, never a guess', () {
      final base = composeNewLetter(ctx).data;
      expect(base.salutationLine, 'Sehr geehrte Damen und Herren,');
      base.contactPerson = 'Müller';
      base.salutation = 'frau';
      expect(base.salutationLine, 'Sehr geehrte Frau Müller,');
      base.salutation = 'herr';
      expect(base.salutationLine, 'Sehr geehrter Herr Müller,');
      base.salutation = 'none';
      expect(base.salutationLine, 'Sehr geehrte Damen und Herren,');
    });

    test('hidden blocks leave the body; betreff and anlagen are not body', () {
      final data = composeNewLetter(ctx).data;
      final before = data.bodyParagraphs.length;
      data.block(LetterSection.warum)!.hidden = true;
      expect(data.bodyParagraphs.length, before - 1);
      expect(data.bodyParagraphs, isNot(contains(data.betreffText)));
    });
  });

  group('token guard', () {
    test('finds curly tokens and bracketed placeholders', () {
      expect(
        findLetterPlaceholders('Ich kann {skill1} gut.'),
        contains('{skill1}'),
      );
      expect(
        findLetterPlaceholders('Bei [Unternehmen] arbeiten.'),
        contains('[Unternehmen]'),
      );
      expect(findLetterPlaceholders('Ein sauberer Satz.'), isEmpty);
    });

    test('letter data reports unfilled placeholders across visible blocks', () {
      final data = composeNewLetter(const LetterContext(jobTitle: 'Koch')).data;
      data.block(LetterSection.kenntnisse)!.text = 'Ich kann {skill1}.';
      expect(data.unfilledPlaceholders, contains('{skill1}'));
    });
  });
}
