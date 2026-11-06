// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfileEntriesTable extends ProfileEntries
    with TableInfo<$ProfileEntriesTable, ProfileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'fullName',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dobDayMeta = const VerificationMeta('dobDay');
  @override
  late final GeneratedColumn<String> dobDay = GeneratedColumn<String>(
    'dobDay',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dobMonthMeta = const VerificationMeta(
    'dobMonth',
  );
  @override
  late final GeneratedColumn<String> dobMonth = GeneratedColumn<String>(
    'dobMonth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dobYearMeta = const VerificationMeta(
    'dobYear',
  );
  @override
  late final GeneratedColumn<String> dobYear = GeneratedColumn<String>(
    'dobYear',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photoPath',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skillMeta = const VerificationMeta('skill');
  @override
  late final GeneratedColumn<String> skill = GeneratedColumn<String>(
    'skill',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workExperienceMeta = const VerificationMeta(
    'workExperience',
  );
  @override
  late final GeneratedColumn<String> workExperience = GeneratedColumn<String>(
    'workExperience',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workTypeMeta = const VerificationMeta(
    'workType',
  );
  @override
  late final GeneratedColumn<String> workType = GeneratedColumn<String>(
    'workType',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toolsMeta = const VerificationMeta('tools');
  @override
  late final GeneratedColumn<String> tools = GeneratedColumn<String>(
    'tools',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drivingLicenseMeta = const VerificationMeta(
    'drivingLicense',
  );
  @override
  late final GeneratedColumn<String> drivingLicense = GeneratedColumn<String>(
    'drivingLicense',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languagesMeta = const VerificationMeta(
    'languages',
  );
  @override
  late final GeneratedColumn<String> languages = GeneratedColumn<String>(
    'languages',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageProficiencyMeta =
      const VerificationMeta('languageProficiency');
  @override
  late final GeneratedColumn<String> languageProficiency =
      GeneratedColumn<String>(
        'languageProficiency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _availabilityMeta = const VerificationMeta(
    'availability',
  );
  @override
  late final GeneratedColumn<String> availability = GeneratedColumn<String>(
    'availability',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'startDate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _educationLevelMeta = const VerificationMeta(
    'educationLevel',
  );
  @override
  late final GeneratedColumn<String> educationLevel = GeneratedColumn<String>(
    'educationLevel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _educationOrtMeta = const VerificationMeta(
    'educationOrt',
  );
  @override
  late final GeneratedColumn<String> educationOrt = GeneratedColumn<String>(
    'educationOrt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _educationDurationMeta = const VerificationMeta(
    'educationDuration',
  );
  @override
  late final GeneratedColumn<String> educationDuration =
      GeneratedColumn<String>(
        'educationDuration',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refNameMeta = const VerificationMeta(
    'refName',
  );
  @override
  late final GeneratedColumn<String> refName = GeneratedColumn<String>(
    'refName',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refPhoneMeta = const VerificationMeta(
    'refPhone',
  );
  @override
  late final GeneratedColumn<String> refPhone = GeneratedColumn<String>(
    'refPhone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previousEmployersMeta = const VerificationMeta(
    'previousEmployers',
  );
  @override
  late final GeneratedColumn<String> previousEmployers =
      GeneratedColumn<String>(
        'previousEmployers',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _previousJobTitlesMeta = const VerificationMeta(
    'previousJobTitles',
  );
  @override
  late final GeneratedColumn<String> previousJobTitles =
      GeneratedColumn<String>(
        'previousJobTitles',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _previousJobDurationsMeta =
      const VerificationMeta('previousJobDurations');
  @override
  late final GeneratedColumn<String> previousJobDurations =
      GeneratedColumn<String>(
        'previousJobDurations',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sharedWorkOrtsMeta = const VerificationMeta(
    'sharedWorkOrts',
  );
  @override
  late final GeneratedColumn<String> sharedWorkOrts = GeneratedColumn<String>(
    'sharedWorkOrts',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sharedWorkTypesMeta = const VerificationMeta(
    'sharedWorkTypes',
  );
  @override
  late final GeneratedColumn<String> sharedWorkTypes = GeneratedColumn<String>(
    'sharedWorkTypes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sharedItSkillsMeta = const VerificationMeta(
    'sharedItSkills',
  );
  @override
  late final GeneratedColumn<String> sharedItSkills = GeneratedColumn<String>(
    'sharedItSkills',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ausbildungEduInstitutionsMeta =
      const VerificationMeta('ausbildungEduInstitutions');
  @override
  late final GeneratedColumn<String> ausbildungEduInstitutions =
      GeneratedColumn<String>(
        'ausbildungEduInstitutions',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ausbildungEduOrtsMeta = const VerificationMeta(
    'ausbildungEduOrts',
  );
  @override
  late final GeneratedColumn<String> ausbildungEduOrts =
      GeneratedColumn<String>(
        'ausbildungEduOrts',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ausbildungEduTypesMeta =
      const VerificationMeta('ausbildungEduTypes');
  @override
  late final GeneratedColumn<String> ausbildungEduTypes =
      GeneratedColumn<String>(
        'ausbildungEduTypes',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ausbildungEduAbschlussMeta =
      const VerificationMeta('ausbildungEduAbschluss');
  @override
  late final GeneratedColumn<String> ausbildungEduAbschluss =
      GeneratedColumn<String>(
        'ausbildungEduAbschluss',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ausbildungEduDurationsMeta =
      const VerificationMeta('ausbildungEduDurations');
  @override
  late final GeneratedColumn<String> ausbildungEduDurations =
      GeneratedColumn<String>(
        'ausbildungEduDurations',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ausbildungEduGradesMeta =
      const VerificationMeta('ausbildungEduGrades');
  @override
  late final GeneratedColumn<String> ausbildungEduGrades =
      GeneratedColumn<String>(
        'ausbildungEduGrades',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ausbildungEscoSkillsMeta =
      const VerificationMeta('ausbildungEscoSkills');
  @override
  late final GeneratedColumn<String> ausbildungEscoSkills =
      GeneratedColumn<String>(
        'ausbildungEscoSkills',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ausbildungTargetOccupationMeta =
      const VerificationMeta('ausbildungTargetOccupation');
  @override
  late final GeneratedColumn<String> ausbildungTargetOccupation =
      GeneratedColumn<String>(
        'ausbildungTargetOccupation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ausbildungTargetOccupationUriMeta =
      const VerificationMeta('ausbildungTargetOccupationUri');
  @override
  late final GeneratedColumn<String> ausbildungTargetOccupationUri =
      GeneratedColumn<String>(
        'ausbildungTargetOccupationUri',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _schulabschlussMeta = const VerificationMeta(
    'schulabschluss',
  );
  @override
  late final GeneratedColumn<String> schulabschluss = GeneratedColumn<String>(
    'schulabschluss',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schulabschlussNoteMeta =
      const VerificationMeta('schulabschlussNote');
  @override
  late final GeneratedColumn<String> schulabschlussNote =
      GeneratedColumn<String>(
        'schulabschlussNote',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _extraDataMeta = const VerificationMeta(
    'extraData',
  );
  @override
  late final GeneratedColumn<String> extraData = GeneratedColumn<String>(
    'extraData',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    dobDay,
    dobMonth,
    dobYear,
    country,
    phone,
    email,
    street,
    city,
    photoPath,
    skill,
    workExperience,
    workType,
    tools,
    drivingLicense,
    languages,
    languageProficiency,
    availability,
    startDate,
    educationLevel,
    educationOrt,
    educationDuration,
    reference,
    refName,
    refPhone,
    previousEmployers,
    previousJobTitles,
    previousJobDurations,
    sharedWorkOrts,
    sharedWorkTypes,
    sharedItSkills,
    ausbildungEduInstitutions,
    ausbildungEduOrts,
    ausbildungEduTypes,
    ausbildungEduAbschluss,
    ausbildungEduDurations,
    ausbildungEduGrades,
    ausbildungEscoSkills,
    ausbildungTargetOccupation,
    ausbildungTargetOccupationUri,
    schulabschluss,
    schulabschlussNote,
    extraData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fullName')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['fullName']!, _fullNameMeta),
      );
    }
    if (data.containsKey('dobDay')) {
      context.handle(
        _dobDayMeta,
        dobDay.isAcceptableOrUnknown(data['dobDay']!, _dobDayMeta),
      );
    }
    if (data.containsKey('dobMonth')) {
      context.handle(
        _dobMonthMeta,
        dobMonth.isAcceptableOrUnknown(data['dobMonth']!, _dobMonthMeta),
      );
    }
    if (data.containsKey('dobYear')) {
      context.handle(
        _dobYearMeta,
        dobYear.isAcceptableOrUnknown(data['dobYear']!, _dobYearMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('photoPath')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photoPath']!, _photoPathMeta),
      );
    }
    if (data.containsKey('skill')) {
      context.handle(
        _skillMeta,
        skill.isAcceptableOrUnknown(data['skill']!, _skillMeta),
      );
    }
    if (data.containsKey('workExperience')) {
      context.handle(
        _workExperienceMeta,
        workExperience.isAcceptableOrUnknown(
          data['workExperience']!,
          _workExperienceMeta,
        ),
      );
    }
    if (data.containsKey('workType')) {
      context.handle(
        _workTypeMeta,
        workType.isAcceptableOrUnknown(data['workType']!, _workTypeMeta),
      );
    }
    if (data.containsKey('tools')) {
      context.handle(
        _toolsMeta,
        tools.isAcceptableOrUnknown(data['tools']!, _toolsMeta),
      );
    }
    if (data.containsKey('drivingLicense')) {
      context.handle(
        _drivingLicenseMeta,
        drivingLicense.isAcceptableOrUnknown(
          data['drivingLicense']!,
          _drivingLicenseMeta,
        ),
      );
    }
    if (data.containsKey('languages')) {
      context.handle(
        _languagesMeta,
        languages.isAcceptableOrUnknown(data['languages']!, _languagesMeta),
      );
    }
    if (data.containsKey('languageProficiency')) {
      context.handle(
        _languageProficiencyMeta,
        languageProficiency.isAcceptableOrUnknown(
          data['languageProficiency']!,
          _languageProficiencyMeta,
        ),
      );
    }
    if (data.containsKey('availability')) {
      context.handle(
        _availabilityMeta,
        availability.isAcceptableOrUnknown(
          data['availability']!,
          _availabilityMeta,
        ),
      );
    }
    if (data.containsKey('startDate')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['startDate']!, _startDateMeta),
      );
    }
    if (data.containsKey('educationLevel')) {
      context.handle(
        _educationLevelMeta,
        educationLevel.isAcceptableOrUnknown(
          data['educationLevel']!,
          _educationLevelMeta,
        ),
      );
    }
    if (data.containsKey('educationOrt')) {
      context.handle(
        _educationOrtMeta,
        educationOrt.isAcceptableOrUnknown(
          data['educationOrt']!,
          _educationOrtMeta,
        ),
      );
    }
    if (data.containsKey('educationDuration')) {
      context.handle(
        _educationDurationMeta,
        educationDuration.isAcceptableOrUnknown(
          data['educationDuration']!,
          _educationDurationMeta,
        ),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('refName')) {
      context.handle(
        _refNameMeta,
        refName.isAcceptableOrUnknown(data['refName']!, _refNameMeta),
      );
    }
    if (data.containsKey('refPhone')) {
      context.handle(
        _refPhoneMeta,
        refPhone.isAcceptableOrUnknown(data['refPhone']!, _refPhoneMeta),
      );
    }
    if (data.containsKey('previousEmployers')) {
      context.handle(
        _previousEmployersMeta,
        previousEmployers.isAcceptableOrUnknown(
          data['previousEmployers']!,
          _previousEmployersMeta,
        ),
      );
    }
    if (data.containsKey('previousJobTitles')) {
      context.handle(
        _previousJobTitlesMeta,
        previousJobTitles.isAcceptableOrUnknown(
          data['previousJobTitles']!,
          _previousJobTitlesMeta,
        ),
      );
    }
    if (data.containsKey('previousJobDurations')) {
      context.handle(
        _previousJobDurationsMeta,
        previousJobDurations.isAcceptableOrUnknown(
          data['previousJobDurations']!,
          _previousJobDurationsMeta,
        ),
      );
    }
    if (data.containsKey('sharedWorkOrts')) {
      context.handle(
        _sharedWorkOrtsMeta,
        sharedWorkOrts.isAcceptableOrUnknown(
          data['sharedWorkOrts']!,
          _sharedWorkOrtsMeta,
        ),
      );
    }
    if (data.containsKey('sharedWorkTypes')) {
      context.handle(
        _sharedWorkTypesMeta,
        sharedWorkTypes.isAcceptableOrUnknown(
          data['sharedWorkTypes']!,
          _sharedWorkTypesMeta,
        ),
      );
    }
    if (data.containsKey('sharedItSkills')) {
      context.handle(
        _sharedItSkillsMeta,
        sharedItSkills.isAcceptableOrUnknown(
          data['sharedItSkills']!,
          _sharedItSkillsMeta,
        ),
      );
    }
    if (data.containsKey('ausbildungEduInstitutions')) {
      context.handle(
        _ausbildungEduInstitutionsMeta,
        ausbildungEduInstitutions.isAcceptableOrUnknown(
          data['ausbildungEduInstitutions']!,
          _ausbildungEduInstitutionsMeta,
        ),
      );
    }
    if (data.containsKey('ausbildungEduOrts')) {
      context.handle(
        _ausbildungEduOrtsMeta,
        ausbildungEduOrts.isAcceptableOrUnknown(
          data['ausbildungEduOrts']!,
          _ausbildungEduOrtsMeta,
        ),
      );
    }
    if (data.containsKey('ausbildungEduTypes')) {
      context.handle(
        _ausbildungEduTypesMeta,
        ausbildungEduTypes.isAcceptableOrUnknown(
          data['ausbildungEduTypes']!,
          _ausbildungEduTypesMeta,
        ),
      );
    }
    if (data.containsKey('ausbildungEduAbschluss')) {
      context.handle(
        _ausbildungEduAbschlussMeta,
        ausbildungEduAbschluss.isAcceptableOrUnknown(
          data['ausbildungEduAbschluss']!,
          _ausbildungEduAbschlussMeta,
        ),
      );
    }
    if (data.containsKey('ausbildungEduDurations')) {
      context.handle(
        _ausbildungEduDurationsMeta,
        ausbildungEduDurations.isAcceptableOrUnknown(
          data['ausbildungEduDurations']!,
          _ausbildungEduDurationsMeta,
        ),
      );
    }
    if (data.containsKey('ausbildungEduGrades')) {
      context.handle(
        _ausbildungEduGradesMeta,
        ausbildungEduGrades.isAcceptableOrUnknown(
          data['ausbildungEduGrades']!,
          _ausbildungEduGradesMeta,
        ),
      );
    }
    if (data.containsKey('ausbildungEscoSkills')) {
      context.handle(
        _ausbildungEscoSkillsMeta,
        ausbildungEscoSkills.isAcceptableOrUnknown(
          data['ausbildungEscoSkills']!,
          _ausbildungEscoSkillsMeta,
        ),
      );
    }
    if (data.containsKey('ausbildungTargetOccupation')) {
      context.handle(
        _ausbildungTargetOccupationMeta,
        ausbildungTargetOccupation.isAcceptableOrUnknown(
          data['ausbildungTargetOccupation']!,
          _ausbildungTargetOccupationMeta,
        ),
      );
    }
    if (data.containsKey('ausbildungTargetOccupationUri')) {
      context.handle(
        _ausbildungTargetOccupationUriMeta,
        ausbildungTargetOccupationUri.isAcceptableOrUnknown(
          data['ausbildungTargetOccupationUri']!,
          _ausbildungTargetOccupationUriMeta,
        ),
      );
    }
    if (data.containsKey('schulabschluss')) {
      context.handle(
        _schulabschlussMeta,
        schulabschluss.isAcceptableOrUnknown(
          data['schulabschluss']!,
          _schulabschlussMeta,
        ),
      );
    }
    if (data.containsKey('schulabschlussNote')) {
      context.handle(
        _schulabschlussNoteMeta,
        schulabschlussNote.isAcceptableOrUnknown(
          data['schulabschlussNote']!,
          _schulabschlussNoteMeta,
        ),
      );
    }
    if (data.containsKey('extraData')) {
      context.handle(
        _extraDataMeta,
        extraData.isAcceptableOrUnknown(data['extraData']!, _extraDataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fullName'],
      ),
      dobDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dobDay'],
      ),
      dobMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dobMonth'],
      ),
      dobYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dobYear'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photoPath'],
      ),
      skill: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skill'],
      ),
      workExperience: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workExperience'],
      ),
      workType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workType'],
      ),
      tools: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tools'],
      ),
      drivingLicense: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drivingLicense'],
      ),
      languages: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}languages'],
      ),
      languageProficiency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}languageProficiency'],
      ),
      availability: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}availability'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}startDate'],
      ),
      educationLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}educationLevel'],
      ),
      educationOrt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}educationOrt'],
      ),
      educationDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}educationDuration'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      refName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refName'],
      ),
      refPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refPhone'],
      ),
      previousEmployers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previousEmployers'],
      ),
      previousJobTitles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previousJobTitles'],
      ),
      previousJobDurations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previousJobDurations'],
      ),
      sharedWorkOrts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sharedWorkOrts'],
      ),
      sharedWorkTypes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sharedWorkTypes'],
      ),
      sharedItSkills: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sharedItSkills'],
      ),
      ausbildungEduInstitutions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausbildungEduInstitutions'],
      ),
      ausbildungEduOrts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausbildungEduOrts'],
      ),
      ausbildungEduTypes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausbildungEduTypes'],
      ),
      ausbildungEduAbschluss: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausbildungEduAbschluss'],
      ),
      ausbildungEduDurations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausbildungEduDurations'],
      ),
      ausbildungEduGrades: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausbildungEduGrades'],
      ),
      ausbildungEscoSkills: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausbildungEscoSkills'],
      ),
      ausbildungTargetOccupation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausbildungTargetOccupation'],
      ),
      ausbildungTargetOccupationUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausbildungTargetOccupationUri'],
      ),
      schulabschluss: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schulabschluss'],
      ),
      schulabschlussNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schulabschlussNote'],
      ),
      extraData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extraData'],
      ),
    );
  }

  @override
  $ProfileEntriesTable createAlias(String alias) {
    return $ProfileEntriesTable(attachedDatabase, alias);
  }
}

class ProfileEntry extends DataClass implements Insertable<ProfileEntry> {
  final int id;
  final String? fullName;
  final String? dobDay;
  final String? dobMonth;
  final String? dobYear;
  final String? country;
  final String? phone;
  final String? email;
  final String? street;
  final String? city;
  final String? photoPath;
  final String? skill;
  final String? workExperience;
  final String? workType;
  final String? tools;
  final String? drivingLicense;
  final String? languages;
  final String? languageProficiency;
  final String? availability;
  final String? startDate;
  final String? educationLevel;
  final String? educationOrt;
  final String? educationDuration;
  final String? reference;
  final String? refName;
  final String? refPhone;
  final String? previousEmployers;
  final String? previousJobTitles;
  final String? previousJobDurations;
  final String? sharedWorkOrts;
  final String? sharedWorkTypes;
  final String? sharedItSkills;
  final String? ausbildungEduInstitutions;
  final String? ausbildungEduOrts;
  final String? ausbildungEduTypes;
  final String? ausbildungEduAbschluss;
  final String? ausbildungEduDurations;
  final String? ausbildungEduGrades;
  final String? ausbildungEscoSkills;
  final String? ausbildungTargetOccupation;
  final String? ausbildungTargetOccupationUri;
  final String? schulabschluss;
  final String? schulabschlussNote;

  /// JSON object with every profile-map key that has no dedicated column
  /// above (older or future keys). Merged back into the map on read, with
  /// dedicated columns winning on a collision.
  final String? extraData;
  const ProfileEntry({
    required this.id,
    this.fullName,
    this.dobDay,
    this.dobMonth,
    this.dobYear,
    this.country,
    this.phone,
    this.email,
    this.street,
    this.city,
    this.photoPath,
    this.skill,
    this.workExperience,
    this.workType,
    this.tools,
    this.drivingLicense,
    this.languages,
    this.languageProficiency,
    this.availability,
    this.startDate,
    this.educationLevel,
    this.educationOrt,
    this.educationDuration,
    this.reference,
    this.refName,
    this.refPhone,
    this.previousEmployers,
    this.previousJobTitles,
    this.previousJobDurations,
    this.sharedWorkOrts,
    this.sharedWorkTypes,
    this.sharedItSkills,
    this.ausbildungEduInstitutions,
    this.ausbildungEduOrts,
    this.ausbildungEduTypes,
    this.ausbildungEduAbschluss,
    this.ausbildungEduDurations,
    this.ausbildungEduGrades,
    this.ausbildungEscoSkills,
    this.ausbildungTargetOccupation,
    this.ausbildungTargetOccupationUri,
    this.schulabschluss,
    this.schulabschlussNote,
    this.extraData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || fullName != null) {
      map['fullName'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || dobDay != null) {
      map['dobDay'] = Variable<String>(dobDay);
    }
    if (!nullToAbsent || dobMonth != null) {
      map['dobMonth'] = Variable<String>(dobMonth);
    }
    if (!nullToAbsent || dobYear != null) {
      map['dobYear'] = Variable<String>(dobYear);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || street != null) {
      map['street'] = Variable<String>(street);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photoPath'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || skill != null) {
      map['skill'] = Variable<String>(skill);
    }
    if (!nullToAbsent || workExperience != null) {
      map['workExperience'] = Variable<String>(workExperience);
    }
    if (!nullToAbsent || workType != null) {
      map['workType'] = Variable<String>(workType);
    }
    if (!nullToAbsent || tools != null) {
      map['tools'] = Variable<String>(tools);
    }
    if (!nullToAbsent || drivingLicense != null) {
      map['drivingLicense'] = Variable<String>(drivingLicense);
    }
    if (!nullToAbsent || languages != null) {
      map['languages'] = Variable<String>(languages);
    }
    if (!nullToAbsent || languageProficiency != null) {
      map['languageProficiency'] = Variable<String>(languageProficiency);
    }
    if (!nullToAbsent || availability != null) {
      map['availability'] = Variable<String>(availability);
    }
    if (!nullToAbsent || startDate != null) {
      map['startDate'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || educationLevel != null) {
      map['educationLevel'] = Variable<String>(educationLevel);
    }
    if (!nullToAbsent || educationOrt != null) {
      map['educationOrt'] = Variable<String>(educationOrt);
    }
    if (!nullToAbsent || educationDuration != null) {
      map['educationDuration'] = Variable<String>(educationDuration);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || refName != null) {
      map['refName'] = Variable<String>(refName);
    }
    if (!nullToAbsent || refPhone != null) {
      map['refPhone'] = Variable<String>(refPhone);
    }
    if (!nullToAbsent || previousEmployers != null) {
      map['previousEmployers'] = Variable<String>(previousEmployers);
    }
    if (!nullToAbsent || previousJobTitles != null) {
      map['previousJobTitles'] = Variable<String>(previousJobTitles);
    }
    if (!nullToAbsent || previousJobDurations != null) {
      map['previousJobDurations'] = Variable<String>(previousJobDurations);
    }
    if (!nullToAbsent || sharedWorkOrts != null) {
      map['sharedWorkOrts'] = Variable<String>(sharedWorkOrts);
    }
    if (!nullToAbsent || sharedWorkTypes != null) {
      map['sharedWorkTypes'] = Variable<String>(sharedWorkTypes);
    }
    if (!nullToAbsent || sharedItSkills != null) {
      map['sharedItSkills'] = Variable<String>(sharedItSkills);
    }
    if (!nullToAbsent || ausbildungEduInstitutions != null) {
      map['ausbildungEduInstitutions'] = Variable<String>(
        ausbildungEduInstitutions,
      );
    }
    if (!nullToAbsent || ausbildungEduOrts != null) {
      map['ausbildungEduOrts'] = Variable<String>(ausbildungEduOrts);
    }
    if (!nullToAbsent || ausbildungEduTypes != null) {
      map['ausbildungEduTypes'] = Variable<String>(ausbildungEduTypes);
    }
    if (!nullToAbsent || ausbildungEduAbschluss != null) {
      map['ausbildungEduAbschluss'] = Variable<String>(ausbildungEduAbschluss);
    }
    if (!nullToAbsent || ausbildungEduDurations != null) {
      map['ausbildungEduDurations'] = Variable<String>(ausbildungEduDurations);
    }
    if (!nullToAbsent || ausbildungEduGrades != null) {
      map['ausbildungEduGrades'] = Variable<String>(ausbildungEduGrades);
    }
    if (!nullToAbsent || ausbildungEscoSkills != null) {
      map['ausbildungEscoSkills'] = Variable<String>(ausbildungEscoSkills);
    }
    if (!nullToAbsent || ausbildungTargetOccupation != null) {
      map['ausbildungTargetOccupation'] = Variable<String>(
        ausbildungTargetOccupation,
      );
    }
    if (!nullToAbsent || ausbildungTargetOccupationUri != null) {
      map['ausbildungTargetOccupationUri'] = Variable<String>(
        ausbildungTargetOccupationUri,
      );
    }
    if (!nullToAbsent || schulabschluss != null) {
      map['schulabschluss'] = Variable<String>(schulabschluss);
    }
    if (!nullToAbsent || schulabschlussNote != null) {
      map['schulabschlussNote'] = Variable<String>(schulabschlussNote);
    }
    if (!nullToAbsent || extraData != null) {
      map['extraData'] = Variable<String>(extraData);
    }
    return map;
  }

  ProfileEntriesCompanion toCompanion(bool nullToAbsent) {
    return ProfileEntriesCompanion(
      id: Value(id),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      dobDay: dobDay == null && nullToAbsent
          ? const Value.absent()
          : Value(dobDay),
      dobMonth: dobMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dobMonth),
      dobYear: dobYear == null && nullToAbsent
          ? const Value.absent()
          : Value(dobYear),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      street: street == null && nullToAbsent
          ? const Value.absent()
          : Value(street),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      skill: skill == null && nullToAbsent
          ? const Value.absent()
          : Value(skill),
      workExperience: workExperience == null && nullToAbsent
          ? const Value.absent()
          : Value(workExperience),
      workType: workType == null && nullToAbsent
          ? const Value.absent()
          : Value(workType),
      tools: tools == null && nullToAbsent
          ? const Value.absent()
          : Value(tools),
      drivingLicense: drivingLicense == null && nullToAbsent
          ? const Value.absent()
          : Value(drivingLicense),
      languages: languages == null && nullToAbsent
          ? const Value.absent()
          : Value(languages),
      languageProficiency: languageProficiency == null && nullToAbsent
          ? const Value.absent()
          : Value(languageProficiency),
      availability: availability == null && nullToAbsent
          ? const Value.absent()
          : Value(availability),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      educationLevel: educationLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(educationLevel),
      educationOrt: educationOrt == null && nullToAbsent
          ? const Value.absent()
          : Value(educationOrt),
      educationDuration: educationDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(educationDuration),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      refName: refName == null && nullToAbsent
          ? const Value.absent()
          : Value(refName),
      refPhone: refPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(refPhone),
      previousEmployers: previousEmployers == null && nullToAbsent
          ? const Value.absent()
          : Value(previousEmployers),
      previousJobTitles: previousJobTitles == null && nullToAbsent
          ? const Value.absent()
          : Value(previousJobTitles),
      previousJobDurations: previousJobDurations == null && nullToAbsent
          ? const Value.absent()
          : Value(previousJobDurations),
      sharedWorkOrts: sharedWorkOrts == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedWorkOrts),
      sharedWorkTypes: sharedWorkTypes == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedWorkTypes),
      sharedItSkills: sharedItSkills == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedItSkills),
      ausbildungEduInstitutions:
          ausbildungEduInstitutions == null && nullToAbsent
          ? const Value.absent()
          : Value(ausbildungEduInstitutions),
      ausbildungEduOrts: ausbildungEduOrts == null && nullToAbsent
          ? const Value.absent()
          : Value(ausbildungEduOrts),
      ausbildungEduTypes: ausbildungEduTypes == null && nullToAbsent
          ? const Value.absent()
          : Value(ausbildungEduTypes),
      ausbildungEduAbschluss: ausbildungEduAbschluss == null && nullToAbsent
          ? const Value.absent()
          : Value(ausbildungEduAbschluss),
      ausbildungEduDurations: ausbildungEduDurations == null && nullToAbsent
          ? const Value.absent()
          : Value(ausbildungEduDurations),
      ausbildungEduGrades: ausbildungEduGrades == null && nullToAbsent
          ? const Value.absent()
          : Value(ausbildungEduGrades),
      ausbildungEscoSkills: ausbildungEscoSkills == null && nullToAbsent
          ? const Value.absent()
          : Value(ausbildungEscoSkills),
      ausbildungTargetOccupation:
          ausbildungTargetOccupation == null && nullToAbsent
          ? const Value.absent()
          : Value(ausbildungTargetOccupation),
      ausbildungTargetOccupationUri:
          ausbildungTargetOccupationUri == null && nullToAbsent
          ? const Value.absent()
          : Value(ausbildungTargetOccupationUri),
      schulabschluss: schulabschluss == null && nullToAbsent
          ? const Value.absent()
          : Value(schulabschluss),
      schulabschlussNote: schulabschlussNote == null && nullToAbsent
          ? const Value.absent()
          : Value(schulabschlussNote),
      extraData: extraData == null && nullToAbsent
          ? const Value.absent()
          : Value(extraData),
    );
  }

  factory ProfileEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileEntry(
      id: serializer.fromJson<int>(json['id']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      dobDay: serializer.fromJson<String?>(json['dobDay']),
      dobMonth: serializer.fromJson<String?>(json['dobMonth']),
      dobYear: serializer.fromJson<String?>(json['dobYear']),
      country: serializer.fromJson<String?>(json['country']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      street: serializer.fromJson<String?>(json['street']),
      city: serializer.fromJson<String?>(json['city']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      skill: serializer.fromJson<String?>(json['skill']),
      workExperience: serializer.fromJson<String?>(json['workExperience']),
      workType: serializer.fromJson<String?>(json['workType']),
      tools: serializer.fromJson<String?>(json['tools']),
      drivingLicense: serializer.fromJson<String?>(json['drivingLicense']),
      languages: serializer.fromJson<String?>(json['languages']),
      languageProficiency: serializer.fromJson<String?>(
        json['languageProficiency'],
      ),
      availability: serializer.fromJson<String?>(json['availability']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      educationLevel: serializer.fromJson<String?>(json['educationLevel']),
      educationOrt: serializer.fromJson<String?>(json['educationOrt']),
      educationDuration: serializer.fromJson<String?>(
        json['educationDuration'],
      ),
      reference: serializer.fromJson<String?>(json['reference']),
      refName: serializer.fromJson<String?>(json['refName']),
      refPhone: serializer.fromJson<String?>(json['refPhone']),
      previousEmployers: serializer.fromJson<String?>(
        json['previousEmployers'],
      ),
      previousJobTitles: serializer.fromJson<String?>(
        json['previousJobTitles'],
      ),
      previousJobDurations: serializer.fromJson<String?>(
        json['previousJobDurations'],
      ),
      sharedWorkOrts: serializer.fromJson<String?>(json['sharedWorkOrts']),
      sharedWorkTypes: serializer.fromJson<String?>(json['sharedWorkTypes']),
      sharedItSkills: serializer.fromJson<String?>(json['sharedItSkills']),
      ausbildungEduInstitutions: serializer.fromJson<String?>(
        json['ausbildungEduInstitutions'],
      ),
      ausbildungEduOrts: serializer.fromJson<String?>(
        json['ausbildungEduOrts'],
      ),
      ausbildungEduTypes: serializer.fromJson<String?>(
        json['ausbildungEduTypes'],
      ),
      ausbildungEduAbschluss: serializer.fromJson<String?>(
        json['ausbildungEduAbschluss'],
      ),
      ausbildungEduDurations: serializer.fromJson<String?>(
        json['ausbildungEduDurations'],
      ),
      ausbildungEduGrades: serializer.fromJson<String?>(
        json['ausbildungEduGrades'],
      ),
      ausbildungEscoSkills: serializer.fromJson<String?>(
        json['ausbildungEscoSkills'],
      ),
      ausbildungTargetOccupation: serializer.fromJson<String?>(
        json['ausbildungTargetOccupation'],
      ),
      ausbildungTargetOccupationUri: serializer.fromJson<String?>(
        json['ausbildungTargetOccupationUri'],
      ),
      schulabschluss: serializer.fromJson<String?>(json['schulabschluss']),
      schulabschlussNote: serializer.fromJson<String?>(
        json['schulabschlussNote'],
      ),
      extraData: serializer.fromJson<String?>(json['extraData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fullName': serializer.toJson<String?>(fullName),
      'dobDay': serializer.toJson<String?>(dobDay),
      'dobMonth': serializer.toJson<String?>(dobMonth),
      'dobYear': serializer.toJson<String?>(dobYear),
      'country': serializer.toJson<String?>(country),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'street': serializer.toJson<String?>(street),
      'city': serializer.toJson<String?>(city),
      'photoPath': serializer.toJson<String?>(photoPath),
      'skill': serializer.toJson<String?>(skill),
      'workExperience': serializer.toJson<String?>(workExperience),
      'workType': serializer.toJson<String?>(workType),
      'tools': serializer.toJson<String?>(tools),
      'drivingLicense': serializer.toJson<String?>(drivingLicense),
      'languages': serializer.toJson<String?>(languages),
      'languageProficiency': serializer.toJson<String?>(languageProficiency),
      'availability': serializer.toJson<String?>(availability),
      'startDate': serializer.toJson<String?>(startDate),
      'educationLevel': serializer.toJson<String?>(educationLevel),
      'educationOrt': serializer.toJson<String?>(educationOrt),
      'educationDuration': serializer.toJson<String?>(educationDuration),
      'reference': serializer.toJson<String?>(reference),
      'refName': serializer.toJson<String?>(refName),
      'refPhone': serializer.toJson<String?>(refPhone),
      'previousEmployers': serializer.toJson<String?>(previousEmployers),
      'previousJobTitles': serializer.toJson<String?>(previousJobTitles),
      'previousJobDurations': serializer.toJson<String?>(previousJobDurations),
      'sharedWorkOrts': serializer.toJson<String?>(sharedWorkOrts),
      'sharedWorkTypes': serializer.toJson<String?>(sharedWorkTypes),
      'sharedItSkills': serializer.toJson<String?>(sharedItSkills),
      'ausbildungEduInstitutions': serializer.toJson<String?>(
        ausbildungEduInstitutions,
      ),
      'ausbildungEduOrts': serializer.toJson<String?>(ausbildungEduOrts),
      'ausbildungEduTypes': serializer.toJson<String?>(ausbildungEduTypes),
      'ausbildungEduAbschluss': serializer.toJson<String?>(
        ausbildungEduAbschluss,
      ),
      'ausbildungEduDurations': serializer.toJson<String?>(
        ausbildungEduDurations,
      ),
      'ausbildungEduGrades': serializer.toJson<String?>(ausbildungEduGrades),
      'ausbildungEscoSkills': serializer.toJson<String?>(ausbildungEscoSkills),
      'ausbildungTargetOccupation': serializer.toJson<String?>(
        ausbildungTargetOccupation,
      ),
      'ausbildungTargetOccupationUri': serializer.toJson<String?>(
        ausbildungTargetOccupationUri,
      ),
      'schulabschluss': serializer.toJson<String?>(schulabschluss),
      'schulabschlussNote': serializer.toJson<String?>(schulabschlussNote),
      'extraData': serializer.toJson<String?>(extraData),
    };
  }

  ProfileEntry copyWith({
    int? id,
    Value<String?> fullName = const Value.absent(),
    Value<String?> dobDay = const Value.absent(),
    Value<String?> dobMonth = const Value.absent(),
    Value<String?> dobYear = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> street = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<String?> skill = const Value.absent(),
    Value<String?> workExperience = const Value.absent(),
    Value<String?> workType = const Value.absent(),
    Value<String?> tools = const Value.absent(),
    Value<String?> drivingLicense = const Value.absent(),
    Value<String?> languages = const Value.absent(),
    Value<String?> languageProficiency = const Value.absent(),
    Value<String?> availability = const Value.absent(),
    Value<String?> startDate = const Value.absent(),
    Value<String?> educationLevel = const Value.absent(),
    Value<String?> educationOrt = const Value.absent(),
    Value<String?> educationDuration = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    Value<String?> refName = const Value.absent(),
    Value<String?> refPhone = const Value.absent(),
    Value<String?> previousEmployers = const Value.absent(),
    Value<String?> previousJobTitles = const Value.absent(),
    Value<String?> previousJobDurations = const Value.absent(),
    Value<String?> sharedWorkOrts = const Value.absent(),
    Value<String?> sharedWorkTypes = const Value.absent(),
    Value<String?> sharedItSkills = const Value.absent(),
    Value<String?> ausbildungEduInstitutions = const Value.absent(),
    Value<String?> ausbildungEduOrts = const Value.absent(),
    Value<String?> ausbildungEduTypes = const Value.absent(),
    Value<String?> ausbildungEduAbschluss = const Value.absent(),
    Value<String?> ausbildungEduDurations = const Value.absent(),
    Value<String?> ausbildungEduGrades = const Value.absent(),
    Value<String?> ausbildungEscoSkills = const Value.absent(),
    Value<String?> ausbildungTargetOccupation = const Value.absent(),
    Value<String?> ausbildungTargetOccupationUri = const Value.absent(),
    Value<String?> schulabschluss = const Value.absent(),
    Value<String?> schulabschlussNote = const Value.absent(),
    Value<String?> extraData = const Value.absent(),
  }) => ProfileEntry(
    id: id ?? this.id,
    fullName: fullName.present ? fullName.value : this.fullName,
    dobDay: dobDay.present ? dobDay.value : this.dobDay,
    dobMonth: dobMonth.present ? dobMonth.value : this.dobMonth,
    dobYear: dobYear.present ? dobYear.value : this.dobYear,
    country: country.present ? country.value : this.country,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    street: street.present ? street.value : this.street,
    city: city.present ? city.value : this.city,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    skill: skill.present ? skill.value : this.skill,
    workExperience: workExperience.present
        ? workExperience.value
        : this.workExperience,
    workType: workType.present ? workType.value : this.workType,
    tools: tools.present ? tools.value : this.tools,
    drivingLicense: drivingLicense.present
        ? drivingLicense.value
        : this.drivingLicense,
    languages: languages.present ? languages.value : this.languages,
    languageProficiency: languageProficiency.present
        ? languageProficiency.value
        : this.languageProficiency,
    availability: availability.present ? availability.value : this.availability,
    startDate: startDate.present ? startDate.value : this.startDate,
    educationLevel: educationLevel.present
        ? educationLevel.value
        : this.educationLevel,
    educationOrt: educationOrt.present ? educationOrt.value : this.educationOrt,
    educationDuration: educationDuration.present
        ? educationDuration.value
        : this.educationDuration,
    reference: reference.present ? reference.value : this.reference,
    refName: refName.present ? refName.value : this.refName,
    refPhone: refPhone.present ? refPhone.value : this.refPhone,
    previousEmployers: previousEmployers.present
        ? previousEmployers.value
        : this.previousEmployers,
    previousJobTitles: previousJobTitles.present
        ? previousJobTitles.value
        : this.previousJobTitles,
    previousJobDurations: previousJobDurations.present
        ? previousJobDurations.value
        : this.previousJobDurations,
    sharedWorkOrts: sharedWorkOrts.present
        ? sharedWorkOrts.value
        : this.sharedWorkOrts,
    sharedWorkTypes: sharedWorkTypes.present
        ? sharedWorkTypes.value
        : this.sharedWorkTypes,
    sharedItSkills: sharedItSkills.present
        ? sharedItSkills.value
        : this.sharedItSkills,
    ausbildungEduInstitutions: ausbildungEduInstitutions.present
        ? ausbildungEduInstitutions.value
        : this.ausbildungEduInstitutions,
    ausbildungEduOrts: ausbildungEduOrts.present
        ? ausbildungEduOrts.value
        : this.ausbildungEduOrts,
    ausbildungEduTypes: ausbildungEduTypes.present
        ? ausbildungEduTypes.value
        : this.ausbildungEduTypes,
    ausbildungEduAbschluss: ausbildungEduAbschluss.present
        ? ausbildungEduAbschluss.value
        : this.ausbildungEduAbschluss,
    ausbildungEduDurations: ausbildungEduDurations.present
        ? ausbildungEduDurations.value
        : this.ausbildungEduDurations,
    ausbildungEduGrades: ausbildungEduGrades.present
        ? ausbildungEduGrades.value
        : this.ausbildungEduGrades,
    ausbildungEscoSkills: ausbildungEscoSkills.present
        ? ausbildungEscoSkills.value
        : this.ausbildungEscoSkills,
    ausbildungTargetOccupation: ausbildungTargetOccupation.present
        ? ausbildungTargetOccupation.value
        : this.ausbildungTargetOccupation,
    ausbildungTargetOccupationUri: ausbildungTargetOccupationUri.present
        ? ausbildungTargetOccupationUri.value
        : this.ausbildungTargetOccupationUri,
    schulabschluss: schulabschluss.present
        ? schulabschluss.value
        : this.schulabschluss,
    schulabschlussNote: schulabschlussNote.present
        ? schulabschlussNote.value
        : this.schulabschlussNote,
    extraData: extraData.present ? extraData.value : this.extraData,
  );
  ProfileEntry copyWithCompanion(ProfileEntriesCompanion data) {
    return ProfileEntry(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      dobDay: data.dobDay.present ? data.dobDay.value : this.dobDay,
      dobMonth: data.dobMonth.present ? data.dobMonth.value : this.dobMonth,
      dobYear: data.dobYear.present ? data.dobYear.value : this.dobYear,
      country: data.country.present ? data.country.value : this.country,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      street: data.street.present ? data.street.value : this.street,
      city: data.city.present ? data.city.value : this.city,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      skill: data.skill.present ? data.skill.value : this.skill,
      workExperience: data.workExperience.present
          ? data.workExperience.value
          : this.workExperience,
      workType: data.workType.present ? data.workType.value : this.workType,
      tools: data.tools.present ? data.tools.value : this.tools,
      drivingLicense: data.drivingLicense.present
          ? data.drivingLicense.value
          : this.drivingLicense,
      languages: data.languages.present ? data.languages.value : this.languages,
      languageProficiency: data.languageProficiency.present
          ? data.languageProficiency.value
          : this.languageProficiency,
      availability: data.availability.present
          ? data.availability.value
          : this.availability,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      educationLevel: data.educationLevel.present
          ? data.educationLevel.value
          : this.educationLevel,
      educationOrt: data.educationOrt.present
          ? data.educationOrt.value
          : this.educationOrt,
      educationDuration: data.educationDuration.present
          ? data.educationDuration.value
          : this.educationDuration,
      reference: data.reference.present ? data.reference.value : this.reference,
      refName: data.refName.present ? data.refName.value : this.refName,
      refPhone: data.refPhone.present ? data.refPhone.value : this.refPhone,
      previousEmployers: data.previousEmployers.present
          ? data.previousEmployers.value
          : this.previousEmployers,
      previousJobTitles: data.previousJobTitles.present
          ? data.previousJobTitles.value
          : this.previousJobTitles,
      previousJobDurations: data.previousJobDurations.present
          ? data.previousJobDurations.value
          : this.previousJobDurations,
      sharedWorkOrts: data.sharedWorkOrts.present
          ? data.sharedWorkOrts.value
          : this.sharedWorkOrts,
      sharedWorkTypes: data.sharedWorkTypes.present
          ? data.sharedWorkTypes.value
          : this.sharedWorkTypes,
      sharedItSkills: data.sharedItSkills.present
          ? data.sharedItSkills.value
          : this.sharedItSkills,
      ausbildungEduInstitutions: data.ausbildungEduInstitutions.present
          ? data.ausbildungEduInstitutions.value
          : this.ausbildungEduInstitutions,
      ausbildungEduOrts: data.ausbildungEduOrts.present
          ? data.ausbildungEduOrts.value
          : this.ausbildungEduOrts,
      ausbildungEduTypes: data.ausbildungEduTypes.present
          ? data.ausbildungEduTypes.value
          : this.ausbildungEduTypes,
      ausbildungEduAbschluss: data.ausbildungEduAbschluss.present
          ? data.ausbildungEduAbschluss.value
          : this.ausbildungEduAbschluss,
      ausbildungEduDurations: data.ausbildungEduDurations.present
          ? data.ausbildungEduDurations.value
          : this.ausbildungEduDurations,
      ausbildungEduGrades: data.ausbildungEduGrades.present
          ? data.ausbildungEduGrades.value
          : this.ausbildungEduGrades,
      ausbildungEscoSkills: data.ausbildungEscoSkills.present
          ? data.ausbildungEscoSkills.value
          : this.ausbildungEscoSkills,
      ausbildungTargetOccupation: data.ausbildungTargetOccupation.present
          ? data.ausbildungTargetOccupation.value
          : this.ausbildungTargetOccupation,
      ausbildungTargetOccupationUri: data.ausbildungTargetOccupationUri.present
          ? data.ausbildungTargetOccupationUri.value
          : this.ausbildungTargetOccupationUri,
      schulabschluss: data.schulabschluss.present
          ? data.schulabschluss.value
          : this.schulabschluss,
      schulabschlussNote: data.schulabschlussNote.present
          ? data.schulabschlussNote.value
          : this.schulabschlussNote,
      extraData: data.extraData.present ? data.extraData.value : this.extraData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileEntry(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('dobDay: $dobDay, ')
          ..write('dobMonth: $dobMonth, ')
          ..write('dobYear: $dobYear, ')
          ..write('country: $country, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('street: $street, ')
          ..write('city: $city, ')
          ..write('photoPath: $photoPath, ')
          ..write('skill: $skill, ')
          ..write('workExperience: $workExperience, ')
          ..write('workType: $workType, ')
          ..write('tools: $tools, ')
          ..write('drivingLicense: $drivingLicense, ')
          ..write('languages: $languages, ')
          ..write('languageProficiency: $languageProficiency, ')
          ..write('availability: $availability, ')
          ..write('startDate: $startDate, ')
          ..write('educationLevel: $educationLevel, ')
          ..write('educationOrt: $educationOrt, ')
          ..write('educationDuration: $educationDuration, ')
          ..write('reference: $reference, ')
          ..write('refName: $refName, ')
          ..write('refPhone: $refPhone, ')
          ..write('previousEmployers: $previousEmployers, ')
          ..write('previousJobTitles: $previousJobTitles, ')
          ..write('previousJobDurations: $previousJobDurations, ')
          ..write('sharedWorkOrts: $sharedWorkOrts, ')
          ..write('sharedWorkTypes: $sharedWorkTypes, ')
          ..write('sharedItSkills: $sharedItSkills, ')
          ..write('ausbildungEduInstitutions: $ausbildungEduInstitutions, ')
          ..write('ausbildungEduOrts: $ausbildungEduOrts, ')
          ..write('ausbildungEduTypes: $ausbildungEduTypes, ')
          ..write('ausbildungEduAbschluss: $ausbildungEduAbschluss, ')
          ..write('ausbildungEduDurations: $ausbildungEduDurations, ')
          ..write('ausbildungEduGrades: $ausbildungEduGrades, ')
          ..write('ausbildungEscoSkills: $ausbildungEscoSkills, ')
          ..write('ausbildungTargetOccupation: $ausbildungTargetOccupation, ')
          ..write(
            'ausbildungTargetOccupationUri: $ausbildungTargetOccupationUri, ',
          )
          ..write('schulabschluss: $schulabschluss, ')
          ..write('schulabschlussNote: $schulabschlussNote, ')
          ..write('extraData: $extraData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    fullName,
    dobDay,
    dobMonth,
    dobYear,
    country,
    phone,
    email,
    street,
    city,
    photoPath,
    skill,
    workExperience,
    workType,
    tools,
    drivingLicense,
    languages,
    languageProficiency,
    availability,
    startDate,
    educationLevel,
    educationOrt,
    educationDuration,
    reference,
    refName,
    refPhone,
    previousEmployers,
    previousJobTitles,
    previousJobDurations,
    sharedWorkOrts,
    sharedWorkTypes,
    sharedItSkills,
    ausbildungEduInstitutions,
    ausbildungEduOrts,
    ausbildungEduTypes,
    ausbildungEduAbschluss,
    ausbildungEduDurations,
    ausbildungEduGrades,
    ausbildungEscoSkills,
    ausbildungTargetOccupation,
    ausbildungTargetOccupationUri,
    schulabschluss,
    schulabschlussNote,
    extraData,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileEntry &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.dobDay == this.dobDay &&
          other.dobMonth == this.dobMonth &&
          other.dobYear == this.dobYear &&
          other.country == this.country &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.street == this.street &&
          other.city == this.city &&
          other.photoPath == this.photoPath &&
          other.skill == this.skill &&
          other.workExperience == this.workExperience &&
          other.workType == this.workType &&
          other.tools == this.tools &&
          other.drivingLicense == this.drivingLicense &&
          other.languages == this.languages &&
          other.languageProficiency == this.languageProficiency &&
          other.availability == this.availability &&
          other.startDate == this.startDate &&
          other.educationLevel == this.educationLevel &&
          other.educationOrt == this.educationOrt &&
          other.educationDuration == this.educationDuration &&
          other.reference == this.reference &&
          other.refName == this.refName &&
          other.refPhone == this.refPhone &&
          other.previousEmployers == this.previousEmployers &&
          other.previousJobTitles == this.previousJobTitles &&
          other.previousJobDurations == this.previousJobDurations &&
          other.sharedWorkOrts == this.sharedWorkOrts &&
          other.sharedWorkTypes == this.sharedWorkTypes &&
          other.sharedItSkills == this.sharedItSkills &&
          other.ausbildungEduInstitutions == this.ausbildungEduInstitutions &&
          other.ausbildungEduOrts == this.ausbildungEduOrts &&
          other.ausbildungEduTypes == this.ausbildungEduTypes &&
          other.ausbildungEduAbschluss == this.ausbildungEduAbschluss &&
          other.ausbildungEduDurations == this.ausbildungEduDurations &&
          other.ausbildungEduGrades == this.ausbildungEduGrades &&
          other.ausbildungEscoSkills == this.ausbildungEscoSkills &&
          other.ausbildungTargetOccupation == this.ausbildungTargetOccupation &&
          other.ausbildungTargetOccupationUri ==
              this.ausbildungTargetOccupationUri &&
          other.schulabschluss == this.schulabschluss &&
          other.schulabschlussNote == this.schulabschlussNote &&
          other.extraData == this.extraData);
}

class ProfileEntriesCompanion extends UpdateCompanion<ProfileEntry> {
  final Value<int> id;
  final Value<String?> fullName;
  final Value<String?> dobDay;
  final Value<String?> dobMonth;
  final Value<String?> dobYear;
  final Value<String?> country;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> street;
  final Value<String?> city;
  final Value<String?> photoPath;
  final Value<String?> skill;
  final Value<String?> workExperience;
  final Value<String?> workType;
  final Value<String?> tools;
  final Value<String?> drivingLicense;
  final Value<String?> languages;
  final Value<String?> languageProficiency;
  final Value<String?> availability;
  final Value<String?> startDate;
  final Value<String?> educationLevel;
  final Value<String?> educationOrt;
  final Value<String?> educationDuration;
  final Value<String?> reference;
  final Value<String?> refName;
  final Value<String?> refPhone;
  final Value<String?> previousEmployers;
  final Value<String?> previousJobTitles;
  final Value<String?> previousJobDurations;
  final Value<String?> sharedWorkOrts;
  final Value<String?> sharedWorkTypes;
  final Value<String?> sharedItSkills;
  final Value<String?> ausbildungEduInstitutions;
  final Value<String?> ausbildungEduOrts;
  final Value<String?> ausbildungEduTypes;
  final Value<String?> ausbildungEduAbschluss;
  final Value<String?> ausbildungEduDurations;
  final Value<String?> ausbildungEduGrades;
  final Value<String?> ausbildungEscoSkills;
  final Value<String?> ausbildungTargetOccupation;
  final Value<String?> ausbildungTargetOccupationUri;
  final Value<String?> schulabschluss;
  final Value<String?> schulabschlussNote;
  final Value<String?> extraData;
  const ProfileEntriesCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.dobDay = const Value.absent(),
    this.dobMonth = const Value.absent(),
    this.dobYear = const Value.absent(),
    this.country = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.street = const Value.absent(),
    this.city = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.skill = const Value.absent(),
    this.workExperience = const Value.absent(),
    this.workType = const Value.absent(),
    this.tools = const Value.absent(),
    this.drivingLicense = const Value.absent(),
    this.languages = const Value.absent(),
    this.languageProficiency = const Value.absent(),
    this.availability = const Value.absent(),
    this.startDate = const Value.absent(),
    this.educationLevel = const Value.absent(),
    this.educationOrt = const Value.absent(),
    this.educationDuration = const Value.absent(),
    this.reference = const Value.absent(),
    this.refName = const Value.absent(),
    this.refPhone = const Value.absent(),
    this.previousEmployers = const Value.absent(),
    this.previousJobTitles = const Value.absent(),
    this.previousJobDurations = const Value.absent(),
    this.sharedWorkOrts = const Value.absent(),
    this.sharedWorkTypes = const Value.absent(),
    this.sharedItSkills = const Value.absent(),
    this.ausbildungEduInstitutions = const Value.absent(),
    this.ausbildungEduOrts = const Value.absent(),
    this.ausbildungEduTypes = const Value.absent(),
    this.ausbildungEduAbschluss = const Value.absent(),
    this.ausbildungEduDurations = const Value.absent(),
    this.ausbildungEduGrades = const Value.absent(),
    this.ausbildungEscoSkills = const Value.absent(),
    this.ausbildungTargetOccupation = const Value.absent(),
    this.ausbildungTargetOccupationUri = const Value.absent(),
    this.schulabschluss = const Value.absent(),
    this.schulabschlussNote = const Value.absent(),
    this.extraData = const Value.absent(),
  });
  ProfileEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.dobDay = const Value.absent(),
    this.dobMonth = const Value.absent(),
    this.dobYear = const Value.absent(),
    this.country = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.street = const Value.absent(),
    this.city = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.skill = const Value.absent(),
    this.workExperience = const Value.absent(),
    this.workType = const Value.absent(),
    this.tools = const Value.absent(),
    this.drivingLicense = const Value.absent(),
    this.languages = const Value.absent(),
    this.languageProficiency = const Value.absent(),
    this.availability = const Value.absent(),
    this.startDate = const Value.absent(),
    this.educationLevel = const Value.absent(),
    this.educationOrt = const Value.absent(),
    this.educationDuration = const Value.absent(),
    this.reference = const Value.absent(),
    this.refName = const Value.absent(),
    this.refPhone = const Value.absent(),
    this.previousEmployers = const Value.absent(),
    this.previousJobTitles = const Value.absent(),
    this.previousJobDurations = const Value.absent(),
    this.sharedWorkOrts = const Value.absent(),
    this.sharedWorkTypes = const Value.absent(),
    this.sharedItSkills = const Value.absent(),
    this.ausbildungEduInstitutions = const Value.absent(),
    this.ausbildungEduOrts = const Value.absent(),
    this.ausbildungEduTypes = const Value.absent(),
    this.ausbildungEduAbschluss = const Value.absent(),
    this.ausbildungEduDurations = const Value.absent(),
    this.ausbildungEduGrades = const Value.absent(),
    this.ausbildungEscoSkills = const Value.absent(),
    this.ausbildungTargetOccupation = const Value.absent(),
    this.ausbildungTargetOccupationUri = const Value.absent(),
    this.schulabschluss = const Value.absent(),
    this.schulabschlussNote = const Value.absent(),
    this.extraData = const Value.absent(),
  });
  static Insertable<ProfileEntry> custom({
    Expression<int>? id,
    Expression<String>? fullName,
    Expression<String>? dobDay,
    Expression<String>? dobMonth,
    Expression<String>? dobYear,
    Expression<String>? country,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? street,
    Expression<String>? city,
    Expression<String>? photoPath,
    Expression<String>? skill,
    Expression<String>? workExperience,
    Expression<String>? workType,
    Expression<String>? tools,
    Expression<String>? drivingLicense,
    Expression<String>? languages,
    Expression<String>? languageProficiency,
    Expression<String>? availability,
    Expression<String>? startDate,
    Expression<String>? educationLevel,
    Expression<String>? educationOrt,
    Expression<String>? educationDuration,
    Expression<String>? reference,
    Expression<String>? refName,
    Expression<String>? refPhone,
    Expression<String>? previousEmployers,
    Expression<String>? previousJobTitles,
    Expression<String>? previousJobDurations,
    Expression<String>? sharedWorkOrts,
    Expression<String>? sharedWorkTypes,
    Expression<String>? sharedItSkills,
    Expression<String>? ausbildungEduInstitutions,
    Expression<String>? ausbildungEduOrts,
    Expression<String>? ausbildungEduTypes,
    Expression<String>? ausbildungEduAbschluss,
    Expression<String>? ausbildungEduDurations,
    Expression<String>? ausbildungEduGrades,
    Expression<String>? ausbildungEscoSkills,
    Expression<String>? ausbildungTargetOccupation,
    Expression<String>? ausbildungTargetOccupationUri,
    Expression<String>? schulabschluss,
    Expression<String>? schulabschlussNote,
    Expression<String>? extraData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'fullName': fullName,
      if (dobDay != null) 'dobDay': dobDay,
      if (dobMonth != null) 'dobMonth': dobMonth,
      if (dobYear != null) 'dobYear': dobYear,
      if (country != null) 'country': country,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (photoPath != null) 'photoPath': photoPath,
      if (skill != null) 'skill': skill,
      if (workExperience != null) 'workExperience': workExperience,
      if (workType != null) 'workType': workType,
      if (tools != null) 'tools': tools,
      if (drivingLicense != null) 'drivingLicense': drivingLicense,
      if (languages != null) 'languages': languages,
      if (languageProficiency != null)
        'languageProficiency': languageProficiency,
      if (availability != null) 'availability': availability,
      if (startDate != null) 'startDate': startDate,
      if (educationLevel != null) 'educationLevel': educationLevel,
      if (educationOrt != null) 'educationOrt': educationOrt,
      if (educationDuration != null) 'educationDuration': educationDuration,
      if (reference != null) 'reference': reference,
      if (refName != null) 'refName': refName,
      if (refPhone != null) 'refPhone': refPhone,
      if (previousEmployers != null) 'previousEmployers': previousEmployers,
      if (previousJobTitles != null) 'previousJobTitles': previousJobTitles,
      if (previousJobDurations != null)
        'previousJobDurations': previousJobDurations,
      if (sharedWorkOrts != null) 'sharedWorkOrts': sharedWorkOrts,
      if (sharedWorkTypes != null) 'sharedWorkTypes': sharedWorkTypes,
      if (sharedItSkills != null) 'sharedItSkills': sharedItSkills,
      if (ausbildungEduInstitutions != null)
        'ausbildungEduInstitutions': ausbildungEduInstitutions,
      if (ausbildungEduOrts != null) 'ausbildungEduOrts': ausbildungEduOrts,
      if (ausbildungEduTypes != null) 'ausbildungEduTypes': ausbildungEduTypes,
      if (ausbildungEduAbschluss != null)
        'ausbildungEduAbschluss': ausbildungEduAbschluss,
      if (ausbildungEduDurations != null)
        'ausbildungEduDurations': ausbildungEduDurations,
      if (ausbildungEduGrades != null)
        'ausbildungEduGrades': ausbildungEduGrades,
      if (ausbildungEscoSkills != null)
        'ausbildungEscoSkills': ausbildungEscoSkills,
      if (ausbildungTargetOccupation != null)
        'ausbildungTargetOccupation': ausbildungTargetOccupation,
      if (ausbildungTargetOccupationUri != null)
        'ausbildungTargetOccupationUri': ausbildungTargetOccupationUri,
      if (schulabschluss != null) 'schulabschluss': schulabschluss,
      if (schulabschlussNote != null) 'schulabschlussNote': schulabschlussNote,
      if (extraData != null) 'extraData': extraData,
    });
  }

  ProfileEntriesCompanion copyWith({
    Value<int>? id,
    Value<String?>? fullName,
    Value<String?>? dobDay,
    Value<String?>? dobMonth,
    Value<String?>? dobYear,
    Value<String?>? country,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? street,
    Value<String?>? city,
    Value<String?>? photoPath,
    Value<String?>? skill,
    Value<String?>? workExperience,
    Value<String?>? workType,
    Value<String?>? tools,
    Value<String?>? drivingLicense,
    Value<String?>? languages,
    Value<String?>? languageProficiency,
    Value<String?>? availability,
    Value<String?>? startDate,
    Value<String?>? educationLevel,
    Value<String?>? educationOrt,
    Value<String?>? educationDuration,
    Value<String?>? reference,
    Value<String?>? refName,
    Value<String?>? refPhone,
    Value<String?>? previousEmployers,
    Value<String?>? previousJobTitles,
    Value<String?>? previousJobDurations,
    Value<String?>? sharedWorkOrts,
    Value<String?>? sharedWorkTypes,
    Value<String?>? sharedItSkills,
    Value<String?>? ausbildungEduInstitutions,
    Value<String?>? ausbildungEduOrts,
    Value<String?>? ausbildungEduTypes,
    Value<String?>? ausbildungEduAbschluss,
    Value<String?>? ausbildungEduDurations,
    Value<String?>? ausbildungEduGrades,
    Value<String?>? ausbildungEscoSkills,
    Value<String?>? ausbildungTargetOccupation,
    Value<String?>? ausbildungTargetOccupationUri,
    Value<String?>? schulabschluss,
    Value<String?>? schulabschlussNote,
    Value<String?>? extraData,
  }) {
    return ProfileEntriesCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dobDay: dobDay ?? this.dobDay,
      dobMonth: dobMonth ?? this.dobMonth,
      dobYear: dobYear ?? this.dobYear,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      street: street ?? this.street,
      city: city ?? this.city,
      photoPath: photoPath ?? this.photoPath,
      skill: skill ?? this.skill,
      workExperience: workExperience ?? this.workExperience,
      workType: workType ?? this.workType,
      tools: tools ?? this.tools,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      languages: languages ?? this.languages,
      languageProficiency: languageProficiency ?? this.languageProficiency,
      availability: availability ?? this.availability,
      startDate: startDate ?? this.startDate,
      educationLevel: educationLevel ?? this.educationLevel,
      educationOrt: educationOrt ?? this.educationOrt,
      educationDuration: educationDuration ?? this.educationDuration,
      reference: reference ?? this.reference,
      refName: refName ?? this.refName,
      refPhone: refPhone ?? this.refPhone,
      previousEmployers: previousEmployers ?? this.previousEmployers,
      previousJobTitles: previousJobTitles ?? this.previousJobTitles,
      previousJobDurations: previousJobDurations ?? this.previousJobDurations,
      sharedWorkOrts: sharedWorkOrts ?? this.sharedWorkOrts,
      sharedWorkTypes: sharedWorkTypes ?? this.sharedWorkTypes,
      sharedItSkills: sharedItSkills ?? this.sharedItSkills,
      ausbildungEduInstitutions:
          ausbildungEduInstitutions ?? this.ausbildungEduInstitutions,
      ausbildungEduOrts: ausbildungEduOrts ?? this.ausbildungEduOrts,
      ausbildungEduTypes: ausbildungEduTypes ?? this.ausbildungEduTypes,
      ausbildungEduAbschluss:
          ausbildungEduAbschluss ?? this.ausbildungEduAbschluss,
      ausbildungEduDurations:
          ausbildungEduDurations ?? this.ausbildungEduDurations,
      ausbildungEduGrades: ausbildungEduGrades ?? this.ausbildungEduGrades,
      ausbildungEscoSkills: ausbildungEscoSkills ?? this.ausbildungEscoSkills,
      ausbildungTargetOccupation:
          ausbildungTargetOccupation ?? this.ausbildungTargetOccupation,
      ausbildungTargetOccupationUri:
          ausbildungTargetOccupationUri ?? this.ausbildungTargetOccupationUri,
      schulabschluss: schulabschluss ?? this.schulabschluss,
      schulabschlussNote: schulabschlussNote ?? this.schulabschlussNote,
      extraData: extraData ?? this.extraData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fullName.present) {
      map['fullName'] = Variable<String>(fullName.value);
    }
    if (dobDay.present) {
      map['dobDay'] = Variable<String>(dobDay.value);
    }
    if (dobMonth.present) {
      map['dobMonth'] = Variable<String>(dobMonth.value);
    }
    if (dobYear.present) {
      map['dobYear'] = Variable<String>(dobYear.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (photoPath.present) {
      map['photoPath'] = Variable<String>(photoPath.value);
    }
    if (skill.present) {
      map['skill'] = Variable<String>(skill.value);
    }
    if (workExperience.present) {
      map['workExperience'] = Variable<String>(workExperience.value);
    }
    if (workType.present) {
      map['workType'] = Variable<String>(workType.value);
    }
    if (tools.present) {
      map['tools'] = Variable<String>(tools.value);
    }
    if (drivingLicense.present) {
      map['drivingLicense'] = Variable<String>(drivingLicense.value);
    }
    if (languages.present) {
      map['languages'] = Variable<String>(languages.value);
    }
    if (languageProficiency.present) {
      map['languageProficiency'] = Variable<String>(languageProficiency.value);
    }
    if (availability.present) {
      map['availability'] = Variable<String>(availability.value);
    }
    if (startDate.present) {
      map['startDate'] = Variable<String>(startDate.value);
    }
    if (educationLevel.present) {
      map['educationLevel'] = Variable<String>(educationLevel.value);
    }
    if (educationOrt.present) {
      map['educationOrt'] = Variable<String>(educationOrt.value);
    }
    if (educationDuration.present) {
      map['educationDuration'] = Variable<String>(educationDuration.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (refName.present) {
      map['refName'] = Variable<String>(refName.value);
    }
    if (refPhone.present) {
      map['refPhone'] = Variable<String>(refPhone.value);
    }
    if (previousEmployers.present) {
      map['previousEmployers'] = Variable<String>(previousEmployers.value);
    }
    if (previousJobTitles.present) {
      map['previousJobTitles'] = Variable<String>(previousJobTitles.value);
    }
    if (previousJobDurations.present) {
      map['previousJobDurations'] = Variable<String>(
        previousJobDurations.value,
      );
    }
    if (sharedWorkOrts.present) {
      map['sharedWorkOrts'] = Variable<String>(sharedWorkOrts.value);
    }
    if (sharedWorkTypes.present) {
      map['sharedWorkTypes'] = Variable<String>(sharedWorkTypes.value);
    }
    if (sharedItSkills.present) {
      map['sharedItSkills'] = Variable<String>(sharedItSkills.value);
    }
    if (ausbildungEduInstitutions.present) {
      map['ausbildungEduInstitutions'] = Variable<String>(
        ausbildungEduInstitutions.value,
      );
    }
    if (ausbildungEduOrts.present) {
      map['ausbildungEduOrts'] = Variable<String>(ausbildungEduOrts.value);
    }
    if (ausbildungEduTypes.present) {
      map['ausbildungEduTypes'] = Variable<String>(ausbildungEduTypes.value);
    }
    if (ausbildungEduAbschluss.present) {
      map['ausbildungEduAbschluss'] = Variable<String>(
        ausbildungEduAbschluss.value,
      );
    }
    if (ausbildungEduDurations.present) {
      map['ausbildungEduDurations'] = Variable<String>(
        ausbildungEduDurations.value,
      );
    }
    if (ausbildungEduGrades.present) {
      map['ausbildungEduGrades'] = Variable<String>(ausbildungEduGrades.value);
    }
    if (ausbildungEscoSkills.present) {
      map['ausbildungEscoSkills'] = Variable<String>(
        ausbildungEscoSkills.value,
      );
    }
    if (ausbildungTargetOccupation.present) {
      map['ausbildungTargetOccupation'] = Variable<String>(
        ausbildungTargetOccupation.value,
      );
    }
    if (ausbildungTargetOccupationUri.present) {
      map['ausbildungTargetOccupationUri'] = Variable<String>(
        ausbildungTargetOccupationUri.value,
      );
    }
    if (schulabschluss.present) {
      map['schulabschluss'] = Variable<String>(schulabschluss.value);
    }
    if (schulabschlussNote.present) {
      map['schulabschlussNote'] = Variable<String>(schulabschlussNote.value);
    }
    if (extraData.present) {
      map['extraData'] = Variable<String>(extraData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileEntriesCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('dobDay: $dobDay, ')
          ..write('dobMonth: $dobMonth, ')
          ..write('dobYear: $dobYear, ')
          ..write('country: $country, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('street: $street, ')
          ..write('city: $city, ')
          ..write('photoPath: $photoPath, ')
          ..write('skill: $skill, ')
          ..write('workExperience: $workExperience, ')
          ..write('workType: $workType, ')
          ..write('tools: $tools, ')
          ..write('drivingLicense: $drivingLicense, ')
          ..write('languages: $languages, ')
          ..write('languageProficiency: $languageProficiency, ')
          ..write('availability: $availability, ')
          ..write('startDate: $startDate, ')
          ..write('educationLevel: $educationLevel, ')
          ..write('educationOrt: $educationOrt, ')
          ..write('educationDuration: $educationDuration, ')
          ..write('reference: $reference, ')
          ..write('refName: $refName, ')
          ..write('refPhone: $refPhone, ')
          ..write('previousEmployers: $previousEmployers, ')
          ..write('previousJobTitles: $previousJobTitles, ')
          ..write('previousJobDurations: $previousJobDurations, ')
          ..write('sharedWorkOrts: $sharedWorkOrts, ')
          ..write('sharedWorkTypes: $sharedWorkTypes, ')
          ..write('sharedItSkills: $sharedItSkills, ')
          ..write('ausbildungEduInstitutions: $ausbildungEduInstitutions, ')
          ..write('ausbildungEduOrts: $ausbildungEduOrts, ')
          ..write('ausbildungEduTypes: $ausbildungEduTypes, ')
          ..write('ausbildungEduAbschluss: $ausbildungEduAbschluss, ')
          ..write('ausbildungEduDurations: $ausbildungEduDurations, ')
          ..write('ausbildungEduGrades: $ausbildungEduGrades, ')
          ..write('ausbildungEscoSkills: $ausbildungEscoSkills, ')
          ..write('ausbildungTargetOccupation: $ausbildungTargetOccupation, ')
          ..write(
            'ausbildungTargetOccupationUri: $ausbildungTargetOccupationUri, ',
          )
          ..write('schulabschluss: $schulabschluss, ')
          ..write('schulabschlussNote: $schulabschlussNote, ')
          ..write('extraData: $extraData')
          ..write(')'))
        .toString();
  }
}

class $CvDocumentsTable extends CvDocuments
    with TableInfo<$CvDocumentsTable, CvDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CvDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accentColorMeta = const VerificationMeta(
    'accentColor',
  );
  @override
  late final GeneratedColumn<String> accentColor = GeneratedColumn<String>(
    'accent_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fontSizeMeta = const VerificationMeta(
    'fontSize',
  );
  @override
  late final GeneratedColumn<String> fontSize = GeneratedColumn<String>(
    'font_size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spacingMeta = const VerificationMeta(
    'spacing',
  );
  @override
  late final GeneratedColumn<String> spacing = GeneratedColumn<String>(
    'spacing',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _showPhotoMeta = const VerificationMeta(
    'showPhoto',
  );
  @override
  late final GeneratedColumn<bool> showPhoto = GeneratedColumn<bool>(
    'show_photo',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_photo" IN (0, 1))',
    ),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    name,
    templateId,
    accentColor,
    fontSize,
    spacing,
    showPhoto,
    payload,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cv_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<CvDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('accent_color')) {
      context.handle(
        _accentColorMeta,
        accentColor.isAcceptableOrUnknown(
          data['accent_color']!,
          _accentColorMeta,
        ),
      );
    }
    if (data.containsKey('font_size')) {
      context.handle(
        _fontSizeMeta,
        fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta),
      );
    }
    if (data.containsKey('spacing')) {
      context.handle(
        _spacingMeta,
        spacing.isAcceptableOrUnknown(data['spacing']!, _spacingMeta),
      );
    }
    if (data.containsKey('show_photo')) {
      context.handle(
        _showPhotoMeta,
        showPhoto.isAcceptableOrUnknown(data['show_photo']!, _showPhotoMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CvDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CvDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      accentColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent_color'],
      ),
      fontSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}font_size'],
      ),
      spacing: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spacing'],
      ),
      showPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_photo'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CvDocumentsTable createAlias(String alias) {
    return $CvDocumentsTable(attachedDatabase, alias);
  }
}

class CvDocument extends DataClass implements Insertable<CvDocument> {
  final int id;

  /// 'job' or 'ausbildung'.
  final String kind;
  final String name;

  /// DocumentTemplate.storageKey of the chosen template, when set.
  final String? templateId;
  final String? accentColor;
  final String? fontSize;
  final String? spacing;
  final bool? showPhoto;

  /// JSON of the per-CV answers (the questionnaire fields for this CV, in
  /// the same flat string-map shape the v1 profile used).
  final String payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CvDocument({
    required this.id,
    required this.kind,
    required this.name,
    this.templateId,
    this.accentColor,
    this.fontSize,
    this.spacing,
    this.showPhoto,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    if (!nullToAbsent || accentColor != null) {
      map['accent_color'] = Variable<String>(accentColor);
    }
    if (!nullToAbsent || fontSize != null) {
      map['font_size'] = Variable<String>(fontSize);
    }
    if (!nullToAbsent || spacing != null) {
      map['spacing'] = Variable<String>(spacing);
    }
    if (!nullToAbsent || showPhoto != null) {
      map['show_photo'] = Variable<bool>(showPhoto);
    }
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CvDocumentsCompanion toCompanion(bool nullToAbsent) {
    return CvDocumentsCompanion(
      id: Value(id),
      kind: Value(kind),
      name: Value(name),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      accentColor: accentColor == null && nullToAbsent
          ? const Value.absent()
          : Value(accentColor),
      fontSize: fontSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fontSize),
      spacing: spacing == null && nullToAbsent
          ? const Value.absent()
          : Value(spacing),
      showPhoto: showPhoto == null && nullToAbsent
          ? const Value.absent()
          : Value(showPhoto),
      payload: Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CvDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CvDocument(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      accentColor: serializer.fromJson<String?>(json['accentColor']),
      fontSize: serializer.fromJson<String?>(json['fontSize']),
      spacing: serializer.fromJson<String?>(json['spacing']),
      showPhoto: serializer.fromJson<bool?>(json['showPhoto']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'name': serializer.toJson<String>(name),
      'templateId': serializer.toJson<String?>(templateId),
      'accentColor': serializer.toJson<String?>(accentColor),
      'fontSize': serializer.toJson<String?>(fontSize),
      'spacing': serializer.toJson<String?>(spacing),
      'showPhoto': serializer.toJson<bool?>(showPhoto),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CvDocument copyWith({
    int? id,
    String? kind,
    String? name,
    Value<String?> templateId = const Value.absent(),
    Value<String?> accentColor = const Value.absent(),
    Value<String?> fontSize = const Value.absent(),
    Value<String?> spacing = const Value.absent(),
    Value<bool?> showPhoto = const Value.absent(),
    String? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CvDocument(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    templateId: templateId.present ? templateId.value : this.templateId,
    accentColor: accentColor.present ? accentColor.value : this.accentColor,
    fontSize: fontSize.present ? fontSize.value : this.fontSize,
    spacing: spacing.present ? spacing.value : this.spacing,
    showPhoto: showPhoto.present ? showPhoto.value : this.showPhoto,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CvDocument copyWithCompanion(CvDocumentsCompanion data) {
    return CvDocument(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      accentColor: data.accentColor.present
          ? data.accentColor.value
          : this.accentColor,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      spacing: data.spacing.present ? data.spacing.value : this.spacing,
      showPhoto: data.showPhoto.present ? data.showPhoto.value : this.showPhoto,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CvDocument(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('templateId: $templateId, ')
          ..write('accentColor: $accentColor, ')
          ..write('fontSize: $fontSize, ')
          ..write('spacing: $spacing, ')
          ..write('showPhoto: $showPhoto, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    name,
    templateId,
    accentColor,
    fontSize,
    spacing,
    showPhoto,
    payload,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CvDocument &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.templateId == this.templateId &&
          other.accentColor == this.accentColor &&
          other.fontSize == this.fontSize &&
          other.spacing == this.spacing &&
          other.showPhoto == this.showPhoto &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CvDocumentsCompanion extends UpdateCompanion<CvDocument> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> name;
  final Value<String?> templateId;
  final Value<String?> accentColor;
  final Value<String?> fontSize;
  final Value<String?> spacing;
  final Value<bool?> showPhoto;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CvDocumentsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.templateId = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.spacing = const Value.absent(),
    this.showPhoto = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CvDocumentsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String name,
    this.templateId = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.spacing = const Value.absent(),
    this.showPhoto = const Value.absent(),
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : kind = Value(kind),
       name = Value(name),
       payload = Value(payload),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CvDocument> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? templateId,
    Expression<String>? accentColor,
    Expression<String>? fontSize,
    Expression<String>? spacing,
    Expression<bool>? showPhoto,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (templateId != null) 'template_id': templateId,
      if (accentColor != null) 'accent_color': accentColor,
      if (fontSize != null) 'font_size': fontSize,
      if (spacing != null) 'spacing': spacing,
      if (showPhoto != null) 'show_photo': showPhoto,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CvDocumentsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? name,
    Value<String?>? templateId,
    Value<String?>? accentColor,
    Value<String?>? fontSize,
    Value<String?>? spacing,
    Value<bool?>? showPhoto,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CvDocumentsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      accentColor: accentColor ?? this.accentColor,
      fontSize: fontSize ?? this.fontSize,
      spacing: spacing ?? this.spacing,
      showPhoto: showPhoto ?? this.showPhoto,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (accentColor.present) {
      map['accent_color'] = Variable<String>(accentColor.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<String>(fontSize.value);
    }
    if (spacing.present) {
      map['spacing'] = Variable<String>(spacing.value);
    }
    if (showPhoto.present) {
      map['show_photo'] = Variable<bool>(showPhoto.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CvDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('templateId: $templateId, ')
          ..write('accentColor: $accentColor, ')
          ..write('fontSize: $fontSize, ')
          ..write('spacing: $spacing, ')
          ..write('showPhoto: $showPhoto, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LetterDocumentsTable extends LetterDocuments
    with TableInfo<$LetterDocumentsTable, LetterDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LetterDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jobTitleMeta = const VerificationMeta(
    'jobTitle',
  );
  @override
  late final GeneratedColumn<String> jobTitle = GeneratedColumn<String>(
    'job_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    company,
    jobTitle,
    payload,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'letter_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<LetterDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('job_title')) {
      context.handle(
        _jobTitleMeta,
        jobTitle.isAcceptableOrUnknown(data['job_title']!, _jobTitleMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LetterDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LetterDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      jobTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_title'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LetterDocumentsTable createAlias(String alias) {
    return $LetterDocumentsTable(attachedDatabase, alias);
  }
}

class LetterDocument extends DataClass implements Insertable<LetterDocument> {
  final int id;
  final String name;
  final String? company;
  final String? jobTitle;

  /// JSON: block texts + phrase choices for this letter (v2 letter phase
  /// defines the inner shape; the v1 migration stores the Unterlagen
  /// selection here, see data/legacy_migration.dart).
  final String payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LetterDocument({
    required this.id,
    required this.name,
    this.company,
    this.jobTitle,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || jobTitle != null) {
      map['job_title'] = Variable<String>(jobTitle);
    }
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LetterDocumentsCompanion toCompanion(bool nullToAbsent) {
    return LetterDocumentsCompanion(
      id: Value(id),
      name: Value(name),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      jobTitle: jobTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(jobTitle),
      payload: Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LetterDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LetterDocument(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      company: serializer.fromJson<String?>(json['company']),
      jobTitle: serializer.fromJson<String?>(json['jobTitle']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'company': serializer.toJson<String?>(company),
      'jobTitle': serializer.toJson<String?>(jobTitle),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LetterDocument copyWith({
    int? id,
    String? name,
    Value<String?> company = const Value.absent(),
    Value<String?> jobTitle = const Value.absent(),
    String? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LetterDocument(
    id: id ?? this.id,
    name: name ?? this.name,
    company: company.present ? company.value : this.company,
    jobTitle: jobTitle.present ? jobTitle.value : this.jobTitle,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LetterDocument copyWithCompanion(LetterDocumentsCompanion data) {
    return LetterDocument(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      company: data.company.present ? data.company.value : this.company,
      jobTitle: data.jobTitle.present ? data.jobTitle.value : this.jobTitle,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LetterDocument(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, company, jobTitle, payload, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LetterDocument &&
          other.id == this.id &&
          other.name == this.name &&
          other.company == this.company &&
          other.jobTitle == this.jobTitle &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LetterDocumentsCompanion extends UpdateCompanion<LetterDocument> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> company;
  final Value<String?> jobTitle;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LetterDocumentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.company = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LetterDocumentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.company = const Value.absent(),
    this.jobTitle = const Value.absent(),
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       payload = Value(payload),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LetterDocument> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? company,
    Expression<String>? jobTitle,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (company != null) 'company': company,
      if (jobTitle != null) 'job_title': jobTitle,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LetterDocumentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? company,
    Value<String?>? jobTitle,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LetterDocumentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (jobTitle.present) {
      map['job_title'] = Variable<String>(jobTitle.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LetterDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('company: $company, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CertificatesTable extends Certificates
    with TableInfo<$CertificatesTable, Certificate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CertificatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, kind, filePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'certificates';
  @override
  VerificationContext validateIntegrity(
    Insertable<Certificate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Certificate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Certificate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CertificatesTable createAlias(String alias) {
    return $CertificatesTable(attachedDatabase, alias);
  }
}

class Certificate extends DataClass implements Insertable<Certificate> {
  final int id;

  /// Display label as shown in the Unterlagen list (e.g. 'Sprachzertifikat
  /// B1').
  final String label;

  /// Free-form kind: 'language', 'school', 'recognition', 'licence',
  /// 'custom', ... (the v1 Unterlagen list only knew plain labels).
  final String kind;

  /// Path of an attached scan/file, when the user added one.
  final String? filePath;
  final DateTime createdAt;
  const Certificate({
    required this.id,
    required this.label,
    required this.kind,
    this.filePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CertificatesCompanion toCompanion(bool nullToAbsent) {
    return CertificatesCompanion(
      id: Value(id),
      label: Value(label),
      kind: Value(kind),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      createdAt: Value(createdAt),
    );
  }

  factory Certificate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Certificate(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      kind: serializer.fromJson<String>(json['kind']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'kind': serializer.toJson<String>(kind),
      'filePath': serializer.toJson<String?>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Certificate copyWith({
    int? id,
    String? label,
    String? kind,
    Value<String?> filePath = const Value.absent(),
    DateTime? createdAt,
  }) => Certificate(
    id: id ?? this.id,
    label: label ?? this.label,
    kind: kind ?? this.kind,
    filePath: filePath.present ? filePath.value : this.filePath,
    createdAt: createdAt ?? this.createdAt,
  );
  Certificate copyWithCompanion(CertificatesCompanion data) {
    return Certificate(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      kind: data.kind.present ? data.kind.value : this.kind,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Certificate(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('kind: $kind, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, kind, filePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Certificate &&
          other.id == this.id &&
          other.label == this.label &&
          other.kind == this.kind &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt);
}

class CertificatesCompanion extends UpdateCompanion<Certificate> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> kind;
  final Value<String?> filePath;
  final Value<DateTime> createdAt;
  const CertificatesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.kind = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CertificatesCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String kind,
    this.filePath = const Value.absent(),
    required DateTime createdAt,
  }) : label = Value(label),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Certificate> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? kind,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (kind != null) 'kind': kind,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CertificatesCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? kind,
    Value<String?>? filePath,
    Value<DateTime>? createdAt,
  }) {
    return CertificatesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      kind: kind ?? this.kind,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CertificatesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('kind: $kind, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedJobsTable extends SavedJobs
    with TableInfo<$SavedJobsTable, SavedJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _refnrMeta = const VerificationMeta('refnr');
  @override
  late final GeneratedColumn<String> refnr = GeneratedColumn<String>(
    'refnr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    refnr,
    title,
    company,
    location,
    source,
    savedAt,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('refnr')) {
      context.handle(
        _refnrMeta,
        refnr.isAcceptableOrUnknown(data['refnr']!, _refnrMeta),
      );
    } else if (isInserting) {
      context.missing(_refnrMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    } else if (isInserting) {
      context.missing(_companyMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {refnr};
  @override
  SavedJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedJob(
      refnr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refnr'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $SavedJobsTable createAlias(String alias) {
    return $SavedJobsTable(attachedDatabase, alias);
  }
}

class SavedJob extends DataClass implements Insertable<SavedJob> {
  final String refnr;
  final String title;
  final String company;
  final String location;

  /// Which surface saved it: 'jobs', 'ausbildung' or 'minijob'.
  final String source;
  final DateTime savedAt;
  final String payload;
  const SavedJob({
    required this.refnr,
    required this.title,
    required this.company,
    required this.location,
    required this.source,
    required this.savedAt,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['refnr'] = Variable<String>(refnr);
    map['title'] = Variable<String>(title);
    map['company'] = Variable<String>(company);
    map['location'] = Variable<String>(location);
    map['source'] = Variable<String>(source);
    map['saved_at'] = Variable<DateTime>(savedAt);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  SavedJobsCompanion toCompanion(bool nullToAbsent) {
    return SavedJobsCompanion(
      refnr: Value(refnr),
      title: Value(title),
      company: Value(company),
      location: Value(location),
      source: Value(source),
      savedAt: Value(savedAt),
      payload: Value(payload),
    );
  }

  factory SavedJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedJob(
      refnr: serializer.fromJson<String>(json['refnr']),
      title: serializer.fromJson<String>(json['title']),
      company: serializer.fromJson<String>(json['company']),
      location: serializer.fromJson<String>(json['location']),
      source: serializer.fromJson<String>(json['source']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'refnr': serializer.toJson<String>(refnr),
      'title': serializer.toJson<String>(title),
      'company': serializer.toJson<String>(company),
      'location': serializer.toJson<String>(location),
      'source': serializer.toJson<String>(source),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'payload': serializer.toJson<String>(payload),
    };
  }

  SavedJob copyWith({
    String? refnr,
    String? title,
    String? company,
    String? location,
    String? source,
    DateTime? savedAt,
    String? payload,
  }) => SavedJob(
    refnr: refnr ?? this.refnr,
    title: title ?? this.title,
    company: company ?? this.company,
    location: location ?? this.location,
    source: source ?? this.source,
    savedAt: savedAt ?? this.savedAt,
    payload: payload ?? this.payload,
  );
  SavedJob copyWithCompanion(SavedJobsCompanion data) {
    return SavedJob(
      refnr: data.refnr.present ? data.refnr.value : this.refnr,
      title: data.title.present ? data.title.value : this.title,
      company: data.company.present ? data.company.value : this.company,
      location: data.location.present ? data.location.value : this.location,
      source: data.source.present ? data.source.value : this.source,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedJob(')
          ..write('refnr: $refnr, ')
          ..write('title: $title, ')
          ..write('company: $company, ')
          ..write('location: $location, ')
          ..write('source: $source, ')
          ..write('savedAt: $savedAt, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(refnr, title, company, location, source, savedAt, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedJob &&
          other.refnr == this.refnr &&
          other.title == this.title &&
          other.company == this.company &&
          other.location == this.location &&
          other.source == this.source &&
          other.savedAt == this.savedAt &&
          other.payload == this.payload);
}

class SavedJobsCompanion extends UpdateCompanion<SavedJob> {
  final Value<String> refnr;
  final Value<String> title;
  final Value<String> company;
  final Value<String> location;
  final Value<String> source;
  final Value<DateTime> savedAt;
  final Value<String> payload;
  final Value<int> rowid;
  const SavedJobsCompanion({
    this.refnr = const Value.absent(),
    this.title = const Value.absent(),
    this.company = const Value.absent(),
    this.location = const Value.absent(),
    this.source = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedJobsCompanion.insert({
    required String refnr,
    required String title,
    required String company,
    required String location,
    required String source,
    required DateTime savedAt,
    required String payload,
    this.rowid = const Value.absent(),
  }) : refnr = Value(refnr),
       title = Value(title),
       company = Value(company),
       location = Value(location),
       source = Value(source),
       savedAt = Value(savedAt),
       payload = Value(payload);
  static Insertable<SavedJob> custom({
    Expression<String>? refnr,
    Expression<String>? title,
    Expression<String>? company,
    Expression<String>? location,
    Expression<String>? source,
    Expression<DateTime>? savedAt,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (refnr != null) 'refnr': refnr,
      if (title != null) 'title': title,
      if (company != null) 'company': company,
      if (location != null) 'location': location,
      if (source != null) 'source': source,
      if (savedAt != null) 'saved_at': savedAt,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedJobsCompanion copyWith({
    Value<String>? refnr,
    Value<String>? title,
    Value<String>? company,
    Value<String>? location,
    Value<String>? source,
    Value<DateTime>? savedAt,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return SavedJobsCompanion(
      refnr: refnr ?? this.refnr,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      source: source ?? this.source,
      savedAt: savedAt ?? this.savedAt,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (refnr.present) {
      map['refnr'] = Variable<String>(refnr.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedJobsCompanion(')
          ..write('refnr: $refnr, ')
          ..write('title: $title, ')
          ..write('company: $company, ')
          ..write('location: $location, ')
          ..write('source: $source, ')
          ..write('savedAt: $savedAt, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedSearchesTable extends SavedSearches
    with TableInfo<$SavedSearchesTable, SavedSearch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsMeta = const VerificationMeta('params');
  @override
  late final GeneratedColumn<String> params = GeneratedColumn<String>(
    'params',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastRunAtMeta = const VerificationMeta(
    'lastRunAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRunAt = GeneratedColumn<DateTime>(
    'last_run_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastTopRefnrMeta = const VerificationMeta(
    'lastTopRefnr',
  );
  @override
  late final GeneratedColumn<String> lastTopRefnr = GeneratedColumn<String>(
    'last_top_refnr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    params,
    lastRunAt,
    lastTopRefnr,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedSearch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('params')) {
      context.handle(
        _paramsMeta,
        params.isAcceptableOrUnknown(data['params']!, _paramsMeta),
      );
    } else if (isInserting) {
      context.missing(_paramsMeta);
    }
    if (data.containsKey('last_run_at')) {
      context.handle(
        _lastRunAtMeta,
        lastRunAt.isAcceptableOrUnknown(data['last_run_at']!, _lastRunAtMeta),
      );
    }
    if (data.containsKey('last_top_refnr')) {
      context.handle(
        _lastTopRefnrMeta,
        lastTopRefnr.isAcceptableOrUnknown(
          data['last_top_refnr']!,
          _lastTopRefnrMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedSearch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedSearch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      params: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params'],
      )!,
      lastRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_run_at'],
      ),
      lastTopRefnr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_top_refnr'],
      ),
    );
  }

  @override
  $SavedSearchesTable createAlias(String alias) {
    return $SavedSearchesTable(attachedDatabase, alias);
  }
}

class SavedSearch extends DataClass implements Insertable<SavedSearch> {
  final int id;
  final String label;
  final String params;
  final DateTime? lastRunAt;
  final String? lastTopRefnr;
  const SavedSearch({
    required this.id,
    required this.label,
    required this.params,
    this.lastRunAt,
    this.lastTopRefnr,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['params'] = Variable<String>(params);
    if (!nullToAbsent || lastRunAt != null) {
      map['last_run_at'] = Variable<DateTime>(lastRunAt);
    }
    if (!nullToAbsent || lastTopRefnr != null) {
      map['last_top_refnr'] = Variable<String>(lastTopRefnr);
    }
    return map;
  }

  SavedSearchesCompanion toCompanion(bool nullToAbsent) {
    return SavedSearchesCompanion(
      id: Value(id),
      label: Value(label),
      params: Value(params),
      lastRunAt: lastRunAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRunAt),
      lastTopRefnr: lastTopRefnr == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTopRefnr),
    );
  }

  factory SavedSearch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedSearch(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      params: serializer.fromJson<String>(json['params']),
      lastRunAt: serializer.fromJson<DateTime?>(json['lastRunAt']),
      lastTopRefnr: serializer.fromJson<String?>(json['lastTopRefnr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'params': serializer.toJson<String>(params),
      'lastRunAt': serializer.toJson<DateTime?>(lastRunAt),
      'lastTopRefnr': serializer.toJson<String?>(lastTopRefnr),
    };
  }

  SavedSearch copyWith({
    int? id,
    String? label,
    String? params,
    Value<DateTime?> lastRunAt = const Value.absent(),
    Value<String?> lastTopRefnr = const Value.absent(),
  }) => SavedSearch(
    id: id ?? this.id,
    label: label ?? this.label,
    params: params ?? this.params,
    lastRunAt: lastRunAt.present ? lastRunAt.value : this.lastRunAt,
    lastTopRefnr: lastTopRefnr.present ? lastTopRefnr.value : this.lastTopRefnr,
  );
  SavedSearch copyWithCompanion(SavedSearchesCompanion data) {
    return SavedSearch(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      params: data.params.present ? data.params.value : this.params,
      lastRunAt: data.lastRunAt.present ? data.lastRunAt.value : this.lastRunAt,
      lastTopRefnr: data.lastTopRefnr.present
          ? data.lastTopRefnr.value
          : this.lastTopRefnr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedSearch(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('params: $params, ')
          ..write('lastRunAt: $lastRunAt, ')
          ..write('lastTopRefnr: $lastTopRefnr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, params, lastRunAt, lastTopRefnr);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedSearch &&
          other.id == this.id &&
          other.label == this.label &&
          other.params == this.params &&
          other.lastRunAt == this.lastRunAt &&
          other.lastTopRefnr == this.lastTopRefnr);
}

class SavedSearchesCompanion extends UpdateCompanion<SavedSearch> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> params;
  final Value<DateTime?> lastRunAt;
  final Value<String?> lastTopRefnr;
  const SavedSearchesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.params = const Value.absent(),
    this.lastRunAt = const Value.absent(),
    this.lastTopRefnr = const Value.absent(),
  });
  SavedSearchesCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String params,
    this.lastRunAt = const Value.absent(),
    this.lastTopRefnr = const Value.absent(),
  }) : label = Value(label),
       params = Value(params);
  static Insertable<SavedSearch> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? params,
    Expression<DateTime>? lastRunAt,
    Expression<String>? lastTopRefnr,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (params != null) 'params': params,
      if (lastRunAt != null) 'last_run_at': lastRunAt,
      if (lastTopRefnr != null) 'last_top_refnr': lastTopRefnr,
    });
  }

  SavedSearchesCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? params,
    Value<DateTime?>? lastRunAt,
    Value<String?>? lastTopRefnr,
  }) {
    return SavedSearchesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      params: params ?? this.params,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      lastTopRefnr: lastTopRefnr ?? this.lastTopRefnr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (params.present) {
      map['params'] = Variable<String>(params.value);
    }
    if (lastRunAt.present) {
      map['last_run_at'] = Variable<DateTime>(lastRunAt.value);
    }
    if (lastTopRefnr.present) {
      map['last_top_refnr'] = Variable<String>(lastTopRefnr.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedSearchesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('params: $params, ')
          ..write('lastRunAt: $lastRunAt, ')
          ..write('lastTopRefnr: $lastTopRefnr')
          ..write(')'))
        .toString();
  }
}

class $ApplicationsTable extends Applications
    with TableInfo<$ApplicationsTable, Application> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApplicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _refnrMeta = const VerificationMeta('refnr');
  @override
  late final GeneratedColumn<String> refnr = GeneratedColumn<String>(
    'refnr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobTitleMeta = const VerificationMeta(
    'jobTitle',
  );
  @override
  late final GeneratedColumn<String> jobTitle = GeneratedColumn<String>(
    'job_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cvDocumentIdMeta = const VerificationMeta(
    'cvDocumentId',
  );
  @override
  late final GeneratedColumn<int> cvDocumentId = GeneratedColumn<int>(
    'cv_document_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _letterDocumentIdMeta = const VerificationMeta(
    'letterDocumentId',
  );
  @override
  late final GeneratedColumn<int> letterDocumentId = GeneratedColumn<int>(
    'letter_document_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    refnr,
    company,
    jobTitle,
    status,
    cvDocumentId,
    letterDocumentId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'applications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Application> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('refnr')) {
      context.handle(
        _refnrMeta,
        refnr.isAcceptableOrUnknown(data['refnr']!, _refnrMeta),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    } else if (isInserting) {
      context.missing(_companyMeta);
    }
    if (data.containsKey('job_title')) {
      context.handle(
        _jobTitleMeta,
        jobTitle.isAcceptableOrUnknown(data['job_title']!, _jobTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_jobTitleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('cv_document_id')) {
      context.handle(
        _cvDocumentIdMeta,
        cvDocumentId.isAcceptableOrUnknown(
          data['cv_document_id']!,
          _cvDocumentIdMeta,
        ),
      );
    }
    if (data.containsKey('letter_document_id')) {
      context.handle(
        _letterDocumentIdMeta,
        letterDocumentId.isAcceptableOrUnknown(
          data['letter_document_id']!,
          _letterDocumentIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Application map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Application(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      refnr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refnr'],
      ),
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      )!,
      jobTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      cvDocumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_document_id'],
      ),
      letterDocumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}letter_document_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ApplicationsTable createAlias(String alias) {
    return $ApplicationsTable(attachedDatabase, alias);
  }
}

class Application extends DataClass implements Insertable<Application> {
  final int id;

  /// Bundesagentur reference number of the posting, when the application
  /// came from a posting inside the app. Null for manual entries.
  final String? refnr;
  final String company;
  final String jobTitle;
  final String status;
  final int? cvDocumentId;
  final int? letterDocumentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Application({
    required this.id,
    this.refnr,
    required this.company,
    required this.jobTitle,
    required this.status,
    this.cvDocumentId,
    this.letterDocumentId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || refnr != null) {
      map['refnr'] = Variable<String>(refnr);
    }
    map['company'] = Variable<String>(company);
    map['job_title'] = Variable<String>(jobTitle);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || cvDocumentId != null) {
      map['cv_document_id'] = Variable<int>(cvDocumentId);
    }
    if (!nullToAbsent || letterDocumentId != null) {
      map['letter_document_id'] = Variable<int>(letterDocumentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ApplicationsCompanion toCompanion(bool nullToAbsent) {
    return ApplicationsCompanion(
      id: Value(id),
      refnr: refnr == null && nullToAbsent
          ? const Value.absent()
          : Value(refnr),
      company: Value(company),
      jobTitle: Value(jobTitle),
      status: Value(status),
      cvDocumentId: cvDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(cvDocumentId),
      letterDocumentId: letterDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(letterDocumentId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Application.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Application(
      id: serializer.fromJson<int>(json['id']),
      refnr: serializer.fromJson<String?>(json['refnr']),
      company: serializer.fromJson<String>(json['company']),
      jobTitle: serializer.fromJson<String>(json['jobTitle']),
      status: serializer.fromJson<String>(json['status']),
      cvDocumentId: serializer.fromJson<int?>(json['cvDocumentId']),
      letterDocumentId: serializer.fromJson<int?>(json['letterDocumentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'refnr': serializer.toJson<String?>(refnr),
      'company': serializer.toJson<String>(company),
      'jobTitle': serializer.toJson<String>(jobTitle),
      'status': serializer.toJson<String>(status),
      'cvDocumentId': serializer.toJson<int?>(cvDocumentId),
      'letterDocumentId': serializer.toJson<int?>(letterDocumentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Application copyWith({
    int? id,
    Value<String?> refnr = const Value.absent(),
    String? company,
    String? jobTitle,
    String? status,
    Value<int?> cvDocumentId = const Value.absent(),
    Value<int?> letterDocumentId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Application(
    id: id ?? this.id,
    refnr: refnr.present ? refnr.value : this.refnr,
    company: company ?? this.company,
    jobTitle: jobTitle ?? this.jobTitle,
    status: status ?? this.status,
    cvDocumentId: cvDocumentId.present ? cvDocumentId.value : this.cvDocumentId,
    letterDocumentId: letterDocumentId.present
        ? letterDocumentId.value
        : this.letterDocumentId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Application copyWithCompanion(ApplicationsCompanion data) {
    return Application(
      id: data.id.present ? data.id.value : this.id,
      refnr: data.refnr.present ? data.refnr.value : this.refnr,
      company: data.company.present ? data.company.value : this.company,
      jobTitle: data.jobTitle.present ? data.jobTitle.value : this.jobTitle,
      status: data.status.present ? data.status.value : this.status,
      cvDocumentId: data.cvDocumentId.present
          ? data.cvDocumentId.value
          : this.cvDocumentId,
      letterDocumentId: data.letterDocumentId.present
          ? data.letterDocumentId.value
          : this.letterDocumentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Application(')
          ..write('id: $id, ')
          ..write('refnr: $refnr, ')
          ..write('company: $company, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('status: $status, ')
          ..write('cvDocumentId: $cvDocumentId, ')
          ..write('letterDocumentId: $letterDocumentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    refnr,
    company,
    jobTitle,
    status,
    cvDocumentId,
    letterDocumentId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Application &&
          other.id == this.id &&
          other.refnr == this.refnr &&
          other.company == this.company &&
          other.jobTitle == this.jobTitle &&
          other.status == this.status &&
          other.cvDocumentId == this.cvDocumentId &&
          other.letterDocumentId == this.letterDocumentId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ApplicationsCompanion extends UpdateCompanion<Application> {
  final Value<int> id;
  final Value<String?> refnr;
  final Value<String> company;
  final Value<String> jobTitle;
  final Value<String> status;
  final Value<int?> cvDocumentId;
  final Value<int?> letterDocumentId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ApplicationsCompanion({
    this.id = const Value.absent(),
    this.refnr = const Value.absent(),
    this.company = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.status = const Value.absent(),
    this.cvDocumentId = const Value.absent(),
    this.letterDocumentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ApplicationsCompanion.insert({
    this.id = const Value.absent(),
    this.refnr = const Value.absent(),
    required String company,
    required String jobTitle,
    required String status,
    this.cvDocumentId = const Value.absent(),
    this.letterDocumentId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : company = Value(company),
       jobTitle = Value(jobTitle),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Application> custom({
    Expression<int>? id,
    Expression<String>? refnr,
    Expression<String>? company,
    Expression<String>? jobTitle,
    Expression<String>? status,
    Expression<int>? cvDocumentId,
    Expression<int>? letterDocumentId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (refnr != null) 'refnr': refnr,
      if (company != null) 'company': company,
      if (jobTitle != null) 'job_title': jobTitle,
      if (status != null) 'status': status,
      if (cvDocumentId != null) 'cv_document_id': cvDocumentId,
      if (letterDocumentId != null) 'letter_document_id': letterDocumentId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ApplicationsCompanion copyWith({
    Value<int>? id,
    Value<String?>? refnr,
    Value<String>? company,
    Value<String>? jobTitle,
    Value<String>? status,
    Value<int?>? cvDocumentId,
    Value<int?>? letterDocumentId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ApplicationsCompanion(
      id: id ?? this.id,
      refnr: refnr ?? this.refnr,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      status: status ?? this.status,
      cvDocumentId: cvDocumentId ?? this.cvDocumentId,
      letterDocumentId: letterDocumentId ?? this.letterDocumentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (refnr.present) {
      map['refnr'] = Variable<String>(refnr.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (jobTitle.present) {
      map['job_title'] = Variable<String>(jobTitle.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (cvDocumentId.present) {
      map['cv_document_id'] = Variable<int>(cvDocumentId.value);
    }
    if (letterDocumentId.present) {
      map['letter_document_id'] = Variable<int>(letterDocumentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApplicationsCompanion(')
          ..write('id: $id, ')
          ..write('refnr: $refnr, ')
          ..write('company: $company, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('status: $status, ')
          ..write('cvDocumentId: $cvDocumentId, ')
          ..write('letterDocumentId: $letterDocumentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $JobCacheTable extends JobCache
    with TableInfo<$JobCacheTable, JobCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, payload, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  JobCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobCacheData(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $JobCacheTable createAlias(String alias) {
    return $JobCacheTable(attachedDatabase, alias);
  }
}

class JobCacheData extends DataClass implements Insertable<JobCacheData> {
  final String cacheKey;
  final String payload;
  final DateTime fetchedAt;
  const JobCacheData({
    required this.cacheKey,
    required this.payload,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  JobCacheCompanion toCompanion(bool nullToAbsent) {
    return JobCacheCompanion(
      cacheKey: Value(cacheKey),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory JobCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobCacheData(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  JobCacheData copyWith({
    String? cacheKey,
    String? payload,
    DateTime? fetchedAt,
  }) => JobCacheData(
    cacheKey: cacheKey ?? this.cacheKey,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  JobCacheData copyWithCompanion(JobCacheCompanion data) {
    return JobCacheData(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobCacheData(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, payload, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobCacheData &&
          other.cacheKey == this.cacheKey &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt);
}

class JobCacheCompanion extends UpdateCompanion<JobCacheData> {
  final Value<String> cacheKey;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const JobCacheCompanion({
    this.cacheKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobCacheCompanion.insert({
    required String cacheKey,
    required String payload,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt);
  static Insertable<JobCacheData> custom({
    Expression<String>? cacheKey,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobCacheCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return JobCacheCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobCacheCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfileEntriesTable profileEntries = $ProfileEntriesTable(this);
  late final $CvDocumentsTable cvDocuments = $CvDocumentsTable(this);
  late final $LetterDocumentsTable letterDocuments = $LetterDocumentsTable(
    this,
  );
  late final $CertificatesTable certificates = $CertificatesTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $SavedJobsTable savedJobs = $SavedJobsTable(this);
  late final $SavedSearchesTable savedSearches = $SavedSearchesTable(this);
  late final $ApplicationsTable applications = $ApplicationsTable(this);
  late final $JobCacheTable jobCache = $JobCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profileEntries,
    cvDocuments,
    letterDocuments,
    certificates,
    appMeta,
    savedJobs,
    savedSearches,
    applications,
    jobCache,
  ];
}

typedef $$ProfileEntriesTableCreateCompanionBuilder =
    ProfileEntriesCompanion Function({
      Value<int> id,
      Value<String?> fullName,
      Value<String?> dobDay,
      Value<String?> dobMonth,
      Value<String?> dobYear,
      Value<String?> country,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> street,
      Value<String?> city,
      Value<String?> photoPath,
      Value<String?> skill,
      Value<String?> workExperience,
      Value<String?> workType,
      Value<String?> tools,
      Value<String?> drivingLicense,
      Value<String?> languages,
      Value<String?> languageProficiency,
      Value<String?> availability,
      Value<String?> startDate,
      Value<String?> educationLevel,
      Value<String?> educationOrt,
      Value<String?> educationDuration,
      Value<String?> reference,
      Value<String?> refName,
      Value<String?> refPhone,
      Value<String?> previousEmployers,
      Value<String?> previousJobTitles,
      Value<String?> previousJobDurations,
      Value<String?> sharedWorkOrts,
      Value<String?> sharedWorkTypes,
      Value<String?> sharedItSkills,
      Value<String?> ausbildungEduInstitutions,
      Value<String?> ausbildungEduOrts,
      Value<String?> ausbildungEduTypes,
      Value<String?> ausbildungEduAbschluss,
      Value<String?> ausbildungEduDurations,
      Value<String?> ausbildungEduGrades,
      Value<String?> ausbildungEscoSkills,
      Value<String?> ausbildungTargetOccupation,
      Value<String?> ausbildungTargetOccupationUri,
      Value<String?> schulabschluss,
      Value<String?> schulabschlussNote,
      Value<String?> extraData,
    });
typedef $$ProfileEntriesTableUpdateCompanionBuilder =
    ProfileEntriesCompanion Function({
      Value<int> id,
      Value<String?> fullName,
      Value<String?> dobDay,
      Value<String?> dobMonth,
      Value<String?> dobYear,
      Value<String?> country,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> street,
      Value<String?> city,
      Value<String?> photoPath,
      Value<String?> skill,
      Value<String?> workExperience,
      Value<String?> workType,
      Value<String?> tools,
      Value<String?> drivingLicense,
      Value<String?> languages,
      Value<String?> languageProficiency,
      Value<String?> availability,
      Value<String?> startDate,
      Value<String?> educationLevel,
      Value<String?> educationOrt,
      Value<String?> educationDuration,
      Value<String?> reference,
      Value<String?> refName,
      Value<String?> refPhone,
      Value<String?> previousEmployers,
      Value<String?> previousJobTitles,
      Value<String?> previousJobDurations,
      Value<String?> sharedWorkOrts,
      Value<String?> sharedWorkTypes,
      Value<String?> sharedItSkills,
      Value<String?> ausbildungEduInstitutions,
      Value<String?> ausbildungEduOrts,
      Value<String?> ausbildungEduTypes,
      Value<String?> ausbildungEduAbschluss,
      Value<String?> ausbildungEduDurations,
      Value<String?> ausbildungEduGrades,
      Value<String?> ausbildungEscoSkills,
      Value<String?> ausbildungTargetOccupation,
      Value<String?> ausbildungTargetOccupationUri,
      Value<String?> schulabschluss,
      Value<String?> schulabschlussNote,
      Value<String?> extraData,
    });

class $$ProfileEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileEntriesTable> {
  $$ProfileEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dobDay => $composableBuilder(
    column: $table.dobDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dobMonth => $composableBuilder(
    column: $table.dobMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dobYear => $composableBuilder(
    column: $table.dobYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workExperience => $composableBuilder(
    column: $table.workExperience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workType => $composableBuilder(
    column: $table.workType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tools => $composableBuilder(
    column: $table.tools,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drivingLicense => $composableBuilder(
    column: $table.drivingLicense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languages => $composableBuilder(
    column: $table.languages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageProficiency => $composableBuilder(
    column: $table.languageProficiency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get availability => $composableBuilder(
    column: $table.availability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get educationOrt => $composableBuilder(
    column: $table.educationOrt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get educationDuration => $composableBuilder(
    column: $table.educationDuration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refName => $composableBuilder(
    column: $table.refName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refPhone => $composableBuilder(
    column: $table.refPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousEmployers => $composableBuilder(
    column: $table.previousEmployers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousJobTitles => $composableBuilder(
    column: $table.previousJobTitles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousJobDurations => $composableBuilder(
    column: $table.previousJobDurations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sharedWorkOrts => $composableBuilder(
    column: $table.sharedWorkOrts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sharedWorkTypes => $composableBuilder(
    column: $table.sharedWorkTypes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sharedItSkills => $composableBuilder(
    column: $table.sharedItSkills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausbildungEduInstitutions => $composableBuilder(
    column: $table.ausbildungEduInstitutions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausbildungEduOrts => $composableBuilder(
    column: $table.ausbildungEduOrts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausbildungEduTypes => $composableBuilder(
    column: $table.ausbildungEduTypes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausbildungEduAbschluss => $composableBuilder(
    column: $table.ausbildungEduAbschluss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausbildungEduDurations => $composableBuilder(
    column: $table.ausbildungEduDurations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausbildungEduGrades => $composableBuilder(
    column: $table.ausbildungEduGrades,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausbildungEscoSkills => $composableBuilder(
    column: $table.ausbildungEscoSkills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausbildungTargetOccupation => $composableBuilder(
    column: $table.ausbildungTargetOccupation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausbildungTargetOccupationUri => $composableBuilder(
    column: $table.ausbildungTargetOccupationUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schulabschluss => $composableBuilder(
    column: $table.schulabschluss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schulabschlussNote => $composableBuilder(
    column: $table.schulabschlussNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraData => $composableBuilder(
    column: $table.extraData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileEntriesTable> {
  $$ProfileEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dobDay => $composableBuilder(
    column: $table.dobDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dobMonth => $composableBuilder(
    column: $table.dobMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dobYear => $composableBuilder(
    column: $table.dobYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skill => $composableBuilder(
    column: $table.skill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workExperience => $composableBuilder(
    column: $table.workExperience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workType => $composableBuilder(
    column: $table.workType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tools => $composableBuilder(
    column: $table.tools,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drivingLicense => $composableBuilder(
    column: $table.drivingLicense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languages => $composableBuilder(
    column: $table.languages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageProficiency => $composableBuilder(
    column: $table.languageProficiency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get availability => $composableBuilder(
    column: $table.availability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get educationOrt => $composableBuilder(
    column: $table.educationOrt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get educationDuration => $composableBuilder(
    column: $table.educationDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refName => $composableBuilder(
    column: $table.refName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refPhone => $composableBuilder(
    column: $table.refPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousEmployers => $composableBuilder(
    column: $table.previousEmployers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousJobTitles => $composableBuilder(
    column: $table.previousJobTitles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousJobDurations => $composableBuilder(
    column: $table.previousJobDurations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sharedWorkOrts => $composableBuilder(
    column: $table.sharedWorkOrts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sharedWorkTypes => $composableBuilder(
    column: $table.sharedWorkTypes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sharedItSkills => $composableBuilder(
    column: $table.sharedItSkills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausbildungEduInstitutions => $composableBuilder(
    column: $table.ausbildungEduInstitutions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausbildungEduOrts => $composableBuilder(
    column: $table.ausbildungEduOrts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausbildungEduTypes => $composableBuilder(
    column: $table.ausbildungEduTypes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausbildungEduAbschluss => $composableBuilder(
    column: $table.ausbildungEduAbschluss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausbildungEduDurations => $composableBuilder(
    column: $table.ausbildungEduDurations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausbildungEduGrades => $composableBuilder(
    column: $table.ausbildungEduGrades,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausbildungEscoSkills => $composableBuilder(
    column: $table.ausbildungEscoSkills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausbildungTargetOccupation => $composableBuilder(
    column: $table.ausbildungTargetOccupation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausbildungTargetOccupationUri =>
      $composableBuilder(
        column: $table.ausbildungTargetOccupationUri,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get schulabschluss => $composableBuilder(
    column: $table.schulabschluss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schulabschlussNote => $composableBuilder(
    column: $table.schulabschlussNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraData => $composableBuilder(
    column: $table.extraData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileEntriesTable> {
  $$ProfileEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get dobDay =>
      $composableBuilder(column: $table.dobDay, builder: (column) => column);

  GeneratedColumn<String> get dobMonth =>
      $composableBuilder(column: $table.dobMonth, builder: (column) => column);

  GeneratedColumn<String> get dobYear =>
      $composableBuilder(column: $table.dobYear, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get skill =>
      $composableBuilder(column: $table.skill, builder: (column) => column);

  GeneratedColumn<String> get workExperience => $composableBuilder(
    column: $table.workExperience,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workType =>
      $composableBuilder(column: $table.workType, builder: (column) => column);

  GeneratedColumn<String> get tools =>
      $composableBuilder(column: $table.tools, builder: (column) => column);

  GeneratedColumn<String> get drivingLicense => $composableBuilder(
    column: $table.drivingLicense,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languages =>
      $composableBuilder(column: $table.languages, builder: (column) => column);

  GeneratedColumn<String> get languageProficiency => $composableBuilder(
    column: $table.languageProficiency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get availability => $composableBuilder(
    column: $table.availability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get educationOrt => $composableBuilder(
    column: $table.educationOrt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get educationDuration => $composableBuilder(
    column: $table.educationDuration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get refName =>
      $composableBuilder(column: $table.refName, builder: (column) => column);

  GeneratedColumn<String> get refPhone =>
      $composableBuilder(column: $table.refPhone, builder: (column) => column);

  GeneratedColumn<String> get previousEmployers => $composableBuilder(
    column: $table.previousEmployers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousJobTitles => $composableBuilder(
    column: $table.previousJobTitles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousJobDurations => $composableBuilder(
    column: $table.previousJobDurations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sharedWorkOrts => $composableBuilder(
    column: $table.sharedWorkOrts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sharedWorkTypes => $composableBuilder(
    column: $table.sharedWorkTypes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sharedItSkills => $composableBuilder(
    column: $table.sharedItSkills,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausbildungEduInstitutions => $composableBuilder(
    column: $table.ausbildungEduInstitutions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausbildungEduOrts => $composableBuilder(
    column: $table.ausbildungEduOrts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausbildungEduTypes => $composableBuilder(
    column: $table.ausbildungEduTypes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausbildungEduAbschluss => $composableBuilder(
    column: $table.ausbildungEduAbschluss,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausbildungEduDurations => $composableBuilder(
    column: $table.ausbildungEduDurations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausbildungEduGrades => $composableBuilder(
    column: $table.ausbildungEduGrades,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausbildungEscoSkills => $composableBuilder(
    column: $table.ausbildungEscoSkills,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausbildungTargetOccupation => $composableBuilder(
    column: $table.ausbildungTargetOccupation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausbildungTargetOccupationUri =>
      $composableBuilder(
        column: $table.ausbildungTargetOccupationUri,
        builder: (column) => column,
      );

  GeneratedColumn<String> get schulabschluss => $composableBuilder(
    column: $table.schulabschluss,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schulabschlussNote => $composableBuilder(
    column: $table.schulabschlussNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extraData =>
      $composableBuilder(column: $table.extraData, builder: (column) => column);
}

class $$ProfileEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileEntriesTable,
          ProfileEntry,
          $$ProfileEntriesTableFilterComposer,
          $$ProfileEntriesTableOrderingComposer,
          $$ProfileEntriesTableAnnotationComposer,
          $$ProfileEntriesTableCreateCompanionBuilder,
          $$ProfileEntriesTableUpdateCompanionBuilder,
          (
            ProfileEntry,
            BaseReferences<_$AppDatabase, $ProfileEntriesTable, ProfileEntry>,
          ),
          ProfileEntry,
          PrefetchHooks Function()
        > {
  $$ProfileEntriesTableTableManager(
    _$AppDatabase db,
    $ProfileEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> dobDay = const Value.absent(),
                Value<String?> dobMonth = const Value.absent(),
                Value<String?> dobYear = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> street = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> skill = const Value.absent(),
                Value<String?> workExperience = const Value.absent(),
                Value<String?> workType = const Value.absent(),
                Value<String?> tools = const Value.absent(),
                Value<String?> drivingLicense = const Value.absent(),
                Value<String?> languages = const Value.absent(),
                Value<String?> languageProficiency = const Value.absent(),
                Value<String?> availability = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> educationLevel = const Value.absent(),
                Value<String?> educationOrt = const Value.absent(),
                Value<String?> educationDuration = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> refName = const Value.absent(),
                Value<String?> refPhone = const Value.absent(),
                Value<String?> previousEmployers = const Value.absent(),
                Value<String?> previousJobTitles = const Value.absent(),
                Value<String?> previousJobDurations = const Value.absent(),
                Value<String?> sharedWorkOrts = const Value.absent(),
                Value<String?> sharedWorkTypes = const Value.absent(),
                Value<String?> sharedItSkills = const Value.absent(),
                Value<String?> ausbildungEduInstitutions = const Value.absent(),
                Value<String?> ausbildungEduOrts = const Value.absent(),
                Value<String?> ausbildungEduTypes = const Value.absent(),
                Value<String?> ausbildungEduAbschluss = const Value.absent(),
                Value<String?> ausbildungEduDurations = const Value.absent(),
                Value<String?> ausbildungEduGrades = const Value.absent(),
                Value<String?> ausbildungEscoSkills = const Value.absent(),
                Value<String?> ausbildungTargetOccupation =
                    const Value.absent(),
                Value<String?> ausbildungTargetOccupationUri =
                    const Value.absent(),
                Value<String?> schulabschluss = const Value.absent(),
                Value<String?> schulabschlussNote = const Value.absent(),
                Value<String?> extraData = const Value.absent(),
              }) => ProfileEntriesCompanion(
                id: id,
                fullName: fullName,
                dobDay: dobDay,
                dobMonth: dobMonth,
                dobYear: dobYear,
                country: country,
                phone: phone,
                email: email,
                street: street,
                city: city,
                photoPath: photoPath,
                skill: skill,
                workExperience: workExperience,
                workType: workType,
                tools: tools,
                drivingLicense: drivingLicense,
                languages: languages,
                languageProficiency: languageProficiency,
                availability: availability,
                startDate: startDate,
                educationLevel: educationLevel,
                educationOrt: educationOrt,
                educationDuration: educationDuration,
                reference: reference,
                refName: refName,
                refPhone: refPhone,
                previousEmployers: previousEmployers,
                previousJobTitles: previousJobTitles,
                previousJobDurations: previousJobDurations,
                sharedWorkOrts: sharedWorkOrts,
                sharedWorkTypes: sharedWorkTypes,
                sharedItSkills: sharedItSkills,
                ausbildungEduInstitutions: ausbildungEduInstitutions,
                ausbildungEduOrts: ausbildungEduOrts,
                ausbildungEduTypes: ausbildungEduTypes,
                ausbildungEduAbschluss: ausbildungEduAbschluss,
                ausbildungEduDurations: ausbildungEduDurations,
                ausbildungEduGrades: ausbildungEduGrades,
                ausbildungEscoSkills: ausbildungEscoSkills,
                ausbildungTargetOccupation: ausbildungTargetOccupation,
                ausbildungTargetOccupationUri: ausbildungTargetOccupationUri,
                schulabschluss: schulabschluss,
                schulabschlussNote: schulabschlussNote,
                extraData: extraData,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> dobDay = const Value.absent(),
                Value<String?> dobMonth = const Value.absent(),
                Value<String?> dobYear = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> street = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> skill = const Value.absent(),
                Value<String?> workExperience = const Value.absent(),
                Value<String?> workType = const Value.absent(),
                Value<String?> tools = const Value.absent(),
                Value<String?> drivingLicense = const Value.absent(),
                Value<String?> languages = const Value.absent(),
                Value<String?> languageProficiency = const Value.absent(),
                Value<String?> availability = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> educationLevel = const Value.absent(),
                Value<String?> educationOrt = const Value.absent(),
                Value<String?> educationDuration = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> refName = const Value.absent(),
                Value<String?> refPhone = const Value.absent(),
                Value<String?> previousEmployers = const Value.absent(),
                Value<String?> previousJobTitles = const Value.absent(),
                Value<String?> previousJobDurations = const Value.absent(),
                Value<String?> sharedWorkOrts = const Value.absent(),
                Value<String?> sharedWorkTypes = const Value.absent(),
                Value<String?> sharedItSkills = const Value.absent(),
                Value<String?> ausbildungEduInstitutions = const Value.absent(),
                Value<String?> ausbildungEduOrts = const Value.absent(),
                Value<String?> ausbildungEduTypes = const Value.absent(),
                Value<String?> ausbildungEduAbschluss = const Value.absent(),
                Value<String?> ausbildungEduDurations = const Value.absent(),
                Value<String?> ausbildungEduGrades = const Value.absent(),
                Value<String?> ausbildungEscoSkills = const Value.absent(),
                Value<String?> ausbildungTargetOccupation =
                    const Value.absent(),
                Value<String?> ausbildungTargetOccupationUri =
                    const Value.absent(),
                Value<String?> schulabschluss = const Value.absent(),
                Value<String?> schulabschlussNote = const Value.absent(),
                Value<String?> extraData = const Value.absent(),
              }) => ProfileEntriesCompanion.insert(
                id: id,
                fullName: fullName,
                dobDay: dobDay,
                dobMonth: dobMonth,
                dobYear: dobYear,
                country: country,
                phone: phone,
                email: email,
                street: street,
                city: city,
                photoPath: photoPath,
                skill: skill,
                workExperience: workExperience,
                workType: workType,
                tools: tools,
                drivingLicense: drivingLicense,
                languages: languages,
                languageProficiency: languageProficiency,
                availability: availability,
                startDate: startDate,
                educationLevel: educationLevel,
                educationOrt: educationOrt,
                educationDuration: educationDuration,
                reference: reference,
                refName: refName,
                refPhone: refPhone,
                previousEmployers: previousEmployers,
                previousJobTitles: previousJobTitles,
                previousJobDurations: previousJobDurations,
                sharedWorkOrts: sharedWorkOrts,
                sharedWorkTypes: sharedWorkTypes,
                sharedItSkills: sharedItSkills,
                ausbildungEduInstitutions: ausbildungEduInstitutions,
                ausbildungEduOrts: ausbildungEduOrts,
                ausbildungEduTypes: ausbildungEduTypes,
                ausbildungEduAbschluss: ausbildungEduAbschluss,
                ausbildungEduDurations: ausbildungEduDurations,
                ausbildungEduGrades: ausbildungEduGrades,
                ausbildungEscoSkills: ausbildungEscoSkills,
                ausbildungTargetOccupation: ausbildungTargetOccupation,
                ausbildungTargetOccupationUri: ausbildungTargetOccupationUri,
                schulabschluss: schulabschluss,
                schulabschlussNote: schulabschlussNote,
                extraData: extraData,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfileEntriesTable, ProfileEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProfileEntriesTable,
                    ProfileEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileEntriesTable,
      ProfileEntry,
      $$ProfileEntriesTableFilterComposer,
      $$ProfileEntriesTableOrderingComposer,
      $$ProfileEntriesTableAnnotationComposer,
      $$ProfileEntriesTableCreateCompanionBuilder,
      $$ProfileEntriesTableUpdateCompanionBuilder,
      (
        ProfileEntry,
        BaseReferences<_$AppDatabase, $ProfileEntriesTable, ProfileEntry>,
      ),
      ProfileEntry,
      PrefetchHooks Function()
    >;
typedef $$CvDocumentsTableCreateCompanionBuilder =
    CvDocumentsCompanion Function({
      Value<int> id,
      required String kind,
      required String name,
      Value<String?> templateId,
      Value<String?> accentColor,
      Value<String?> fontSize,
      Value<String?> spacing,
      Value<bool?> showPhoto,
      required String payload,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CvDocumentsTableUpdateCompanionBuilder =
    CvDocumentsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> name,
      Value<String?> templateId,
      Value<String?> accentColor,
      Value<String?> fontSize,
      Value<String?> spacing,
      Value<bool?> showPhoto,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CvDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $CvDocumentsTable> {
  $$CvDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spacing => $composableBuilder(
    column: $table.spacing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showPhoto => $composableBuilder(
    column: $table.showPhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CvDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CvDocumentsTable> {
  $$CvDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spacing => $composableBuilder(
    column: $table.spacing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showPhoto => $composableBuilder(
    column: $table.showPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CvDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CvDocumentsTable> {
  $$CvDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<String> get spacing =>
      $composableBuilder(column: $table.spacing, builder: (column) => column);

  GeneratedColumn<bool> get showPhoto =>
      $composableBuilder(column: $table.showPhoto, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CvDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CvDocumentsTable,
          CvDocument,
          $$CvDocumentsTableFilterComposer,
          $$CvDocumentsTableOrderingComposer,
          $$CvDocumentsTableAnnotationComposer,
          $$CvDocumentsTableCreateCompanionBuilder,
          $$CvDocumentsTableUpdateCompanionBuilder,
          (
            CvDocument,
            BaseReferences<_$AppDatabase, $CvDocumentsTable, CvDocument>,
          ),
          CvDocument,
          PrefetchHooks Function()
        > {
  $$CvDocumentsTableTableManager(_$AppDatabase db, $CvDocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CvDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CvDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CvDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<String?> accentColor = const Value.absent(),
                Value<String?> fontSize = const Value.absent(),
                Value<String?> spacing = const Value.absent(),
                Value<bool?> showPhoto = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CvDocumentsCompanion(
                id: id,
                kind: kind,
                name: name,
                templateId: templateId,
                accentColor: accentColor,
                fontSize: fontSize,
                spacing: spacing,
                showPhoto: showPhoto,
                payload: payload,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String name,
                Value<String?> templateId = const Value.absent(),
                Value<String?> accentColor = const Value.absent(),
                Value<String?> fontSize = const Value.absent(),
                Value<String?> spacing = const Value.absent(),
                Value<bool?> showPhoto = const Value.absent(),
                required String payload,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CvDocumentsCompanion.insert(
                id: id,
                kind: kind,
                name: name,
                templateId: templateId,
                accentColor: accentColor,
                fontSize: fontSize,
                spacing: spacing,
                showPhoto: showPhoto,
                payload: payload,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CvDocumentsTable, CvDocument>(table),
                  BaseReferences<_$AppDatabase, $CvDocumentsTable, CvDocument>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CvDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CvDocumentsTable,
      CvDocument,
      $$CvDocumentsTableFilterComposer,
      $$CvDocumentsTableOrderingComposer,
      $$CvDocumentsTableAnnotationComposer,
      $$CvDocumentsTableCreateCompanionBuilder,
      $$CvDocumentsTableUpdateCompanionBuilder,
      (
        CvDocument,
        BaseReferences<_$AppDatabase, $CvDocumentsTable, CvDocument>,
      ),
      CvDocument,
      PrefetchHooks Function()
    >;
typedef $$LetterDocumentsTableCreateCompanionBuilder =
    LetterDocumentsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> company,
      Value<String?> jobTitle,
      required String payload,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$LetterDocumentsTableUpdateCompanionBuilder =
    LetterDocumentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> company,
      Value<String?> jobTitle,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$LetterDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $LetterDocumentsTable> {
  $$LetterDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LetterDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LetterDocumentsTable> {
  $$LetterDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LetterDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LetterDocumentsTable> {
  $$LetterDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get jobTitle =>
      $composableBuilder(column: $table.jobTitle, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LetterDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LetterDocumentsTable,
          LetterDocument,
          $$LetterDocumentsTableFilterComposer,
          $$LetterDocumentsTableOrderingComposer,
          $$LetterDocumentsTableAnnotationComposer,
          $$LetterDocumentsTableCreateCompanionBuilder,
          $$LetterDocumentsTableUpdateCompanionBuilder,
          (
            LetterDocument,
            BaseReferences<
              _$AppDatabase,
              $LetterDocumentsTable,
              LetterDocument
            >,
          ),
          LetterDocument,
          PrefetchHooks Function()
        > {
  $$LetterDocumentsTableTableManager(
    _$AppDatabase db,
    $LetterDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LetterDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LetterDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LetterDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> jobTitle = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LetterDocumentsCompanion(
                id: id,
                name: name,
                company: company,
                jobTitle: jobTitle,
                payload: payload,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> company = const Value.absent(),
                Value<String?> jobTitle = const Value.absent(),
                required String payload,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => LetterDocumentsCompanion.insert(
                id: id,
                name: name,
                company: company,
                jobTitle: jobTitle,
                payload: payload,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LetterDocumentsTable, LetterDocument>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LetterDocumentsTable,
                    LetterDocument
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LetterDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LetterDocumentsTable,
      LetterDocument,
      $$LetterDocumentsTableFilterComposer,
      $$LetterDocumentsTableOrderingComposer,
      $$LetterDocumentsTableAnnotationComposer,
      $$LetterDocumentsTableCreateCompanionBuilder,
      $$LetterDocumentsTableUpdateCompanionBuilder,
      (
        LetterDocument,
        BaseReferences<_$AppDatabase, $LetterDocumentsTable, LetterDocument>,
      ),
      LetterDocument,
      PrefetchHooks Function()
    >;
typedef $$CertificatesTableCreateCompanionBuilder =
    CertificatesCompanion Function({
      Value<int> id,
      required String label,
      required String kind,
      Value<String?> filePath,
      required DateTime createdAt,
    });
typedef $$CertificatesTableUpdateCompanionBuilder =
    CertificatesCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> kind,
      Value<String?> filePath,
      Value<DateTime> createdAt,
    });

class $$CertificatesTableFilterComposer
    extends Composer<_$AppDatabase, $CertificatesTable> {
  $$CertificatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CertificatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CertificatesTable> {
  $$CertificatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CertificatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CertificatesTable> {
  $$CertificatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CertificatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CertificatesTable,
          Certificate,
          $$CertificatesTableFilterComposer,
          $$CertificatesTableOrderingComposer,
          $$CertificatesTableAnnotationComposer,
          $$CertificatesTableCreateCompanionBuilder,
          $$CertificatesTableUpdateCompanionBuilder,
          (
            Certificate,
            BaseReferences<_$AppDatabase, $CertificatesTable, Certificate>,
          ),
          Certificate,
          PrefetchHooks Function()
        > {
  $$CertificatesTableTableManager(_$AppDatabase db, $CertificatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CertificatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CertificatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CertificatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CertificatesCompanion(
                id: id,
                label: label,
                kind: kind,
                filePath: filePath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String kind,
                Value<String?> filePath = const Value.absent(),
                required DateTime createdAt,
              }) => CertificatesCompanion.insert(
                id: id,
                label: label,
                kind: kind,
                filePath: filePath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CertificatesTable, Certificate>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CertificatesTable,
                    Certificate
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CertificatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CertificatesTable,
      Certificate,
      $$CertificatesTableFilterComposer,
      $$CertificatesTableOrderingComposer,
      $$CertificatesTableAnnotationComposer,
      $$CertificatesTableCreateCompanionBuilder,
      $$CertificatesTableUpdateCompanionBuilder,
      (
        Certificate,
        BaseReferences<_$AppDatabase, $CertificatesTable, Certificate>,
      ),
      Certificate,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, AppMetaData>(table),
                  BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;
typedef $$SavedJobsTableCreateCompanionBuilder =
    SavedJobsCompanion Function({
      required String refnr,
      required String title,
      required String company,
      required String location,
      required String source,
      required DateTime savedAt,
      required String payload,
      Value<int> rowid,
    });
typedef $$SavedJobsTableUpdateCompanionBuilder =
    SavedJobsCompanion Function({
      Value<String> refnr,
      Value<String> title,
      Value<String> company,
      Value<String> location,
      Value<String> source,
      Value<DateTime> savedAt,
      Value<String> payload,
      Value<int> rowid,
    });

class $$SavedJobsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedJobsTable> {
  $$SavedJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get refnr => $composableBuilder(
    column: $table.refnr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedJobsTable> {
  $$SavedJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get refnr => $composableBuilder(
    column: $table.refnr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedJobsTable> {
  $$SavedJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get refnr =>
      $composableBuilder(column: $table.refnr, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$SavedJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedJobsTable,
          SavedJob,
          $$SavedJobsTableFilterComposer,
          $$SavedJobsTableOrderingComposer,
          $$SavedJobsTableAnnotationComposer,
          $$SavedJobsTableCreateCompanionBuilder,
          $$SavedJobsTableUpdateCompanionBuilder,
          (SavedJob, BaseReferences<_$AppDatabase, $SavedJobsTable, SavedJob>),
          SavedJob,
          PrefetchHooks Function()
        > {
  $$SavedJobsTableTableManager(_$AppDatabase db, $SavedJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> refnr = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedJobsCompanion(
                refnr: refnr,
                title: title,
                company: company,
                location: location,
                source: source,
                savedAt: savedAt,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String refnr,
                required String title,
                required String company,
                required String location,
                required String source,
                required DateTime savedAt,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => SavedJobsCompanion.insert(
                refnr: refnr,
                title: title,
                company: company,
                location: location,
                source: source,
                savedAt: savedAt,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavedJobsTable, SavedJob>(table),
                  BaseReferences<_$AppDatabase, $SavedJobsTable, SavedJob>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedJobsTable,
      SavedJob,
      $$SavedJobsTableFilterComposer,
      $$SavedJobsTableOrderingComposer,
      $$SavedJobsTableAnnotationComposer,
      $$SavedJobsTableCreateCompanionBuilder,
      $$SavedJobsTableUpdateCompanionBuilder,
      (SavedJob, BaseReferences<_$AppDatabase, $SavedJobsTable, SavedJob>),
      SavedJob,
      PrefetchHooks Function()
    >;
typedef $$SavedSearchesTableCreateCompanionBuilder =
    SavedSearchesCompanion Function({
      Value<int> id,
      required String label,
      required String params,
      Value<DateTime?> lastRunAt,
      Value<String?> lastTopRefnr,
    });
typedef $$SavedSearchesTableUpdateCompanionBuilder =
    SavedSearchesCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> params,
      Value<DateTime?> lastRunAt,
      Value<String?> lastTopRefnr,
    });

class $$SavedSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedSearchesTable> {
  $$SavedSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRunAt => $composableBuilder(
    column: $table.lastRunAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastTopRefnr => $composableBuilder(
    column: $table.lastTopRefnr,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedSearchesTable> {
  $$SavedSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRunAt => $composableBuilder(
    column: $table.lastRunAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastTopRefnr => $composableBuilder(
    column: $table.lastTopRefnr,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedSearchesTable> {
  $$SavedSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get params =>
      $composableBuilder(column: $table.params, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRunAt =>
      $composableBuilder(column: $table.lastRunAt, builder: (column) => column);

  GeneratedColumn<String> get lastTopRefnr => $composableBuilder(
    column: $table.lastTopRefnr,
    builder: (column) => column,
  );
}

class $$SavedSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedSearchesTable,
          SavedSearch,
          $$SavedSearchesTableFilterComposer,
          $$SavedSearchesTableOrderingComposer,
          $$SavedSearchesTableAnnotationComposer,
          $$SavedSearchesTableCreateCompanionBuilder,
          $$SavedSearchesTableUpdateCompanionBuilder,
          (
            SavedSearch,
            BaseReferences<_$AppDatabase, $SavedSearchesTable, SavedSearch>,
          ),
          SavedSearch,
          PrefetchHooks Function()
        > {
  $$SavedSearchesTableTableManager(_$AppDatabase db, $SavedSearchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> params = const Value.absent(),
                Value<DateTime?> lastRunAt = const Value.absent(),
                Value<String?> lastTopRefnr = const Value.absent(),
              }) => SavedSearchesCompanion(
                id: id,
                label: label,
                params: params,
                lastRunAt: lastRunAt,
                lastTopRefnr: lastTopRefnr,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String params,
                Value<DateTime?> lastRunAt = const Value.absent(),
                Value<String?> lastTopRefnr = const Value.absent(),
              }) => SavedSearchesCompanion.insert(
                id: id,
                label: label,
                params: params,
                lastRunAt: lastRunAt,
                lastTopRefnr: lastTopRefnr,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavedSearchesTable, SavedSearch>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SavedSearchesTable,
                    SavedSearch
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedSearchesTable,
      SavedSearch,
      $$SavedSearchesTableFilterComposer,
      $$SavedSearchesTableOrderingComposer,
      $$SavedSearchesTableAnnotationComposer,
      $$SavedSearchesTableCreateCompanionBuilder,
      $$SavedSearchesTableUpdateCompanionBuilder,
      (
        SavedSearch,
        BaseReferences<_$AppDatabase, $SavedSearchesTable, SavedSearch>,
      ),
      SavedSearch,
      PrefetchHooks Function()
    >;
typedef $$ApplicationsTableCreateCompanionBuilder =
    ApplicationsCompanion Function({
      Value<int> id,
      Value<String?> refnr,
      required String company,
      required String jobTitle,
      required String status,
      Value<int?> cvDocumentId,
      Value<int?> letterDocumentId,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ApplicationsTableUpdateCompanionBuilder =
    ApplicationsCompanion Function({
      Value<int> id,
      Value<String?> refnr,
      Value<String> company,
      Value<String> jobTitle,
      Value<String> status,
      Value<int?> cvDocumentId,
      Value<int?> letterDocumentId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$ApplicationsTableFilterComposer
    extends Composer<_$AppDatabase, $ApplicationsTable> {
  $$ApplicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refnr => $composableBuilder(
    column: $table.refnr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvDocumentId => $composableBuilder(
    column: $table.cvDocumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get letterDocumentId => $composableBuilder(
    column: $table.letterDocumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApplicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ApplicationsTable> {
  $$ApplicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refnr => $composableBuilder(
    column: $table.refnr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvDocumentId => $composableBuilder(
    column: $table.cvDocumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get letterDocumentId => $composableBuilder(
    column: $table.letterDocumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApplicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApplicationsTable> {
  $$ApplicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get refnr =>
      $composableBuilder(column: $table.refnr, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get jobTitle =>
      $composableBuilder(column: $table.jobTitle, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get cvDocumentId => $composableBuilder(
    column: $table.cvDocumentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get letterDocumentId => $composableBuilder(
    column: $table.letterDocumentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ApplicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApplicationsTable,
          Application,
          $$ApplicationsTableFilterComposer,
          $$ApplicationsTableOrderingComposer,
          $$ApplicationsTableAnnotationComposer,
          $$ApplicationsTableCreateCompanionBuilder,
          $$ApplicationsTableUpdateCompanionBuilder,
          (
            Application,
            BaseReferences<_$AppDatabase, $ApplicationsTable, Application>,
          ),
          Application,
          PrefetchHooks Function()
        > {
  $$ApplicationsTableTableManager(_$AppDatabase db, $ApplicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApplicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApplicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApplicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> refnr = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<String> jobTitle = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> cvDocumentId = const Value.absent(),
                Value<int?> letterDocumentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ApplicationsCompanion(
                id: id,
                refnr: refnr,
                company: company,
                jobTitle: jobTitle,
                status: status,
                cvDocumentId: cvDocumentId,
                letterDocumentId: letterDocumentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> refnr = const Value.absent(),
                required String company,
                required String jobTitle,
                required String status,
                Value<int?> cvDocumentId = const Value.absent(),
                Value<int?> letterDocumentId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ApplicationsCompanion.insert(
                id: id,
                refnr: refnr,
                company: company,
                jobTitle: jobTitle,
                status: status,
                cvDocumentId: cvDocumentId,
                letterDocumentId: letterDocumentId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ApplicationsTable, Application>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ApplicationsTable,
                    Application
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApplicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApplicationsTable,
      Application,
      $$ApplicationsTableFilterComposer,
      $$ApplicationsTableOrderingComposer,
      $$ApplicationsTableAnnotationComposer,
      $$ApplicationsTableCreateCompanionBuilder,
      $$ApplicationsTableUpdateCompanionBuilder,
      (
        Application,
        BaseReferences<_$AppDatabase, $ApplicationsTable, Application>,
      ),
      Application,
      PrefetchHooks Function()
    >;
typedef $$JobCacheTableCreateCompanionBuilder =
    JobCacheCompanion Function({
      required String cacheKey,
      required String payload,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$JobCacheTableUpdateCompanionBuilder =
    JobCacheCompanion Function({
      Value<String> cacheKey,
      Value<String> payload,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$JobCacheTableFilterComposer
    extends Composer<_$AppDatabase, $JobCacheTable> {
  $$JobCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JobCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $JobCacheTable> {
  $$JobCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobCacheTable> {
  $$JobCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$JobCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobCacheTable,
          JobCacheData,
          $$JobCacheTableFilterComposer,
          $$JobCacheTableOrderingComposer,
          $$JobCacheTableAnnotationComposer,
          $$JobCacheTableCreateCompanionBuilder,
          $$JobCacheTableUpdateCompanionBuilder,
          (
            JobCacheData,
            BaseReferences<_$AppDatabase, $JobCacheTable, JobCacheData>,
          ),
          JobCacheData,
          PrefetchHooks Function()
        > {
  $$JobCacheTableTableManager(_$AppDatabase db, $JobCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobCacheCompanion(
                cacheKey: cacheKey,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String payload,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => JobCacheCompanion.insert(
                cacheKey: cacheKey,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JobCacheTable, JobCacheData>(table),
                  BaseReferences<_$AppDatabase, $JobCacheTable, JobCacheData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JobCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobCacheTable,
      JobCacheData,
      $$JobCacheTableFilterComposer,
      $$JobCacheTableOrderingComposer,
      $$JobCacheTableAnnotationComposer,
      $$JobCacheTableCreateCompanionBuilder,
      $$JobCacheTableUpdateCompanionBuilder,
      (
        JobCacheData,
        BaseReferences<_$AppDatabase, $JobCacheTable, JobCacheData>,
      ),
      JobCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfileEntriesTableTableManager get profileEntries =>
      $$ProfileEntriesTableTableManager(_db, _db.profileEntries);
  $$CvDocumentsTableTableManager get cvDocuments =>
      $$CvDocumentsTableTableManager(_db, _db.cvDocuments);
  $$LetterDocumentsTableTableManager get letterDocuments =>
      $$LetterDocumentsTableTableManager(_db, _db.letterDocuments);
  $$CertificatesTableTableManager get certificates =>
      $$CertificatesTableTableManager(_db, _db.certificates);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$SavedJobsTableTableManager get savedJobs =>
      $$SavedJobsTableTableManager(_db, _db.savedJobs);
  $$SavedSearchesTableTableManager get savedSearches =>
      $$SavedSearchesTableTableManager(_db, _db.savedSearches);
  $$ApplicationsTableTableManager get applications =>
      $$ApplicationsTableTableManager(_db, _db.applications);
  $$JobCacheTableTableManager get jobCache =>
      $$JobCacheTableTableManager(_db, _db.jobCache);
}
