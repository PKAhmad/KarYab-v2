import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/karyab_data.dart';
import '../models/user_profile.dart';
import '../providers/language_provider.dart';
import '../services/official_letter.dart';
import '../services/official_letter_pdf.dart';
import '../services/official_letter_send.dart';
import '../services/official_letter_strings.dart';
import '../services/tts_service.dart';
import '../services/work_permit_letter.dart';
import '../services/work_permit_strings.dart';
import '../ui/karyab_ui.dart';
import '../utils/pdf_save_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OfficialLettersScreen (Phase 9) - the Behördenbriefe flow.
//
// Four steps: (1) the office (type picker, name, email with
// validation, postal address), (2) the purpose and its fields, with
// the user's profile data prefilled read-only like Phase 8, (3) the
// attachments, which become pages of the letter PDF and its Anlagen
// list, (4) the review: the German letter, a plain-language
// explanation in the user's language, a listen button, the legal
// note, and the mandatory read-and-checked confirmation. Only then
// can the user send the letter, from his own email app with the PDF
// attached (flutter_email_sender), or via the explained two-step
// fallback, or save the PDF. Every letter is stored with the letters
// (payload docKind 'official_letter').
//
// Purpose 'workPermit' is the Phase 8 letter: same template engine,
// same saved-offer picker, now with attachments. [initialPurpose]
// presets the purpose (the deep-link entry into purpose 1).
// ─────────────────────────────────────────────────────────────────────────────

class _Offer {
  final String company;
  final String jobTitle;
  final bool isAusbildung;
  const _Offer(this.company, this.jobTitle, this.isAusbildung);
  String get label => '$jobTitle · $company';
}

class OfficialLettersScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;
  final OfficialPurpose? initialPurpose;

  const OfficialLettersScreen({
    super.key,
    required this.language,
    required this.voiceMode,
    this.initialPurpose,
  });

  @override
  State<OfficialLettersScreen> createState() => _OfficialLettersScreenState();
}

class _OfficialLettersScreenState extends State<OfficialLettersScreen> {
  // Office step.
  OfficeType _officeType = OfficeType.auslaenderbehoerde;
  final _officeNameCtrl = TextEditingController(
    text: OfficeType.auslaenderbehoerde.germanLabel,
  );
  final _officeEmailCtrl = TextEditingController();
  final _officeStreetCtrl = TextEditingController();
  final _officeCityCtrl = TextEditingController();
  bool _emailTouched = false;

  // Purpose step.
  late OfficialPurpose _purpose;
  final _companyCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  bool _isAusbildung = false;
  String _startDate = '';
  List<_Offer> _offers = const [];
  int _offerIndex = -1;
  final _courseProviderCtrl = TextEditingController();
  String _courseStart = '';
  final _germanLevelCtrl = TextEditingController();
  String _permitExpiry = '';
  final _terminReasonCtrl = TextEditingController();
  final _newAddressCtrl = TextEditingController();
  String _moveInDate = '';
  final _terminTopicCtrl = TextEditingController();
  final _documentNamesCtrl = TextEditingController();
  final _questionSubjectCtrl = TextEditingController();
  final _questionTextCtrl = TextEditingController();

  // Attachments + flow state.
  final List<OfficialAttachment> _attachments = [];
  int _step = 0;
  UserProfile? _profile;
  bool _loading = true;
  bool _confirmed = false;
  bool _busy = false;
  String? _savedForLetterHash;

  // Phase 13: the message of the last failed Continue gate. Shown as a
  // persistent inline error above the bottom bar (see _gateErrorBar),
  // never as a SnackBar: the floating SnackBar used before rendered on
  // top of the Continue button and swallowed the user's taps.
  String? _gateError;

  List<TextEditingController> get _controllers => [
    _officeNameCtrl,
    _officeEmailCtrl,
    _officeStreetCtrl,
    _officeCityCtrl,
    _companyCtrl,
    _jobTitleCtrl,
    _courseProviderCtrl,
    _germanLevelCtrl,
    _terminReasonCtrl,
    _newAddressCtrl,
    _terminTopicCtrl,
    _documentNamesCtrl,
    _questionSubjectCtrl,
    _questionTextCtrl,
  ];

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
    _purpose = widget.initialPurpose ?? OfficialPurpose.workPermit;
    for (final c in _controllers) {
      c.addListener(_onChanged);
    }
    _load();
  }

  @override
  void dispose() {
    TtsService().stop();
    for (final c in _controllers) {
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

  bool get _profileComplete {
    final p = _profile;
    return p != null &&
        p.fullName.isNotEmpty &&
        p.street.isNotEmpty &&
        p.city.isNotEmpty;
  }

  bool get _officeComplete =>
      _officeNameCtrl.text.trim().isNotEmpty &&
      isValidOfficeEmail(_officeEmailCtrl.text);

  /// Whether the current step's Continue gate is still unmet. The
  /// inline gate error (Phase 13) shows only while this is true, so
  /// it clears itself the moment the user completes the step's input.
  bool get _gateStillFailing {
    switch (_step) {
      case 0:
        return !_officeComplete;
      case 1:
        return !_profileComplete || !_purposeComplete;
      case 2:
        return _purpose == OfficialPurpose.submitDocuments &&
            _documentNames.isEmpty &&
            _attachments.isEmpty;
      default:
        return false;
    }
  }

  bool get _purposeComplete {
    switch (_purpose) {
      case OfficialPurpose.workPermit:
        return _companyCtrl.text.trim().isNotEmpty &&
            _jobTitleCtrl.text.trim().isNotEmpty &&
            _startDate.isNotEmpty;
      case OfficialPurpose.integrationCourse:
      case OfficialPurpose.appointmentGeneral:
      case OfficialPurpose.appointmentJob:
        return true;
      case OfficialPurpose.permitExtension:
        return _permitExpiry.isNotEmpty;
      case OfficialPurpose.appointmentRegistration:
        return _newAddressCtrl.text.trim().isNotEmpty;
      case OfficialPurpose.submitDocuments:
        return true; // checked when leaving the attachments step
      case OfficialPurpose.question:
        return _questionSubjectCtrl.text.trim().isNotEmpty &&
            _questionTextCtrl.text.trim().isNotEmpty;
    }
  }

  List<String> get _documentNames => _documentNamesCtrl.text
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  OfficialLetterData? get _data {
    final p = _profile;
    if (p == null) return null;
    return OfficialLetterData(
      senderName: p.fullName,
      senderStreet: p.street,
      senderCity: p.city,
      dateOfBirth: _dob,
      nationality: p.country ?? '',
      phone: p.phone,
      email: p.email,
      officeType: _officeType,
      officeName: _officeNameCtrl.text.trim(),
      officeStreet: _officeStreetCtrl.text.trim(),
      officeCity: _officeCityCtrl.text.trim(),
      officeEmail: _officeEmailCtrl.text.trim(),
      purpose: _purpose,
      company: _companyCtrl.text.trim(),
      jobTitle: _jobTitleCtrl.text.trim(),
      isAusbildung: _isAusbildung,
      startDate: _startDate,
      courseProvider: _courseProviderCtrl.text.trim(),
      courseStart: _courseStart,
      germanLevel: _germanLevelCtrl.text.trim(),
      permitExpiry: _permitExpiry,
      terminReason: _terminReasonCtrl.text.trim(),
      newAddress: _newAddressCtrl.text.trim(),
      moveInDate: _moveInDate,
      terminTopic: _terminTopicCtrl.text.trim(),
      documentNames: _documentNames,
      questionSubject: _questionSubjectCtrl.text.trim(),
      questionText: _questionTextCtrl.text.trim(),
      attachmentNames: [for (final a in _attachments) a.name],
      today: formatGermanDate(DateTime.now()),
    );
  }

  // ── Step navigation ──────────────────────────────────────────────────

  void _next() {
    final lang = _lang;
    // Phase 13: gate failures set the persistent inline gate error
    // instead of firing a SnackBar. The old floating SnackBar landed
    // exactly on the Continue button, absorbed every tap while it was
    // visible and stacked on repeated taps, so after a single failed
    // tap the button was dead even once the input was fixed (the
    // CEO's phone report). The gates themselves are unchanged.
    if (_step == 0 && !_officeComplete) {
      setState(() {
        _emailTouched = true;
        _gateError = OfficialLetterStrings.fillOfficeFirst(lang);
      });
      return;
    }
    if (_step == 1 && (!_profileComplete || !_purposeComplete)) {
      setState(
        () => _gateError = OfficialLetterStrings.fillPurposeFirst(lang),
      );
      return;
    }
    if (_step == 2 &&
        _purpose == OfficialPurpose.submitDocuments &&
        _documentNames.isEmpty &&
        _attachments.isEmpty) {
      setState(() => _gateError = OfficialLetterStrings.docsNeeded(lang));
      return;
    }
    if (_step < 3) {
      setState(() {
        _step++;
        _confirmed = false;
        _gateError = null;
      });
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() {
        _step--;
        _gateError = null;
      });
    }
  }

  // ── Attachments ──────────────────────────────────────────────────────

  Future<void> _pickFiles() async {
    final lang = _lang;
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: true,
      );
    } catch (_) {
      result = null;
    }
    if (result == null || !mounted) return;
    var added = 0;
    for (final f in result.files) {
      if (_attachments.length >= kMaxOfficialAttachments) {
        kSnack(
          context,
          OfficialLetterStrings.attachTooMany(lang),
          kind: KSnackKind.error,
        );
        break;
      }
      if (f.size > kMaxOfficialAttachmentBytes) {
        kSnack(
          context,
          OfficialLetterStrings.attachTooBig(lang),
          kind: KSnackKind.error,
        );
        continue;
      }
      var bytes = f.bytes;
      if (bytes == null && (f.path ?? '').isNotEmpty) {
        try {
          bytes = await File(f.path!).readAsBytes();
        } catch (_) {
          bytes = null;
        }
      }
      if (!mounted) return;
      final duplicate = _attachments.any(
        (a) => a.name == f.name && a.sizeBytes == f.size,
      );
      if (duplicate) continue;
      _attachments.add(
        OfficialAttachment(
          name: f.name,
          path: f.path ?? '',
          bytes: bytes,
          sizeBytes: f.size,
        ),
      );
      added++;
    }
    if (added > 0 && mounted) setState(() {});
  }

  // ── Saving, PDF, sending ─────────────────────────────────────────────

  Future<void> _ensureSaved(OfficialLetterData d, String letter) async {
    final docs = KaryabData.documents;
    if (docs == null) return;
    final hash = letter.hashCode.toString();
    if (_savedForLetterHash == hash) return;
    try {
      await docs.createLetterDocument(
        name: officialLetterSubject(d),
        company: d.purpose == OfficialPurpose.workPermit && d.company.isNotEmpty
            ? d.company
            : null,
        jobTitle:
            d.purpose == OfficialPurpose.workPermit && d.jobTitle.isNotEmpty
            ? d.jobTitle
            : null,
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

  Future<({OfficialPdfResult pdf, String name})?> _buildPdf(
    OfficialLetterData d,
    String letter,
  ) async {
    await _ensureSaved(d, letter);
    final pdf = await buildOfficialLetterPdf(d, _attachments);
    if (!mounted) return null;
    if (pdf.skippedPdfs > 0) {
      kSnack(
        context,
        OfficialLetterStrings.attachSkippedPdf(_lang),
        kind: KSnackKind.error,
      );
    }
    return (pdf: pdf, name: officialLetterPdfFileName(d));
  }

  Future<void> _sendEmail() async {
    final d = _data;
    if (d == null || !_confirmed || _busy) return;
    setState(() => _busy = true);
    try {
      final letter = buildOfficialLetter(d);
      final built = await _buildPdf(d, letter);
      if (built == null) return;
      final outcome = await OfficialLetterMailer().composeWithPdf(
        data: d,
        letter: letter,
        pdfBytes: built.pdf.bytes,
        pdfFileName: built.name,
      );
      if (!mounted) return;
      if (outcome == OfficialSendOutcome.composed) {
        kSnack(
          context,
          OfficialLetterStrings.emailOpened(_lang),
          kind: KSnackKind.success,
        );
      } else {
        await _runFallback(d, letter, built.pdf.bytes, built.name);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Two-step fallback when the mail app cannot take the PDF itself:
  /// explain first, then mailto with the letter text, then share the
  /// PDF so the user attaches it to the same email.
  Future<void> _runFallback(
    OfficialLetterData d,
    String letter,
    Uint8List pdfBytes,
    String pdfName,
  ) async {
    final lang = _lang;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(OfficialLetterStrings.fallbackTitle(lang)),
          content: Text(OfficialLetterStrings.fallbackBody(lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(OfficialLetterStrings.back(lang)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(OfficialLetterStrings.fallbackGo(lang)),
            ),
          ],
        ),
      ),
    );
    if (go != true || !mounted) return;
    final uri = Uri(
      scheme: 'mailto',
      path: d.officeEmail,
      queryParameters: {'subject': officialLetterSubject(d), 'body': letter},
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    await Share.shareXFiles([
      XFile.fromData(pdfBytes, name: pdfName, mimeType: 'application/pdf'),
    ], subject: officialLetterSubject(d));
  }

  Future<void> _savePdf() async {
    final d = _data;
    if (d == null || !_confirmed || _busy) return;
    setState(() => _busy = true);
    try {
      final letter = buildOfficialLetter(d);
      final built = await _buildPdf(d, letter);
      if (built == null) return;
      final saved = await savePdfToDownloads(built.pdf.bytes, built.name);
      if (!mounted) return;
      if (saved) {
        kSnack(
          context,
          WorkPermitStrings.pdfSaved(_lang),
          kind: KSnackKind.success,
        );
      } else {
        await Share.shareXFiles([
          XFile.fromData(
            built.pdf.bytes,
            name: built.name,
            mimeType: 'application/pdf',
          ),
        ], subject: officialLetterSubject(d));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDate(void Function(String) apply) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      setState(() => apply(formatGermanDate(picked)));
    }
  }

  // ── Build ────────────────────────────────────────────────────────────

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
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _header(lang),
                                const SizedBox(height: 14),
                                _stepHeader(lang),
                                const SizedBox(height: 14),
                                if (_step == 0) _officeStep(lang),
                                if (_step == 1) _purposeStep(lang),
                                if (_step == 2) _attachmentsStep(lang),
                                if (_step == 3) _reviewStep(lang),
                              ],
                            ),
                          ),
                        ),
                        if (_gateError != null && _gateStillFailing)
                          _gateErrorBar(),
                        _bottomBar(lang),
                      ],
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
            OfficialLetterStrings.title(lang),
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

  String _stepName(String lang, int step) {
    switch (step) {
      case 0:
        return OfficialLetterStrings.stepOffice(lang);
      case 1:
        return OfficialLetterStrings.stepPurpose(lang);
      case 2:
        return OfficialLetterStrings.stepAttachments(lang);
      default:
        return OfficialLetterStrings.stepReview(lang);
    }
  }

  Widget _stepHeader(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${OfficialLetterStrings.stepOf(lang, _step + 1, 4)} · '
          '${_stepName(lang, _step)}',
          style: TextStyle(
            fontFamily: karyabFontFamily(lang),
            color: KColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: i <= _step ? KColors.green : KColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

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

  Widget _field(
    TextEditingController ctrl,
    String label,
    String lang, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? errorText,
    Widget? suffixIcon,
    VoidCallback? onBlur,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) onBlur?.call();
        },
        child: TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: KColors.navy, fontSize: 15),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorText,
            suffixIcon: suffixIcon,
            labelStyle: TextStyle(
              fontFamily: karyabFontFamily(lang),
              color: KColors.textSecondary,
            ),
            hintStyle: const TextStyle(
              color: KColors.textSecondary,
              fontSize: 13,
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
      ),
    );
  }

  Widget _dateRow(
    String label,
    String value,
    VoidCallback onPick,
    String lang,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label: '
              '${value.isEmpty ? WorkPermitStrings.pickDate(lang) : value}',
              style: _panelText(lang),
            ),
          ),
          TextButton(
            onPressed: onPick,
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
    );
  }

  // ── Step 1: office ───────────────────────────────────────────────────

  Widget _officeStep(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KGlassSurface(
          borderRadius: 20,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(OfficialLetterStrings.intro(lang), style: _panelText(lang)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _listenButton(
                  OfficialLetterStrings.intro(lang),
                  lang,
                  lang,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          OfficialLetterStrings.whichOffice(lang),
          style: _panelText(
            lang,
            size: 15,
          ).copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in OfficeType.values)
              ChoiceChip(
                label: Text(
                  OfficialLetterStrings.officeType(lang, type),
                  style: TextStyle(
                    fontFamily: karyabFontFamily(lang),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _officeType == type ? Colors.white : KColors.navy,
                  ),
                ),
                selected: _officeType == type,
                selectedColor: KColors.green,
                backgroundColor: Colors.white.withValues(
                  alpha: KColors.glassFillAlpha,
                ),
                side: BorderSide(
                  color: _officeType == type
                      ? KColors.green
                      : KColors.borderSoft,
                ),
                onSelected: (_) {
                  setState(() {
                    _officeType = type;
                    final current = _officeNameCtrl.text.trim();
                    final isPrefill = OfficeType.values.any(
                      (t) =>
                          t.germanLabel.isNotEmpty && t.germanLabel == current,
                    );
                    if (current.isEmpty || isPrefill) {
                      _officeNameCtrl.text = type.germanLabel;
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        KGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                _officeNameCtrl,
                OfficialLetterStrings.officeName(lang),
                lang,
                hint: OfficialLetterStrings.officeNameHint(lang),
              ),
              _field(
                _officeEmailCtrl,
                OfficialLetterStrings.officeEmail(lang),
                lang,
                hint: OfficialLetterStrings.officeEmailHint(lang),
                keyboardType: TextInputType.emailAddress,
                // Phase 13: also flag an EMPTY email once the field
                // was touched (blur or a failed Continue tap). Before,
                // an empty address showed no inline error at all, so
                // nothing on screen said what Continue was waiting for.
                errorText:
                    _emailTouched && !isValidOfficeEmail(_officeEmailCtrl.text)
                    ? OfficialLetterStrings.emailInvalid(lang)
                    : null,
                onBlur: () => setState(() => _emailTouched = true),
              ),
              _field(
                _officeStreetCtrl,
                OfficialLetterStrings.officeStreet(lang),
                lang,
              ),
              _field(
                _officeCityCtrl,
                OfficialLetterStrings.officeCity(lang),
                lang,
              ),
              Text(
                OfficialLetterStrings.officePostalOptional(lang),
                style: _panelText(lang, size: 12.5),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 2: purpose + fields ─────────────────────────────────────────

  Widget _purposeStep(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          OfficialLetterStrings.purposeTitle(lang),
          style: _panelText(
            lang,
            size: 15,
          ).copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (final purpose in OfficialPurpose.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: KGlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              onTap: () => setState(() => _purpose = purpose),
              child: Row(
                children: [
                  Icon(
                    _purpose == purpose
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _purpose == purpose
                        ? KColors.green
                        : KColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      OfficialLetterStrings.purposeName(lang, purpose),
                      style: _panelText(lang).copyWith(
                        fontWeight: _purpose == purpose
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 6),
        _yourDataPanel(lang),
        const SizedBox(height: 14),
        KGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: _purposeFields(lang),
        ),
      ],
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
          if (!_profileComplete)
            Text(WorkPermitStrings.needProfile(lang), style: _panelText(lang))
          else ...[
            _dataLine(p!.fullName),
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

  Widget _purposeFields(String lang) {
    switch (_purpose) {
      case OfficialPurpose.workPermit:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            _dateRow(
              WorkPermitStrings.startDate(lang),
              _startDate,
              () => _pickDate((v) => _startDate = v),
              lang,
            ),
          ],
        );
      case OfficialPurpose.integrationCourse:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              _courseProviderCtrl,
              OfficialLetterStrings.courseProvider(lang),
              lang,
            ),
            _field(
              _germanLevelCtrl,
              OfficialLetterStrings.germanLevel(lang),
              lang,
              hint: OfficialLetterStrings.germanLevelHint(lang),
            ),
            _dateRow(
              OfficialLetterStrings.courseStart(lang),
              _courseStart,
              () => _pickDate((v) => _courseStart = v),
              lang,
            ),
          ],
        );
      case OfficialPurpose.permitExtension:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dateRow(
              OfficialLetterStrings.permitExpiry(lang),
              _permitExpiry,
              () => _pickDate((v) => _permitExpiry = v),
              lang,
            ),
          ],
        );
      case OfficialPurpose.appointmentGeneral:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              _terminReasonCtrl,
              OfficialLetterStrings.terminReason(lang),
              lang,
            ),
          ],
        );
      case OfficialPurpose.appointmentRegistration:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              _newAddressCtrl,
              OfficialLetterStrings.newAddress(lang),
              lang,
            ),
            _dateRow(
              OfficialLetterStrings.moveInDate(lang),
              _moveInDate,
              () => _pickDate((v) => _moveInDate = v),
              lang,
            ),
          ],
        );
      case OfficialPurpose.appointmentJob:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              _terminTopicCtrl,
              OfficialLetterStrings.terminTopic(lang),
              lang,
              maxLines: 2,
            ),
          ],
        );
      case OfficialPurpose.submitDocuments:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              _documentNamesCtrl,
              OfficialLetterStrings.documentNames(lang),
              lang,
              hint: OfficialLetterStrings.documentNamesHint(lang),
              maxLines: 4,
            ),
          ],
        );
      case OfficialPurpose.question:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              _questionSubjectCtrl,
              OfficialLetterStrings.questionSubject(lang),
              lang,
              suffixIcon: KDictationButton(controller: _questionSubjectCtrl),
            ),
            _field(
              _questionTextCtrl,
              OfficialLetterStrings.questionText(lang),
              lang,
              maxLines: 6,
              suffixIcon: KDictationButton(controller: _questionTextCtrl),
            ),
          ],
        );
    }
  }

  // ── Step 3: attachments ──────────────────────────────────────────────

  Widget _attachmentsStep(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KGlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                OfficialLetterStrings.attachmentsTitle(lang),
                style: _panelText(
                  lang,
                  size: 15,
                ).copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                OfficialLetterStrings.attachmentsIntro(lang),
                style: _panelText(lang),
              ),
              const SizedBox(height: 8),
              Text(
                OfficialLetterStrings.attachLimitNote(lang),
                style: _panelText(lang, size: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < _attachments.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: KGlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(
                children: [
                  Icon(
                    _attachments[i].isPdf
                        ? Icons.picture_as_pdf_rounded
                        : Icons.image_rounded,
                    color: KColors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _attachments[i].name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _panelText(lang, size: 13.5),
                    ),
                  ),
                  IconButton(
                    tooltip: OfficialLetterStrings.attachRemove(lang),
                    onPressed: () => setState(() => _attachments.removeAt(i)),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: KColors.textSecondary,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Opacity(
          opacity: _attachments.length >= kMaxOfficialAttachments ? 0.45 : 1,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: KGlassCard(
              borderRadius: 16,
              onTap: _attachments.length >= kMaxOfficialAttachments
                  ? null
                  : _pickFiles,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    color: KColors.greenDark,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    OfficialLetterStrings.attachButton(lang),
                    style: TextStyle(
                      fontFamily: karyabFontFamily(lang),
                      color: KColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 4: review ───────────────────────────────────────────────────

  Widget _reviewStep(String lang) {
    final d = _data;
    if (d == null) return const SizedBox.shrink();
    final letter = buildOfficialLetter(d);
    final explanation = officialLetterExplanation(lang, d);
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
        const SizedBox(height: 14),
        KGlassCard(
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
              const SizedBox(height: 6),
              Text(
                OfficialLetterStrings.legalNote(lang),
                style: _panelText(lang, size: 12.5).copyWith(
                  color: KColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _listenButton(explanation, lang, lang),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _confirmRow(lang),
      ],
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

  // ── Bottom bar: navigation / review actions ──────────────────────────

  // Phase 13: persistent inline error for a failed Continue gate.
  // Sits above the bottom bar, stays until the step is completed and
  // never overlaps a button, unlike the SnackBar it replaces.
  Widget _gateErrorBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB3261E),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _gateError!,
              style: TextStyle(
                fontFamily: karyabFontFamily(_lang),
                color: const Color(0xFFB3261E),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: _step < 3 ? _navButtons(lang) : _reviewActions(lang),
    );
  }

  // Secondary action button in the kit glass style (same shape as the
  // CV wizard's Back/Skip buttons): 52 high, radius 22, centred label.
  Widget _glassButton({
    required String lang,
    required String label,
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

  Widget _navButtons(String lang) {
    return Row(
      children: [
        if (_step > 0) ...[
          Expanded(
            flex: 2,
            child: _glassButton(
              lang: lang,
              label: OfficialLetterStrings.back(lang),
              onTap: _back,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: _step > 0 ? 3 : 1,
          child: KPrimaryCta(
            icon: Icons.arrow_forward_rounded,
            label: OfficialLetterStrings.continueLabel(lang),
            isRtl: _isRtl,
            isSelected: false,
            onTap: _next,
          ),
        ),
      ],
    );
  }

  Widget _reviewActions(String lang) {
    final enabled = _confirmed && !_busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Opacity(
          opacity: enabled ? 1 : 0.45,
          child: KPrimaryCta(
            icon: Icons.send_rounded,
            label: OfficialLetterStrings.sendEmail(lang),
            isRtl: _isRtl,
            isSelected: false,
            onTap: () {
              if (enabled) _sendEmail();
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          OfficialLetterStrings.sendEmailNote(lang),
          textAlign: TextAlign.center,
          style: _panelText(lang, size: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _glassButton(
                lang: lang,
                label: OfficialLetterStrings.back(lang),
                onTap: _back,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _glassButton(
                lang: lang,
                label: WorkPermitStrings.savePdf(lang),
                onTap: enabled ? _savePdf : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
