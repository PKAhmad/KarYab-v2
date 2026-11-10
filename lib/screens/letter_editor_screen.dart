import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../data/karyab_data.dart';
import '../data/repositories.dart';
import '../models/user_profile.dart';
import '../services/ats_checker.dart';
import '../services/letter_model.dart';
import '../services/letter_pdf.dart';
import '../services/jobs_strings.dart';
import '../services/letter_phrase_bank.dart';
import '../services/tts_service.dart';
import '../ui/karyab_ui.dart';
import '../utils/navigation_helpers.dart';
import '../utils/pdf_save_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Anschreiben block editor (Phase 4, items 2, 3, 5, 6).
//
// Two modes in one screen:
//  - Setup mode (no record yet): start-from-the-job form (company block,
//    contact person + salutation choice, job title, reference, tone,
//    company presets). Submitting composes the letter ONCE via the
//    deterministic phrase bank and saves it as a letter_documents row.
//  - Edit mode: the frozen blocks of a saved v2 letter. Every change is a
//    deliberate user action (edit text, swap phrase, reorder, hide) and is
//    autosaved; reopening never recomposes anything. Undo walks back the
//    session's snapshots. Export is blocked while unfilled placeholders
//    remain in any visible block.
//
// Understand mode shows the Pashto/Dari translation of the chosen phrase
// under each block and can read it aloud; it is view-only and is never
// part of the PDF.
// ─────────────────────────────────────────────────────────────────────────────

class LetterPrefill {
  final String jobTitle;
  final String companyName;
  final String companyCity;
  final String jobLocation;
  final String referenceNumber;
  final bool isAusbildung;

  const LetterPrefill({
    this.jobTitle = '',
    this.companyName = '',
    this.companyCity = '',
    this.jobLocation = '',
    this.referenceNumber = '',
    this.isAusbildung = false,
  });
}

class LetterEditorScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  /// Open an existing letter_documents row. Null starts a new letter.
  final int? recordId;
  final LetterPrefill? prefill;

  const LetterEditorScreen({
    super.key,
    required this.language,
    this.voiceMode = false,
    this.recordId,
    this.prefill,
  });

  @override
  State<LetterEditorScreen> createState() => _LetterEditorScreenState();
}

class _LetterEditorScreenState extends State<LetterEditorScreen> {
  String get _lang => widget.language;
  bool get _isRtl => _lang == 'ps' || _lang == 'fa' || _lang == 'ar';

  bool _loading = true;
  bool _setupMode = false;
  bool _legacyRecord = false;
  bool _busy = false;
  bool _understand = false;

  LetterData? _data;
  int? _id;
  String _recordName = '';
  UserProfile _profile = const UserProfile(
    fullName: '',
    phone: '',
    email: '',
    street: '',
    city: '',
    languages: [],
  );
  Map<String, dynamic> _profileMap = const {};
  List<CertificateRecord> _certs = const [];
  List<CompanyPreset> _presets = const [];
  Map<String, LetterRecommendation> _reasons = {};
  final List<String> _history = [];
  int? _pageCount;

  // Setup form controllers.
  final _companyCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _plzCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  String _salutation = 'none';
  String _tone = LetterTone.formal;
  bool _isAusbildung = false;
  bool _savePreset = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _companyCtrl,
      _streetCtrl,
      _plzCtrl,
      _cityCtrl,
      _contactCtrl,
      _titleCtrl,
      _locationCtrl,
      _refCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final map = await KaryabData.profile.loadProfileMap();
      _profileMap = map ?? const {};
      _profile = UserProfile.fromMap(_profileMap);
      _certs = await KaryabData.documents?.listCertificates() ?? const [];
      _presets = await loadSavedCompanies();
      final prefill = widget.prefill;
      if (prefill != null) {
        _companyCtrl.text = prefill.companyName;
        _cityCtrl.text = prefill.companyCity;
        _titleCtrl.text = prefill.jobTitle;
        _locationCtrl.text = prefill.jobLocation;
        _refCtrl.text = prefill.referenceNumber;
        _isAusbildung = prefill.isAusbildung;
      }
      if (widget.recordId != null) {
        final rec = await KaryabData.documents?.getLetterDocument(
          widget.recordId!,
        );
        final data = rec == null ? null : LetterData.fromPayload(rec.payload);
        if (rec == null || data == null) {
          _legacyRecord = true;
        } else {
          _data = data;
          _id = rec.id;
          _recordName = rec.name;
        }
      } else {
        _setupMode = true;
      }
    } catch (_) {
      if (widget.recordId != null) _legacyRecord = true;
    }
    if (mounted) {
      setState(() => _loading = false);
      if (_data != null) _refreshPageCount();
    }
  }

  // ── Persistence ─────────────────────────────────────────────────────────

  void _pushHistory() {
    final data = _data;
    if (data == null) return;
    _history.add(jsonEncode(data.toPayload()));
    if (_history.length > 40) _history.removeAt(0);
  }

  Future<void> _persist() async {
    final data = _data;
    final id = _id;
    if (data == null || id == null) return;
    try {
      await KaryabData.documents?.updateLetterDocument(
        id,
        payload: data.toPayload(),
        company: data.companyName,
        jobTitle: data.jobTitle,
      );
    } catch (_) {}
  }

  void _mutate(void Function() change) {
    _pushHistory();
    setState(change);
    _persist();
    _refreshPageCount();
  }

  void _undo() {
    if (_history.isEmpty || _data == null) return;
    final prev = _history.removeLast();
    final restored = LetterData.fromPayload(
      jsonDecode(prev) as Map<String, dynamic>,
    );
    if (restored == null) return;
    setState(() => _data = restored);
    _persist();
    _refreshPageCount();
  }

  Future<void> _refreshPageCount() async {
    final data = _data;
    if (data == null) return;
    try {
      final bytes = await generateLetterPdf(_profile, data);
      if (mounted) setState(() => _pageCount = countPdfPages(bytes));
    } catch (_) {}
  }

  // ── Setup mode: compose once ────────────────────────────────────────────

  List<String> get _defaultAnlagen {
    final items = <String>['Lebenslauf'];
    for (final c in _certs) {
      if (!items.contains(c.label)) items.add(c.label);
    }
    return items;
  }

  LetterContext _contextFor({
    required String jobTitle,
    required String companyName,
    String companyStreet = '',
    String companyPlz = '',
    String companyCity = '',
    String jobLocation = '',
    String referenceNumber = '',
    bool? isAusbildung,
    String? tone,
  }) {
    return letterContextFromProfile(
      profile: _profile,
      profileMap: _profileMap,
      jobTitle: jobTitle,
      companyName: companyName,
      companyStreet: companyStreet,
      companyPlz: companyPlz,
      companyCity: companyCity,
      jobLocation: jobLocation,
      referenceNumber: referenceNumber,
      isAusbildung: isAusbildung ?? _data?.isAusbildung ?? false,
      tone: tone ?? _data?.tone ?? LetterTone.formal,
      anlagenItems: _data?.anlagenItems ?? _defaultAnlagen,
    );
  }

  Future<void> _createLetter() async {
    if (_busy) return;
    final wasNew = _id == null;
    setState(() => _busy = true);
    try {
      final ctx = _contextFor(
        jobTitle: _titleCtrl.text,
        companyName: _companyCtrl.text,
        companyStreet: _streetCtrl.text,
        companyPlz: _plzCtrl.text,
        companyCity: _cityCtrl.text,
        jobLocation: _locationCtrl.text,
        referenceNumber: _refCtrl.text,
        isAusbildung: _isAusbildung,
        tone: _tone,
      );
      final (:data, :reasons) = composeNewLetter(ctx);
      // Contact person and salutation are part of the same creation act
      // (the composer context factory does not carry them).
      data.contactPerson = _contactCtrl.text.trim();
      data.salutation = _salutation;
      final job = data.jobTitle.trim();
      final company = data.companyName.trim();
      final name = [job, company].where((s) => s.isNotEmpty).join(' · ');
      final id = await KaryabData.documents?.createLetterDocument(
        name: name.isEmpty ? t('title') : name,
        payload: data.toPayload(),
        company: company,
        jobTitle: job,
      );
      if (_savePreset && company.isNotEmpty) {
        _presets = await saveCompanyPreset(
          CompanyPreset(
            name: company,
            street: data.companyStreet,
            plz: data.companyPlz,
            city: data.companyCity,
            contactPerson: data.contactPerson,
            salutation: data.salutation,
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _data = data;
        _id = id;
        _recordName = name.isEmpty ? t('title') : name;
        _reasons = reasons;
        _setupMode = false;
        _busy = false;
      });
      _refreshPageCount();
      // Phase 7 hook: a letter created for a posting (it carries the BA
      // reference number) offers to mark the matching application as
      // Applied and link this letter to it.
      if (wasNew) await _offerMarkApplied(id, data);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _offerMarkApplied(int? letterId, LetterData data) async {
    final refnr = _refCtrl.text.trim();
    final jobs = KaryabData.jobs;
    if (jobs == null || refnr.isEmpty || !mounted) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(JobsStrings.myApplications(_lang)),
        content: Text(JobsStrings.letterAppliedBody(_lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(JobsStrings.notNow(_lang)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(JobsStrings.yes(_lang)),
          ),
        ],
      ),
    );
    if (yes != true) return;
    var app = await jobs.applicationByRefnr(refnr);
    if (app == null) {
      await jobs.createApplication(
        refnr: refnr,
        company: data.companyName,
        jobTitle: data.jobTitle,
        status: ApplicationStatus.applied,
      );
      app = await jobs.applicationByRefnr(refnr);
    } else if (app.status == ApplicationStatus.saved) {
      await jobs.updateApplicationStatus(app.id, ApplicationStatus.applied);
    }
    if (letterId != null && app != null) {
      await jobs.linkApplicationDocuments(
        app.id,
        letterDocumentId: letterId,
        setLetter: true,
      );
    }
  }

  void _applyPreset(CompanyPreset p) {
    setState(() {
      _companyCtrl.text = p.name;
      _streetCtrl.text = p.street;
      _plzCtrl.text = p.plz;
      _cityCtrl.text = p.city;
      _contactCtrl.text = p.contactPerson;
      _salutation = p.salutation;
    });
  }

  // ── Job details editing (edit mode) ─────────────────────────────────────

  Future<void> _editDetails() async {
    final data = _data;
    if (data == null) return;
    final company = TextEditingController(text: data.companyName);
    final street = TextEditingController(text: data.companyStreet);
    final plz = TextEditingController(text: data.companyPlz);
    final city = TextEditingController(text: data.companyCity);
    final contact = TextEditingController(text: data.contactPerson);
    final title = TextEditingController(text: data.jobTitle);
    final ref = TextEditingController(text: data.referenceNumber);
    var salutation = data.salutation;
    var updateBetreff = !(data.block(LetterSection.betreff)?.edited ?? false);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Directionality(
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              t('jobDetails'),
              style: const TextStyle(
                color: KColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(company, t('company')),
                  _dialogField(street, t('street')),
                  Row(
                    children: [
                      Expanded(child: _dialogField(plz, t('plz'))),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: _dialogField(city, t('city'))),
                    ],
                  ),
                  _dialogField(contact, t('contactPerson')),
                  _salutationPicker(
                    salutation,
                    (v) => setLocal(() => salutation = v),
                  ),
                  _dialogField(title, t('jobTitle')),
                  _dialogField(ref, t('reference')),
                  CheckboxListTile(
                    value: updateBetreff,
                    onChanged: (v) =>
                        setLocal(() => updateBetreff = v ?? false),
                    title: Text(
                      t('updateBetreff'),
                      style: const TextStyle(color: KColors.navy, fontSize: 13),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  t('cancel'),
                  style: const TextStyle(
                    color: KColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  t('save'),
                  style: const TextStyle(
                    color: KColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true) {
      for (final c in [company, street, plz, city, contact, title, ref]) {
        c.dispose();
      }
      return;
    }
    _mutate(() {
      data.companyName = company.text.trim();
      data.companyStreet = street.text.trim();
      data.companyPlz = plz.text.trim();
      data.companyCity = city.text.trim();
      data.contactPerson = contact.text.trim();
      data.salutation = salutation;
      data.jobTitle = title.text.trim();
      data.referenceNumber = ref.text.trim();
      if (updateBetreff) {
        final betreff = data.block(LetterSection.betreff);
        if (betreff != null) {
          betreff.text = buildBetreff(
            jobTitle: data.jobTitle,
            isAusbildung: data.isAusbildung,
            referenceNumber: data.referenceNumber,
          );
        }
      }
    });
    for (final c in [company, street, plz, city, contact, title, ref]) {
      c.dispose();
    }
  }

  Widget _dialogField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: KColors.navy, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _salutationPicker(String value, void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          for (final option in const ['none', 'frau', 'herr'])
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(t('salutation_$option')),
                selected: value == option,
                onSelected: (_) => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }

  // ── Block actions ───────────────────────────────────────────────────────

  Future<void> _editBlockText(LetterBlockData block) async {
    final ctrl = TextEditingController(text: block.text);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            t('section_${block.id}'),
            style: const TextStyle(
              color: KColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: ctrl,
            maxLines: 8,
            minLines: 3,
            style: const TextStyle(
              color: KColors.navy,
              fontSize: 14,
              height: 1.4,
            ),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                t('cancel'),
                style: const TextStyle(
                  color: KColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                t('save'),
                style: const TextStyle(
                  color: KColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final text = ctrl.text;
    ctrl.dispose();
    if (ok != true) return;
    _mutate(() {
      block.text = text;
      block.edited = true;
    });
  }

  LetterContext get _swapContext => _contextFor(
    jobTitle: _data?.jobTitle ?? '',
    companyName: _data?.companyName ?? '',
    companyCity: _data?.companyCity ?? '',
    isAusbildung: _data?.isAusbildung,
    tone: _data?.tone,
  );

  Future<void> _swapPhrase(LetterBlockData block) async {
    final data = _data;
    if (data == null) return;
    final ctx = _swapContext;
    final ranked = rankLetterPhrases(
      block.id,
      values: ctx.values,
      sectorHint: ctx.sectorHint,
      tone: data.tone,
    );
    if (ranked.isEmpty) {
      kSnack(context, t('noPhrases'), kind: KSnackKind.error);
      return;
    }
    final picked = await showModalBottomSheet<LetterRecommendation>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const KSheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t('choosePhrase'),
                    style: const TextStyle(
                      color: KColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ranked.length,
                  itemBuilder: (_, i) {
                    final rec = ranked[i];
                    final isCurrent = rec.phrase.id == block.phraseId;
                    return ListTile(
                      title: Text(
                        rec.phrase.fill(ctx.values),
                        style: const TextStyle(
                          color: KColors.navy,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      subtitle: Wrap(
                        spacing: 6,
                        children: [
                          _chip(t('tone_${rec.phrase.tone}')),
                          for (final s in rec.phrase.sectors)
                            _chip(t('sector_$s')),
                          if (i == 0) _chip(t('recommended'), strong: true),
                          if (isCurrent) _chip(t('current'), strong: true),
                        ],
                      ),
                      onTap: () => Navigator.pop(sheetCtx, rec),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    _mutate(() {
      block.text = picked.phrase.fill(ctx.values);
      block.phraseId = picked.phrase.id;
      block.edited = false;
    });
    setState(() => _reasons[block.id] = picked);
  }

  Widget _chip(String label, {bool strong = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: strong
            ? KColors.green.withValues(alpha: 0.25)
            : KColors.navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: KColors.navy,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _moveBlock(LetterBlockData block, int direction) {
    final data = _data;
    if (data == null) return;
    final idx = data.blocks.indexOf(block);
    if (idx < 0) return;
    // Only reorderable sections swap, and only with a reorderable neighbour.
    var j = idx + direction;
    while (j >= 0 && j < data.blocks.length) {
      if (LetterSection.reorderable.contains(data.blocks[j].id)) break;
      j += direction;
    }
    if (j < 0 || j >= data.blocks.length) return;
    _mutate(() {
      final other = data.blocks[j];
      data.blocks[j] = block;
      data.blocks[idx] = other;
    });
  }

  Future<void> _editAnlagen() async {
    final data = _data;
    if (data == null) return;
    final options = <String>['Lebenslauf'];
    for (final label in const [
      'Zeugnisse',
      'Sprachzertifikat',
      'Führerschein',
      'Praktikumsbescheinigung',
    ]) {
      if (!options.contains(label)) options.add(label);
    }
    for (final c in _certs) {
      if (!options.contains(c.label)) options.add(c.label);
    }
    for (final item in data.anlagenItems) {
      if (!options.contains(item)) options.add(item);
    }
    final selected = {...data.anlagenItems};
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Directionality(
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              t('section_anlagen'),
              style: const TextStyle(
                color: KColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final option in options)
                    CheckboxListTile(
                      value: selected.contains(option),
                      title: Text(
                        option,
                        style: const TextStyle(
                          color: KColors.navy,
                          fontSize: 13,
                        ),
                      ),
                      onChanged: (v) => setLocal(() {
                        if (v == true) {
                          selected.add(option);
                        } else {
                          selected.remove(option);
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  t('cancel'),
                  style: const TextStyle(
                    color: KColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  t('save'),
                  style: const TextStyle(
                    color: KColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    _mutate(() {
      data.anlagenItems = [
        for (final o in options)
          if (selected.contains(o)) o,
      ];
      final anlagen = data.block(LetterSection.anlagen);
      if (anlagen != null) anlagen.text = data.anlagenItems.join(', ');
    });
  }

  // ── Understand mode ─────────────────────────────────────────────────────

  Widget _understandSection(LetterBlockData block) {
    final phrase = letterPhraseById(block.phraseId);
    if (phrase == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          t('noPhraseNote'),
          style: TextStyle(
            color: KColors.navy.withValues(alpha: 0.6),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    final values = _swapContext.values;
    final edited = block.edited || block.text != phrase.fill(values);
    final langs = _lang == 'ps'
        ? const ['ps']
        : _lang == 'fa'
        ? const ['fa']
        : const ['ps', 'fa', 'ar'];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final lang in langs) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    fillLetterTokens(phrase.translationFor(lang), values),
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: KColors.navy.withValues(alpha: 0.75),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 19),
                  color: KColors.navy,
                  onPressed: () => TtsService().speak(
                    fillLetterTokens(phrase.translationFor(lang), values),
                    lang,
                  ),
                ),
              ],
            ),
          ],
          if (edited)
            Text(
              t('translationNote'),
              style: TextStyle(
                color: KColors.navy.withValues(alpha: 0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  // ── Export ──────────────────────────────────────────────────────────────

  bool get _guardBlocked =>
      _data != null && _data!.unfilledPlaceholders.isNotEmpty;

  Future<bool> _checkGuard() async {
    final data = _data;
    if (data == null) return false;
    final missing = data.unfilledPlaceholders;
    if (missing.isEmpty) return true;
    await showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            t('placeholderTitle'),
            style: const TextStyle(
              color: KColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            '${t('placeholderBody')}\n${missing.join(', ')}',
            style: const TextStyle(
              color: KColors.navy,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                t('ok'),
                style: const TextStyle(
                  color: KColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return false;
  }

  String get _letterFileName =>
      'Anschreiben_${sanitiseFileNamePart(_profile.fullName)}.pdf';

  Future<void> _downloadPdf() async {
    final data = _data;
    if (data == null || _busy) return;
    if (!await _checkGuard()) return;
    setState(() => _busy = true);
    try {
      final bytes = await generateLetterPdf(_profile, data);
      final saved = await savePdfToDownloads(bytes, _letterFileName);
      if (!mounted) return;
      if (saved) {
        kSnack(context, t('saved'), kind: KSnackKind.success);
      } else {
        await Printing.sharePdf(bytes: bytes, filename: _letterFileName);
      }
      try {
        await KaryabData.profile.setBool('anschreiben_created', true);
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _previewPdf() async {
    final data = _data;
    if (data == null) return;
    if (!await _checkGuard()) return;
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(t('preview'))),
          body: PdfPreview(
            build: (PdfPageFormat format) => generateLetterPdf(_profile, data),
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            pdfFileName: _letterFileName,
          ),
        ),
      ),
    );
  }

  Future<void> _downloadMappe() async {
    final data = _data;
    if (data == null || _busy) return;
    if (!await _checkGuard()) return;
    setState(() => _busy = true);
    try {
      CvDocumentRecord? cvDoc;
      try {
        final kind = data.isAusbildung ? 'ausbildung' : 'job';
        final docs =
            await KaryabData.documents?.listCvDocuments(kind: kind) ??
            const <CvDocumentRecord>[];
        if (docs.isNotEmpty) cvDoc = docs.first;
      } catch (_) {}
      final result = await buildBewerbungsmappe(
        profile: _profile,
        letter: data,
        certificates: _certs,
        cvDocument: cvDoc,
      );
      if (!mounted) return;
      if (result == null) {
        kSnack(context, t('mappeFailed'), kind: KSnackKind.error);
        return;
      }
      final filename = bewerbungFileName(_profile.fullName, data.companyName);
      final saved = await savePdfToDownloads(result.bytes, filename);
      if (!mounted) return;
      if (saved) {
        kSnack(context, t('saved'), kind: KSnackKind.success);
      } else {
        await Printing.sharePdf(bytes: result.bytes, filename: filename);
      }
      if (!mounted) return;
      if (result.notEmbedded.isNotEmpty) {
        kSnack(
          context,
          '${t('mappeNotEmbedded')}: ${result.notEmbedded.join(', ')}',
          kind: KSnackKind.info,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  void _goHome() => goHomeToIntroduction(
    context,
    language: _lang,
    voiceMode: widget.voiceMode,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.pageBase,
      body: Stack(
        children: [
          const KBackgroundGlow(),
          SafeArea(
            child: Directionality(
              textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Row(
                      children: [
                        KNavButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            _setupMode ? t('setupTitle') : t('title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: KColors.navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!_setupMode && _data != null) ...[
                          KNavButton(
                            icon: Icons.undo_rounded,
                            onTap: _history.isEmpty ? () {} : _undo,
                            active: _history.isNotEmpty,
                          ),
                          const SizedBox(width: 6),
                          KNavButton(
                            icon: Icons.translate_rounded,
                            onTap: () =>
                                setState(() => _understand = !_understand),
                            active: _understand,
                          ),
                          const SizedBox(width: 6),
                        ],
                        KNavButton(icon: Icons.home_rounded, onTap: _goHome),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _legacyRecord
                        ? _legacyView()
                        : _setupMode
                        ? _setupForm()
                        : _editorBody(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legacyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t('legacyNote'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: KColors.navy, fontSize: 14),
            ),
            const SizedBox(height: 16),
            KPrimaryCta(
              icon: Icons.add_rounded,
              label: t('createNewInstead'),
              isRtl: _isRtl,
              isSelected: false,
              onTap: () => setState(() {
                _legacyRecord = false;
                _setupMode = true;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: KColors.navy, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.75),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _setupForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        if (_presets.isNotEmpty) ...[
          Text(
            t('presetsLabel'),
            style: const TextStyle(
              color: KColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final p in _presets)
                ActionChip(
                  label: Text(p.name),
                  onPressed: () => _applyPreset(p),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        KGlassCard(
          borderRadius: 22,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formField(t('company'), _companyCtrl),
              _formField(t('street'), _streetCtrl),
              Row(
                children: [
                  Expanded(child: _formField(t('plz'), _plzCtrl)),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: _formField(t('city'), _cityCtrl)),
                ],
              ),
              _formField(t('contactPerson'), _contactCtrl),
              _salutationPicker(
                _salutation,
                (v) => setState(() => _salutation = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        KGlassCard(
          borderRadius: 22,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formField(t('jobTitle'), _titleCtrl),
              _formField(t('jobLocation'), _locationCtrl),
              _formField(t('reference'), _refCtrl),
              Text(
                t('toneLabel'),
                style: const TextStyle(
                  color: KColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final tone in LetterTone.all)
                    ChoiceChip(
                      label: Text(t('tone_$tone')),
                      selected: _tone == tone,
                      onSelected: (_) => setState(() => _tone = tone),
                    ),
                ],
              ),
              SwitchListTile(
                value: _isAusbildung,
                onChanged: (v) => setState(() => _isAusbildung = v),
                title: Text(
                  t('forAusbildung'),
                  style: const TextStyle(color: KColors.navy, fontSize: 13),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _savePreset,
                onChanged: (v) => setState(() => _savePreset = v ?? false),
                title: Text(
                  t('savePreset'),
                  style: const TextStyle(color: KColors.navy, fontSize: 13),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        KPrimaryCta(
          icon: Icons.mail_rounded,
          label: t('createLetter'),
          isRtl: _isRtl,
          isSelected: _busy,
          onTap: _createLetter,
        ),
      ],
    );
  }

  Widget _editorBody() {
    final data = _data;
    if (data == null) return const SizedBox.shrink();
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            children: [
              _detailsCard(data),
              const SizedBox(height: 12),
              for (final block in data.blocks) _blockCard(data, block),
            ],
          ),
        ),
        _exportBar(data),
      ],
    );
  }

  Widget _detailsCard(LetterData data) {
    final companyLine = [
      data.jobTitle,
      data.companyName,
    ].where((s) => s.trim().isNotEmpty).join(' · ');
    return KGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  companyLine.isEmpty ? _recordName : companyLine,
                  style: const TextStyle(
                    color: KColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _editDetails,
                icon: const Icon(Icons.edit_rounded, size: 17),
                label: Text(t('editDetails')),
              ),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (data.date.isNotEmpty) _chip(data.date),
              if (_pageCount != null)
                _chip(
                  _pageCount == 1
                      ? t('fitsOnePage')
                      : '$_pageCount ${t('pagesWord')}',
                  strong: _pageCount == 1,
                ),
              if (_guardBlocked) _chip(t('guardWarning')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blockCard(LetterData data, LetterBlockData block) {
    final isBank = const [
      LetterSection.einleitung,
      LetterSection.erfahrung,
      LetterSection.kenntnisse,
      LetterSection.warum,
      LetterSection.verfuegbarkeit,
      LetterSection.schluss,
    ].contains(block.id);
    final reason = _reasons[block.id];
    final showReason =
        reason != null && reason.phrase.id == block.phraseId && !block.edited;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: KGlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t('section_${block.id}'),
                    style: const TextStyle(
                      color: KColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (block.edited) _chip(t('edited')),
                if (block.hidden) _chip(t('hiddenChip')),
                if (showReason) _chip(_reasonText(reason), strong: true),
              ],
            ),
            const SizedBox(height: 6),
            if (block.hidden)
              Text(
                t('hiddenNote'),
                style: TextStyle(
                  color: KColors.navy.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                block.text,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: KColors.navy,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
            if (_understand && isBank && !block.hidden)
              _understandSection(block),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isBank)
                  IconButton(
                    icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                    color: KColors.navy,
                    tooltip: t('choosePhrase'),
                    onPressed: () => _swapPhrase(block),
                  ),
                if (block.id != LetterSection.anlagen)
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 19),
                    color: KColors.navy,
                    tooltip: t('edit'),
                    onPressed: () => _editBlockText(block),
                  ),
                if (block.id == LetterSection.anlagen)
                  IconButton(
                    icon: const Icon(Icons.checklist_rounded, size: 20),
                    color: KColors.navy,
                    tooltip: t('section_anlagen'),
                    onPressed: _editAnlagen,
                  ),
                if (isBank || block.id == LetterSection.betreff)
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 19),
                    color: KColors.navy,
                    tooltip: t('listen'),
                    onPressed: () => TtsService().speak(block.text, 'de'),
                  ),
                if (LetterSection.reorderable.contains(block.id)) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, size: 19),
                    color: KColors.navy,
                    onPressed: () => _moveBlock(block, -1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward_rounded, size: 19),
                    color: KColors.navy,
                    onPressed: () => _moveBlock(block, 1),
                  ),
                ],
                if (LetterSection.hideable.contains(block.id))
                  IconButton(
                    icon: Icon(
                      block.hidden
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 19,
                    ),
                    color: KColors.navy,
                    onPressed: () =>
                        _mutate(() => block.hidden = !block.hidden),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _reasonText(LetterRecommendation reason) {
    switch (reason.reasonKey) {
      case 'sector':
        return '${t('reasonSector')}: ${t('sector_${reason.reasonValue}')}';
      case 'tone':
        return t('reasonTone');
      case 'specific':
        return t('reasonSpecific');
      default:
        return t('reasonGeneral');
    }
  }

  Widget _exportBar(LetterData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: KPrimaryCta(
              icon: Icons.picture_as_pdf_rounded,
              label: t('pdf'),
              isRtl: _isRtl,
              isSelected: _busy,
              onTap: _downloadPdf,
            ),
          ),
          const SizedBox(width: 10),
          KNavButton(icon: Icons.preview_rounded, onTap: _previewPdf),
          const SizedBox(width: 8),
          KNavButton(
            icon: Icons.folder_zip_rounded,
            onTap: _downloadMappe,
            active: true,
          ),
        ],
      ),
    );
  }

  // ── Strings ─────────────────────────────────────────────────────────────

  String t(String key) {
    String pick(String ps, String fa, String en, String ar) {
      switch (_lang) {
        case 'ps':
          return ps;
        case 'fa':
          return fa;
        case 'ar':
          return ar;
        default:
          return en;
      }
    }

    switch (key) {
      case 'title':
        return pick('پوښتنلیک', 'نامه پوششی', 'Cover letter', 'رسالة التغطية');
      case 'setupTitle':
        return pick('نوی لیک', 'نامه جدید', 'New letter', 'رسالة جديدة');
      case 'jobDetails':
        return pick('د دندې معلومات', 'مشخصات شغل', 'Job details', 'تفاصيل الوظيفة');
      case 'company':
        return pick('شرکت', 'شرکت', 'Company', 'الشركة');
      case 'street':
        return pick('کوڅه او شمېره', 'خیابان و شماره', 'Street and number', 'الشارع والرقم');
      case 'plz':
        return pick('پوستي کوډ', 'کد پستی', 'Postal code', 'الرمز البريدي');
      case 'city':
        return pick('ښار', 'شهر', 'City', 'المدينة');
      case 'contactPerson':
        return pick('د اړیکې کس', 'شخص تماس', 'Contact person', 'شخص الاتصال');
      case 'jobTitle':
        return pick('د دندې نوم', 'عنوان شغل', 'Job title', 'المسمى الوظيفي');
      case 'jobLocation':
        return pick('د کار ځای', 'محل کار', 'Work location', 'مكان العمل');
      case 'reference':
        return pick('حواله شمېره', 'شماره مرجع', 'Reference number', 'رقم المرجع');
      case 'salutation_none':
        return pick('پرته له نومه', 'بدون نام', 'No name', 'بدون اسم');
      case 'salutation_frau':
        return pick('اغلې (Frau)', 'خانم (Frau)', 'Mrs (Frau)', 'السيدة (Frau)');
      case 'salutation_herr':
        return pick('ښاغلی (Herr)', 'آقا (Herr)', 'Mr (Herr)', 'السيد (Herr)');
      case 'updateBetreff':
        return pick(
          'موضوع هم تازه کول',
          'موضوع را هم به‌روز کن',
          'Also update the subject line',
          'تحديث سطر الموضوع أيضا',
        );
      case 'cancel':
        return pick('لغوه', 'لغو', 'Cancel', 'إلغاء');
      case 'save':
        return pick('خوندي کول', 'ذخیره', 'Save', 'حفظ');
      case 'ok':
        return pick('سمه ده', 'باشه', 'OK', 'حسنا');
      case 'edit':
        return pick('سمول', 'ویرایش', 'Edit', 'تعديل');
      case 'editDetails':
        return pick('معلومات سمول', 'ویرایش مشخصات', 'Edit details', 'تعديل التفاصيل');
      case 'listen':
        return pick('اورېدل', 'شنیدن', 'Listen', 'استماع');
      case 'section_betreff':
        return pick('موضوع', 'موضوع', 'Subject', 'الموضوع');
      case 'section_einleitung':
        return pick('پرانیسته', 'شروع', 'Opening', 'الافتتاح');
      case 'section_erfahrung':
        return pick('زما تجربه', 'تجربه من', 'My experience', 'خبرتي');
      case 'section_kenntnisse':
        return pick(
          'مهارتونه او قوتونه',
          'مهارت‌ها و نقاط قوت',
          'Skills and strengths',
          'المهارات ونقاط القوة',
        );
      case 'section_warum':
        return pick('ولې دا شرکت', 'چرا این شرکت', 'Why this company', 'لماذا هذه الشركة');
      case 'section_verfuegbarkeit':
        return pick('شتون', 'دسترسی', 'Availability', 'التوفر');
      case 'section_schluss':
        return pick('پای', 'پایان', 'Closing', 'الخاتمة');
      case 'section_anlagen':
        return pick('ضمیمې', 'پیوست‌ها', 'Attachments', 'المرفقات');
      case 'edited':
        return pick('سمول شوی', 'ویرایش شده', 'Edited', 'تم تعديله');
      case 'hiddenChip':
        return pick('پټ', 'پنهان', 'Hidden', 'مخفي');
      case 'hiddenNote':
        return pick(
          'دا برخه په لیک کې نه چاپېږي.',
          'این بخش در نامه چاپ نمی‌شود.',
          'This part is not printed in the letter.',
          'هذا الجزء لا يُطبع في الرسالة.',
        );
      case 'choosePhrase':
        return pick('جمله غوره کول', 'انتخاب جمله', 'Choose a sentence', 'اختيار جملة');
      case 'recommended':
        return pick('وړاندیز شوی', 'پیشنهاد شده', 'Recommended', 'موصى به');
      case 'current':
        return pick('اوسنی', 'فعلی', 'Current', 'الحالي');
      case 'noPhrases':
        return pick(
          'د دې برخې لپاره جمله نشته، لومړی خپل معلومات ډک کړئ.',
          'برای این بخش جمله‌ای نیست، اول اطلاعات خود را کامل کنید.',
          'No sentence fits this part yet. Complete your profile data first.',
          'لا توجد جملة لهذا الجزء بعد. أكمل بياناتك أولا.',
        );
      case 'tone_formal':
        return pick('رسمي', 'رسمی', 'Formal', 'رسمي');
      case 'tone_friendly':
        return pick('دوستانه', 'دوستانه', 'Friendly', 'ودي');
      case 'tone_confident':
        return pick('ډاډه', 'مطمئن', 'Confident', 'واثق');
      case 'toneLabel':
        return pick('ډول', 'لحن', 'Tone', 'الأسلوب');
      case 'sector_general':
        return pick('عمومي', 'عمومی', 'General', 'عام');
      case 'sector_warehouse':
        return pick('ګودام', 'انبار', 'Warehouse', 'المستودع');
      case 'sector_care':
        return pick('پاملرنه', 'مراقبت', 'Care', 'الرعاية');
      case 'sector_gastronomy':
        return pick('رستورانت', 'رستوران', 'Gastronomy', 'المطعم');
      case 'sector_retail':
        return pick('پلورنه', 'فروش', 'Retail', 'المبيعات');
      case 'sector_cleaning':
        return pick('پاکول', 'نظافت', 'Cleaning', 'التنظيف');
      case 'sector_construction':
        return pick('ودانیز', 'ساختمان', 'Construction', 'البناء');
      case 'sector_driving':
        return pick('موټر چلول', 'رانندگی', 'Driving', 'القيادة');
      case 'sector_office':
        return pick('دفتر', 'دفتر', 'Office', 'المكتب');
      case 'reasonSector':
        return pick('ستاسو دندې ته مناسب', 'مناسب شغل شما', 'Fits your job', 'يناسب وظيفتك');
      case 'reasonTone':
        return pick('ستاسو ډول ته مناسب', 'مناسب لحن شما', 'Fits your tone', 'يناسب أسلوبك');
      case 'reasonSpecific':
        return pick(
          'ستاسو معلومات کاروي',
          'از اطلاعات شما استفاده می‌کند',
          'Uses your data',
          'يستخدم بياناتك',
        );
      case 'reasonGeneral':
        return pick('وړاندیز شوی', 'پیشنهاد شده', 'Recommended', 'موصى به');
      case 'translationNote':
        return pick(
          'دا ژباړه غوره شوې جمله پوښي. ستاسو خپل سمونونه یوازې په آلماني کې دي.',
          'این ترجمه جمله انتخاب‌شده را پوشش می‌دهد. ویرایش‌های شما فقط به آلمانی است.',
          'This translation covers the chosen sentence. Your own edits are in German only.',
          'هذه الترجمة تغطي الجملة المختارة. تعديلاتك الخاصة بالألمانية فقط.',
        );
      case 'noPhraseNote':
        return pick(
          'دا متن تاسو پخپله لیکلی دی، ژباړه نشته.',
          'این متن را خودتان نوشته‌اید، ترجمه‌ای نیست.',
          'You wrote this text yourself, there is no translation.',
          'أنت كتبت هذا النص بنفسك، لا توجد ترجمة.',
        );
      case 'placeholderTitle':
        return pick(
          'لیک لا بشپړ نه دی',
          'نامه هنوز کامل نیست',
          'The letter is not complete yet',
          'الرسالة ليست كاملة بعد',
        );
      case 'placeholderBody':
        return pick(
          'په لیک کې لا ځای ناستي شته، لومړی یې سمول پکار دي:',
          'در نامه هنوز جای خالی هست، اول باید اصلاح شود:',
          'There are still placeholders in the letter. Fix them first:',
          'لا تزال هناك عناصر نائبة في الرسالة. أصلحها أولا:',
        );
      case 'saved':
        return pick(
          'په ډاونلوډونو کې خوندي شو',
          'در دانلودها ذخیره شد',
          'Saved to Downloads',
          'تم الحفظ في التنزيلات',
        );
      case 'preview':
        return pick('کتل', 'مشاهده', 'Preview', 'معاينة');
      case 'pdf':
        return pick('PDF جوړول', 'ساختن PDF', 'Create PDF', 'إنشاء PDF');
      case 'mappeFailed':
        return pick(
          'بشپړ غوښتنلیک جوړ نه شو.',
          'پوشه کامل درخواست ساخته نشد.',
          'The full application could not be created.',
          'تعذر إنشاء ملف الطلب الكامل.',
        );
      case 'mappeNotEmbedded':
        return pick(
          'دا اسناد یوازې په ضمیمو کې نومول شوي، دننه نه دي',
          'این مدارک فقط در پیوست‌ها نام برده شده‌اند، داخل نیستند',
          'These documents are only named in the attachments, not included',
          'هذه المستندات مذكورة في المرفقات فقط، وليست مضمنة',
        );
      case 'fitsOnePage':
        return pick('یوه پاڼه', 'یک صفحه', 'Fits on one page', 'صفحة واحدة');
      case 'pagesWord':
        return pick('پاڼې', 'صفحه', 'pages', 'صفحات');
      case 'guardWarning':
        return pick('ځای ناستي شته', 'جای خالی هست', 'Placeholders remain', 'توجد عناصر نائبة');
      case 'createLetter':
        return pick('لیک جوړول', 'ساختن نامه', 'Create letter', 'إنشاء الرسالة');
      case 'presetsLabel':
        return pick(
          'خوندي شوي شرکتونه',
          'شرکت‌های ذخیره‌شده',
          'Saved companies',
          'الشركات المحفوظة',
        );
      case 'savePreset':
        return pick(
          'دا شرکت خوندي کول',
          'این شرکت را ذخیره کن',
          'Save this company',
          'حفظ هذه الشركة',
        );
      case 'forAusbildung':
        return pick(
          'د زده کړې (Ausbildung) لپاره',
          'برای کارآموزی (Ausbildung)',
          'For an Ausbildung',
          'من أجل Ausbildung',
        );
      case 'legacyNote':
        return pick(
          'دا لیک په زاړه بڼه کې جوړ شوی و. متن یې دلته نه پرانیستل کېږي.',
          'این نامه در نسخه قدیمی ساخته شده بود. متن آن اینجا باز نمی‌شود.',
          'This letter was created in the old version. Its text cannot be opened here.',
          'تم إنشاء هذه الرسالة في الإصدار القديم. لا يمكن فتح نصها هنا.',
        );
      case 'createNewInstead':
        return pick('نوی لیک جوړول', 'ساختن نامه جدید', 'Create a new letter', 'إنشاء رسالة جديدة');
      default:
        return key;
    }
  }
}
