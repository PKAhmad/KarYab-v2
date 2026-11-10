import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/karyab_data.dart';
import '../data/repositories.dart';
import '../providers/language_provider.dart';
import '../services/guides/guides.dart';
import '../services/official_letter_strings.dart';
import '../services/tts_service.dart';
import '../services/work_permit_strings.dart';
import '../ui/karyab_ui.dart';
import 'my_letters_screen.dart';
import 'official_letters_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Guides (Phase 11): step-by-step guides in the user's language.
//
// Three screens, all rendering the data-driven content model
// (lib/services/guides): the guides home (two track cards with real
// progress, plus the honest footer note), the track screen (the step
// list with check-off circles) and the step page (explanation in
// short paragraphs, documents list, scam warning box, listen button,
// jump buttons into the app features the step belongs to, and the
// big finished button).
//
// Check-offs persist in the Drift guide_progress table through
// GuidesRepository; when the data layer is not initialised (degraded
// mode) the screens fall back to in-memory state so the guides still
// work. In voice mode a step page speaks its text when it opens.
// ─────────────────────────────────────────────────────────────────────────────

/// Loads and saves the done set shared by the three guide screens.
class _GuideProgress {
  Set<String> _done = {};

  Set<String> get done => _done;

  bool isDone(String trackId, String stepId) =>
      _done.contains(GuidesRepository.stepKey(trackId, stepId));

  Future<void> load() async {
    final repo = KaryabData.guides;
    if (repo == null) return;
    try {
      _done = await repo.loadDoneStepKeys();
    } catch (_) {
      // Progress is a comfort feature; the guides work without it.
    }
  }

  Future<void> setDone(String trackId, String stepId, bool done) async {
    final key = GuidesRepository.stepKey(trackId, stepId);
    if (done) {
      _done = {..._done, key};
    } else {
      _done = {..._done}..remove(key);
    }
    final repo = KaryabData.guides;
    if (repo == null) return;
    try {
      await repo.setStepDone(trackId, stepId, done);
    } catch (_) {
      // Same contract as load(): never block the user on storage.
    }
  }

  int doneCount(GuideTrack track) => track.steps
      .where((s) => _done.contains(GuidesRepository.stepKey(track.id, s.id)))
      .length;
}

mixin _GuideLangMixin<T extends StatefulWidget> on State<T> {
  String get widgetLanguage;
  bool get widgetVoiceMode;

  String get lang {
    try {
      final providerLang = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).language;
      return providerLang.isNotEmpty ? providerLang : widgetLanguage;
    } catch (_) {
      return widgetLanguage;
    }
  }

  bool get isRtl => lang == 'ps' || lang == 'fa';

  TextStyle textStyle(
    double size,
    FontWeight weight,
    Color color, {
    double height = 1.45,
  }) => TextStyle(
    fontFamily: karyabFontFamily(lang),
    fontFamilyFallback: karyabFontFallback(lang),
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  Widget header(String title, {bool showBack = true}) {
    return Row(
      children: [
        if (showBack)
          KNavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          )
        else
          const SizedBox(width: 44),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textStyle(18, FontWeight.w800, KColors.navy, height: 1.25),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }

  Widget listenButton(String text) {
    return TextButton.icon(
      onPressed: () => TtsService().speak(text, lang),
      icon: const Icon(Icons.volume_up_rounded, color: KColors.green, size: 18),
      label: Text(
        WorkPermitStrings.listen(lang),
        style: textStyle(14, FontWeight.w700, KColors.green),
      ),
    );
  }

  /// Runs one of the step's in-app jump actions.
  Future<void> runAction(GuideAction action) async {
    switch (action) {
      case GuideAction.ausbildungSearch:
        await Navigator.pushNamed(
          context,
          '/ausbildung',
          arguments: {'language': lang, 'voiceMode': widgetVoiceMode},
        );
      case GuideAction.cvBuilder:
        await Navigator.pushNamed(
          context,
          '/choose-cv-type',
          arguments: {'language': lang, 'voiceMode': widgetVoiceMode},
        );
      case GuideAction.deutschCourses:
        await Navigator.pushNamed(
          context,
          '/deutsch-courses',
          arguments: {'language': lang, 'voiceMode': widgetVoiceMode},
        );
      case GuideAction.coverLetter:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MyLettersScreen(language: lang, voiceMode: widgetVoiceMode),
          ),
        );
      case GuideAction.officialLetters:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OfficialLettersScreen(
              language: lang,
              voiceMode: widgetVoiceMode,
            ),
          ),
        );
      case GuideAction.examGuide:
        final track = guideTrackFor(lang, 'exam');
        if (track != null) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GuideTrackScreen(
                language: lang,
                voiceMode: widgetVoiceMode,
                track: track,
              ),
            ),
          );
        }
    }
  }
}

// ── Guides home ──────────────────────────────────────────────────────────

class GuidesScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  const GuidesScreen({
    super.key,
    required this.language,
    required this.voiceMode,
  });

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen>
    with _GuideLangMixin<GuidesScreen> {
  final _GuideProgress _progress = _GuideProgress();

  @override
  String get widgetLanguage => widget.language;
  @override
  bool get widgetVoiceMode => widget.voiceMode;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    await _progress.load();
    if (mounted) setState(() {});
  }

  Future<void> _openTrack(GuideTrack track) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideTrackScreen(
          language: lang,
          voiceMode: widget.voiceMode,
          track: track,
        ),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final tracks = guidesForLanguage(lang);
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: KColors.pageBase,
        body: Stack(
          children: [
            const KBackgroundGlow(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header(GuideStrings.title(lang)),
                    const SizedBox(height: 14),
                    KGlassSurface(
                      borderRadius: 22,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            GuideStrings.intro(lang),
                            style: textStyle(
                              14.5,
                              FontWeight.w600,
                              KColors.navy,
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: listenButton(GuideStrings.intro(lang)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final track in tracks) ...[
                      _trackCard(track),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      GuideStrings.footerNote(lang),
                      textAlign: TextAlign.center,
                      style: textStyle(
                        12,
                        FontWeight.w600,
                        KColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      GuideStrings.lastChecked(lang),
                      textAlign: TextAlign.center,
                      style: textStyle(
                        12,
                        FontWeight.w600,
                        KColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trackCard(GuideTrack track) {
    final done = _progress.doneCount(track);
    final total = track.steps.length;
    return KGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: () => _openTrack(track),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: KColors.green.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(track.icon, color: KColors.greenDark, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: textStyle(15.5, FontWeight.w800, KColors.navy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.subtitle,
                      style: textStyle(
                        12,
                        FontWeight.w600,
                        KColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isRtl
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: KColors.textSecondary,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          KLiquidProgressBar(value: total == 0 ? 0 : done / total, height: 8),
          const SizedBox(height: 6),
          Text(
            GuideStrings.stepsDone(lang, done, total),
            style: textStyle(12, FontWeight.w700, KColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Track screen: the step list ──────────────────────────────────────────

class GuideTrackScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;
  final GuideTrack track;

  const GuideTrackScreen({
    super.key,
    required this.language,
    required this.voiceMode,
    required this.track,
  });

  @override
  State<GuideTrackScreen> createState() => _GuideTrackScreenState();
}

class _GuideTrackScreenState extends State<GuideTrackScreen>
    with _GuideLangMixin<GuideTrackScreen> {
  final _GuideProgress _progress = _GuideProgress();

  @override
  String get widgetLanguage => widget.language;
  @override
  bool get widgetVoiceMode => widget.voiceMode;

  /// The track content in the CURRENT language (the widget may have
  /// been opened in another one; ids are stable across languages).
  GuideTrack get _track => guideTrackFor(lang, widget.track.id) ?? widget.track;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    await _progress.load();
    if (mounted) setState(() {});
  }

  Future<void> _toggle(GuideStep step) async {
    final nowDone = !_progress.isDone(_track.id, step.id);
    await _progress.setDone(_track.id, step.id, nowDone);
    if (mounted) setState(() {});
  }

  Future<void> _openStep(GuideStep step) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideStepScreen(
          language: lang,
          voiceMode: widget.voiceMode,
          track: _track,
          step: step,
        ),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final track = _track;
    final done = _progress.doneCount(track);
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: KColors.pageBase,
        body: Stack(
          children: [
            const KBackgroundGlow(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: header(track.title),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        GuideStrings.stepsDone(lang, done, track.steps.length),
                        style: textStyle(
                          13,
                          FontWeight.w700,
                          KColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
                      itemCount: track.steps.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _stepRow(track.steps[i], i),
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

  Widget _stepRow(GuideStep step, int index) {
    final done = _progress.isDone(_track.id, step.id);
    return KGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      onTap: () => _openStep(step),
      child: Row(
        children: [
          // The check-off circle: its own tap target, so a step can
          // be marked without opening it.
          GestureDetector(
            onTap: () => _toggle(step),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: done ? KColors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? KColors.green : KColors.border,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : Center(
                      child: Text(
                        '${index + 1}',
                        style: textStyle(
                          13,
                          FontWeight.w800,
                          KColors.textSecondary,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.title,
              style: textStyle(14.5, FontWeight.w700, KColors.navy),
            ),
          ),
          Icon(
            isRtl
                ? Icons.arrow_back_ios_new_rounded
                : Icons.arrow_forward_ios_rounded,
            color: KColors.textSecondary,
            size: 15,
          ),
        ],
      ),
    );
  }
}

// ── Step page ────────────────────────────────────────────────────────────

class GuideStepScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;
  final GuideTrack track;
  final GuideStep step;

  const GuideStepScreen({
    super.key,
    required this.language,
    required this.voiceMode,
    required this.track,
    required this.step,
  });

  @override
  State<GuideStepScreen> createState() => _GuideStepScreenState();
}

class _GuideStepScreenState extends State<GuideStepScreen>
    with _GuideLangMixin<GuideStepScreen> {
  final _GuideProgress _progress = _GuideProgress();
  bool _done = false;
  bool _spokeOnce = false;

  @override
  String get widgetLanguage => widget.language;
  @override
  bool get widgetVoiceMode => widget.voiceMode;

  GuideTrack get _track => guideTrackFor(lang, widget.track.id) ?? widget.track;

  GuideStep get _step => _track.stepById(widget.step.id) ?? widget.step;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _progress.load();
    if (!mounted) return;
    setState(() => _done = _progress.isDone(_track.id, _step.id));
    // Voice guidance mode: a step page reads itself when it opens.
    if (widget.voiceMode && !_spokeOnce) {
      _spokeOnce = true;
      final text = _spokenText;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TtsService().speak(text, lang).catchError((_) {});
      });
    }
  }

  @override
  void dispose() {
    TtsService().stop();
    super.dispose();
  }

  String get _spokenText => _step.spokenText(
    GuideStrings.documentsTitle(lang),
    GuideStrings.warningTitle(lang),
  );

  Future<void> _toggleDone() async {
    final nowDone = !_done;
    await _progress.setDone(_track.id, _step.id, nowDone);
    if (mounted) setState(() => _done = nowDone);
  }

  Future<void> _openLink(GuideLink link) async {
    final uri = Uri.tryParse(link.url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // A missing browser must not crash the guide; the URL is also
      // visible on the button, so the user can type it elsewhere.
    }
  }

  int get _stepIndex => _track.steps.indexWhere((s) => s.id == _step.id);

  @override
  Widget build(BuildContext context) {
    final step = _step;
    final index = _stepIndex;
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: KColors.pageBase,
        body: Stack(
          children: [
            const KBackgroundGlow(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: header(_track.title),
                  ),
                  if (index >= 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          OfficialLetterStrings.stepOf(
                            lang,
                            index + 1,
                            _track.steps.length,
                          ),
                          style: textStyle(
                            13,
                            FontWeight.w700,
                            KColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          KGlassSurface(
                            borderRadius: 22,
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      step.icon,
                                      color: KColors.greenDark,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        step.title,
                                        style: textStyle(
                                          17,
                                          FontWeight.w800,
                                          KColors.navy,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                for (final p in step.paragraphs) ...[
                                  Text(
                                    p,
                                    style: textStyle(
                                      14.5,
                                      FontWeight.w600,
                                      KColors.navy,
                                      height: 1.55,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: listenButton(_spokenText),
                                ),
                              ],
                            ),
                          ),
                          if (step.documents.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _documentsCard(step),
                          ],
                          if (step.warning != null) ...[
                            const SizedBox(height: 12),
                            _warningCard(step.warning!),
                          ],
                          for (final action in step.actions) ...[
                            const SizedBox(height: 12),
                            KPrimaryCta(
                              icon: _actionIcon(action),
                              label: GuideStrings.actionLabel(lang, action),
                              isRtl: isRtl,
                              isSelected: false,
                              onTap: () => runAction(action),
                            ),
                          ],
                          for (final link in step.links) ...[
                            const SizedBox(height: 12),
                            KGlassCard(
                              borderRadius: 20,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                14,
                              ),
                              onTap: () => _openLink(link),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    color: KColors.greenDark,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      link.label,
                                      style: textStyle(
                                        14,
                                        FontWeight.w700,
                                        KColors.navy,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _doneButton(),
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

  IconData _actionIcon(GuideAction action) {
    switch (action) {
      case GuideAction.ausbildungSearch:
        return Icons.search_rounded;
      case GuideAction.cvBuilder:
        return Icons.description_rounded;
      case GuideAction.coverLetter:
        return Icons.mail_rounded;
      case GuideAction.officialLetters:
        return Icons.mark_email_read_rounded;
      case GuideAction.deutschCourses:
        return Icons.translate_rounded;
      case GuideAction.examGuide:
        return Icons.school_rounded;
    }
  }

  Widget _documentsCard(GuideStep step) {
    return KGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_open_rounded,
                color: KColors.greenDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  GuideStrings.documentsTitle(lang),
                  style: textStyle(14.5, FontWeight.w800, KColors.navy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final doc in step.documents)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: KColors.greenDark,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doc,
                      style: textStyle(14, FontWeight.w600, KColors.navy),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _warningCard(String warning) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0B24A), width: 1.4),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFB26A00),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                GuideStrings.warningTitle(lang),
                style: textStyle(
                  14.5,
                  FontWeight.w800,
                  const Color(0xFF7A4A00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            warning,
            style: textStyle(
              14,
              FontWeight.w600,
              const Color(0xFF5C3A00),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _doneButton() {
    return KGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      selected: _done,
      onTap: _toggleDone,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: KColors.greenDark,
            size: 24,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _done
                  ? GuideStrings.markUndone(lang)
                  : GuideStrings.markDone(lang),
              style: textStyle(15.5, FontWeight.w800, KColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}
