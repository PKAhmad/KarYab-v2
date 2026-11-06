import 'package:flutter/material.dart';

import '../data/karyab_data.dart';
import '../data/repositories.dart';
import '../services/job_search_service.dart';
import '../services/jobs_strings.dart';
import '../ui/karyab_ui.dart';
import 'job_posting_navigation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TrackerScreen - Phase 7 application tracker. Applications are grouped
// by status (Saved, Applied, Invited, Answer received); each card can
// advance one step with one tap, link an existing CV and/or cover
// letter, or be deleted. Tapping a card whose posting is still in the
// saved-jobs payloads reopens the posting.
// ─────────────────────────────────────────────────────────────────────────────

class TrackerScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  const TrackerScreen({
    super.key,
    required this.language,
    this.voiceMode = false,
  });

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  static const Color _navy = KColors.navy;
  static const Color _muted = KColors.textSecondary;

  String get _lang => widget.language;
  bool get _isRtl => _lang == 'ps' || _lang == 'fa';

  List<ApplicationRecord>? _apps;
  List<CvDocumentRecord> _cvs = const [];
  List<LetterDocumentRecord> _letters = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final jobs = KaryabData.jobs;
    final docs = KaryabData.documents;
    if (jobs == null) {
      setState(() => _apps = const []);
      return;
    }
    final apps = await jobs.listApplications();
    final cvs = docs == null ? <CvDocumentRecord>[] : await docs.listCvDocuments();
    final letters =
        docs == null ? <LetterDocumentRecord>[] : await docs.listLetterDocuments();
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _cvs = cvs;
      _letters = letters;
    });
  }

  Future<void> _advance(ApplicationRecord app) async {
    final jobs = KaryabData.jobs;
    if (jobs == null) return;
    await jobs.advanceApplicationStatus(app.id);
    await _load();
  }

  Future<void> _delete(ApplicationRecord app) async {
    final jobs = KaryabData.jobs;
    if (jobs == null) return;
    await jobs.deleteApplication(app.id);
    await _load();
  }

  Future<void> _openPosting(ApplicationRecord app) async {
    final repo = KaryabData.jobs;
    final refnr = app.refnr;
    if (repo == null || refnr == null || refnr.isEmpty) return;
    final saved = await repo.listSavedJobs();
    SavedJobRecord? match;
    for (final j in saved) {
      if (j.refnr == refnr) {
        match = j;
        break;
      }
    }
    if (!mounted || match == null) return;
    openJobPosting(
      context,
      BaJob.fromJson(match.payload),
      language: _lang,
      voiceMode: widget.voiceMode,
      isAusbildung: match.source == 'ausbildung',
    );
  }

  String? _cvName(int? id) {
    if (id == null) return null;
    for (final c in _cvs) {
      if (c.id == id) return c.name;
    }
    return null;
  }

  String? _letterName(int? id) {
    if (id == null) return null;
    for (final l in _letters) {
      if (l.id == id) return l.name;
    }
    return null;
  }

  Future<void> _showLinkDialog(ApplicationRecord app) async {
    var cvId = app.cvDocumentId;
    var letterId = app.letterDocumentId;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(JobsStrings.linkDocuments(_lang)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(JobsStrings.yourCvs(_lang),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              DropdownButton<int?>(
                value: cvId,
                isExpanded: true,
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(JobsStrings.noneOption(_lang)),
                  ),
                  for (final c in _cvs)
                    DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setLocal(() => cvId = v),
              ),
              const SizedBox(height: 12),
              Text(JobsStrings.yourLetters(_lang),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              DropdownButton<int?>(
                value: letterId,
                isExpanded: true,
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(JobsStrings.noneOption(_lang)),
                  ),
                  for (final l in _letters)
                    DropdownMenuItem<int?>(
                        value: l.id, child: Text(l.name)),
                ],
                onChanged: (v) => setLocal(() => letterId = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(JobsStrings.cancel(_lang)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(JobsStrings.ok(_lang)),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    final jobs = KaryabData.jobs;
    if (jobs == null) return;
    await jobs.linkApplicationDocuments(
      app.id,
      cvDocumentId: cvId,
      setCv: true,
      letterDocumentId: letterId,
      setLetter: true,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: KColors.pageBase,
        body: Stack(
          children: [
            const KBackgroundGlow(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        KNavButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            JobsStrings.myApplications(_lang),
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
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final apps = _apps;
    if (apps == null) return const Center(child: CircularProgressIndicator());
    if (apps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: KGlassSurface(
            borderRadius: 20,
            padding: const EdgeInsets.all(28),
            child: Text(
              JobsStrings.emptyApplications(_lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ),
      );
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        for (final status in ApplicationStatus.flow) ...[
          if (apps.any((a) => a.status == status)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              child: Text(
                '${JobsStrings.statusName(_lang, status)} '
                '(${apps.where((a) => a.status == status).length})',
                style: const TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            for (final app in apps.where((a) => a.status == status))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCard(app),
              ),
          ],
        ],
      ],
    );
  }

  Widget _buildCard(ApplicationRecord app) {
    final next = ApplicationStatus.next(app.status);
    final cvName = _cvName(app.cvDocumentId);
    final letterName = _letterName(app.letterDocumentId);
    return KGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      onTap: () => _openPosting(app),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            app.company,
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
            app.jobTitle,
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            [
              if (cvName != null) 'CV: $cvName',
              if (letterName != null) letterName,
            ].isEmpty
                ? JobsStrings.noLinkedDocs(_lang)
                : [
                    if (cvName != null) 'CV: $cvName',
                    if (letterName != null) letterName,
                  ].join('  ·  '),
            style: const TextStyle(color: _muted, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (next != null)
                TextButton.icon(
                  onPressed: () => _advance(app),
                  icon: const Icon(Icons.arrow_circle_up_rounded, size: 18),
                  label: Text(JobsStrings.markAs(_lang, next)),
                ),
              TextButton.icon(
                onPressed: () => _showLinkDialog(app),
                icon: const Icon(Icons.link_rounded, size: 18),
                label: Text(JobsStrings.linkDocuments(_lang)),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: _muted, size: 22),
                tooltip: JobsStrings.delete(_lang),
                onPressed: () => _delete(app),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
