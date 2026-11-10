import 'dart:io';

import 'package:flutter/material.dart';

import '../ui/karyab_ui.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/karyab_data.dart';
import '../services/analytics_service.dart';
import '../services/tts_service.dart';
import 'ausbildung_cv_questionnaire_screen.dart';
import 'questionnaire_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared personal-data pre-step - name, DOB, nationality, address, phone,
// email, photo. Shown once, before either CV questionnaire, and only when
// this data doesn't already exist in 'saved_profile' (ChooseCvTypeScreen
// skips straight past this screen when it's already filled in). Writes into
// the same keys questionnaire_screen.dart's Page 1 used to write
// (fullName, dobDay/dobMonth/dobYear, country, street, city, phone, email,
// photoPath, plus the legacy user_phone/user_email/user_street/user_city/
// user_postal/questionnaire_full_name keys other screens still read), so
// both CV types - and the rest of the app - see the same data.
// ─────────────────────────────────────────────────────────────────────────────

class PersonalDataScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;
  // 'job' or 'ausbildung' - which questionnaire to continue into once this
  // step is saved.
  final String nextCvType;

  const PersonalDataScreen({
    super.key,
    required this.language,
    required this.nextCvType,
    this.voiceMode = false,
  });

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  static const Color _navy  = Color(0xFF091733);
  static const Color _green = Color(0xFF39EA2B);
  static const Color _muted = Color(0xFF65738A);

  late String _lang;
  late bool _voiceMode;
  bool _saving = false;
  String? _error;

  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  int?    _dobDay;
  int?    _dobMonth;
  int?    _dobYear;
  String? _country;
  bool _countryOtherOpen = false;
  final _countryOtherCtrl = TextEditingController();
  String? _photoPath;

  bool get _isRtl => _lang == 'ps' || _lang == 'fa' || _lang == 'ar';
  bool get _showSpeaker => _voiceMode && _isRtl;

  @override
  void initState() {
    super.initState();
    _lang = widget.language;
    _voiceMode = widget.voiceMode;
    AnalyticsService().logScreen('personal_data');
    TtsService().addListener(_onSoundChange);
    _loadExisting();
  }

  void _onSoundChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TtsService().removeListener(_onSoundChange);
    TtsService().stop();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _countryOtherCtrl.dispose();
    super.dispose();
  }

  void _speak(String text) => TtsService().speak(text, _lang);

  // Pre-fills whatever partial personal data already exists, in case this
  // step is reached with some (but not all) shared fields already set.
  Future<void> _loadExisting() async {
    try {
      final map = await KaryabData.profile.loadProfileMap();
      if (map == null || map.isEmpty) return;
      final fullName = map['fullName'] as String? ?? '';
      final phone    = map['phone'] as String? ?? '';
      final email    = map['email'] as String? ?? '';
      final street   = map['street'] as String? ?? '';
      final city     = map['city'] as String? ?? '';
      final country  = map['country'] as String?;
      final photo    = map['photoPath'] as String?;
      final dobDay   = int.tryParse(map['dobDay'] as String? ?? '');
      final dobMonth = int.tryParse(map['dobMonth'] as String? ?? '');
      final dobYear  = int.tryParse(map['dobYear'] as String? ?? '');
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = fullName;
        _phoneCtrl.text = phone;
        _emailCtrl.text = email;
        _addressCtrl.text =
            [street, city].where((s) => s.isNotEmpty).join(', ');
        _country = (country != null && country.isNotEmpty) ? country : null;
        _photoPath = (photo != null && photo.isNotEmpty) ? photo : null;
        _dobDay = dobDay;
        _dobMonth = dobMonth;
        _dobYear = dobYear;
      });
    } catch (_) {}
  }

  // Same comma-or-postal-code split as questionnaire_screen.dart, so
  // street/city stay compatible with every screen that already expects
  // them split (review/preview/cover-letter text).
  (String, String) _splitAddress() {
    final full = _addressCtrl.text.trim();
    final idx = full.indexOf(',');
    if (idx != -1) {
      return (full.substring(0, idx).trim(), full.substring(idx + 1).trim());
    }
    final plz = RegExp(r'\b\d{5}\b').firstMatch(full);
    if (plz != null && plz.start > 0) {
      final street = full.substring(0, plz.start).trim();
      final city = full.substring(plz.start).trim();
      if (street.isNotEmpty && city.isNotEmpty) return (street, city);
    }
    return (full, '');
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty || _country == null) {
      setState(() => _error = _requiredMsg);
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });

    final (street, city) = _splitAddress();
    try {
      final map =
          await KaryabData.profile.loadProfileMap() ?? <String, dynamic>{};

      map['fullName']  = name;
      map['phone']     = phone;
      map['email']     = _emailCtrl.text.trim();
      map['street']    = street;
      map['city']      = city;
      map['country']   = _country;
      map['dobDay']    = _dobDay?.toString() ?? '';
      map['dobMonth']  = _dobMonth?.toString() ?? '';
      map['dobYear']   = _dobYear?.toString() ?? '';
      map['photoPath'] = _photoPath ?? '';

      await KaryabData.profile.saveProfileMap(map);
      await KaryabData.profile.setString('user_phone', phone);
      await KaryabData.profile.setString('user_email', _emailCtrl.text.trim());
      await KaryabData.profile.setString('user_street', street);
      await KaryabData.profile.setString('user_city', city);
      await KaryabData.profile.setString('user_postal', '');
      await KaryabData.profile.setString('questionnaire_full_name', name);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    _goToQuestionnaire();
  }

  void _goToQuestionnaire() {
    if (widget.nextCvType == 'job') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              QuestionnaireScreen(language: _lang, voiceMode: _voiceMode),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AusbildungCvQuestionnaireScreen(
              language: _lang, voiceMode: _voiceMode),
        ),
      );
    }
  }

  // ── Localised strings ──────────────────────────────────────────────────────

  String get _titleLabel {
    switch (_lang) {
      case 'ps': return 'شخصي معلومات';
      case 'fa': return 'اطلاعات شخصی';
      case 'ar': return 'المعلومات الشخصية';
      default:   return 'Personal Information';
    }
  }

  String get _subtitleLabel {
    switch (_lang) {
      case 'ps': return 'دا معلومات یوځل ډک کړئ، بیا به هره ځل کارول کیږي';
      case 'fa': return 'این اطلاعات را یک بار پر کنید، هر بار استفاده می‌شود';
      case 'ar': return 'املأ هذه المعلومات مرة واحدة، وستستخدم في كل مرة';
      default:   return 'Fill this in once - it will be reused every time';
    }
  }

  String get _requiredMsg {
    switch (_lang) {
      case 'ps': return 'مهرباني وکړئ ټول تش ځایونه ډک کړئ';
      case 'fa': return 'لطفاً همه فیلدهای ضروری را پر کنید';
      case 'ar': return 'املأ جميع الحقول المطلوبة من فضلك';
      default:   return 'Please fill in all required fields';
    }
  }

  String get _nameHint {
    switch (_lang) {
      case 'ps': return 'خپل بشپړ نوم ولیکئ';
      case 'fa': return 'نام کامل خود را بنویسید';
      case 'ar': return 'اكتب اسمك الكامل';
      default:   return 'Enter your full name';
    }
  }

  String get _addressHint {
    switch (_lang) {
      case 'ps': return 'کوڅه، کور شمیره، ښار او پوسټل کوډ';
      case 'fa': return 'خیابان، شماره، شهر و کد پستی';
      case 'ar': return 'الشارع، الرقم، المدينة والرمز البريدي';
      default:   return 'e.g. Musterstraße 12, 37073 Göttingen';
    }
  }

  String get _continueLabel {
    switch (_lang) {
      case 'ps': return 'دوام →';
      case 'fa': return 'ادامه →';
      case 'ar': return 'متابعة →';
      default:   return 'Continue →';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        TtsService().stop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFF),
        body: Stack(
          children: [
            const KBackgroundGlow(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: Column(
                        children: [
                          _buildTitleCard(),
                          const SizedBox(height: 16),
                          _QCard(
                            question: _lang == 'ps' ? '۱. ستاسو بشپړ نوم څه دی؟'
                                : _lang == 'fa' ? '۱. نام کامل شما چیست؟'
                                : _lang == 'ar' ? '١. ما اسمك الكامل؟'
                                : '1. What is your full name?',
                            isRtl: _isRtl,
                            showSpeaker: _showSpeaker,
                            onSpeak: () => _speak(_nameHint),
                            child: _TxtField(
                                controller: _nameCtrl, hint: _nameHint),
                          ),
                          const SizedBox(height: 12),
                          _QCard(
                            question: _lang == 'ps' ? '۲. ستاسو د پیداکیدو نیټه؟'
                                : _lang == 'fa' ? '۲. تاریخ تولد شما؟'
                                : _lang == 'ar' ? '٢. ما تاريخ ميلادك؟'
                                : '2. Date of birth?',
                            isRtl: _isRtl,
                            showSpeaker: _showSpeaker,
                            onSpeak: () => _speak(_lang == 'ps'
                                ? 'ستاسو د پیدایښت نیټه'
                                : _lang == 'ar'
                                ? 'ما تاريخ ميلادك؟'
                                : 'تاریخ تولد شما چیست؟'),
                            child: _DobRow(
                              day: _dobDay,
                              month: _dobMonth,
                              year: _dobYear,
                              lang: _lang,
                              onChanged: (d, m, y) => setState(() {
                                _dobDay = d;
                                _dobMonth = m;
                                _dobYear = y;
                              }),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _QCard(
                            question: _lang == 'ps' ? '۳. تاسو له کوم هیواده یاست؟'
                                : _lang == 'fa' ? '۳. از کدام کشور هستید؟'
                                : _lang == 'ar' ? '٣. من أي بلد أنت؟'
                                : '3. Which country are you from?',
                            isRtl: _isRtl,
                            showSpeaker: _showSpeaker,
                            onSpeak: () => _speak(_lang == 'ps'
                                ? 'تاسو د کوم هیواد یاست؟'
                                : _lang == 'ar'
                                ? 'من أي بلد أنت؟'
                                : 'از کدام کشور هستید؟'),
                            child: _countryPicker(),
                          ),
                          const SizedBox(height: 12),
                          _QCard(
                            question: _lang == 'ps' ? '۴. ستاسو د تیلیفون شمیره'
                                : _lang == 'fa' ? '۴. شماره تلفن شما'
                                : _lang == 'ar' ? '٤. رقم هاتفك'
                                : '4. Your phone number',
                            isRtl: _isRtl,
                            showSpeaker: _showSpeaker,
                            onSpeak: () => _speak(_lang == 'ps'
                                ? 'ستاسو د تیلیفون شمیره'
                                : _lang == 'ar'
                                ? 'رقم هاتفك'
                                : 'شماره تلفن شما'),
                            child: _TxtField(
                              controller: _phoneCtrl,
                              hint: '+49...',
                              type: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _QCard(
                            question: _lang == 'ps' ? '۵. ستاسو ایمیل'
                                : _lang == 'fa' ? '۵. ایمیل شما'
                                : _lang == 'ar' ? '٥. بريدك الإلكتروني'
                                : '5. Your email address',
                            isRtl: _isRtl,
                            showSpeaker: _showSpeaker,
                            onSpeak: () =>
                                _speak(_lang == 'ps' ? 'ستاسو ایمیل' : _lang == 'ar' ? 'بريدك الإلكتروني' : 'ایمیل شما'),
                            child: _TxtField(
                              controller: _emailCtrl,
                              hint: 'name@email.com',
                              type: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _QCard(
                            question: _lang == 'ps' ? '۶. ستاسو پته په جرمني کې'
                                : _lang == 'fa' ? '۶. آدرس شما در آلمان'
                                : _lang == 'ar' ? '٦. عنوانك في ألمانيا'
                                : '6. Your address in Germany',
                            isRtl: _isRtl,
                            showSpeaker: _showSpeaker,
                            onSpeak: () => _speak(_lang == 'ps'
                                ? 'ستاسو پته په جرمني کې'
                                : _lang == 'ar'
                                ? 'عنوانك في ألمانيا'
                                : 'آدرس شما در آلمان'),
                            child: _TxtField(
                                controller: _addressCtrl, hint: _addressHint),
                          ),
                          const SizedBox(height: 12),
                          _QCard(
                            question: _lang == 'ps'
                                ? '۷. خپله انځور اضافه کړئ (اختیاري)'
                                : _lang == 'fa' ? '۷. عکس خود را اضافه کنید (اختیاری)'
                                : _lang == 'ar' ? '٧. أضف صورتك (اختياري)'
                                : '7. Add your photo (optional)',
                            isRtl: _isRtl,
                            showSpeaker: _showSpeaker,
                            onSpeak: () => _speak(_lang == 'ps'
                                ? 'خپله انځور انتخاب کړئ'
                                : _lang == 'ar'
                                ? 'أضف صورتك'
                                : 'عکس خود را اضافه کنید'),
                            child: _photoPickerContent(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: 20),
                          _BigButton(
                            label: _continueLabel,
                            enabled: !_saving,
                            onTap: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _NavBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              TtsService().stop();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Text(
              _titleLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return KGlassSurface(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          children: [
            Text(
              _titleLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _subtitleLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Country picker (chips + "Other" free text) ──────────────────────────────

  Widget _countryPicker() {
    const countries = [
      ['af', 'Afghanistan', 'افغانستان', 'افغانستان', 'أفغانستان'],
      ['pk', 'Pakistan',    'پاکستان',   'پاکستان',   'باكستان'],
      ['ir', 'Iran',        'ایران',      'ایران',      'إيران'],
      ['iq', 'Iraq',        'عراق',       'عراق',       'العراق'],
      ['sy', 'Syria',       'سوریه',     'سوریه',     'سوريا'],
      ['so', 'Somalia',     'سومالیا',   'سومالیا',   'الصومال'],
      ['er', 'Eritrea',     'اریتریا',   'اریتریا',   'إريتريا'],
    ];
    final presetCodes = countries.map((c) => c[1]).toSet();
    final isCustom = _country != null && !presetCodes.contains(_country);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: countries.map((c) {
            final lbl = _lang == 'ps' ? c[2] : _lang == 'fa' ? c[3] : _lang == 'ar' ? c[4] : c[1];
            final sel = _country == c[1];
            return GestureDetector(
              onTap: () => setState(() {
                _country = c[1];
                _countryOtherOpen = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFFEAFBE9)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? _green : Colors.white.withValues(alpha: 0.9),
                    width: sel ? 2.0 : 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lbl,
                        style: TextStyle(
                          color: _navy,
                          fontSize: 13,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        )),
                    if (sel) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_rounded, color: _green, size: 14),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        _otherRow(
          selected: isCustom ? _country : null,
          open: _countryOtherOpen,
          ctrl: _countryOtherCtrl,
          onToggleOpen: () =>
              setState(() => _countryOtherOpen = !_countryOtherOpen),
          onSubmit: (v) => setState(() {
            _country = v;
            _countryOtherOpen = false;
          }),
        ),
      ],
    );
  }

  String get _otherLabel {
    switch (_lang) {
      case 'ps': return 'نور (پخپله ولیکئ)';
      case 'fa': return 'دیگر (خودتان بنویسید)';
      case 'ar': return 'أخرى (اكتب بنفسك)';
      default:   return 'Other / type your own';
    }
  }

  String get _otherHint {
    switch (_lang) {
      case 'ps': return 'دلته ولیکئ...';
      case 'fa': return 'اینجا بنویسید...';
      case 'ar': return 'اكتب هنا...';
      default:   return 'Type your answer...';
    }
  }

  Widget _otherRow({
    required String? selected,
    required bool open,
    required TextEditingController ctrl,
    required VoidCallback onToggleOpen,
    required ValueChanged<String> onSubmit,
  }) {
    final isCustomSelected =
        selected != null && selected.isNotEmpty && selected == ctrl.text;
    final active = open || isCustomSelected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggleOpen,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFEAFBE9) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? _green : const Color(0xFFDDE4EF),
                width: active ? 2.0 : 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_rounded, size: 14, color: active ? _green : _muted),
                const SizedBox(width: 5),
                Text(_otherLabel,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
                if (isCustomSelected) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_rounded, color: _green, size: 13),
                ],
              ],
            ),
          ),
        ),
        if (open) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _TxtField(controller: ctrl, hint: _otherHint)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final v = ctrl.text.trim();
                  if (v.isNotEmpty) onSubmit(v);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_rounded, color: _navy, size: 20),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Photo picker ─────────────────────────────────────────────────────────

  Future<void> _pickPhoto(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_lang == 'ps'
                ? 'کیمره اجازه ورکړئ - ترتیباتو ته لاړ شئ'
                : _lang == 'fa'
                    ? 'دسترسی دوربین را مجاز کنید'
                    : _lang == 'ar'
                    ? 'اسمح بالوصول إلى الكاميرا في الإعدادات من فضلك'
                    : 'Please allow camera access in Settings'),
            action: SnackBarAction(
              label: _lang == 'ps' ? 'ترتیبات' : _lang == 'ar' ? 'الإعدادات' : 'Settings',
              onPressed: () => openAppSettings(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped != null && mounted) {
      setState(() => _photoPath = cropped.path);
    }
  }

  Widget _photoPickerContent() {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEAFBE9),
                  border: Border.all(
                    color:
                        _photoPath != null ? _green : Colors.white.withValues(alpha: 0.9),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _photoPath != null
                    ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                    : const Icon(Icons.person_rounded, color: _muted, size: 62),
              ),
              if (_photoPath != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.black, size: 15),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _photoBtn(
              icon: Icons.camera_alt_rounded,
              label: _lang == 'ps' ? 'کیمره' : _lang == 'fa' ? 'کیمره' : _lang == 'ar' ? 'الكاميرا' : 'Camera',
              onTap: () => _pickPhoto(ImageSource.camera),
            ),
            const SizedBox(width: 12),
            _photoBtn(
              icon: Icons.photo_library_rounded,
              label: _lang == 'ps' ? 'ګالري' : _lang == 'fa' ? 'گالری' : _lang == 'ar' ? 'المعرض' : 'Gallery',
              onTap: () => _pickPhoto(ImageSource.gallery),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => _photoPath = null),
          child: Text(
            _lang == 'ps' ? 'اوس پریږدئ' : _lang == 'fa' ? 'فعلاً رد کنید' : _lang == 'ar' ? 'تخط الآن' : 'Skip for now',
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              decoration: TextDecoration.underline,
              decorationColor: _muted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _photoBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF4B5B6E), size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets (per-file duplication, matching this codebase's
// established convention).
// ─────────────────────────────────────────────────────────────────────────────

class _QCard extends StatelessWidget {
  static const Color _navy  = Color(0xFF091733);
  static const Color _green = Color(0xFF39EA2B);

  final String question;
  final bool isRtl;
  final bool showSpeaker;
  final VoidCallback onSpeak;
  final Widget child;

  const _QCard({
    required this.question,
    required this.isRtl,
    required this.showSpeaker,
    required this.onSpeak,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return KGlassSurface(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                child: Text(
                  question,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              if (showSpeaker) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onSpeak,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAFBE9),
                      shape: BoxShape.circle,
                      border: Border.all(color: _green.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.volume_up_rounded,
                        color: _green, size: 15),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TxtField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType type;

  const _TxtField({
    required this.controller,
    required this.hint,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        textDirection: TextDirection.ltr,
        style: const TextStyle(color: Color(0xFF091733)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF65738A), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          // Voice dictation on free-text fields only (Phase 8).
          suffixIcon: type == TextInputType.text
              ? KDictationButton(controller: controller)
              : null,
        ),
      ),
    );
  }
}

class _DobRow extends StatelessWidget {
  final int? day;
  final int? month;
  final int? year;
  final String lang;
  final void Function(int?, int?, int?) onChanged;

  const _DobRow({
    required this.day,
    required this.month,
    required this.year,
    required this.lang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Drop(
            hint: lang == 'ps' ? 'ورځ' : lang == 'fa' ? 'روز' : lang == 'ar' ? 'يوم' : 'Day',
            value: day?.toString(),
            items: List.generate(31, (i) => '${i + 1}'),
            onChanged: (v) => onChanged(int.tryParse(v ?? ''), month, year),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Drop(
            hint: lang == 'ps' ? 'میاشت' : lang == 'fa' ? 'ماه' : lang == 'ar' ? 'شهر' : 'Month',
            value: month?.toString(),
            items: List.generate(12, (i) => '${i + 1}'),
            onChanged: (v) => onChanged(day, int.tryParse(v ?? ''), year),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _Drop(
            hint: lang == 'ps' ? 'کال' : lang == 'fa' ? 'سال' : lang == 'ar' ? 'سنة' : 'Year',
            value: year?.toString(),
            items: List.generate(60, (i) => '${2006 - i}'),
            onChanged: (v) => onChanged(day, month, int.tryParse(v ?? '')),
          ),
        ),
      ],
    );
  }
}

class _Drop extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _Drop({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // Deliberately still `value`, not the dart-fix suggested `initialValue`:
      // the DOB day/month/year dropdowns are controlled by the parent and can
      // be set programmatically (edit-mode prefill / reset), which
      // `initialValue` would not reflect after first build.
      // ignore: deprecated_member_use
      value: value,
      hint: Text(hint,
          style: const TextStyle(color: Color(0xFF65738A), fontSize: 12)),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Color(0xFF091733), fontSize: 13),
      icon: const Icon(Icons.expand_more, color: Color(0xFF65738A), size: 18),
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.85),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF39EA2B), width: 1.5),
        ),
      ),
      items: items
          .map((v) => DropdownMenuItem(
              value: v,
              child: Text(v,
                  style: const TextStyle(
                      color: Color(0xFF091733), fontSize: 13))))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _BigButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          color: const Color(0xFF39EA2B),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF39EA2B).withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(29),
            onTap: enabled ? onTap : null,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF091733),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  static const Color _navy = Color(0xFF091733);

  final IconData icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: KGlassSurface(
        width: 44,
        height: 44,
        borderRadius: 14,
        padding: EdgeInsets.zero,
        child: Icon(icon, color: _navy, size: 20),
      ),
    );
  }
}




