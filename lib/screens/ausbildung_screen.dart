import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/karyab_data.dart';
import '../data/repositories.dart';
import '../providers/language_provider.dart';
import '../services/analytics_service.dart';
import '../services/job_search_service.dart';
import '../services/jobs_strings.dart';
import '../services/tts_service.dart';
import '../utils/location_helpers.dart';
import '../utils/navigation_helpers.dart';
import '../ui/karyab_ui.dart';

// ── Data model ────────────────────────────────────────────────────────────────

// Why a job list request failed, so the UI can show a specific message
// instead of one generic "check your connection" for every failure.
enum _JobsErrorKind { noConnection, timeout, unavailable }

class _JobsException implements Exception {
  final _JobsErrorKind kind;
  const _JobsException(this.kind);
}

class _Job {
  final String title;
  final String company;
  final String ort;
  final String plz;
  final String strasseHausnummer;
  final String refnr;

  /// Raw BA payload, kept so the posting can be saved and cached
  /// (Phase 7).
  final Map<String, dynamic>? rawJson;

  const _Job({
    required this.title,
    required this.company,
    required this.ort,
    required this.plz,
    required this.strasseHausnummer,
    required this.refnr,
    this.rawJson,
  });

  String get locationDisplay {
    if (plz.isNotEmpty && ort.isNotEmpty) return '$plz $ort';
    return ort;
  }

  factory _Job.fromJson(Map<String, dynamic> j) {
    final locs = j['stellenlokationen'] as List<dynamic>? ?? [];
    final loc = locs.isNotEmpty ? locs.first as Map<String, dynamic> : {};
    final ao = loc['adresse'] as Map<String, dynamic>? ?? {};
    return _Job(
      title: j['stellenangebotsTitel'] as String? ?? '',
      company: j['firma'] as String? ?? '',
      ort: ao['ort'] as String? ?? '',
      plz: ao['plz'] as String? ?? '',
      strasseHausnummer: ao['strasseHausnummer'] as String? ?? '',
      refnr: j['referenznummer'] as String? ?? '',
      rawJson: j,
    );
  }

  factory _Job.fromBaJob(BaJob b) => _Job(
    title: b.title,
    company: b.company,
    ort: b.ort,
    plz: b.plz,
    strasseHausnummer: b.strasseHausnummer,
    refnr: b.refnr,
    rawJson: b.raw,
  );
}

/// The outcome of a job list load: fresh results, or results served
/// from the offline cache ([cachedAt] set) after a transport failure.
class _JobsLoadResult {
  final List<_Job> jobs;
  final DateTime? cachedAt;
  const _JobsLoadResult(this.jobs, {this.cachedAt});
}

// ── Category descriptor ───────────────────────────────────────────────────────

class _Cat {
  final String key;
  final String searchTerm;
  final IconData icon;
  final String en;
  final String ps;
  final String fa;
  final String ar;
  final String ur;

  const _Cat(this.key, this.searchTerm, this.icon, this.en, this.ps, this.fa, this.ar, this.ur);

  String label(String lang) {
    if (lang == 'ps') return ps;
    if (lang == 'fa') return fa;
    if (lang == 'ar') return ar;
    if (lang == 'ur') return ur;
    return en;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AusbildungScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  const AusbildungScreen({
    super.key,
    required this.language,
    this.voiceMode = false,
  });

  @override
  State<AusbildungScreen> createState() => _AusbildungScreenState();
}

class _AusbildungScreenState extends State<AusbildungScreen> {
  static const Color _navy = KColors.navy;
  static const Color _green = KColors.green;
  static const Color _muted = KColors.textSecondary;

  static const _kRadii = [5, 10, 25, 50, 100];

  static const _kCats = <_Cat>[
    _Cat('All', '', Icons.apps_rounded, 'All', 'ټول', 'همه', 'الكل', 'تمام'),
    _Cat(
      'IT',
      'Fachinformatiker',
      Icons.computer_rounded,
      'IT / Tech',
      'IT / ټیک',
      'IT / فناوری',
      'IT / تقنية',
      'IT / ٹیک',
    ),
    _Cat(
      'Handwerk',
      'Handwerk Ausbildung',
      Icons.build_rounded,
      'Trades',
      'کسب',
      'صنعت',
      'حرف',
      'دستکاری',
    ),
    _Cat(
      'Einzelhandel',
      'Kaufmann Einzelhandel',
      Icons.store_rounded,
      'Retail',
      'پلور',
      'خرده‌فروشی',
      'بيع',
      'خوردہ فروشی',
    ),
    _Cat(
      'Gesundheit',
      'Pflege Ausbildung',
      Icons.health_and_safety_rounded,
      'Health',
      'روغتیا',
      'بهداشت',
      'صحة',
      'صحت',
    ),
    _Cat(
      'Buero',
      'Kaufmann Büromanagement',
      Icons.business_center_rounded,
      'Office',
      'دفتر',
      'اداری',
      'مكتب',
      'دفتر',
    ),
    _Cat(
      'Gastro',
      'Koch Ausbildung',
      Icons.restaurant_rounded,
      'Gastronomy',
      'هوتل',
      'هتل‌داری',
      'مطاعم',
      'ہوٹل',
    ),
    _Cat(
      'Bau',
      'Bauhandwerk Ausbildung',
      Icons.construction_rounded,
      'Construction',
      'ساختمان',
      'ساختمان',
      'بناء',
      'تعمیرات',
    ),
    _Cat(
      'Logistik',
      'Fachlagerist',
      Icons.local_shipping_rounded,
      'Logistics',
      'لوجستیک',
      'لجستیک',
      'نقل وتخزين',
      'لاجسٹکس',
    ),
  ];

  String _lang = 'en';
  String _city = '';
  int _selectedRadius = 25;
  String _selectedCatKey = 'All';
  bool _editingCity = false;
  bool _locating = false;
  Future<_JobsLoadResult>? _jobsFuture;

  // Phase 7: shared search client + bookmarked refnrs.
  final JobSearchService _searchService = JobSearchService();
  JobQuery? _lastQuery;
  String? _lastTopRefnr;
  Set<String> _savedRefnrs = {};

  final _cityCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _cityFocus = FocusNode();

  void _onSoundChange() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreen('ausbildung');
    _loadSavedRefnrs();
    TtsService().addListener(_onSoundChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LanguageProvider>().syncFromNav(
          widget.language,
          voiceMode: widget.voiceMode,
        );
      }
    });
    // No default city — pre-fill from a previously-detected location if one
    // was saved (by this screen or job_finder_screen.dart), otherwise wait
    // for the user to type a city or tap "use my location".
    _loadSavedCity();
  }

  Future<void> _loadSavedCity() async {
    final saved = await loadLastKnownCity();
    if (saved == null || !mounted || _city.isNotEmpty) return;
    setState(() {
      _city = saved;
      _cityCtrl.text = saved;
    });
    _refetch();
  }

  @override
  void dispose() {
    TtsService().removeListener(_onSoundChange);
    _cityCtrl.dispose();
    _searchCtrl.dispose();
    _cityFocus.dispose();
    super.dispose();
  }

  // ── API ───────────────────────────────────────────────────────────────────

  /// Phase 7 fetch: through JobSearchService, with the offline cache
  /// fallback (same contract as the job finder).
  Future<_JobsLoadResult> _fetch() async {
    final cat = _kCats.firstWhere(
      (c) => c.key == _selectedCatKey,
      orElse: () => _kCats.first,
    );
    final typed = _searchCtrl.text.trim();
    final searchTerm = typed.isNotEmpty ? typed : cat.searchTerm;
    final query = JobQuery.ausbildung(
      was: searchTerm,
      wo: _city,
      umkreis: _selectedRadius,
    );
    _lastQuery = query;
    final repo = KaryabData.jobs;

    try {
      final results = await _searchService.runQuery(query);
      _lastTopRefnr = results.isEmpty ? null : results.first.refnr;
      if (repo != null) {
        unawaited(
          repo.putCache(
            JobsRepository.searchCacheKey(query.cacheKey),
            jsonEncode(results.map((j) => j.raw).toList()),
          ),
        );
      }
      return _JobsLoadResult(results.map(_Job.fromBaJob).toList());
    } on BaJobsException catch (e) {
      final kind = switch (e.kind) {
        BaJobsErrorKind.noConnection => _JobsErrorKind.noConnection,
        BaJobsErrorKind.timeout => _JobsErrorKind.timeout,
        BaJobsErrorKind.unavailable => _JobsErrorKind.unavailable,
      };
      final cached = repo == null
          ? null
          : await repo.getCache(JobsRepository.searchCacheKey(query.cacheKey));
      if (cached != null &&
          JobSearchService.shouldUseCachedResults(e.kind, true)) {
        try {
          final rawList = jsonDecode(cached.payload) as List<dynamic>;
          final jobs = rawList
              .map((j) => _Job.fromJson(j as Map<String, dynamic>))
              .toList();
          _lastTopRefnr = jobs.isEmpty ? null : jobs.first.refnr;
          return _JobsLoadResult(jobs, cachedAt: cached.fetchedAt);
        } catch (_) {
          // Corrupt cache entry: fall through to the honest error.
        }
      }
      throw _JobsException(kind);
    }
  }

  Future<void> _loadSavedRefnrs() async {
    final repo = KaryabData.jobs;
    if (repo == null) return;
    final saved = await repo.savedRefnrs();
    if (mounted) setState(() => _savedRefnrs = saved);
  }

  /// Bookmark toggle on an Ausbildung card (Phase 7 saved jobs).
  Future<void> _toggleSaveJob(_Job job) async {
    final repo = KaryabData.jobs;
    if (repo == null || job.refnr.isEmpty) return;
    final wasSaved = _savedRefnrs.contains(job.refnr);
    setState(() {
      if (wasSaved) {
        _savedRefnrs.remove(job.refnr);
      } else {
        _savedRefnrs.add(job.refnr);
      }
    });
    if (wasSaved) {
      await repo.unsaveJob(job.refnr);
    } else {
      await repo.saveJob(
        refnr: job.refnr,
        title: job.title,
        company: job.company,
        location: job.locationDisplay,
        source: 'ausbildung',
        payload:
            job.rawJson ??
            <String, dynamic>{
              'stellenangebotsTitel': job.title,
              'firma': job.company,
              'referenznummer': job.refnr,
            },
      );
    }
  }

  /// "Save search" for the current Ausbildung search (Phase 7).
  Future<void> _saveCurrentSearch() async {
    final repo = KaryabData.jobs;
    final query = _lastQuery;
    if (repo == null || query == null) return;
    const prefix = 'Ausbildung';
    var label = query.autoLabel;
    label = label.isEmpty ? prefix : '$prefix, $label';
    await repo.saveSearch(
      label: label,
      params: query.toJson(),
      topRefnr: _lastTopRefnr,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(JobsStrings.searchSaved(_lang))));
  }

  void _refetch() {
    if (_city.isEmpty) return;
    setState(() {
      _jobsFuture = _fetch();
    });
  }

  void _commitCity(String v) {
    final s = v.trim();
    setState(() {
      if (s.isNotEmpty) _city = s;
      _editingCity = false;
    });
    if (s.isNotEmpty) _refetch();
  }

  Future<void> _useMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final result = await detectCurrentCity();
      if (result.city == null) {
        if (!mounted) return;
        switch (result.error!) {
          case LocationLookupError.serviceDisabled:
            _snack(_locationServiceDisabledMsg);
            break;
          case LocationLookupError.permissionDenied:
            _snack(_locationPermissionDeniedMsg);
            break;
          case LocationLookupError.lookupFailed:
            _snack(_locationLookupFailedMsg);
            break;
        }
        return;
      }

      if (!mounted) return;
      setState(() {
        _city = result.city!;
        _cityCtrl.text = result.city!;
        _editingCity = false;
      });
      _refetch();
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String msg) {
    kSnack(context, msg);
  }

  // Same destination every other "Home" button in the app uses (see
  // ausbildung_document_preview_screen.dart's _goHome()).
  void _goHome() {
    TtsService().stop();
    goHomeToIntroduction(context, language: _lang, voiceMode: widget.voiceMode);
  }

  void _openJob(_Job job) async {
    // Phase 7 offline cache for opened postings.
    final repo = KaryabData.jobs;
    if (repo != null && job.refnr.isNotEmpty && job.rawJson != null) {
      unawaited(
        repo.putCache(
          JobsRepository.detailCacheKey(job.refnr),
          jsonEncode(job.rawJson),
        ),
      );
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final addrParts = <String>[];
    if (job.strasseHausnummer.isNotEmpty) addrParts.add(job.strasseHausnummer);
    final cityPart = [job.plz, job.ort].where((s) => s.isNotEmpty).join(' ');
    if (cityPart.isNotEmpty) addrParts.add(cityPart);
    Navigator.pushNamed(
      context,
      '/job_apply',
      arguments: <String, String>{
        'jobTitle': job.title,
        'companyName': job.company,
        'companyAddress': addrParts.join(', '),
        'jobLocation': job.locationDisplay,
        'formUrl':
            'https://www.arbeitsagentur.de/jobsuche/jobdetail/${job.refnr}',
        'companyPhone': '',
        'companyEmail': '',
        'companyWebsite': '',
        'refnr': job.refnr,
        'language': _lang,
        'voiceMode': widget.voiceMode.toString(),
        'isAusbildung': 'true',
      },
    );
  }

  // ── Localised strings ─────────────────────────────────────────────────────

  String get _titleLabel {
    switch (_lang) {
      case 'ps':
        return 'د زده کړې کار ومومئ';
      case 'fa':
        return 'کارآموزی پیدا کنید';
      case 'ar':
        return 'ابحث عن Ausbildung';
      case 'ur':
        return 'Ausbildung تلاش کریں';
      default:
        return 'Find Ausbildung';
    }
  }

  String get _cityHint {
    switch (_lang) {
      case 'ps':
        return 'دلته د ښار نوم ولیکئ';
      case 'fa':
        return 'نام شهر را بنویسید';
      case 'ar':
        return 'اكتب اسم المدينة هنا';
      case 'ur':
        return 'یہاں شہر کا نام لکھیں';
      default:
        return 'Enter city name';
    }
  }

  String get _loadingLbl {
    switch (_lang) {
      case 'ps':
        return 'د زده کړې کارونه پلټل کیږي...';
      case 'fa':
        return 'در حال جستجوی کارآموزی...';
      case 'ar':
        return 'يتم البحث عن Ausbildung...';
      case 'ur':
        return 'Ausbildung تلاش کی جا رہی ہے...';
      default:
        return 'Searching apprenticeships...';
    }
  }

  String _msg({
    required String en,
    required String de,
    required String ps,
    required String fa,
    required String ar,
    required String ur,
  }) {
    switch (_lang) {
      case 'ps':
        return ps;
      case 'fa':
        return fa;
      case 'ar':
        return ar;
      case 'ur':
        return ur;
      case 'de':
        return de;
      default:
        return en;
    }
  }

  _JobsErrorKind _errorKind(Object? error) =>
      error is _JobsException ? error.kind : _JobsErrorKind.unavailable;

  IconData _errorIcon(_JobsErrorKind kind) {
    switch (kind) {
      case _JobsErrorKind.noConnection:
        return Icons.wifi_off_rounded;
      case _JobsErrorKind.timeout:
        return Icons.hourglass_bottom_rounded;
      case _JobsErrorKind.unavailable:
        return Icons.cloud_off_rounded;
    }
  }

  String _errorMessage(_JobsErrorKind kind) {
    switch (kind) {
      case _JobsErrorKind.noConnection:
        return _msg(
          en: 'No internet connection. Please check your connection and try again.',
          de: 'Keine Internetverbindung. Bitte prüfe deine Verbindung und versuche es erneut.',
          ps: 'انټرنیټ نشته. خپل اتصال وګورئ او بیا هڅه وکړئ.',
          fa: 'اتصال اینترنت وجود ندارد. اتصال خود را بررسی کنید و دوباره تلاش کنید.',
          ar: 'لا يوجد اتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.',
          ur: 'انٹرنیٹ نہیں ہے۔ اپنا کنکشن چیک کریں اور دوبارہ کوشش کریں۔',
        );
      case _JobsErrorKind.timeout:
        return _msg(
          en: 'The server is too slow. Please try again.',
          de: 'Der Server antwortet zu langsam. Bitte versuche es erneut.',
          ps: 'سرور ډېر ورو ځواب ورکوي. بیا هڅه وکړئ.',
          fa: 'سرور خیلی کند پاسخ می‌دهد. دوباره تلاش کنید.',
          ar: 'الخادم يرد ببطء شديد. يرجى المحاولة مرة أخرى.',
          ur: 'سرور بہت آہستہ جواب دے رہا ہے۔ براہ کرم دوبارہ کوشش کریں۔',
        );
      case _JobsErrorKind.unavailable:
        return _msg(
          en: 'The job service is temporarily unavailable. Please try again later.',
          de: 'Der Jobdienst ist vorübergehend nicht erreichbar. Bitte versuche es später erneut.',
          ps: 'د کارونو خدمت اوس مهال نشته. وروسته بیا هڅه وکړئ.',
          fa: 'سرویس کاریابی موقتا در دسترس نیست. بعدا دوباره تلاش کنید.',
          ar: 'خدمة الوظائف غير متاحة مؤقتا. يرجى المحاولة لاحقا.',
          ur: 'ملازمتوں کی سروس عارضی طور پر دستیاب نہیں ہے۔ براہ کرم بعد میں دوبارہ کوشش کریں۔',
        );
    }
  }

  String get _emptyLbl {
    switch (_lang) {
      case 'ps':
        return 'د زده کړې کارونه ونه موندل شول';
      case 'fa':
        return 'کارآموزی یافت نشد';
      case 'ar':
        return 'لم يتم العثور على Ausbildung';
      case 'ur':
        return 'کوئی Ausbildung نہیں ملی';
      default:
        return 'No apprenticeships found';
    }
  }

  String get _emptySuggestionLbl => _msg(
    en: 'Try another distance or job type',
    de: 'Versuche einen anderen Umkreis oder eine andere Stellenart',
    ps: 'بل واټن یا د کار ډول هڅه وکړئ',
    fa: 'فاصله یا نوع کار دیگری را امتحان کنید',
    ar: 'جرب مسافة أخرى أو نوع عمل آخر',
    ur: 'کوئی اور فاصلہ یا ملازمت کی قسم آزمائیں',
  );

  String get _retryLbl {
    switch (_lang) {
      case 'ps':
        return 'بیا هڅه وکړئ';
      case 'fa':
        return 'دوباره تلاش کنید';
      case 'ar':
        return 'حاول مرة أخرى';
      case 'ur':
        return 'دوبارہ کوشش کریں';
      default:
        return 'Retry';
    }
  }

  String get _applyLbl {
    switch (_lang) {
      case 'ps':
        return 'غوښتنلیک';
      case 'fa':
        return 'ثبت نام';
      case 'ar':
        return 'تقديم طلب';
      case 'ur':
        return 'درخواست دیں';
      default:
        return 'Apply';
    }
  }

  String get _searchHint {
    switch (_lang) {
      case 'ps':
        return 'د زده کړې کار ولټوئ...';
      case 'fa':
        return 'جستجوی کارآموزی...';
      case 'ar':
        return 'ابحث عن Ausbildung...';
      case 'ur':
        return 'Ausbildung تلاش کریں...';
      default:
        return 'Search apprenticeships...';
    }
  }

  String get _locationServiceDisabledMsg {
    switch (_lang) {
      case 'ps':
        return 'د لوکیشن خدمت غیرفعال دی. مهرباني وکړئ يې فعال کړئ.';
      case 'fa':
        return 'سرویس موقعیت‌مکانی غیرفعال است. لطفاً آن را فعال کنید.';
      case 'ar':
        return 'خدمة الموقع متوقفة. يرجى تشغيلها.';
      case 'ur':
        return 'مقام کی سروس بند ہے۔ براہ کرم اسے آن کریں۔';
      default:
        return 'Location services are disabled. Please enable them.';
    }
  }

  String get _locationPermissionDeniedMsg {
    switch (_lang) {
      case 'ps':
        return 'د لوکیشن اجازه ونه درکړل شوه. مهرباني وکړئ ښار پخپله ولیکئ.';
      case 'fa':
        return 'اجازه دسترسی به موقعیت داده نشد. لطفاً شهر را دستی وارد کنید.';
      case 'ar':
        return 'لم يتم إعطاء إذن الموقع. يرجى كتابة المدينة بنفسك.';
      case 'ur':
        return 'مقام کی اجازت نہیں ملی۔ براہ کرم اپنا شہر خود لکھیں۔';
      default:
        return 'Location permission denied. Please enter your city manually.';
    }
  }

  String get _locationLookupFailedMsg {
    switch (_lang) {
      case 'ps':
        return 'ستاسو ښار ونه موندل شو. مهرباني وکړئ يې پخپله ولیکئ.';
      case 'fa':
        return 'شهر شما پیدا نشد. لطفاً آن را به‌صورت دستی وارد کنید.';
      case 'ar':
        return 'لم يتم العثور على مدينتك. يرجى كتابتها بنفسك.';
      case 'ur':
        return 'آپ کا شہر نہیں مل سکا۔ براہ کرم اسے خود لکھیں۔';
      default:
        return 'Could not detect your city. Please enter it manually.';
    }
  }

  String get _cityPromptLabel {
    switch (_lang) {
      case 'ps':
        return 'د زده کړې کارونو د موندلو لپاره خپل ښار ولیکئ یا خپل موقعیت وکاروئ';
      case 'fa':
        return 'برای یافتن کارآموزی، نام شهر خود را بنویسید یا از موقعیت مکانی خود استفاده کنید';
      case 'ar':
        return 'للعثور على Ausbildung، اكتب مدينتك أو استخدم موقعك';
      case 'ur':
        return 'Ausbildung تلاش کرنے کے لیے اپنا شہر لکھیں یا اپنا مقام استعمال کریں';
      default:
        return 'Enter your city or use your location to find apprenticeships near you';
    }
  }

  String get _useMyLocationLabel {
    switch (_lang) {
      case 'ps':
        return 'زما موقعیت وکاروئ';
      case 'fa':
        return 'استفاده از موقعیت من';
      case 'ar':
        return 'استخدم موقعي';
      case 'ur':
        return 'میرا مقام استعمال کریں';
      default:
        return 'Use my location';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<LanguageProvider>().language;
    final isRtl = _lang == 'ps' || _lang == 'fa' || _lang == 'ar' || _lang == 'ur';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        TtsService().stop();
      },
      child: Scaffold(
        backgroundColor: KColors.pageBase,
        body: Stack(
          children: [
            const KBackgroundGlow(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildLocationCard(),
                  const SizedBox(height: 10),
                  _buildSearchBar(isRtl),
                  const SizedBox(height: 10),
                  _buildFilterDropdownRow(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _jobsFuture == null
                        ? _buildCityPrompt()
                        : FutureBuilder<_JobsLoadResult>(
                            future: _jobsFuture,
                            builder: (_, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildLoading();
                              }
                              if (snap.hasError) return _buildError(snap.error);
                              final result =
                                  snap.data ?? const _JobsLoadResult(<_Job>[]);
                              if (result.jobs.isEmpty) return _buildEmpty();
                              return _buildList(result, isRtl);
                            },
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

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          KNavButton(
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
          KNavButton(icon: Icons.home_rounded, onTap: _goHome),
          const SizedBox(width: 8),
          KNavButton(
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

  // ── Location card ─────────────────────────────────────────────────────────

  Widget _buildLocationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: _green, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: _editingCity
                  ? TextField(
                      controller: _cityCtrl,
                      focusNode: _cityFocus,
                      autofocus: true,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: _cityHint,
                        hintStyle: const TextStyle(color: _muted, fontSize: 14),
                      ),
                      onSubmitted: _commitCity,
                    )
                  : GestureDetector(
                      onTap: () {
                        _cityCtrl.text = _city;
                        setState(() => _editingCity = true);
                        Future.delayed(const Duration(milliseconds: 50), () {
                          _cityFocus.requestFocus();
                        });
                      },
                      child: Text(
                        _city.isEmpty ? _cityHint : _city,
                        style: TextStyle(
                          color: _city.isEmpty ? _muted : _navy,
                          fontSize: 14,
                          fontWeight: _city.isEmpty
                              ? FontWeight.w500
                              : FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _locating ? null : _useMyLocation,
              child: _locating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _green,
                      ),
                    )
                  : const Icon(
                      Icons.my_location_rounded,
                      color: _green,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 6),
            if (_editingCity)
              GestureDetector(
                onTap: () => _commitCity(_cityCtrl.text),
                child: const Icon(Icons.check_rounded, color: _green, size: 22),
              )
            else
              const Icon(Icons.search_rounded, color: _green, size: 22),
          ],
        ),
      ),
    );
  }

  // ── City prompt (no default city — shown until the user provides one) ─────

  Widget _buildCityPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: KGlassSurface(
          borderRadius: 20,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_searching_rounded,
                color: _muted,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                _cityPromptLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _locating ? null : _useMyLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _green.withValues(alpha: 0.30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_locating)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _navy,
                          ),
                        )
                      else
                        const Icon(
                          Icons.my_location_rounded,
                          color: _navy,
                          size: 18,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _useMyLocationLabel,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search bar (free-text keyword search) ──────────────────────────────────

  Widget _buildSearchBar(bool isRtl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            const Icon(Icons.search_rounded, color: _muted, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(color: _navy, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _searchHint,
                  hintStyle: const TextStyle(color: _muted, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _refetch(),
              ),
            ),
            GestureDetector(
              onTap: _refetch,
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: _green,
                size: 20,
              ),
            ),
            if (_lang == 'ps') ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => TtsService().speak('د زده کړې کار ولټوئ', 'ps'),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: _green,
                  size: 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Filter dropdown row (Category | Distance) ─────────────────────────────
  //
  // Same compact pill-dropdown pattern as job_finder_screen.dart's
  // _buildFilterDropdownRow/_dropdownPill/_openFilterSheet/_sheetOption —
  // copied precisely for visual and behavioral consistency between the two
  // screens. Same underlying state and refetch logic as the chip rows they
  // replace — this is a UI-only change.

  Widget _buildFilterDropdownRow() {
    final categoryLabel = _kCats
        .firstWhere((c) => c.key == _selectedCatKey, orElse: () => _kCats.first)
        .label(_lang);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _dropdownPill(
              label: categoryLabel,
              onTap: _showCategorySheet,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _dropdownPill(
              label: '${_selectedRadius}km',
              onTap: _showRadiusSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownPill({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter bottom sheets ────────────────────────────────────────────────

  void _openFilterSheet(List<Widget> options) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: KColors.handle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(child: Column(children: options)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _green.withValues(alpha: 0.10) : KColors.pageBase,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _green : KColors.borderSoft,
            width: selected ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: selected ? _green : _muted),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: _green, size: 20),
          ],
        ),
      ),
    );
  }

  void _showRadiusSheet() {
    _openFilterSheet(
      _kRadii.map((r) {
        final selected = r == _selectedRadius;
        return _sheetOption(
          label: '${r}km',
          selected: selected,
          onTap: () {
            Navigator.pop(context);
            if (!selected) {
              setState(() => _selectedRadius = r);
              _refetch();
            }
          },
        );
      }).toList(),
    );
  }

  void _showCategorySheet() {
    _openFilterSheet(
      _kCats.map((cat) {
        final selected = cat.key == _selectedCatKey;
        return _sheetOption(
          label: cat.label(_lang),
          selected: selected,
          icon: cat.icon,
          onTap: () {
            Navigator.pop(context);
            if (!selected) {
              _searchCtrl.clear();
              setState(() => _selectedCatKey = cat.key);
              _refetch();
            }
          },
        );
      }).toList(),
    );
  }

  // ── Loading / error / empty ───────────────────────────────────────────────

  // Phase 5: glass skeleton rows during the real waiting state.
  Widget _buildLoading() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _loadingLbl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (var i = 0; i < 5; i++) ...[
          const KGlassSkeletonRow(),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildError(Object? error) {
    final kind = _errorKind(error);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: KGlassSurface(
          borderRadius: 20,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_errorIcon(kind), color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage(kind),
                textAlign: TextAlign.center,
                style: const TextStyle(color: _navy, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _refetch,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _retryLbl,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: KGlassSurface(
          borderRadius: 20,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, color: _muted, size: 52),
              const SizedBox(height: 16),
              Text(
                _emptyLbl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _emptySuggestionLbl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Job list ──────────────────────────────────────────────────────────────

  Widget _buildList(_JobsLoadResult result, bool isRtl) {
    final jobs = result.jobs;
    final hasBanner = result.cachedAt != null;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: jobs.length + (hasBanner ? 2 : 1),
      itemBuilder: (_, i) {
        var idx = i;
        if (hasBanner) {
          if (idx == 0) {
            final time = JobsStrings.cacheTime(result.cachedAt!);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF2C078)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 18,
                      color: Color(0xFFB26A00),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        JobsStrings.offlineBanner(_lang, time),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF7A4A00),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          idx--;
        }
        if (idx == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    JobsStrings.resultsCount(_lang, jobs.length),
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _saveCurrentSearch,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: Text(JobsStrings.saveSearch(_lang)),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCard(jobs[idx - 1], isRtl),
        );
      },
    );
  }

  Widget _buildCard(_Job job, bool isRtl) {
    return KGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      onTap: () => _openJob(job),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: KColors.mint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _green.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(Icons.school_rounded, color: _green, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: isRtl
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  job.company,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  job.title,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: _muted,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        job.locationDisplay,
                        style: const TextStyle(color: _muted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              _savedRefnrs.contains(job.refnr)
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _savedRefnrs.contains(job.refnr) ? _green : _muted,
              size: 22,
            ),
            tooltip: JobsStrings.saveJob(_lang),
            onPressed: () => _toggleSaveJob(job),
          ),
          Text(
            _applyLbl,
            style: const TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios_rounded, color: _green, size: 14),
        ],
      ),
    );
  }
}

// ── Nav button ────────────────────────────────────────────────────────────────
