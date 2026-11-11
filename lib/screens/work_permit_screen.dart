import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/karyab_data.dart';
import '../models/user_profile.dart';
import '../providers/language_provider.dart';
import '../services/tts_service.dart';
import '../services/work_permit_letter.dart';
import '../services/work_permit_pdf.dart';
import '../services/work_permit_strings.dart';
import '../ui/karyab_ui.dart';
import '../utils/pdf_save_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WorkPermitScreen (Phase 8, blueprint §6.9) - guided flow for the
// Ausländerbehörde work-permission letter.
//
// The user picks the office and the concrete job/Ausbildung offer (or a
// saved one), sees the fixed German letter AND a plain-language
// explanation in his own language, listens to both, confirms he read and
// checked everything, and only then sends it himself (share sheet or his
// email app) or saves it as PDF. The app never sends anything on its own.
// The request is stored with the letters (payload docKind 'work_permit').
// ─────────────────────────────────────────────────────────────────────────────

class _Offer {
  final String company;
  final String jobTitle;
  final bool isAusbildung;
  const _Offer(this.company, this.jobTitle, this.isAusbildung);
  String get label => '$jobTitle · $company';
}

class WorkPermitScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  const WorkPermitScreen({
    super.key,
    required this.language,
    required this.voiceMode,
  });

  @override
  State<WorkPermitScreen> createState() => _WorkPermitScreenState();
}

class _WorkPermitScreenState extends State<WorkPermitScreen> {
  final _authorityNameCtrl = TextEditingController();
  final _authorityCityCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();

  UserProfile? _profile;
  bool _loading = true;
  bool _isAusbildung = false;
  String _startDate = '';
  bool _confirmed = false;
  bool _busy = false;
  String? _savedForLetterHash;
  List<_Offer> _offers = const [];
  int _offerIndex = -1; // -1 = enter manually

  String get _lang {
    try {
      final providerLang = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).language;
      return providerLang.isNotEmpty ? providerLang : widget.language;
    } catch (_) {
      return widget.language;
    }
  }

  bool get _isRtl => _lang == 'ps' || _lang == 'fa' || _lang == 'ar' || _lang == 'ur';

  @override
  void initState() {
    super.initState();
    for (final c in [
      _authorityNameCtrl,
      _authorityCityCtrl,
      _companyCtrl,
      _jobTitleCtrl,
    ]) {
      c.addListener(_onChanged);
    }
    _load();
  }

  @override
  void dispose() {
    TtsService().stop();
    for (final c in [
      _authorityNameCtrl,
      _authorityCityCtrl,
      _companyCtrl,
      _jobTitleCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    UserProfile? profile;
    try {
      profile = await KaryabData.profile.loadProfile();
    } catch (_) {
      profile = null;
    }
    final offers = <_Offer>[];
    final jobs = KaryabData.jobs;
    if (jobs != null) {
      try {
        for (final a in await jobs.listApplications()) {
          if (a.company.isNotEmpty && a.jobTitle.isNotEmpty) {
            offers.add(_Offer(a.company, a.jobTitle, false));
          }
        }
        for (final j in await jobs.listSavedJobs()) {
          if (j.company.isNotEmpty && j.title.isNotEmpty) {
            offers.add(_Offer(j.company, j.title, j.source == 'ausbildung'));
          }
        }
      } catch (_) {
        // Offers are a convenience; manual entry always works.
      }
    }
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _offers = offers;
      _loading = false;
    });
  }

  String get _dob {
    final p = _profile;
    if (p == null ||
        p.dobDay == null ||
        p.dobMonth == null ||
        p.dobYear == null) {
      return '';
    }
    return formatGermanDate(DateTime(p.dobYear!, p.dobMonth!, p.dobDay!));
  }

  bool get _formComplete {
    final p = _profile;
    return p != null &&
        p.fullName.isNotEmpty &&
        p.street.isNotEmpty &&
        p.city.isNotEmpty &&
        _authorityNameCtrl.text.trim().isNotEmpty &&
        _authorityCityCtrl.text.trim().isNotEmpty &&
        _companyCtrl.text.trim().isNotEmpty &&
        _jobTitleCtrl.text.trim().isNotEmpty &&
        _startDate.isNotEmpty;
  }

  WorkPermitData? get _data {
    final p = _profile;
    if (p == null) return null;
    return WorkPermitData(
      senderName: p.fullName,
      senderStreet: p.street,
      senderCity: p.city,
      dateOfBirth: _dob,
      nationality: p.country ?? '',
      phone: p.phone,
      email: p.email,
      authorityName: _authorityNameCtrl.text.trim(),
      authorityCity: _authorityCityCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      jobTitle: _jobTitleCtrl.text.trim(),
      isAusbildung: _isAusbildung,
      startDate: _startDate,
      today: formatGermanDate(DateTime.now()),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      setState(() => _startDate = formatGermanDate(picked));
    }
  }

  /// Stores the request with the letters, once per letter content. In
  /// degraded mode (no document repository) this is a silent no-op.
  Future<void> _ensureSaved(WorkPermitData d, String letter) async {
    final docs = KaryabData.documents;
    if (docs == null) return;
    final hash = letter.hashCode.toString();
    if (_savedForLetterHash == hash) return;
    try {
      await docs.createLetterDocument(
        name: 'Arbeitserlaubnis · ${d.company}',
        company: d.company,
        jobTitle: d.jobTitle,
        payload: {...d.toPayload(), 'letterText': letter},
      );
      _savedForLetterHash = hash;
      if (mounted) {
        kSnack(
          context,
          WorkPermitStrings.savedNote(_lang),
          kind: KSnackKind.success,
        );
      }
    } catch (_) {
      // Saving the record must never block sending the letter.
    }
  }

  Future<void> _share(WorkPermitData d, String letter) async {
    await _ensureSaved(d, letter);
    await Share.share(letter, subject: workPermitSubject(d));
  }

  Future<void> _email(WorkPermitData d, String letter) async {
    await _ensureSaved(d, letter);
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {'subject': workPermitSubject(d), 'body': letter},
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _pdf(WorkPermitData d, String letter) async {
    setState(() => _busy = true);
    try {
      await _ensureSaved(d, letter);
      final bytes = await buildWorkPermitPdf(d);
      final name = workPermitPdfFileName(d.senderName);
      final saved = await savePdfToDownloads(bytes, name);
      if (!mounted) return;
      if (saved) {
        kSnack(
          context,
          WorkPermitStrings.pdfSaved(_lang),
          kind: KSnackKind.success,
        );
      } else {
        // Same fallback as the other document screens: share the file.
        await Share.shareXFiles([
          XFile.fromData(bytes, name: name, mimeType: 'application/pdf'),
        ], subject: workPermitSubject(d));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _guarded(Future<void> Function(WorkPermitData, String) action) {
    final d = _data;
    if (d == null || !_formComplete) {
      kSnack(
        context,
        WorkPermitStrings.fillFirst(_lang),
        kind: KSnackKind.error,
      );
      return;
    }
    if (!_confirmed) return; // Buttons are disabled until confirmed.
    action(d, buildWorkPermitLetter(d));
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lang = _lang;
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: KColors.pageBase,
        body: Stack(
          children: [
            const KBackgroundGlow(),
            SafeArea(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: KColors.green),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _header(lang),
                          const SizedBox(height: 16),
                          _introPanel(lang),
                          const SizedBox(height: 14),
                          _yourDataPanel(lang),
                          const SizedBox(height: 14),
                          _formPanel(lang),
                          if (_formComplete) ...[
                            const SizedBox(height: 14),
                            _letterPanel(lang),
                            const SizedBox(height: 14),
                            _explanationPanel(lang),
                            const SizedBox(height: 14),
                            _confirmRow(lang),
                            const SizedBox(height: 12),
                            _actions(lang),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String lang) {
    return Row(
      children: [
        KNavButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            WorkPermitStrings.title(lang),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: karyabFontFamily(lang),
              color: KColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }

  TextStyle _panelText(String lang, {double size = 14}) => TextStyle(
    fontFamily: karyabFontFamily(lang),
    color: KColors.navy,
    fontSize: size,
    height: 1.5,
  );

  Widget _listenButton(String text, String speakLang, String lang) {
    return TextButton.icon(
      onPressed: () => TtsService().speak(text, speakLang),
      icon: const Icon(Icons.volume_up_rounded, color: KColors.green, size: 18),
      label: Text(
        WorkPermitStrings.listen(lang),
        style: TextStyle(
          fontFamily: karyabFontFamily(lang),
          color: KColors.green,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _introPanel(String lang) {
    return KGlassSurface(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(WorkPermitStrings.intro(lang), style: _panelText(lang)),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _listenButton(WorkPermitStrings.intro(lang), lang, lang),
          ),
        ],
      ),
    );
  }

  Widget _yourDataPanel(String lang) {
    final p = _profile;
    return KGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            WorkPermitStrings.yourDataTitle(lang),
            style: _panelText(
              lang,
              size: 15,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (p == null || p.fullName.isEmpty)
            Text(WorkPermitStrings.needProfile(lang), style: _panelText(lang))
          else ...[
            _dataLine(p.fullName),
            if (_dob.isNotEmpty) _dataLine(_dob),
            if ((p.country ?? '').isNotEmpty) _dataLine(p.country!),
            _dataLine('${p.street}, ${p.city}'),
            if (p.phone.isNotEmpty) _dataLine(p.phone),
            if (p.email.isNotEmpty) _dataLine(p.email),
          ],
        ],
      ),
    );
  }

  Widget _dataLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: KColors.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String lang, {
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: KColors.navy, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            fontFamily: karyabFontFamily(lang),
            color: KColors.textSecondary,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: KColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: KColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: KColors.green, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _formPanel(String lang) {
    return KGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            _authorityNameCtrl,
            WorkPermitStrings.authorityName(lang),
            lang,
            hint: WorkPermitStrings.authorityNameHint(lang),
          ),
          _field(
            _authorityCityCtrl,
            WorkPermitStrings.authorityCity(lang),
            lang,
          ),
          if (_offers.isNotEmpty) ...[
            Text(
              WorkPermitStrings.savedOffer(lang),
              style: TextStyle(
                fontFamily: karyabFontFamily(lang),
                color: KColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButton<int>(
                value: _offerIndex,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(
                    value: -1,
                    child: Text(WorkPermitStrings.enterManually(lang)),
                  ),
                  for (var i = 0; i < _offers.length; i++)
                    DropdownMenuItem(value: i, child: Text(_offers[i].label)),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _offerIndex = v;
                    if (v >= 0) {
                      _companyCtrl.text = _offers[v].company;
                      _jobTitleCtrl.text = _offers[v].jobTitle;
                      _isAusbildung = _offers[v].isAusbildung;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          _field(_companyCtrl, WorkPermitStrings.company(lang), lang),
          _field(_jobTitleCtrl, WorkPermitStrings.jobTitle(lang), lang),
          Row(
            children: [
              Switch(
                value: _isAusbildung,
                activeThumbColor: KColors.green,
                onChanged: (v) => setState(() => _isAusbildung = v),
              ),
              Expanded(
                child: Text(
                  WorkPermitStrings.isAusbildung(lang),
                  style: _panelText(lang),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${WorkPermitStrings.startDate(lang)}: '
                  '${_startDate.isEmpty ? WorkPermitStrings.pickDate(lang) : _startDate}',
                  style: _panelText(lang),
                ),
              ),
              TextButton(
                onPressed: _pickDate,
                child: Text(
                  WorkPermitStrings.pickDate(lang),
                  style: TextStyle(
                    fontFamily: karyabFontFamily(lang),
                    color: KColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _letterPanel(String lang) {
    final d = _data!;
    final letter = buildWorkPermitLetter(d);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                WorkPermitStrings.letterTitle(lang),
                style: TextStyle(
                  fontFamily: karyabFontFamily(lang),
                  color: KColors.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _listenButton(letter, 'de', lang),
          ],
        ),
        const SizedBox(height: 8),
        KGlassSurface(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            letter,
            style: const TextStyle(
              color: KColors.navy,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _explanationPanel(String lang) {
    final d = _data!;
    final explanation = workPermitExplanation(lang, d);
    return KGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            WorkPermitStrings.explanationTitle(lang),
            style: _panelText(
              lang,
              size: 15,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(explanation, style: _panelText(lang)),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _listenButton(explanation, lang, lang),
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(String lang) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _confirmed,
          activeColor: KColors.green,
          checkColor: KColors.navy,
          side: const BorderSide(color: KColors.textSecondary),
          onChanged: (v) => setState(() => _confirmed = v ?? false),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _confirmed = !_confirmed),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                WorkPermitStrings.confirmRead(lang),
                style: _panelText(lang),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Secondary action button in the kit glass style (same shape as the
  // CV wizard's Back/Skip buttons): 52 high, radius 22, centred label.
  Widget _glassButton({
    required String label,
    required String lang,
    required VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: SizedBox(
        height: 52,
        child: KGlassCard(
          borderRadius: 22,
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: karyabFontFamily(lang),
                color: KColors.navy,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actions(String lang) {
    final enabled = _confirmed && !_busy;
    return Column(
      children: [
        Opacity(
          opacity: enabled ? 1 : 0.45,
          child: KPrimaryCta(
            icon: Icons.share_rounded,
            label: WorkPermitStrings.sendShare(lang),
            isRtl: _isRtl,
            isSelected: false,
            onTap: () {
              if (enabled) _guarded(_share);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _glassButton(
                label: WorkPermitStrings.openInEmail(lang),
                lang: lang,
                onTap: enabled ? () => _guarded(_email) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _glassButton(
                label: WorkPermitStrings.savePdf(lang),
                lang: lang,
                onTap: enabled ? () => _guarded(_pdf) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
