// ─────────────────────────────────────────────────────────────────────────────
// Work permit letter (Phase 8, blueprint §6.9) - the fixed German template
// for the request to the Ausländerbehörde, plus the plain-language
// explanation of the letter in the app's 4 languages.
//
// The letter text is a FIXED template. Only data the user entered or that
// comes from the user's own profile is inserted; there are no placeholders
// in the output (lines whose data is missing are omitted, per the standing
// no-empty-lines rule) and no legal promises: the letter asks, and says
// the office can request further documents. It must get a legal
// once-over before launch (flagged in the Phase 8 report).
//
// No em-dashes anywhere in this file's user-visible texts.
// ─────────────────────────────────────────────────────────────────────────────

/// Everything the letter needs. All strings are used verbatim as the user
/// entered them (or as stored in the profile).
class WorkPermitData {
  final String senderName;
  final String senderStreet;
  final String senderCity;
  final String dateOfBirth; // dd.MM.yyyy, '' when unknown
  final String nationality;
  final String phone;
  final String email;
  final String authorityName;
  final String authorityCity;
  final String company;
  final String jobTitle;
  final bool isAusbildung;
  final String startDate; // dd.MM.yyyy
  final String today; // dd.MM.yyyy, the letter's date line

  const WorkPermitData({
    required this.senderName,
    required this.senderStreet,
    required this.senderCity,
    required this.nationality,
    required this.authorityName,
    required this.authorityCity,
    required this.company,
    required this.jobTitle,
    required this.startDate,
    required this.today,
    this.dateOfBirth = '',
    this.phone = '',
    this.email = '',
    this.isAusbildung = false,
  });

  Map<String, dynamic> toPayload() => {
        'docKind': 'work_permit',
        'senderName': senderName,
        'senderStreet': senderStreet,
        'senderCity': senderCity,
        'dateOfBirth': dateOfBirth,
        'nationality': nationality,
        'phone': phone,
        'email': email,
        'authorityName': authorityName,
        'authorityCity': authorityCity,
        'company': company,
        'jobTitle': jobTitle,
        'isAusbildung': isAusbildung,
        'startDate': startDate,
        'letterDate': today,
      };
}

/// dd.MM.yyyy with zero padding, the German letter convention.
String formatGermanDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

/// Place name for the date line: the profile city field may carry the PLZ
/// in front ('12345 Berlin'); the date line wants the place only.
String workPermitPlaceName(String cityField) {
  final t = cityField.trim();
  final m = RegExp(r'^\d{5}\s+(.+)$').firstMatch(t);
  return m != null ? m.group(1)!.trim() : t;
}

String workPermitSubject(WorkPermitData d) => d.isAusbildung
    ? 'Antrag auf Erlaubnis zur Aufnahme einer Ausbildung'
    : 'Antrag auf Erlaubnis zur Aufnahme einer Beschäftigung';

/// The full German letter text (subject line included after the address
/// blocks, as in a normal Geschäftsbrief). Also used verbatim as the
/// email body, so it stays plain text.
String buildWorkPermitLetter(WorkPermitData d) {
  final lines = <String>[
    d.senderName,
    d.senderStreet,
    d.senderCity,
    '',
    d.authorityName,
    d.authorityCity,
    '',
    '${workPermitPlaceName(d.senderCity)}, den ${d.today}',
    '',
    'Betreff: ${workPermitSubject(d)}',
    '',
    'Sehr geehrte Damen und Herren,',
    '',
    d.isAusbildung
        ? 'mein Name ist ${d.senderName} und ich bitte Sie um die '
            'Erlaubnis, eine Ausbildung aufnehmen zu dürfen.'
        : 'mein Name ist ${d.senderName} und ich bitte Sie um die '
            'Erlaubnis, eine Beschäftigung aufnehmen zu dürfen.',
    '',
    'Zu meiner Person:',
    'Name: ${d.senderName}',
    if (d.dateOfBirth.isNotEmpty) 'Geburtsdatum: ${d.dateOfBirth}',
    'Staatsangehörigkeit: ${d.nationality}',
    'Anschrift: ${d.senderStreet}, ${d.senderCity}',
    if (d.phone.isNotEmpty) 'Telefon: ${d.phone}',
    if (d.email.isNotEmpty) 'E-Mail: ${d.email}',
    '',
    if (d.isAusbildung)
      'Mir liegt ein konkretes Ausbildungsangebot vor. Die Firma '
          '${d.company} bietet mir ab dem ${d.startDate} einen '
          'Ausbildungsplatz als ${d.jobTitle} an.'
    else
      'Mir liegt ein konkretes Stellenangebot vor. Die Firma '
          '${d.company} möchte mich ab dem ${d.startDate} als '
          '${d.jobTitle} einstellen.',
    '',
    d.isAusbildung
        ? 'Für den Beginn dieser Ausbildung brauche ich die Erlaubnis '
            'der Ausländerbehörde. Ich bitte Sie daher freundlich, mir '
            'diese Erlaubnis zu erteilen.'
        : 'Für die Aufnahme dieser Beschäftigung brauche ich die '
            'Erlaubnis der Ausländerbehörde. Ich bitte Sie daher '
            'freundlich, mir diese Erlaubnis zu erteilen.',
    '',
    'Gern reiche ich Ihnen weitere Unterlagen nach, wenn Sie diese '
        'brauchen, zum Beispiel den Arbeitsvertrag oder die '
        'Stellenbeschreibung.',
    '',
    'Ich danke Ihnen für Ihre Zeit und Ihre Unterstützung. Für '
        'Rückfragen erreichen Sie mich gern unter der oben genannten '
        'Telefonnummer oder per E-Mail.',
    '',
    'Mit freundlichen Grüßen',
    d.senderName,
  ];
  return lines.join('\n');
}

/// Plain-language summary of what the letter says, in the user's language.
/// This is an authored explanation of the fixed template, not a
/// word-for-word translation: it names the office, the company, the job
/// and the start date from the letter, and it is explicit that the office
/// decides and nothing is guaranteed.
String workPermitExplanation(String lang, WorkPermitData d) {
  switch (lang) {
    case 'ps':
      return 'دا لیک ${d.authorityName} ته وايي چې تاسو څوک یاست، شرکت '
          '${d.company} غواړي تاسو د ${d.startDate} څخه د ${d.jobTitle} '
          'په توګه وګماري، او له دفتر څخه غوښتنه کوي چې تاسو ته د کار '
          'د پیل اجازه درکړي. لیک دا هم وايي چې دفتر کولای شي له تاسو '
          'څخه نور سندونه وغواړي، او ستاسو د ټېلېفون شمېره او '
          'برېښنالیک د پوښتنو لپاره ورکوي. پرېکړه دفتر کوي. دا لیک د '
          'اجازې تضمین نه کوي.';
    case 'fa':
      return 'این نامه به ${d.authorityName} می‌گوید که شما چه کسی '
          'هستید، شرکت ${d.company} می‌خواهد شما را از ${d.startDate} '
          'به عنوان ${d.jobTitle} استخدام کند، و از اداره درخواست '
          'می‌کند که به شما اجازه شروع کار بدهد. نامه همچنین می‌گوید '
          'که اداره می‌تواند از شما مدارک بیشتری بخواهد، و شماره تلفن '
          'و ایمیل شما را برای پرسش‌ها می‌دهد. تصمیم با اداره است. '
          'این نامه اجازه را تضمین نمی‌کند.';
    case 'en':
      return 'This letter tells ${d.authorityName} who you are, that '
          'the company ${d.company} wants to employ you as '
          '${d.jobTitle} from ${d.startDate}, and asks the office to '
          'give you permission to start. It also says the office may '
          'ask you for more documents, and it gives your phone number '
          'and email address for questions. The office decides. This '
          'letter does not guarantee permission.';
    case 'de':
    default:
      return 'Dieser Brief sagt der Behörde ${d.authorityName}, wer Sie '
          'sind, dass die Firma ${d.company} Sie ab dem ${d.startDate} '
          'als ${d.jobTitle} einstellen möchte, und bittet die Behörde '
          'um die Erlaubnis für den Arbeitsbeginn. Er sagt auch, dass '
          'die Behörde weitere Unterlagen von Ihnen verlangen kann, und '
          'nennt Ihre Telefonnummer und E-Mail-Adresse für Rückfragen. '
          'Die Behörde entscheidet. Dieser Brief garantiert keine '
          'Erlaubnis.';
  }
}
