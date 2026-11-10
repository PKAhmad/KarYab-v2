import 'dart:typed_data';

import 'work_permit_letter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Official letters (Phase 9) - the Behördenbriefe module. It generalises
// the Phase 8 work-permission letter: the user picks an office (type,
// name, email, postal address), picks a purpose, and the app writes a
// fixed formal German letter from the user's own data. Files the user
// attaches become pages at the end of the letter PDF and are named in
// the letter's Anlagen list.
//
// All letter texts are FIXED templates authored for this module. Only
// data the user entered or that comes from his own profile is inserted;
// lines whose data is missing are omitted (no placeholders, per the
// standing rule), and no template makes a legal promise: the letters
// ask, and the office decides. They must get a legal once-over before
// launch (flagged in the Phase 9 report), same as Phase 8.
//
// No em-dashes anywhere in this file's user-visible texts.
// ─────────────────────────────────────────────────────────────────────────────

/// The eight letter purposes of the module, in display order. Purpose
/// [workPermit] is the Phase 8 template, carried over unchanged.
enum OfficialPurpose {
  workPermit,
  integrationCourse,
  permitExtension,
  appointmentGeneral,
  appointmentRegistration,
  appointmentJob,
  submitDocuments,
  question,
}

extension OfficialPurposeKey on OfficialPurpose {
  /// Stable payload key, stored with every saved letter.
  String get key => switch (this) {
    OfficialPurpose.workPermit => 'work_permit',
    OfficialPurpose.integrationCourse => 'integration_course',
    OfficialPurpose.permitExtension => 'permit_extension',
    OfficialPurpose.appointmentGeneral => 'appointment_general',
    OfficialPurpose.appointmentRegistration => 'appointment_registration',
    OfficialPurpose.appointmentJob => 'appointment_job',
    OfficialPurpose.submitDocuments => 'submit_documents',
    OfficialPurpose.question => 'question',
  };
}

/// The offices the picker offers. [other] is the free choice: the user
/// types the office name himself.
enum OfficeType { auslaenderbehoerde, buergerbuero, jobcenter, agentur, other }

extension OfficeTypeInfo on OfficeType {
  String get key => switch (this) {
    OfficeType.auslaenderbehoerde => 'auslaenderbehoerde',
    OfficeType.buergerbuero => 'buergerbuero',
    OfficeType.jobcenter => 'jobcenter',
    OfficeType.agentur => 'agentur_fuer_arbeit',
    OfficeType.other => 'other',
  };

  /// German office name used as the prefill for the office name field.
  /// Empty for [OfficeType.other] (the user types his own).
  String get germanLabel => switch (this) {
    OfficeType.auslaenderbehoerde => 'Ausländerbehörde',
    OfficeType.buergerbuero => 'Bürgerbüro',
    OfficeType.jobcenter => 'Jobcenter',
    OfficeType.agentur => 'Agentur für Arbeit',
    OfficeType.other => '',
  };
}

/// One file the user attached to a letter. [bytes] is loaded by the
/// caller (the screen reads the picked file); the pure template layer
/// only needs [name], the PDF layer needs [bytes].
class OfficialAttachment {
  final String name;
  final String path;
  final Uint8List? bytes;
  final int sizeBytes;

  const OfficialAttachment({
    required this.name,
    this.path = '',
    this.bytes,
    this.sizeBytes = 0,
  });

  String get extension {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  bool get isImage =>
      extension == 'jpg' || extension == 'jpeg' || extension == 'png';

  bool get isPdf => extension == 'pdf';
}

/// Attachment limits, stated in the UI copy as well: at most 6 files,
/// each at most 10 MB.
const int kMaxOfficialAttachments = 6;
const int kMaxOfficialAttachmentBytes = 10 * 1024 * 1024;

/// Pragmatic email check for the office email field: one @, a domain
/// with a dot and a TLD of at least two letters, no spaces.
bool isValidOfficeEmail(String value) {
  final v = value.trim();
  if (v.isEmpty || v.length > 254 || v.contains(' ')) return false;
  return RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
  ).hasMatch(v);
}

/// Everything one official letter needs. Sender fields come from the
/// user's profile; office fields and purpose fields are what he typed
/// (or picked). All strings are used verbatim.
class OfficialLetterData {
  // Sender (from the profile).
  final String senderName;
  final String senderStreet;
  final String senderCity;
  final String dateOfBirth; // dd.MM.yyyy, '' when unknown
  final String nationality;
  final String phone;
  final String email;

  // Office (user input).
  final OfficeType officeType;
  final String officeName;
  final String officeStreet; // '' when the user only knows name + city
  final String officeCity; // 'PLZ Ort', '' allowed
  final String officeEmail;

  // Purpose + purpose fields (only the ones of the chosen purpose are
  // read by its template; the rest stay empty).
  final OfficialPurpose purpose;
  final String company; // work permit
  final String jobTitle; // work permit
  final bool isAusbildung; // work permit
  final String startDate; // work permit, dd.MM.yyyy
  final String courseProvider; // integration course, optional
  final String courseStart; // integration course, dd.MM.yyyy, optional
  final String germanLevel; // integration course, optional
  final String permitExpiry; // permit extension, dd.MM.yyyy
  final String terminReason; // general appointment, one line
  final String newAddress; // registration appointment
  final String moveInDate; // registration appointment, dd.MM.yyyy
  final String terminTopic; // job appointment
  final List<String> documentNames; // submit documents
  final String questionSubject; // question: the user's own subject line
  final String questionText; // question: the user's own words

  /// Names of the attached files, in pick order (Anlagen list).
  final List<String> attachmentNames;

  final String today; // dd.MM.yyyy, the letter's date line

  const OfficialLetterData({
    required this.senderName,
    required this.senderStreet,
    required this.senderCity,
    required this.officeType,
    required this.officeName,
    required this.officeEmail,
    required this.purpose,
    required this.today,
    this.dateOfBirth = '',
    this.nationality = '',
    this.phone = '',
    this.email = '',
    this.officeStreet = '',
    this.officeCity = '',
    this.company = '',
    this.jobTitle = '',
    this.isAusbildung = false,
    this.startDate = '',
    this.courseProvider = '',
    this.courseStart = '',
    this.germanLevel = '',
    this.permitExpiry = '',
    this.terminReason = '',
    this.newAddress = '',
    this.moveInDate = '',
    this.terminTopic = '',
    this.documentNames = const [],
    this.questionSubject = '',
    this.questionText = '',
    this.attachmentNames = const [],
  });

  /// The Phase 8 view of this letter (purpose 1 reuses its template
  /// verbatim). The office street joins the office city line, because
  /// the Phase 8 receiver block has exactly two lines.
  WorkPermitData toWorkPermitData() => WorkPermitData(
    senderName: senderName,
    senderStreet: senderStreet,
    senderCity: senderCity,
    dateOfBirth: dateOfBirth,
    nationality: nationality,
    phone: phone,
    email: email,
    authorityName: officeName,
    authorityCity: officeStreet.isEmpty
        ? officeCity
        : (officeCity.isEmpty ? officeStreet : '$officeStreet\n$officeCity'),
    company: company,
    jobTitle: jobTitle,
    isAusbildung: isAusbildung,
    startDate: startDate,
    today: today,
  );

  Map<String, dynamic> toPayload() => {
    'docKind': 'official_letter',
    'purpose': purpose.key,
    'officeType': officeType.key,
    'officeName': officeName,
    'officeStreet': officeStreet,
    'officeCity': officeCity,
    'officeEmail': officeEmail,
    'senderName': senderName,
    'senderStreet': senderStreet,
    'senderCity': senderCity,
    'dateOfBirth': dateOfBirth,
    'nationality': nationality,
    'phone': phone,
    'email': email,
    'company': company,
    'jobTitle': jobTitle,
    'isAusbildung': isAusbildung,
    'startDate': startDate,
    'courseProvider': courseProvider,
    'courseStart': courseStart,
    'germanLevel': germanLevel,
    'permitExpiry': permitExpiry,
    'terminReason': terminReason,
    'newAddress': newAddress,
    'moveInDate': moveInDate,
    'terminTopic': terminTopic,
    'documentNames': documentNames,
    'questionSubject': questionSubject,
    'questionText': questionText,
    'attachmentNames': attachmentNames,
    'letterDate': today,
  };
}

/// The names that go into the letter's Anlagen list. For the document
/// submission purpose the user's own document list and the attached
/// files combine (duplicates removed, order kept).
List<String> officialAnlagenNames(OfficialLetterData d) {
  if (d.purpose != OfficialPurpose.submitDocuments) {
    return d.attachmentNames;
  }
  final out = <String>[];
  for (final n in [...d.documentNames, ...d.attachmentNames]) {
    final t = n.trim();
    if (t.isNotEmpty && !out.contains(t)) out.add(t);
  }
  return out;
}

/// Appends the Anlagen block after the signature when there is anything
/// to list. With no attachments the letter stays byte-identical.
String appendAnlagen(String letter, List<String> names) {
  if (names.isEmpty) return letter;
  final b = StringBuffer(letter);
  b.write('\n\nAnlagen:');
  for (final n in names) {
    b.write('\n- $n');
  }
  return b.toString();
}

/// The Betreff of the letter (also the email subject). Purpose
/// [OfficialPurpose.question] uses the subject line the user chose.
String officialLetterSubject(OfficialLetterData d) {
  switch (d.purpose) {
    case OfficialPurpose.workPermit:
      return workPermitSubject(d.toWorkPermitData());
    case OfficialPurpose.integrationCourse:
      return 'Antrag auf Berechtigung zur Teilnahme an einem '
          'Integrationskurs';
    case OfficialPurpose.permitExtension:
      return 'Bitte um einen Termin zur Verlängerung meines '
          'Aufenthaltstitels';
    case OfficialPurpose.appointmentGeneral:
      return 'Terminanfrage';
    case OfficialPurpose.appointmentRegistration:
      return 'Bitte um einen Termin zur Anmeldung einer Wohnung';
    case OfficialPurpose.appointmentJob:
      return 'Terminanfrage: Arbeit und Ausbildung';
    case OfficialPurpose.submitDocuments:
      return 'Einreichung von Unterlagen';
    case OfficialPurpose.question:
      return d.questionSubject;
  }
}

// ── Shared letter blocks (purposes 2 to 8; purpose 1 keeps the Phase 8
//    template, which carries the same blocks in its own wording) ───────

List<String> _personBlock(OfficialLetterData d) => [
  'Zu meiner Person:',
  'Name: ${d.senderName}',
  if (d.dateOfBirth.isNotEmpty) 'Geburtsdatum: ${d.dateOfBirth}',
  if (d.nationality.isNotEmpty) 'Staatsangehörigkeit: ${d.nationality}',
  'Anschrift: ${d.senderStreet}, ${d.senderCity}',
  if (d.phone.isNotEmpty) 'Telefon: ${d.phone}',
  if (d.email.isNotEmpty) 'E-Mail: ${d.email}',
];

/// Thanks line, with the contact sentence only in the form the user's
/// data supports (never pointing at a phone number that is not there).
List<String> _thanksLines(OfficialLetterData d) {
  const thanks = 'Ich danke Ihnen für Ihre Zeit und Ihre Unterstützung.';
  if (d.phone.isNotEmpty && d.email.isNotEmpty) {
    return [
      '$thanks Für Rückfragen erreichen Sie mich gern unter der oben '
          'genannten Telefonnummer oder per E-Mail.',
    ];
  }
  if (d.phone.isNotEmpty) {
    return [
      '$thanks Für Rückfragen erreichen Sie mich gern unter der oben '
          'genannten Telefonnummer.',
    ];
  }
  if (d.email.isNotEmpty) {
    return [
      '$thanks Für Rückfragen erreichen Sie mich gern unter der oben '
          'genannten E-Mail-Adresse.',
    ];
  }
  return [thanks];
}

/// The sentence with which appointment letters accept any slot the
/// office proposes.
const String _terminFlexLine =
    'Ich richte mich gern nach einem Termin, den Sie mir vorschlagen. '
    'Gern können Sie mir den Termin auch per E-Mail oder per Post '
    'mitteilen.';

String _assemble(OfficialLetterData d, List<String> body) {
  final lines = <String>[
    d.senderName,
    d.senderStreet,
    d.senderCity,
    '',
    d.officeName,
    if (d.officeStreet.isNotEmpty) d.officeStreet,
    if (d.officeCity.isNotEmpty) d.officeCity,
    '',
    '${workPermitPlaceName(d.senderCity)}, den ${d.today}',
    '',
    'Betreff: ${officialLetterSubject(d)}',
    '',
    'Sehr geehrte Damen und Herren,',
    '',
    ...body,
    '',
    'Mit freundlichen Grüßen',
    d.senderName,
  ];
  return appendAnlagen(lines.join('\n'), officialAnlagenNames(d));
}

/// The full German letter text for any purpose (subject included after
/// the address blocks, Geschäftsbrief style). Also used as the email
/// body, so it stays plain text.
String buildOfficialLetter(OfficialLetterData d) {
  switch (d.purpose) {
    case OfficialPurpose.workPermit:
      return appendAnlagen(
        buildWorkPermitLetter(d.toWorkPermitData()),
        officialAnlagenNames(d),
      );
    case OfficialPurpose.integrationCourse:
      return _buildIntegrationCourse(d);
    case OfficialPurpose.permitExtension:
      return _buildPermitExtension(d);
    case OfficialPurpose.appointmentGeneral:
      return _buildAppointmentGeneral(d);
    case OfficialPurpose.appointmentRegistration:
      return _buildAppointmentRegistration(d);
    case OfficialPurpose.appointmentJob:
      return _buildAppointmentJob(d);
    case OfficialPurpose.submitDocuments:
      return _buildSubmitDocuments(d);
    case OfficialPurpose.question:
      return _buildQuestion(d);
  }
}

String _buildIntegrationCourse(OfficialLetterData d) {
  final courseBits = <String>[
    if (d.courseStart.isNotEmpty)
      'Ich möchte den Kurs gern ab dem ${d.courseStart} beginnen.',
    if (d.courseProvider.isNotEmpty)
      'Als Kursträger habe ich ${d.courseProvider} vorgesehen.',
    if (d.germanLevel.isNotEmpty)
      'Mein aktuelles Sprachniveau ist ${d.germanLevel}.',
  ];
  return _assemble(d, [
    'mein Name ist ${d.senderName} und ich bitte Sie um die '
        'Berechtigung, an einem Integrationskurs teilnehmen zu dürfen.',
    '',
    ..._personBlock(d),
    if (courseBits.isNotEmpty) ...['', courseBits.join(' ')],
    '',
    'Die deutsche Sprache ist für meine Arbeit, für meine Ausbildung '
        'und für meine Integration in Deutschland sehr wichtig. Ich '
        'bitte Sie daher freundlich, mir die Berechtigung für den '
        'Integrationskurs zu erteilen oder mir mitzuteilen, wie ich '
        'sie erhalten kann.',
    '',
    ..._thanksLines(d),
  ]);
}

String _buildPermitExtension(OfficialLetterData d) {
  return _assemble(d, [
    d.permitExpiry.isNotEmpty
        ? 'mein Name ist ${d.senderName}. Mein Aufenthaltstitel läuft '
              'am ${d.permitExpiry} ab. Ich bitte Sie freundlich um '
              'einen Termin zur Verlängerung meines Aufenthaltstitels.'
        : 'mein Name ist ${d.senderName}. Mein Aufenthaltstitel läuft '
              'bald ab. Ich bitte Sie freundlich um einen Termin zur '
              'Verlängerung meines Aufenthaltstitels.',
    '',
    ..._personBlock(d),
    '',
    _terminFlexLine,
    '',
    ..._thanksLines(d),
  ]);
}

String _buildAppointmentGeneral(OfficialLetterData d) {
  return _assemble(d, [
    'mein Name ist ${d.senderName} und ich bitte Sie freundlich um '
        'einen Termin.',
    if (d.terminReason.isNotEmpty) ...['', 'Mein Anliegen: ${d.terminReason}'],
    '',
    ..._personBlock(d),
    '',
    _terminFlexLine,
    '',
    ..._thanksLines(d),
  ]);
}

String _buildAppointmentRegistration(OfficialLetterData d) {
  return _assemble(d, [
    d.moveInDate.isNotEmpty
        ? 'mein Name ist ${d.senderName}. Ich bin am ${d.moveInDate} '
              'in eine neue Wohnung gezogen und bitte Sie freundlich '
              'um einen Termin zur Anmeldung meiner Wohnung.'
        : 'mein Name ist ${d.senderName}. Ich bin in eine neue '
              'Wohnung gezogen und bitte Sie freundlich um einen Termin '
              'zur Anmeldung meiner Wohnung.',
    if (d.newAddress.isNotEmpty) ...[
      '',
      'Meine neue Anschrift lautet: ${d.newAddress}',
    ],
    '',
    ..._personBlock(d),
    '',
    _terminFlexLine,
    '',
    ..._thanksLines(d),
  ]);
}

String _buildAppointmentJob(OfficialLetterData d) {
  return _assemble(d, [
    'mein Name ist ${d.senderName} und ich bitte Sie freundlich um '
        'einen Termin für ein Beratungsgespräch.',
    if (d.terminTopic.isNotEmpty) ...[
      '',
      'Ich möchte gern über folgendes Thema sprechen: '
          '${d.terminTopic}',
    ],
    '',
    ..._personBlock(d),
    '',
    _terminFlexLine,
    '',
    ..._thanksLines(d),
  ]);
}

String _buildSubmitDocuments(OfficialLetterData d) {
  final names = officialAnlagenNames(d);
  return _assemble(d, [
    if (names.isNotEmpty) ...[
      'mein Name ist ${d.senderName}. Mit diesem Schreiben reiche '
          'ich Ihnen die folgenden Unterlagen ein:',
      '',
      for (final n in names) '- $n',
    ] else
      'mein Name ist ${d.senderName}. Mit diesem Schreiben reiche '
          'ich Ihnen die angeforderten Unterlagen ein.',
    '',
    ..._personBlock(d),
    '',
    'Bitte teilen Sie mir mit, wenn Sie noch weitere Unterlagen von '
        'mir brauchen. Ich danke Ihnen für eine kurze Bestätigung, '
        'dass die Unterlagen bei Ihnen angekommen sind.',
    '',
    ..._thanksLines(d),
  ]);
}

String _buildQuestion(OfficialLetterData d) {
  return _assemble(d, [
    'mein Name ist ${d.senderName}. Ich wende mich mit einem '
        'Anliegen an Sie und bitte Sie um Ihre Unterstützung.',
    '',
    d.questionText,
    '',
    ..._personBlock(d),
    '',
    'Ich danke Ihnen für Ihre Antwort und Ihre Unterstützung.',
  ]);
}

// ── Plain-language explanations, one per purpose, in the app's 4
//    languages. Authored summaries of the fixed templates, not
//    word-for-word translations; each names the office and the key
//    data, and each is explicit that the office decides. The "not
//    legal advice" note is a separate UI string shown next to them.
// ─────────────────────────────────────────────────────────────────────

String officialLetterExplanation(String lang, OfficialLetterData d) {
  switch (d.purpose) {
    case OfficialPurpose.workPermit:
      return workPermitExplanation(lang, d.toWorkPermitData());
    case OfficialPurpose.integrationCourse:
      return _explainIntegrationCourse(lang, d);
    case OfficialPurpose.permitExtension:
      return _explainPermitExtension(lang, d);
    case OfficialPurpose.appointmentGeneral:
      return _explainAppointmentGeneral(lang, d);
    case OfficialPurpose.appointmentRegistration:
      return _explainAppointmentRegistration(lang, d);
    case OfficialPurpose.appointmentJob:
      return _explainAppointmentJob(lang, d);
    case OfficialPurpose.submitDocuments:
      return _explainSubmitDocuments(lang, d);
    case OfficialPurpose.question:
      return _explainQuestion(lang, d);
  }
}

String _explainIntegrationCourse(String lang, OfficialLetterData d) {
  switch (lang) {
    case 'ps':
      return 'دا لیک ${d.officeName} ته وايي چې تاسو څوک یاست او له '
          'دفتر څخه غوښتنه کوي چې تاسو ته د ادغام کورس (Integrationskurs) '
          'اجازه درکړي، تر څو الماني ژبه زده کړئ. لیک دا هم وايي چې '
          'الماني ژبه ستاسو د کار او په المان کې د ژوند لپاره مهمه ده. '
          'پرېکړه دفتر کوي. دا لیک د اجازې تضمین نه کوي.';
    case 'fa':
      return 'این نامه به ${d.officeName} می‌گوید که شما چه کسی هستید '
          'و از اداره درخواست می‌کند که به شما اجازه شرکت در دوره '
          'ادغام (Integrationskurs) را بدهد تا زبان آلمانی یاد بگیرید. '
          'نامه همچنین می‌گوید که زبان آلمانی برای کار و زندگی شما در '
          'آلمان مهم است. تصمیم با اداره است. این نامه اجازه را تضمین '
          'نمی‌کند.';
    case 'ar':
      return 'تخبر هذه الرسالة ${d.officeName} من أنت وتطلب من المكتب '
          'أن يعطيك تصريح المشاركة في دورة الاندماج (Integrationskurs) '
          'حتى تتعلم اللغة الألمانية. وتقول الرسالة أيضا إن اللغة '
          'الألمانية مهمة لعملك ولحياتك في ألمانيا. المكتب يقرر. هذه '
          'الرسالة لا تضمن التصريح.';
    case 'en':
      return 'This letter tells ${d.officeName} who you are and asks '
          'the office for the permission (Berechtigung) to take an '
          'integration course so you can learn German. It also says '
          'that German is important for your work and your life in '
          'Germany. The office decides. This letter does not guarantee '
          'the permission.';
    case 'de':
    default:
      return 'Dieser Brief sagt der Behörde ${d.officeName}, wer Sie '
          'sind, und bittet sie um die Berechtigung für einen '
          'Integrationskurs, damit Sie Deutsch lernen können. Er sagt '
          'auch, dass Deutsch für Ihre Arbeit und Ihr Leben in '
          'Deutschland wichtig ist. Die Behörde entscheidet. Dieser '
          'Brief garantiert keine Berechtigung.';
  }
}

String _explainPermitExtension(String lang, OfficialLetterData d) {
  final expiryNotePs = d.permitExpiry.isNotEmpty
      ? ' ستاسو د اوسېدو اجازه د ${d.permitExpiry} پای ته رسېږي.'
      : '';
  final expiryNoteFa = d.permitExpiry.isNotEmpty
      ? ' اجازه اقامت شما در تاریخ ${d.permitExpiry} تمام می‌شود.'
      : '';
  final expiryNoteAr = d.permitExpiry.isNotEmpty
      ? ' ينتهي تصريح إقامتك في تاريخ ${d.permitExpiry}.'
      : '';
  final expiryNoteEn = d.permitExpiry.isNotEmpty
      ? ' Your residence permit ends on ${d.permitExpiry}.'
      : '';
  final expiryNoteDe = d.permitExpiry.isNotEmpty
      ? ' Ihr Aufenthaltstitel läuft am ${d.permitExpiry} ab.'
      : '';
  switch (lang) {
    case 'ps':
      return 'دا لیک ${d.officeName} ته وايي چې تاسو څوک یاست او له '
          'دفتر څخه د خپل د اوسېدو اجازې د غځولو لپاره وخت غواړي.'
          '$expiryNotePs لیک وايي چې تاسو هر وخت منئ چې دفتر یې '
          'وړاندیز کوي. پرېکړه دفتر کوي.';
    case 'fa':
      return 'این نامه به ${d.officeName} می‌گوید که شما چه کسی هستید '
          'و از اداره برای تمدید اجازه اقامت خود یک قرار می‌خواهد.'
          '$expiryNoteFa نامه می‌گوید که شما هر قراری را که اداره '
          'پیشنهاد کند قبول می‌کنید. تصمیم با اداره است.';
    case 'ar':
      return 'تخبر هذه الرسالة ${d.officeName} من أنت وتطلب من المكتب '
          'موعدا لتمديد تصريح إقامتك.$expiryNoteAr وتقول الرسالة إنك '
          'تقبل أي موعد يقترحه المكتب. المكتب يقرر.';
    case 'en':
      return 'This letter tells ${d.officeName} who you are and asks '
          'the office for an appointment to extend your residence '
          'permit.$expiryNoteEn It says you accept any appointment '
          'the office suggests. The office decides.';
    case 'de':
    default:
      return 'Dieser Brief sagt der Behörde ${d.officeName}, wer Sie '
          'sind, und bittet sie um einen Termin zur Verlängerung '
          'Ihres Aufenthaltstitels.$expiryNoteDe Er sagt, dass Sie '
          'jeden Termin annehmen, den die Behörde vorschlägt. Die '
          'Behörde entscheidet.';
  }
}

String _explainAppointmentGeneral(String lang, OfficialLetterData d) {
  switch (lang) {
    case 'ps':
      return 'دا لیک ${d.officeName} ته وايي چې تاسو څوک یاست او له '
          'دفتر څخه وخت غواړي. لیک ستاسو موضوع هم لنډ بیانوي، تر څو '
          'دفتر پوه شي چې تاسو څه ته اړتیا لرئ. لیک وايي چې تاسو هر '
          'وخت منئ چې دفتر یې وړاندیز کوي. پرېکړه دفتر کوي.';
    case 'fa':
      return 'این نامه به ${d.officeName} می‌گوید که شما چه کسی هستید '
          'و از اداره یک قرار می‌خواهد. نامه موضوع شما را هم کوتاه '
          'توضیح می‌دهد تا اداره بداند چه نیاز دارید. نامه می‌گوید که '
          'شما هر قراری را که اداره پیشنهاد کند قبول می‌کنید. تصمیم '
          'با اداره است.';
    case 'ar':
      return 'تخبر هذه الرسالة ${d.officeName} من أنت وتطلب من المكتب '
          'موعدا. وتذكر الرسالة أيضا موضوعك في سطر واحد، حتى يعرف '
          'المكتب ما تحتاجه. وتقول إنك تقبل أي موعد يقترحه المكتب. '
          'المكتب يقرر.';
    case 'en':
      return 'This letter tells ${d.officeName} who you are and asks '
          'the office for an appointment. It also states your concern '
          'in one line, so the office knows what you need. It says '
          'you accept any appointment the office suggests. The office '
          'decides.';
    case 'de':
    default:
      return 'Dieser Brief sagt der Behörde ${d.officeName}, wer Sie '
          'sind, und bittet sie um einen Termin. Er nennt auch Ihr '
          'Anliegen in einem Satz, damit die Behörde weiß, was Sie '
          'brauchen. Er sagt, dass Sie jeden Termin annehmen, den die '
          'Behörde vorschlägt. Die Behörde entscheidet.';
  }
}

String _explainAppointmentRegistration(String lang, OfficialLetterData d) {
  final addrPs = d.newAddress.isNotEmpty
      ? ' ستاسو نوی پته: ${d.newAddress}.'
      : '';
  final addrFa = d.newAddress.isNotEmpty
      ? ' نشانی جدید شما: ${d.newAddress}.'
      : '';
  final addrAr = d.newAddress.isNotEmpty
      ? ' عنوانك الجديد: ${d.newAddress}.'
      : '';
  final addrEn = d.newAddress.isNotEmpty
      ? ' Your new address: ${d.newAddress}.'
      : '';
  final addrDe = d.newAddress.isNotEmpty
      ? ' Ihre neue Anschrift: ${d.newAddress}.'
      : '';
  switch (lang) {
    case 'ps':
      return 'دا لیک ${d.officeName} ته وايي چې تاسو څوک یاست، تاسو '
          'نوي کور ته کډه شوي یاست او د خپلې پتې د ثبت (Anmeldung) '
          'لپاره وخت غواړئ.$addrPs په المان کې هر څوک باید خپله پته '
          'په دفتر کې ثبت کړي. پرېکړه دفتر کوي.';
    case 'fa':
      return 'این نامه به ${d.officeName} می‌گوید که شما چه کسی هستید، '
          'به خانه جدید نقل مکان کرده‌اید و برای ثبت نشانی خود '
          '(Anmeldung) یک قرار می‌خواهید.$addrFa در آلمان هر کس باید '
          'نشانی خود را در اداره ثبت کند. تصمیم با اداره است.';
    case 'ar':
      return 'تخبر هذه الرسالة ${d.officeName} من أنت، وأنك انتقلت إلى '
          'سكن جديد، وتطلب موعدا لتسجيل عنوانك (Anmeldung).$addrAr في '
          'ألمانيا يجب على كل شخص تسجيل عنوانه في المكتب. المكتب يقرر.';
    case 'en':
      return 'This letter tells ${d.officeName} who you are, that you '
          'moved into a new home, and asks for an appointment to '
          'register your address (Anmeldung).$addrEn In Germany '
          'everyone must register their address at the office. The '
          'office decides.';
    case 'de':
    default:
      return 'Dieser Brief sagt der Behörde ${d.officeName}, wer Sie '
          'sind, dass Sie in eine neue Wohnung gezogen sind, und '
          'bittet sie um einen Termin zur Anmeldung Ihrer '
          'Wohnung.$addrDe In Deutschland muss jeder seine Anschrift '
          'bei der Behörde anmelden. Die Behörde entscheidet.';
  }
}

String _explainAppointmentJob(String lang, OfficialLetterData d) {
  switch (lang) {
    case 'ps':
      return 'دا لیک ${d.officeName} ته وايي چې تاسو څوک یاست او د '
          'کار او روزنې په اړه د مشورې لپاره وخت غواړي. لیک دا هم '
          'وايي چې تاسو د څه په اړه خبرې کول غواړئ او چې تاسو هر '
          'وخت منئ چې دفتر یې وړاندیز کوي. پرېکړه دفتر کوي.';
    case 'fa':
      return 'این نامه به ${d.officeName} می‌گوید که شما چه کسی هستید '
          'و برای مشاوره درباره کار و آموزش یک قرار می‌خواهد. نامه '
          'همچنین می‌گوید که می‌خواهید درباره چه چیزی صحبت کنید و '
          'شما هر قراری را که اداره پیشنهاد کند قبول می‌کنید. تصمیم '
          'با اداره است.';
    case 'ar':
      return 'تخبر هذه الرسالة ${d.officeName} من أنت وتطلب موعدا '
          'للمشورة حول العمل والتدريب المهني. وتقول الرسالة أيضا عن '
          'ماذا تريد أن تتحدث، وأنك تقبل أي موعد يقترحه المكتب. '
          'المكتب يقرر.';
    case 'en':
      return 'This letter tells ${d.officeName} who you are and asks '
          'for an appointment to talk about work and Ausbildung. It '
          'also says what you want to talk about, and that you '
          'accept any appointment the office suggests. The office '
          'decides.';
    case 'de':
    default:
      return 'Dieser Brief sagt der Behörde ${d.officeName}, wer Sie '
          'sind, und bittet sie um einen Termin für ein Gespräch '
          'über Arbeit und Ausbildung. Er sagt auch, worüber Sie '
          'sprechen möchten, und dass Sie jeden Termin annehmen, '
          'den die Behörde vorschlägt. Die Behörde entscheidet.';
  }
}

String _explainSubmitDocuments(String lang, OfficialLetterData d) {
  final names = officialAnlagenNames(d);
  final listPs = names.isNotEmpty ? ' سندونه: ${names.join('، ')}.' : '';
  final listFa = names.isNotEmpty ? ' مدارک: ${names.join('، ')}.' : '';
  final listAr = names.isNotEmpty ? ' المستندات: ${names.join('، ')}.' : '';
  final listEn = names.isNotEmpty ? ' Documents: ${names.join(', ')}.' : '';
  final listDe = names.isNotEmpty ? ' Unterlagen: ${names.join(', ')}.' : '';
  switch (lang) {
    case 'ps':
      return 'دا لیک ${d.officeName} ته وايي چې تاسو څوک یاست او دا '
          'سندونه ورسره استوئ.$listPs لیک له دفتر څخه غوښتنه کوي چې '
          'تاسو ته ووايي ایا سندونه ورسېدل او ایا نورو سندونو ته '
          'اړتیا شته. پرېکړه دفتر کوي.';
    case 'fa':
      return 'این نامه به ${d.officeName} می‌گوید که شما چه کسی هستید '
          'و این مدارک را برای اداره می‌فرستید.$listFa نامه از اداره '
          'می‌خواهد که به شما بگوید آیا مدارک رسیده‌اند و آیا مدارک '
          'دیگری لازم است. تصمیم با اداره است.';
    case 'ar':
      return 'تخبر هذه الرسالة ${d.officeName} من أنت وترسل هذه '
          'المستندات إلى المكتب.$listAr وتطلب الرسالة من المكتب أن '
          'يخبرك ما إذا وصلت المستندات وما إذا كان يحتاج إلى شيء آخر '
          'منك. المكتب يقرر.';
    case 'en':
      return 'This letter tells ${d.officeName} who you are and sends '
          'these documents to the office.$listEn It asks the office '
          'to tell you that the documents arrived and whether it '
          'needs anything else from you. The office decides.';
    case 'de':
    default:
      return 'Dieser Brief sagt der Behörde ${d.officeName}, wer Sie '
          'sind, und sendet ihr diese Unterlagen.$listDe Er bittet '
          'die Behörde, Ihnen zu bestätigen, dass die Unterlagen '
          'angekommen sind, und zu sagen, ob sie noch etwas von '
          'Ihnen braucht. Die Behörde entscheidet.';
  }
}

String _explainQuestion(String lang, OfficialLetterData d) {
  switch (lang) {
    case 'ps':
      return 'دا لیک ${d.officeName} ته ستاسو خپله پوښتنه یا ستونزه '
          'استوي، په هماغو ټکو چې تاسو لیکلي دي. په سر کې لیک وايي '
          'چې تاسو څوک یاست او په پای کې ستاسو معلومات د ځواب لپاره '
          'ورکوي. دفتر ستاسو پوښتنې ته ځواب ورکوي.';
    case 'fa':
      return 'این نامه سؤال یا مشکل خودتان را با همان کلماتی که '
          'نوشته‌اید به ${d.officeName} می‌فرستد. در آغاز نامه '
          'می‌گوید که شما چه کسی هستید و در پایان اطلاعات شما را '
          'برای پاسخ می‌دهد. اداره به سؤال شما جواب می‌دهد.';
    case 'ar':
      return 'ترسل هذه الرسالة سؤالك أو مشكلتك الخاصة إلى '
          '${d.officeName}، بالكلمات التي كتبتها بنفسك. في البداية '
          'تقول من أنت، وفي النهاية تعطي بياناتك حتى يستطيع المكتب '
          'الرد عليك. المكتب يجيب على سؤالك.';
    case 'en':
      return 'This letter sends your own question or problem to '
          '${d.officeName}, in the words you wrote yourself. At the '
          'top it says who you are, and at the end it gives your '
          'data so the office can answer you. The office answers '
          'your question.';
    case 'de':
    default:
      return 'Dieser Brief sendet Ihre eigene Frage oder Ihr Problem '
          'an ${d.officeName}, in den Worten, die Sie selbst '
          'geschrieben haben. Am Anfang sagt er, wer Sie sind, und '
          'am Ende nennt er Ihre Daten, damit die Behörde Ihnen '
          'antworten kann. Die Behörde antwortet auf Ihre Frage.';
  }
}
