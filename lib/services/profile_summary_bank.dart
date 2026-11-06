// ─────────────────────────────────────────────────────────────────────────────
// Profil summary phrase bank (Phase 3).
//
// The Profil step in both CV questionnaires lets the user tick strength and
// experience themes; this bank turns the ticked keys into a short German
// profile text (3 to 5 sentences) for the PROFIL section of the CV. Every
// sentence here is a claim the USER selects about himself - the app never
// adds a sentence on its own, and the composed text stays fully editable
// before it is stored. Documents stay German, per the app rules.
//
// Authoring note: 19 patterns - 8 strength themes, 8 sector experience
// lines, 2 experience openers and 1 Ausbildung opener. No em-dashes.
// ─────────────────────────────────────────────────────────────────────────────

class ProfileTheme {
  final String key;

  /// German sentence printed in the CV when the theme is ticked.
  final String sentenceDe;

  const ProfileTheme(this.key, this.sentenceDe);
}

/// Strength themes, in print order.
const List<ProfileTheme> kProfileThemes = [
  ProfileTheme('reliable',
      'Ich arbeite zuverlässig und halte Absprachen und Arbeitszeiten genau ein.'),
  ProfileTheme('punctualCareful',
      'Ich arbeite sorgfältig und achte auf Qualität und Sicherheit.'),
  ProfileTheme('team',
      'Ich arbeite gern im Team und unterstütze meine Kolleginnen und Kollegen.'),
  ProfileTheme('independent',
      'Ich arbeite selbstständig und übernehme gern Verantwortung für meine Aufgaben.'),
  ProfileTheme('fastLearner',
      'Neue Aufgaben und Abläufe lerne ich schnell und sicher.'),
  ProfileTheme('physical',
      'Körperliche Arbeit bin ich gewohnt und ich bin belastbar.'),
  ProfileTheme('flexible',
      'Zeitlich bin ich flexibel und auch zu Schichtarbeit und Wochenendarbeit bereit.'),
  ProfileTheme('friendly',
      'Im Umgang mit Kunden und Gästen bin ich freundlich und hilfsbereit.'),
];

/// Sector experience lines, in print order.
const List<ProfileTheme> kProfileSectors = [
  ProfileTheme('warehouse',
      'Im Lager habe ich Erfahrung mit dem Sortieren, Verpacken und Vorbereiten von Waren für den Versand.'),
  ProfileTheme('care',
      'In der Betreuung und Pflege unterstütze ich Menschen freundlich und geduldig im Alltag.'),
  ProfileTheme('gastronomy',
      'In der Küche und im Service arbeite ich sauber und schnell und bleibe auch unter Zeitdruck ruhig.'),
  ProfileTheme('retail',
      'Im Verkauf berate ich Kunden freundlich und kenne mich mit dem Auffüllen und Ordnen von Waren aus.'),
  ProfileTheme('cleaning',
      'In der Gebäudereinigung arbeite ich gründlich und zuverlässig, auch in großen Objekten.'),
  ProfileTheme('construction',
      'Auf dem Bau habe ich Erfahrung mit handwerklichen Arbeiten und dem sicheren Umgang mit Werkzeugen.'),
  ProfileTheme('driving',
      'Als Fahrer bin ich zuverlässig unterwegs und bringe Erfahrung im sicheren Transport von Waren mit.'),
  ProfileTheme('office',
      'Im Büro arbeite ich sicher mit den gängigen Computerprogrammen und organisiere meine Aufgaben sorgfältig.'),
];

const String kProfileOpenerAusbildung =
    'Ich suche einen Ausbildungsplatz und bringe große Motivation und Lernbereitschaft mit.';

const Map<String, String> kProfileOpenersByExperience = {
  'more2': 'Ich bringe mehr als zwei Jahre Berufserfahrung mit.',
  'less2': 'Ich bringe erste Berufserfahrung aus meiner bisherigen Arbeit mit.',
};

/// Sectors plausibly matching the user's own entered data, offered first in
/// the Profil step. Derived only from values the user already entered:
/// work type, tools, driving licence, IT skills and (Ausbildung) ESCO
/// skills / target occupation keywords. Everything not matched here is
/// still offered in the full list - this only orders the chips.
Set<String> suggestedProfileSectors(Map<String, dynamic> payload) {
  String v(String key) => (payload[key] as String? ?? '').toLowerCase();
  final result = <String>{};
  final workType = v('workType');
  if (workType.contains('cleaning')) result.add('cleaning');
  if (workType.contains('construction')) result.add('construction');
  if (workType.contains('kitchen')) result.add('gastronomy');
  if (workType.contains('driving')) result.add('driving');
  final tools = v('tools');
  if (tools.contains('kitchen')) result.add('gastronomy');
  if (tools.contains('power_tools') || tools.contains('tractor')) {
    result.add('construction');
  }
  final licence = v('drivingLicense');
  if (licence.contains('license') && !licence.contains('no_license')) {
    result.add('driving');
  }
  if (v('sharedItSkills').isNotEmpty) result.add('office');
  final esco = '${v('ausbildungEscoSkills')} ${v('ausbildungTargetOccupation')}';
  if (esco.contains('lager') || esco.contains('logistik')) {
    result.add('warehouse');
  }
  if (esco.contains('pflege') || esco.contains('betreuung')) {
    result.add('care');
  }
  if (esco.contains('verkauf') || esco.contains('handel')) {
    result.add('retail');
  }
  if (esco.contains('reinigung')) result.add('cleaning');
  if (esco.contains('bau')) result.add('construction');
  if (esco.contains('küche') || esco.contains('gastronomie')) {
    result.add('gastronomy');
  }
  return result;
}

/// Composes the profile text from the ticked [themeKeys] and [sectorKeys].
///
/// Order: opener (Ausbildung line, or the experience line for the user's
/// own workExperience value), then sector lines, then strength themes -
/// each group in bank order, never in tap order, so the text reads the
/// same for the same selection. Capped at 5 sentences. Returns '' when
/// nothing is selected.
String composeProfileSummary({
  required Set<String> themeKeys,
  required Set<String> sectorKeys,
  required bool isAusbildung,
  String workExperience = '',
}) {
  final sentences = <String>[];
  if (isAusbildung) {
    sentences.add(kProfileOpenerAusbildung);
  } else {
    final opener = kProfileOpenersByExperience[workExperience];
    if (opener != null) sentences.add(opener);
  }
  for (final sector in kProfileSectors) {
    if (sectorKeys.contains(sector.key)) sentences.add(sector.sentenceDe);
  }
  for (final theme in kProfileThemes) {
    if (themeKeys.contains(theme.key)) sentences.add(theme.sentenceDe);
  }
  return sentences.take(5).join(' ');
}
