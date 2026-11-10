import 'dart:io';

import 'package:flutter/material.dart';

import '../ui/karyab_ui.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/language_provider.dart';
import '../services/analytics_service.dart';
import '../services/tts_service.dart';

class ReviewScreen extends StatefulWidget {
  final String language;
  final UserProfile profile;

  const ReviewScreen({
    super.key,
    required this.language,
    required this.profile,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  static const Color _navy  = Color(0xFF091733);
  static const Color _green = Color(0xFF39EA2B);
  static const Color _muted = Color(0xFF65738A);

  static String _countryFullName(String value) {
    const map = {
      'af': 'Afghanistan',
      'pk': 'Pakistan',
      'ir': 'Iran',
      'iq': 'Iraq',
      'sy': 'Syria',
      'so': 'Somalia',
      'er': 'Eritrea',
      'other': 'Other',
    };
    return map[value] ?? value;
  }

  // ── Lookup maps ────────────────────────────────────────────────────────────

  static const _skillEn = {
    'lifting': 'Heavy lifting',     'cooking': 'Cooking',
    'driving': 'Driving',           'cleaning': 'Cleaning',
    'fixing': 'Repair',             'packing': 'Packing',
    'security': 'Security',         'forklift': 'Forklift',
    'farming': 'Farming',           'sales': 'Sales',
    'sewing': 'Sewing',             'construction': 'Construction',
    'mobile_repair': 'Mobile repair','amazon_packing': 'Warehouse',
    'dhl': 'Delivery',
  };
  static const _skillPs = {
    'lifting': 'درانه شیان',        'cooking': 'پخلي',
    'driving': 'چلولو',             'cleaning': 'پاکوالی',
    'fixing': 'سمون',               'packing': 'بسته کول',
    'security': 'امنیت',            'forklift': 'فورکلیفت',
    'farming': 'کرنه',              'sales': 'پلور',
    'sewing': 'ګنډل',               'construction': 'جوړونه',
    'mobile_repair': 'موبایل سمول', 'amazon_packing': 'ګدام',
    'dhl': 'ډلیوري',
  };
  static const _skillFa = {
    'lifting': 'حمل بار',           'cooking': 'آشپزی',
    'driving': 'رانندگی',           'cleaning': 'نظافت',
    'fixing': 'تعمیر',              'packing': 'بسته‌بندی',
    'security': 'امنیت',            'forklift': 'لیفتراک',
    'farming': 'کشاورزی',           'sales': 'فروش',
    'sewing': 'خیاطی',              'construction': 'ساخت‌وساز',
    'mobile_repair': 'تعمیر موبایل','amazon_packing': 'انبارداری',
    'dhl': 'تحویل بسته',
  };
  static const _skillAr = {
    'lifting': 'رفع أشياء ثقيلة',   'cooking': 'الطبخ',
    'driving': 'القيادة',           'cleaning': 'التنظيف',
    'fixing': 'الإصلاح',            'packing': 'التغليف',
    'security': 'الأمن',            'forklift': 'الرافعة الشوكية',
    'farming': 'الزراعة',           'sales': 'المبيعات',
    'sewing': 'الخياطة',            'construction': 'البناء',
    'mobile_repair': 'إصلاح الهاتف','amazon_packing': 'المستودع',
    'dhl': 'توصيل الطرود',
  };

  static const _workExpEn = {
    'more2': 'Yes, > 2 years',   'less2': 'Yes, < 2 years',
    'small': 'Small jobs only',  'never': 'Never worked',
  };
  static const _workExpPs = {
    'more2': 'هو، له ۲ کالو زیات', 'less2': 'هو، له ۲ کالو کم',
    'small': 'یوازې کوچني کارونه می کړی دي', 'never': 'هیڅکله می کار نه دی کړی',
  };
  static const _workExpFa = {
    'more2': 'بله، بیش از ۲ سال', 'less2': 'بله، کمتر از ۲ سال',
    'small': 'فقط کارهای کوچک',   'never': 'هرگز کار نکرده‌ام',
  };
  static const _workExpAr = {
    'more2': 'نعم، أكثر من سنتين', 'less2': 'نعم، أقل من سنتين',
    'small': 'وظائف صغيرة فقط',   'never': 'لم أعمل أبدا',
  };

  static const _workTypeEn = {
    'construction': 'Construction', 'cleaning': 'Cleaning',
    'kitchen': 'Kitchen / Restaurant', 'driving': 'Driving',
  };
  static const _workTypePs = {
    'construction': 'جوړونه', 'cleaning': 'سفایي',
    'kitchen': 'آشپزخانه / رستوران', 'driving': 'موټر چلول',
  };
  static const _workTypeFa = {
    'construction': 'ساختمان', 'cleaning': 'نظافت',
    'kitchen': 'آشپزخانه / رستوران', 'driving': 'رانندگی',
  };
  static const _workTypeAr = {
    'construction': 'البناء', 'cleaning': 'التنظيف',
    'kitchen': 'المطبخ / المطعم', 'driving': 'القيادة',
  };

  static const _toolsEn = {
    'power_tools': 'Power tools',   'kitchen_equip': 'Kitchen equipment',
    'tractor': 'Tractor / Heavy vehicles', 'no_tools': 'No tools experience',
  };
  static const _toolsPs = {
    'power_tools': 'برښنایي وسیلې', 'kitchen_equip': 'د آشپزخانې وسیلې',
    'tractor': 'ټراکټر / درنو موټرو', 'no_tools': 'د وسیلو تجربه نشته',
  };
  static const _toolsFa = {
    'power_tools': 'ابزار برقی',  'kitchen_equip': 'تجهیزات آشپزخانه',
    'tractor': 'تراکتور / وسایل سنگین', 'no_tools': 'بدون تجربه ابزار',
  };
  static const _toolsAr = {
    'power_tools': 'أدوات كهربائية', 'kitchen_equip': 'معدات المطبخ',
    'tractor': 'جرار / مركبات ثقيلة', 'no_tools': 'لا خبرة في الأدوات',
  };

  static const _licenseEn = {
    'german_license': 'German license',    'foreign_license': 'Foreign license',
    'want_license': 'No, wants to learn', 'no_license': 'No',
  };
  static const _licensePs = {
    'german_license': 'المانی لیسنس',     'foreign_license': 'بهرني لیسنس',
    'want_license': 'نه، زده کول غواړم', 'no_license': 'نه',
  };
  static const _licenseFa = {
    'german_license': 'گواهینامه آلمانی',       'foreign_license': 'گواهینامه خارجی',
    'want_license': 'نه، می‌خواهم یاد بگیرم', 'no_license': 'خیر',
  };
  static const _licenseAr = {
    'german_license': 'رخصة قيادة ألمانية',    'foreign_license': 'رخصة قيادة أجنبية',
    'want_license': 'لا، أريد أن أتعلم', 'no_license': 'لا',
  };

  static const _langEn = {
    'pashto': 'Pashto', 'dari': 'Dari / Farsi', 'urdu': 'Urdu',
    'arabic': 'Arabic', 'english': 'English',    'german': 'German', 'other': 'Other',
  };
  static const _langPs = {
    'pashto': 'پښتو', 'dari': 'دری / فارسي', 'urdu': 'اردو',
    'arabic': 'عربي', 'english': 'انګلیسي',  'german': 'الماني', 'other': 'نور',
  };
  static const _langFa = {
    'pashto': 'پشتو', 'dari': 'دری / فارسی', 'urdu': 'اردو',
    'arabic': 'عربی', 'english': 'انگلیسی',  'german': 'آلمانی', 'other': 'سایر',
  };
  static const _langAr = {
    'pashto': 'الباشتو', 'dari': 'الداري / الفارسية', 'urdu': 'الأردية',
    'arabic': 'العربية', 'english': 'الإنجليزية',  'german': 'الألمانية', 'other': 'أخرى',
  };

  static const _availEn = {
    'fulltime': 'Full time (40h/wk)', 'parttime': 'Part time (20h/wk)',
    'flexible': 'Flexible',           'weekends': 'Weekends only',
  };
  static const _availPs = {
    'fulltime': 'بشپړ وخت (۴۰ ساعته)', 'parttime': 'نیمه وخت (۲۰ ساعته)',
    'flexible': 'انعطافي',              'weekends': 'یوازې اونۍ پای',
  };
  static const _availFa = {
    'fulltime': 'تمام وقت (۴۰ ساعت)', 'parttime': 'نیمه وقت (۲۰ ساعت)',
    'flexible': 'انعطاف‌پذیر',         'weekends': 'فقط آخر هفته',
  };
  static const _availAr = {
    'fulltime': 'دوام كامل (40 ساعة)', 'parttime': 'دوام جزئي (20 ساعة)',
    'flexible': 'مرن',                  'weekends': 'عطلات نهاية الأسبوع فقط',
  };

  static const _startEn = {
    'immediately': 'Immediately',    'two_weeks': 'Within 2 weeks',
    'one_month': 'Within 1 month', 'unsure': 'Not sure yet',
  };
  static const _startPs = {
    'immediately': 'سمدستي',      'two_weeks': 'دوه اونۍ کې',
    'one_month': 'یو میاشت کې', 'unsure': 'لا ډاډه نه یم',
  };
  static const _startFa = {
    'immediately': 'فوری',        'two_weeks': 'ظرف ۲ هفته',
    'one_month': 'ظرف یک ماه', 'unsure': 'هنوز مطمئن نیستم',
  };
  static const _startAr = {
    'immediately': 'فورا',        'two_weeks': 'خلال أسبوعين',
    'one_month': 'خلال شهر واحد', 'unsure': 'لست متأكدا بعد',
  };

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _t(String lang, String en, String ps, String fa, String ar) {
    switch (lang) {
      case 'ps': return ps;
      case 'fa': return fa;
      case 'ar': return ar;
      default:   return en;
    }
  }

  static String _resolve(
    String? key,
    String lang, {
    required Map<String, String> en,
    required Map<String, String> ps,
    required Map<String, String> fa,
    required Map<String, String> ar,
  }) {
    if (key == null || key.isEmpty) return '—';
    final map = lang == 'ps' ? ps : lang == 'fa' ? fa : lang == 'ar' ? ar : en;
    return map[key] ?? key;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreen('review');
    TtsService().addListener(_onTts);
  }

  void _onTts() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TtsService().removeListener(_onTts);
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lang      = context.watch<LanguageProvider>().language;
    final isRtl     = lang == 'ps' || lang == 'fa' || lang == 'ar';
    final voiceMode = context.read<LanguageProvider>().voiceMode;
    final p         = widget.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      bottomNavigationBar: _buildBottomBar(context, lang, isRtl, voiceMode),
      body: Stack(
        children: [
          const KBackgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, lang),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        _buildProfileCard(p, lang, isRtl),
                        const SizedBox(height: 14),
                        _buildPersonalSection(p, lang, isRtl),
                        const SizedBox(height: 14),
                        _buildWorkSection(p, lang, isRtl),
                        const SizedBox(height: 14),
                        _buildLangSection(p, lang, isRtl),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          _GlassIconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              _t(lang, 'Review Your Information',
                  'خپل معلومات وګورئ',
                  'اطلاعات خود را بررسی کنید',
                  'راجع معلوماتك'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          _GlassIconBtn(
            icon: TtsService().soundEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            active: TtsService().soundEnabled,
            hintPulse: TtsService().hintPulseActive,
            onTap: () {
              TtsService().toggleSound();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  // ── Profile header card ────────────────────────────────────────────────────

  Widget _buildProfileCard(UserProfile p, String lang, bool isRtl) {
    return KGlassSurface(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEAFBE9),
                  border: Border.all(color: _green.withValues(alpha: 0.4), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: p.photoPath != null
                    ? Image.file(File(p.photoPath!), fit: BoxFit.cover)
                    : const Icon(Icons.person_rounded, color: _muted, size: 46),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.fullName.isEmpty ? '—' : p.fullName,
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (p.city.isNotEmpty || p.country != null)
                      Text(
                        [
                          if (p.city.isNotEmpty) p.city,
                          if (p.country != null && p.country!.isNotEmpty)
                            _countryFullName(p.country!),
                        ].join(', '),
                        style: const TextStyle(
                            color: _muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    if (p.phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(p.phone,
                            style: const TextStyle(
                                color: _muted, fontSize: 12)),
                      ),
                    if (p.email.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(p.email,
                            style: const TextStyle(
                                color: _muted, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBE9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _green.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF0E7A20), size: 16),
                const SizedBox(width: 6),
                Text(
                  _t(lang, 'Ready to Apply ✓',
                      'د درخواست لپاره چمتو ✓',
                      'آماده درخواست ✓',
                      'جاهز للتقدم ✓'),
                  style: const TextStyle(
                    color: Color(0xFF0E7A20),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 1: Personal ────────────────────────────────────────────────────

  Widget _buildPersonalSection(UserProfile p, String lang, bool isRtl) {
    return _SectionCard(
      icon: Icons.person_rounded,
      title: _t(lang, 'Personal Information', 'شخصي معلومات', 'اطلاعات شخصی', 'المعلومات الشخصية'),
      isRtl: isRtl,
      children: [
        _DataRowWidget(
          label: _t(lang, 'Date of Birth', 'د زیږیدو نیټه', 'تاریخ تولد', 'تاريخ الميلاد'),
          value: p.dobFormatted,
          isRtl: isRtl,
        ),
        _DataRowWidget(
          label: _t(lang, 'Country', 'هیواد', 'کشور', 'البلد'),
          value: p.country != null && p.country!.isNotEmpty
              ? _countryFullName(p.country!)
              : '—',
          isRtl: isRtl,
        ),
        _DataRowWidget(
          label: _t(lang, 'Street Address', 'کوڅه', 'خیابان', 'الشارع'),
          value: p.street.isEmpty ? '—' : p.street,
          isRtl: isRtl,
        ),
        _DataRowWidget(
          label: _t(lang, 'City & Postal', 'ښار', 'شهر', 'المدينة'),
          value: p.city.isEmpty ? '—' : p.city,
          isRtl: isRtl,
        ),
      ],
    );
  }

  // ── Section 2: Work & Skills ───────────────────────────────────────────────

  Widget _buildWorkSection(UserProfile p, String lang, bool isRtl) {
    final skillKeys = (p.skill ?? '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();
    final skillMap = lang == 'ps' ? _skillPs : lang == 'fa' ? _skillFa : lang == 'ar' ? _skillAr : _skillEn;

    return _SectionCard(
      icon: Icons.work_rounded,
      title: _t(lang, 'Work & Skills', 'کار او مهارتونه', 'کار و مهارت‌ها', 'العمل والمهارات'),
      isRtl: isRtl,
      children: [
        if (skillKeys.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skillKeys.map((k) => _GreenChip(
                  label: skillMap[k] ?? k)).toList(),
            ),
          ),
        ],
        _DataRowWidget(
          label: _t(lang, 'Experience', 'تجربه', 'تجربه', 'الخبرة'),
          value: _resolve(p.workExperience, lang,
              en: _workExpEn, ps: _workExpPs, fa: _workExpFa, ar: _workExpAr),
          isRtl: isRtl,
        ),
        if (p.workType != null)
          _DataRowWidget(
            label: _t(lang, 'Work Type', 'د کار ډول', 'نوع کار', 'نوع العمل'),
            value: _resolve(p.workType, lang,
                en: _workTypeEn, ps: _workTypePs, fa: _workTypeFa, ar: _workTypeAr),
            isRtl: isRtl,
          ),
        _DataRowWidget(
          label: _t(lang, 'Tools', 'وسیلې', 'ابزار', 'الأدوات'),
          value: _resolve(p.tools, lang,
              en: _toolsEn, ps: _toolsPs, fa: _toolsFa, ar: _toolsAr),
          isRtl: isRtl,
        ),
        _DataRowWidget(
          label: _t(lang, 'Driving License', 'د موټر جواز', 'گواهینامه', 'رخصة القيادة'),
          value: _resolve(p.drivingLicense, lang,
              en: _licenseEn, ps: _licensePs, fa: _licenseFa, ar: _licenseAr),
          isRtl: isRtl,
        ),
        if (p.previousEmployers.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            _t(lang, 'Previous Employers', 'پخوانۍ کارونه', 'کارفرمایان قبلی', 'أصحاب العمل السابقون'),
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(
                color: _muted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < p.previousEmployers.length; i++)
            _JobHistoryEntry(
              title: (i < p.previousJobTitles.length &&
                      p.previousJobTitles[i].isNotEmpty)
                  ? '${p.previousJobTitles[i]} – ${p.previousEmployers[i]}'
                  : p.previousEmployers[i],
              duration: i < p.previousJobDurations.length
                  ? p.previousJobDurations[i]
                  : '',
              isRtl: isRtl,
            ),
        ],
      ],
    );
  }

  // ── Section 3: Languages & Availability ───────────────────────────────────

  Widget _buildLangSection(UserProfile p, String lang, bool isRtl) {
    final langMap = lang == 'ps' ? _langPs : lang == 'fa' ? _langFa : lang == 'ar' ? _langAr : _langEn;

    return _SectionCard(
      icon: Icons.language_rounded,
      title: _t(lang, 'Languages & Availability',
          'ژبې او شتون', 'زبان‌ها و در دسترس بودن', 'اللغات والتوفر'),
      isRtl: isRtl,
      children: [
        if (p.languages.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: p.languages
                  .map((k) => _GreenChip(label: langMap[k] ?? k))
                  .toList(),
            ),
          ),
        ],
        // Educated users only (Task 4) — CEFR level per language, in the
        // same "Deutsch – B1" German-CV format cv_preview_screen.dart uses.
        // Empty for the uneducated flow / older saved profiles.
        if (p.languageProficiency.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: p.languageProficiency.entries
                  .map((e) => _GreenChip(label: '${e.key} – ${e.value}'))
                  .toList(),
            ),
          ),
        ],
        _DataRowWidget(
          label: _t(lang, 'Availability', 'شتون', 'در دسترس', 'التوفر'),
          value: _resolve(p.availability, lang,
              en: _availEn, ps: _availPs, fa: _availFa, ar: _availAr),
          isRtl: isRtl,
        ),
        _DataRowWidget(
          label: _t(lang, 'Start Date', 'د پیل نیټه', 'تاریخ شروع', 'تاريخ البدء'),
          value: _resolve(p.startDate, lang,
              en: _startEn, ps: _startPs, fa: _startFa, ar: _startAr),
          isRtl: isRtl,
        ),
      ],
    );
  }

  // ── Bottom buttons ─────────────────────────────────────────────────────────

  Widget _buildBottomBar(
      BuildContext context, String lang, bool isRtl, bool voiceMode) {
    // Shortened Pashto label — the previous phrase ("edit your answers
    // again") overflowed the button at this width; "سمون" ("Edit/Fix")
    // conveys the same action and fits.
    final editLabel   = _t(lang, 'Edit', 'سمون', 'ویرایش', 'تعديل');
    final createLabel = _t(lang, 'Create My CV', 'زما سییوی جوړ کړئ', 'CV من را بسازید', 'إنشاء سيرتي الذاتية');

    return SafeArea(
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            // Edit button (outlined navy)
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: KColors.glassFillAlpha),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _navy, width: 1.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit_rounded, color: _navy, size: 17),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          editLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isRtl && voiceMode) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => TtsService().speak(
                            lang == 'ps'
                                ? 'خپلې ځوابونه سمول'
                                : lang == 'ar'
                                    ? 'تعديل إجاباتك'
                                    : 'ویرایش پاسخ‌ها',
                            lang,
                          ),
                          child: const Icon(Icons.volume_up_rounded,
                              color: _green, size: 17),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Create CV button (navy gradient)
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, '/cv_preview',
                    arguments: widget.profile),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF081532), Color(0xFF07112B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF07112B).withValues(alpha: 0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          createLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded,
                          color: _green, size: 17),
                      if (isRtl && voiceMode) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => TtsService().speak(
                            lang == 'ps'
                                ? 'زما سییوی جوړ کړئ'
                                : lang == 'ar'
                                    ? 'إنشاء سيرتي الذاتية'
                                    : 'CV من را بسازید',
                            lang,
                          ),
                          child: const Icon(Icons.volume_up_rounded,
                              color: _green, size: 17),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  static const Color _navy  = Color(0xFF091733);

  final IconData icon;
  final String title;
  final bool isRtl;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.isRtl,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return KGlassSurface(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBE9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF0E7A20), size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  textDirection:
                      isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data row
// ─────────────────────────────────────────────────────────────────────────────

class _DataRowWidget extends StatelessWidget {
  static const Color _navy  = Color(0xFF091733);
  static const Color _muted = Color(0xFF65738A);

  final String label;
  final String value;
  final bool isRtl;

  const _DataRowWidget({
    required this.label,
    required this.value,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:  ',
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(
                color: _muted, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              style: const TextStyle(
                  color: _navy, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Job history entry — one previous-employer line item (Task 2/3 data)
// ─────────────────────────────────────────────────────────────────────────────

class _JobHistoryEntry extends StatelessWidget {
  static const Color _navy  = Color(0xFF091733);
  static const Color _muted = Color(0xFF65738A);

  final String title;    // "Job Title – Company" or just "Company"
  final String duration;
  final bool isRtl;

  const _JobHistoryEntry({
    required this.title,
    required this.duration,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.work_history_rounded,
                  color: _muted, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  style: const TextStyle(
                      color: _navy, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (duration.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 2),
              child: Text(
                duration,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Green chip
// ─────────────────────────────────────────────────────────────────────────────

class _GreenChip extends StatelessWidget {
  static const Color _green = Color(0xFF39EA2B);

  final String label;
  const _GreenChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAFBE9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0E7A20),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass icon button
// ─────────────────────────────────────────────────────────────────────────────

class _GlassIconBtn extends StatelessWidget {
  static const Color _navy  = Color(0xFF091733);
  static const Color _green = Color(0xFF39EA2B);

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool hintPulse;

  const _GlassIconBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.hintPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: hintPulse
            ? const Color(0xFF091733).withValues(alpha: 0.85)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: KGlassSurface(
        width: 44,
        height: 44,
        borderRadius: 14,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: Icon(icon, color: active ? _green : _navy, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background glow
// ─────────────────────────────────────────────────────────────────────────────



// ─────────────────────────────────────────────────────────────────────────────
// Glass surface
// ─────────────────────────────────────────────────────────────────────────────


