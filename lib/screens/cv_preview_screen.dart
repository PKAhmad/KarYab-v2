import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/karyab_data.dart';
import '../models/cv_style.dart';
import '../models/document_template.dart';
import '../models/user_profile.dart';
import '../providers/language_provider.dart';
import '../services/analytics_service.dart';
import '../services/ats_checker.dart';
import '../services/cv_pdf_generator.dart';
import '../services/tts_service.dart';
import '../utils/navigation_helpers.dart';
import '../utils/pdf_save_helper.dart';
import '../widgets/ats_check_panel.dart';
import '../widgets/cv_style_editor.dart';
import '../widgets/document_template_picker.dart';
import '../ui/karyab_ui.dart';
import 'personal_data_screen.dart';
import 'questionnaire_screen.dart';


// ── Screen ────────────────────────────────────────────────────────────────────

class CvPreviewScreen extends StatefulWidget {
  final UserProfile profile;
  // Which SharedPreferences key this screen instance persists its template
  // choice under. Defaults to the regular home-screen CV flow's key so every
  // existing caller (review_screen.dart, introduction_screen.dart) is
  // unaffected. The Ausbildung flow passes its own independent key
  // ('selected_cv_template_ausbildung') so the two never share state.
  final String templatePrefsKey;
  // True when embedded inside the "My CV" toggle screen
  // (introduction_screen.dart's _MyCvScreen), which supplies its own
  // shared header/background - this screen then renders only its body
  // content (edit bar + template row + preview + bottom buttons), no
  // duplicate header/background.
  final bool embedded;
  // Phase 3: when this preview shows one saved cv_documents row (opened
  // from the My CVs library), template + design changes persist to that
  // row instead of the shared prefs keys, and the ATS checker reads the
  // row's payload. Null for the classic profile-based flow.
  final int? documentId;

  const CvPreviewScreen({
    super.key,
    required this.profile,
    this.templatePrefsKey = 'selected_cv_template_regular',
    this.embedded = false,
    this.documentId,
  });

  @override
  State<CvPreviewScreen> createState() => _CvPreviewScreenState();
}

class _CvPreviewScreenState extends State<CvPreviewScreen> {
  static const Color _navy  = KColors.navy;
  static const Color _green = KColors.green;
  static const Color _muted = KColors.textSecondary;


  Future<Uint8List>? _pdfFutureCache;
  Future<void>? _templateReadyFuture;
  DocumentTemplate _template = DocumentTemplate.atsBlue;
  CvCustomisation _style = CvCustomisation.defaults;
  List<AtsCheckItem>? _atsItems;
  bool _atsLoading = false;
  bool _saving  = false;
  String _refName            = '';
  String _refPhone           = '';
  List<String> _loadedEmployers     = [];
  List<String> _loadedJobTitles     = [];
  List<String> _loadedJobDurations  = [];

  void _onSoundChange() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService().logScreen('cv_preview');
    TtsService().addListener(_onSoundChange);
    _loadRefData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureTemplateReady());
  }

  // ── Template selection ────────────────────────────────────────────────────
  // Shown before CV generation: the very first time (no persisted choice
  // yet) this pops the picker automatically; on later visits it just loads
  // the remembered choice silently. Either way it's resolved before
  // generateCv() ever runs — see _buildPdf().
  Future<void> _ensureTemplateReady() {
    return _templateReadyFuture ??= _initTemplate();
  }

  Future<void> _initTemplate() async {
    // Document flow: template + design live on the cv_documents row; no
    // first-run picker pop (the user picked this document in the library).
    if (widget.documentId != null) {
      try {
        final rec =
            await KaryabData.documents?.getCvDocument(widget.documentId!);
        if (rec != null) {
          if (rec.templateId != null) {
            _template = DocumentTemplateInfo.fromStorageKey(rec.templateId);
          }
          _style = CvCustomisation.fromColumns(
            accentColor: rec.accentColor,
            fontSize: rec.fontSize,
            spacing: rec.spacing,
            showPhoto: rec.showPhoto,
          );
        }
      } catch (_) {}
      if (mounted) setState(() {});
      return;
    }
    await _loadStyle();
    final storedKey = await KaryabData.profile.getString(widget.templatePrefsKey);
    if (storedKey != null) {
      _template = DocumentTemplateInfo.fromStorageKey(storedKey);
      if (mounted) setState(() {});
      return;
    }
    if (!mounted) return;
    final chosen =
        await showDocumentTemplatePicker(context, current: _template);
    if (!mounted) return;
    _template = chosen;
    await saveSelectedDocumentTemplate(widget.templatePrefsKey, chosen);
    setState(() {});
  }

  String get _stylePrefsKey => 'cv_style_${widget.templatePrefsKey}';

  Future<void> _loadStyle() async {
    try {
      final raw = await KaryabData.profile.getString(_stylePrefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _style = CvCustomisation.fromMap(decoded);
        }
      }
    } catch (_) {}
  }

  Future<void> _persistStyle(CvCustomisation style) async {
    try {
      if (widget.documentId != null) {
        await KaryabData.documents?.updateCvDocument(
          widget.documentId!,
          accentColor: style.accentColorHex,
          fontSize: style.fontSize,
          spacing: style.spacing,
          showPhoto: style.showPhoto,
        );
      } else {
        await KaryabData.profile
            .setString(_stylePrefsKey, jsonEncode(style.toMap()));
      }
    } catch (_) {}
  }

  Future<void> _changeStyle() async {
    final lang = context.read<LanguageProvider>().language;
    await showCvStyleEditor(
      context,
      language: lang,
      current: _style,
      onChanged: (next) {
        if (!mounted) return;
        setState(() {
          _style = next;
          _pdfFutureCache = null;
          _atsItems = null;
        });
        _persistStyle(next);
      },
    );
  }

  Future<void> _changeTemplate() async {
    await _ensureTemplateReady();
    if (!mounted) return;
    final chosen =
        await showDocumentTemplatePicker(context, current: _template);
    if (!mounted || chosen == _template) return;
    setState(() {
      _template = chosen;
      _pdfFutureCache = null;
      _atsItems = null;
    });
    if (widget.documentId != null) {
      try {
        await KaryabData.documents?.updateCvDocument(widget.documentId!,
            templateId: chosen.storageKey);
      } catch (_) {}
    } else {
      await saveSelectedDocumentTemplate(widget.templatePrefsKey, chosen);
    }
  }

  // ── ATS check ───────────────────────────────────────────────────────────

  Future<void> _runAtsCheck() async {
    if (_atsLoading) return;
    setState(() => _atsLoading = true);
    try {
      await _ensureTemplateReady();
      final bytes = await _getPdf();
      Map<String, dynamic> payload = {};
      if (widget.documentId != null) {
        final rec =
            await KaryabData.documents?.getCvDocument(widget.documentId!);
        if (rec != null) payload = rec.payload;
      } else {
        payload =
            await KaryabData.profile.loadProfileMap() ?? <String, dynamic>{};
      }
      final items = runAtsChecks(
        profile: _effectiveProfile,
        template: _template,
        payload: payload,
        kind: 'job',
        showPhoto: _style.showPhoto,
        pageCount: countPdfPages(bytes),
      );
      if (mounted) {
        setState(() {
          _atsItems = items;
          _atsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _atsLoading = false);
    }
  }

  Future<void> _onAtsTap(AtsCheckItem item) async {
    final lang = context.read<LanguageProvider>().language;
    final prefs = await SharedPreferences.getInstance();
    final voiceMode = prefs.getBool('voice_mode') ?? false;
    if (!mounted) return;
    if (item.section == 'personal') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PersonalDataScreen(
            language: lang,
            voiceMode: voiceMode,
            nextCvType: 'job',
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireScreen(
          language: lang,
          voiceMode: voiceMode,
          isEditMode: true,
          documentId: widget.documentId,
          initialSection: item.section,
        ),
      ),
    );
  }

  Future<void> _loadRefData() async {
    try {
      final map = await KaryabData.profile.loadProfileMap();
      if (map != null) {
        if (mounted) {
          final empStr      = (map['previousEmployers'] as String?) ?? '';
          final titlesStr   = (map['previousJobTitles'] as String?) ?? '';
          final durationsStr = (map['previousJobDurations'] as String?) ?? '';
          setState(() {
            _refName            = (map['refName']  as String?) ?? '';
            _refPhone           = (map['refPhone'] as String?) ?? '';
            _loadedEmployers    = empStr.isEmpty
                ? []
                : empStr.split(',').where((s) => s.isNotEmpty).toList();
            _loadedJobTitles    =
                titlesStr.isEmpty ? [] : titlesStr.split(',');
            _loadedJobDurations =
                durationsStr.isEmpty ? [] : durationsStr.split(',');
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    TtsService().removeListener(_onSoundChange);
    super.dispose();
  }


  // ── Helpers ───────────────────────────────────────────────────────────────


  List<String> get _effectiveEmployers {
    final fromProfile = widget.profile.previousEmployers;
    return fromProfile.isNotEmpty ? fromProfile : _loadedEmployers;
  }

  List<String> get _effectiveJobTitles {
    final fromProfile = widget.profile.previousJobTitles;
    return fromProfile.isNotEmpty ? fromProfile : _loadedJobTitles;
  }

  List<String> get _effectiveJobDurations {
    final fromProfile = widget.profile.previousJobDurations;
    return fromProfile.isNotEmpty ? fromProfile : _loadedJobDurations;
  }


  // ── PDF Builder ───────────────────────────────────────────────────────────
  // Template-aware: waits for the template picker/preference to resolve
  // (see _ensureTemplateReady), then delegates to the shared generator so
  // every visual template stays in one place (services/cv_pdf_generator.dart)
  // instead of duplicated per screen.

  UserProfile get _effectiveProfile => widget.profile.copyWith(
        previousEmployers: _effectiveEmployers,
        previousJobTitles: _effectiveJobTitles,
        previousJobDurations: _effectiveJobDurations,
        refName: _refName.isNotEmpty ? _refName : null,
        refPhone: _refPhone.isNotEmpty ? _refPhone : null,
      );

  Future<Uint8List> _getPdf() {
    return _pdfFutureCache ??= _buildPdf();
  }

  Future<Uint8List> _buildPdf() async {
    await _ensureTemplateReady();
    return generateCv(_effectiveProfile, _template, style: _style);
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  String get _pdfFilename {
    final name = widget.profile.fullName.replaceAll(' ', '_');
    return 'Lebenslauf_$name.pdf';
  }

  Future<void> _download() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      // Matches ausbildung_document_preview_screen.dart's _download(): generate
      // fresh bytes directly rather than going through _getPdf()/_pdfFutureCache,
      // so a single failed attempt can't leave the button permanently stuck
      // replaying the same rejected cached future on every subsequent tap.
      await _ensureTemplateReady();
      final bytes =
          await generateCv(_effectiveProfile, _template, style: _style);
      final saved = await savePdfToDownloads(bytes, _pdfFilename);

      if (!mounted) return;
      if (saved) {
        _saveCvStatus();
        AnalyticsService().logCVDownloaded();
        AnalyticsService().logCVCreated();
        kSnack(context, 'CV saved to Downloads', kind: KSnackKind.success);
      } else {
        await Printing.sharePdf(bytes: bytes, filename: _pdfFilename);
        _saveCvStatus();
        AnalyticsService().logCVDownloaded();
        AnalyticsService().logCVCreated();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goHome() {
    final lang = context.read<LanguageProvider>().language;
    goHomeToIntroduction(context, language: lang, voiceMode: false);
  }

  // Pushes a fresh questionnaire instance in edit mode, mirroring
  // ausbildung_document_preview_screen.dart's _editAnswers() - reopens
  // QuestionnaireScreen with isEditMode: true so it reloads the previously
  // saved answers instead of starting blank.
  Future<void> _editAnswers() async {
    final lang = context.read<LanguageProvider>().language;
    final prefs = await SharedPreferences.getInstance();
    final voiceMode = prefs.getBool('voice_mode') ?? false;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireScreen(
          language: lang,
          voiceMode: voiceMode,
          isEditMode: true,
          documentId: widget.documentId,
        ),
      ),
    );
  }

  String get _editLabel {
    final lang = context.read<LanguageProvider>().language;
    switch (lang) {
      case 'ps': return 'ځوابونه سمول';
      case 'fa': return 'ویرایش پاسخ‌ها';
      case 'ar': return 'تعديل الإجابات';
      case 'ur': return 'جوابات کی ترمیم کریں';
      default:   return 'Edit answers';
    }
  }

  Future<void> _saveCvStatus() async {
    try {
      print('DEBUG saving cv_created = true');
      await KaryabData.profile.setBool('cv_created', true);
      await KaryabData.profile.setString(
          'user_name', widget.profile.fullName.split(' ').first);
      await KaryabData.profile.setString(
          'questionnaire_full_name', widget.profile.fullName);
      print('DEBUG cv_created saved successfully');
    } catch (_) {}
  }

  Future<void> _findJobs(String lang) async {
    try {
      final bytes = await _getPdf();
      final tempDir = await getTemporaryDirectory();
      final cleanName = widget.profile.fullName
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^\w]'), '');
      final tempCvPath =
          '${tempDir.path}/Lebenslauf_${cleanName.isEmpty ? 'Bewerber' : cleanName}.pdf';
      final tempFile = File(tempCvPath);
      await tempFile.writeAsBytes(bytes);
      await KaryabData.profile.setString('temp_cv_path', tempFile.path);
      await KaryabData.profile.setString(
          'temp_cv_timestamp', DateTime.now().toIso8601String());
      await KaryabData.profile.setBool('cv_created', true);
      await KaryabData.profile.setString(
          'questionnaire_full_name', widget.profile.fullName);
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushNamed(context, '/jobfinder', arguments: lang);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lang        = context.watch<LanguageProvider>().language;
    final showSpeaker = lang == 'ps' || lang == 'fa' || lang == 'ar' || lang == 'ur';
    final body = SafeArea(
      top: !widget.embedded,
      child: Column(
        children: [
          if (!widget.embedded) _buildHeader(lang),
          const SizedBox(height: 4),
          _buildEditBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTemplateRow(),
                  const SizedBox(height: 6),
                  CvStyleRow(
                    language: lang,
                    style: _style,
                    onChange: _changeStyle,
                  ),
                  const SizedBox(height: 8),
                  _buildCvPreview(),
                  const SizedBox(height: 12),
                  AtsCheckPanel(
                    language: lang,
                    items: _atsItems,
                    loading: _atsLoading,
                    onExpand: _runAtsCheck,
                    onTapItem: _onAtsTap,
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButtons(lang, showSpeaker),
        ],
      ),
    );

    if (widget.embedded) {
      return body;
    }
    return Scaffold(
      backgroundColor: KColors.pageBase,
      body: Stack(
        children: [
          const KBackgroundGlow(),
          body,
        ],
      ),
    );
  }

  Widget _buildEditBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: KGlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: _editAnswers,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_rounded, color: KColors.greenDark, size: 18),
              const SizedBox(width: 8),
              Text(
                _editLabel,
                style: const TextStyle(
                  color: KColors.greenDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(String lang) {
    final title = lang == 'ps' ? ' CV ستاسو'
        : lang == 'fa' ? 'CV شما'
        : lang == 'ar' ? 'سيرتك الذاتية'
        : lang == 'ur' ? 'آپ کا CV'
        : 'Your CV';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          KNavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              title,
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

  // ── Template row ──────────────────────────────────────────────────────────
  // The on-screen card below is a rough approximation of the CV content
  // regardless of template (unchanged) — only the generated PDF (download/
  // share/find jobs) actually renders the chosen template's design.

  Widget _buildTemplateRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Template: ${_template.displayName}',
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: _changeTemplate,
            child: const Text(
              'Change',
              style: TextStyle(
                color: _green,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                decorationColor: _green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Live template preview ─────────────────────────────────────────────────
  // Matches ausbildung_document_preview_screen.dart's _buildCvSection(): a
  // real PdfPreview rendering the actual generated PDF for the chosen
  // template, instead of an on-screen approximation that can drift from what
  // the download/share/find-jobs actions actually produce.

  Widget _buildCvPreview() {
    return KGlassSurface(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 440,
          child: PdfPreview(
            key: ValueKey('${_template.name}_${_style.hashCode}'),
            build: (PdfPageFormat format) =>
                generateCv(_effectiveProfile, _template, style: _style),
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            pdfFileName: _pdfFilename,
            loadingWidget: const Center(
              child: CircularProgressIndicator(color: _green),
            ),
          ),
        ),
      ),
    );
  }


  // ── Bottom buttons (fixed) ────────────────────────────────────────────────

  Widget _buildBottomButtons(String lang, bool showSpeaker) {
    final downloadLabel = lang == 'ps' ? 'ډاونلوډ کړئ CV '
        : lang == 'fa' ? 'دانلود CV'
        : lang == 'ar' ? 'تنزيل CV'
        : lang == 'ur' ? 'CV ڈاؤن لوڈ کریں'
        : 'Download CV (PDF)';
    final jobsLabel = lang == 'ps' ? 'نژدی کارونه وګورئ'
        : lang == 'fa' ? 'کارها را پیدا کنید'
        : lang == 'ar' ? 'ابحث عن وظائف قريبة'
        : lang == 'ur' ? 'قریبی نوکریاں تلاش کریں'
        : 'Find Jobs Now';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.9), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  KPrimaryCta(
                    icon: Icons.download_rounded,
                    label: downloadLabel,
                    isRtl: showSpeaker,
                    isSelected: false,
                    onTap: () {
                        if (!_saving) _download();
                      },
                  ),
                  if (_saving)
                    Positioned.directional(
                      textDirection: showSpeaker ? TextDirection.rtl : TextDirection.ltr,
                      start: 8,
                      top: 13,
                      child: Container(
                        width: 38,
                        height: 38,
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          color: KColors.ctaStart,
                          shape: BoxShape.circle,
                        ),
                        child: const CircularProgressIndicator(
                            color: KColors.green, strokeWidth: 2.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Find Jobs button
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: KGlassCard(
                      borderRadius: 22,
                      onTap: () => _findJobs(lang),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_rounded,
                              color: _navy, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            jobsLabel,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showSpeaker)
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => TtsService().speak(
                            lang == 'ps'
                                ? 'نژدی کارونه وګورئ'
                                : lang == 'ar'
                                    ? 'ابحث عن وظائف قريبة'
                                    : lang == 'ur'
                                        ? 'قریبی نوکریاں تلاش کریں'
                                        : 'کارها را پیدا کنید',
                            lang,
                          ),
                          child: const Icon(Icons.volume_up_rounded,
                              color: _navy, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav button (glass surface, matches questionnaire_screen pattern)
// ─────────────────────────────────────────────────────────────────────────────
