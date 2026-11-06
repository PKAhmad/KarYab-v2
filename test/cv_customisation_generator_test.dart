import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:karyab/models/cv_style.dart';
import 'package:karyab/models/document_template.dart';
import 'package:karyab/models/user_profile.dart';
import 'package:karyab/services/ats_checker.dart';
import 'package:karyab/services/cv_pdf_generator.dart';

// Phase 3: the generator must apply a CvCustomisation (accent, font size,
// spacing, photo on/off) for every template, and the default customisation
// must keep producing a valid document everywhere.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const profile = UserProfile(
    fullName: 'Ahmad Rahimi',
    phone: '+49 151 23456789',
    email: 'ahmad.rahimi@example.com',
    street: 'Musterstraße 12',
    city: '12345 Berlin',
    languages: ['pashto', 'german'],
    skill: 'cleaning,driving',
    workExperience: 'more2',
    workType: 'cleaning',
    tools: 'power_tools',
    drivingLicense: 'german_license',
    availability: 'fulltime',
    startDate: 'immediately',
    educationLevel: 'vocational',
    previousEmployers: ['Muster GmbH', 'Beispiel AG'],
    previousJobTitles: ['Reinigungskraft', 'Lagerhelfer'],
    previousJobDurations: ['2022 - 2024', '2020 - 2022'],
    languageProficiency: {'Deutsch': 'B1', 'Paschtu': 'Muttersprache'},
    refName: 'Herr Schmidt',
    refPhone: '+49 170 9998877',
  );

  const styles = <String, CvCustomisation>{
    'default': CvCustomisation.defaults,
    'accent': CvCustomisation(accentColorHex: '#7A2230'),
    'large font': CvCustomisation(fontSize: 'large'),
    'compact': CvCustomisation(fontSize: 'compact', spacing: 'compact'),
    'no photo': CvCustomisation(showPhoto: false),
    'everything': CvCustomisation(
      accentColorHex: '#0E6B5C',
      fontSize: 'large',
      spacing: 'compact',
      showPhoto: false,
    ),
  };

  for (final template in DocumentTemplate.values) {
    for (final entry in styles.entries) {
      test('generateCv (${template.name}, ${entry.key}) renders', () async {
        final bytes =
            await generateCv(profile, template, style: entry.value);
        expect(bytes, isNotEmpty);
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
        expect(countPdfPages(bytes), greaterThanOrEqualTo(1));
      });
    }
  }

  test('showPhoto=false drops the embedded photo image', () async {
    final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
    final file = File(
        '${Directory.systemTemp.path}/cv_style_photo_${DateTime.now().microsecondsSinceEpoch}.png');
    await file.writeAsBytes(png);
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });
    final withPhotoPath = UserProfile(
      fullName: profile.fullName,
      phone: profile.phone,
      email: profile.email,
      street: profile.street,
      city: profile.city,
      languages: profile.languages,
      photoPath: file.path,
    );
    final withPhoto =
        await generateCv(withPhotoPath, DocumentTemplate.darkSidebar);
    final withoutPhoto = await generateCv(
      withPhotoPath,
      DocumentTemplate.darkSidebar,
      style: const CvCustomisation(showPhoto: false),
    );
    // The embedded image XObject makes the photo version clearly larger;
    // without it the template renders its no-photo placeholder form.
    expect(withPhoto.length, greaterThan(withoutPhoto.length));
  });

  test('palette accents all render in the ATS template', () async {
    for (final option in kCvAccentPalette) {
      final bytes = await generateCv(
        profile,
        DocumentTemplate.atsBlue,
        style: CvCustomisation(accentColorHex: option.hex),
      );
      expect(bytes, isNotEmpty, reason: option.hex);
    }
  });
}
