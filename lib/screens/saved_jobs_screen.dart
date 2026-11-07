import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/karyab_data.dart';
import '../data/repositories.dart';
import '../services/job_search_service.dart';
import '../services/jobs_strings.dart';
import '../ui/karyab_ui.dart';
import 'job_posting_navigation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SavedJobsScreen - Phase 7. Two tabs: saved postings (bookmark list,
// tap opens the posting) and saved searches. When the searches tab is
// shown, each search's head (first page) is re-run ONCE, lazily, and a
// glass "n new" badge shows how many results are newer than the top
// result at the last viewing. Nothing runs in the background.
// ─────────────────────────────────────────────────────────────────────────────

class SavedJobsScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  const SavedJobsScreen({
    super.key,
    required this.language,
    this.voiceMode = false,
  });

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  static const Color _navy = KColors.navy;
  static const Color _green = KColors.green;
  static const Color _muted = KColors.textSecondary;

  String get _lang => widget.language;
  bool get _isRtl => _lang == 'ps' || _lang == 'fa';

  int _tab = 0;
  List<SavedJobRecord>? _jobs;
  List<SavedSearchRecord>? _searches;
  final Map<int, int> _newCounts = {};
  bool _checkedNew = false;

  final JobSearchService _service = JobSearchService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = KaryabData.jobs;
    if (repo == null) {
      setState(() {
        _jobs = const [];
        _searches = const [];
      });
      return;
    }
    final jobs = await repo.listSavedJobs();
    final searches = await repo.listSavedSearches();
    if (!mounted) return;
    setState(() {
      _jobs = jobs;
      _searches = searches;
    });
    _checkNewCounts();
  }

  /// Lazy "new since last visit" check: one head request per saved
  /// search, only when this screen opens. Failures simply show no
  /// badge (the search itself may still work when opened).
  Future<void> _checkNewCounts() async {
    if (_checkedNew) return;
    _checkedNew = true;
    final searches = _searches ?? const [];
    for (final s in searches) {
      try {
        final results = await _service.runQuery(s.query);
        final count = JobSearchService.countNewJobs(
          results.map((j) => j.refnr).toList(),
          s.lastTopRefnr,
        );
        if (mounted && count > 0) {
          setState(() => _newCounts[s.id] = count);
        }
      } catch (_) {
        // Offline or API error: no badge for this search.
      }
    }
  }

  Future<void> _unsave(SavedJobRecord job) async {
    final repo = KaryabData.jobs;
    if (repo == null) return;
    await repo.unsaveJob(job.refnr);
    if (!mounted) return;
    setState(() {
      _jobs = (_jobs ?? []).where((j) => j.refnr != job.refnr).toList();
    });
  }

  Future<void> _deleteSearch(SavedSearchRecord search) async {
    final repo = KaryabData.jobs;
    if (repo == null) return;
    await repo.deleteSavedSearch(search.id);
    if (!mounted) return;
    setState(() {
      _searches =
          (_searches ?? []).where((s) => s.id != search.id).toList();
      _newCounts.remove(search.id);
    });
  }

  Future<void> _openSearch(SavedSearchRecord search) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedSearchResultsScreen(
          language: _lang,
          voiceMode: widget.voiceMode,
          query: search.query,
          label: search.label,
          searchId: search.id,
        ),
      ),
    );
    // Viewing updated last_top_refnr inside the results screen; the
    // badge for this search is spent.
    if (mounted) {
      setState(() => _newCounts.remove(search.id));
      _load();
    }
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
                  _buildHeader(),
                  const SizedBox(height: 6),
                  _buildTabs(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _tab == 0 ? _buildJobsTab() : _buildSearchesTab(),
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
        textDirection: TextDirection.ltr,
        children: [
          KNavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              JobsStrings.savedJobs(_lang),
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

  Widget _buildTabs() {
    Widget chip(int index, IconData icon, String label) {
      final selected = _tab == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? _navy : Colors.white.withValues(alpha: KColors.glassFillAlpha),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? _navy : KColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 17, color: selected ? Colors.white : _muted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : _navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          chip(0, Icons.bookmark_rounded, JobsStrings.savedJobs(_lang)),
          const SizedBox(width: 10),
          chip(1, Icons.search_rounded, JobsStrings.savedSearches(_lang)),
        ],
      ),
    );
  }

  Widget _buildJobsTab() {
    final jobs = _jobs;
    if (jobs == null) return const Center(child: CircularProgressIndicator());
    if (jobs.isEmpty) {
      return _emptyState(JobsStrings.emptySavedJobs(_lang));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: jobs.length,
      itemBuilder: (_, i) {
        final job = jobs[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: KGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            onTap: () => openJobPosting(
              context,
              BaJob.fromJson(job.payload),
              language: _lang,
              voiceMode: widget.voiceMode,
              isAusbildung: job.source == 'ausbildung',
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: KColors.mint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _green.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Icon(
                    job.source == 'ausbildung'
                        ? Icons.school_rounded
                        : Icons.work_rounded,
                    color: _green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: _muted, fontSize: 13, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.location,
                        style: const TextStyle(color: _muted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove_outlined,
                      color: _muted, size: 22),
                  tooltip: JobsStrings.remove(_lang),
                  onPressed: () => _unsave(job),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchesTab() {
    final searches = _searches;
    if (searches == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (searches.isEmpty) {
      return _emptyState(JobsStrings.emptySavedSearches(_lang));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: searches.length,
      itemBuilder: (_, i) {
        final search = searches[i];
        final newCount = _newCounts[search.id] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: KGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            onTap: () => _openSearch(search),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: KColors.mint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _green.withValues(alpha: 0.3), width: 1),
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: _green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        search.label,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (search.lastRunAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          JobsStrings.cacheTime(search.lastRunAt!),
                          style:
                              const TextStyle(color: _muted, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                if (newCount > 0) ...[
                  // Glass "new" badge (solid translucent panel with a
                  // border, no BackdropFilter inside a list).
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: _green.withValues(alpha: 0.55), width: 1),
                    ),
                    child: Text(
                      JobsStrings.newCount(_lang, newCount),
                      style: const TextStyle(
                        color: Color(0xFF1B7A12),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: _muted, size: 22),
                  tooltip: JobsStrings.delete(_lang),
                  onPressed: () => _deleteSearch(search),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: KGlassSurface(
          borderRadius: 20,
          padding: const EdgeInsets.all(28),
          child: Text(
            message,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// SavedSearchResultsScreen - runs one saved JobQuery and lists the
// results; a successful load marks the search as viewed (the baseline
// for the next "new" count). Falls back to the offline cache on
// transport failures, like the finder lists.
// ─────────────────────────────────────────────────────────────────────────────

class SavedSearchResultsScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;
  final JobQuery query;
  final String label;
  final int? searchId;

  const SavedSearchResultsScreen({
    super.key,
    required this.language,
    required this.query,
    required this.label,
    this.voiceMode = false,
    this.searchId,
  });

  @override
  State<SavedSearchResultsScreen> createState() =>
      _SavedSearchResultsScreenState();
}

class _SavedSearchResultsScreenState extends State<SavedSearchResultsScreen> {
  static const Color _navy = KColors.navy;
  static const Color _green = KColors.green;
  static const Color _muted = KColors.textSecondary;

  String get _lang => widget.language;
  bool get _isRtl => _lang == 'ps' || _lang == 'fa';

  final JobSearchService _service = JobSearchService();
  late Future<_ResultsState> _future;
  Set<String> _savedRefnrs = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final repo = KaryabData.jobs;
    if (repo == null) return;
    final saved = await repo.savedRefnrs();
    if (mounted) setState(() => _savedRefnrs = saved);
  }

  Future<_ResultsState> _load() async {
    final repo = KaryabData.jobs;
    try {
      final results = await _service.runQuery(widget.query);
      if (repo != null) {
        unawaited(repo.putCache(
          JobsRepository.searchCacheKey(widget.query.cacheKey),
          jsonEncode(results.map((j) => j.raw).toList()),
        ));
        final searchId = widget.searchId;
        if (searchId != null) {
          await repo.markSearchViewed(
            searchId,
            topRefnr: results.isEmpty ? null : results.first.refnr,
          );
        }
      }
      return _ResultsState(results);
    } on BaJobsException catch (e) {
      final cached = repo == null
          ? null
          : await repo
              .getCache(JobsRepository.searchCacheKey(widget.query.cacheKey));
      if (cached != null &&
          JobSearchService.shouldUseCachedResults(e.kind, true)) {
        try {
          final rawList = jsonDecode(cached.payload) as List<dynamic>;
          return _ResultsState(
            rawList
                .map((j) => BaJob.fromJson(j as Map<String, dynamic>))
                .toList(),
            cachedAt: cached.fetchedAt,
          );
        } catch (_) {
          // Fall through to the error state.
        }
      }
      return const _ResultsState([], failed: true);
    }
  }

  Future<void> _toggleSave(BaJob job) async {
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
        source: widget.query.mode,
        payload: job.raw,
      );
    }
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
                            widget.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FutureBuilder<_ResultsState>(
                      future: _future,
                      builder: (_, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final state = snap.data ??
                            const _ResultsState([], failed: true);
                        if (state.failed) return _buildError();
                        if (state.jobs.isEmpty) {
                          return _buildError(empty: true);
                        }
                        return _buildList(state);
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

  Widget _buildError({bool empty = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: KGlassSurface(
          borderRadius: 20,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                empty
                    ? JobsStrings.emptySavedSearches(_lang)
                    : JobsStrings.searchError(_lang),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => setState(() => _future = _load()),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(JobsStrings.retry(_lang)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(_ResultsState state) {
    final jobs = state.jobs;
    final hasBanner = state.cachedAt != null;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: jobs.length + (hasBanner ? 1 : 0),
      itemBuilder: (_, i) {
        var idx = i;
        if (hasBanner) {
          if (idx == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF2C078)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 18, color: Color(0xFFB26A00)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        JobsStrings.offlineBanner(
                            _lang, JobsStrings.cacheTime(state.cachedAt!)),
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
        final job = jobs[idx];
        final saved = _savedRefnrs.contains(job.refnr);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: KGlassCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            onTap: () => openJobPosting(
              context,
              job,
              language: _lang,
              voiceMode: widget.voiceMode,
              isAusbildung: widget.query.mode == 'ausbildung',
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: KColors.mint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _green.withValues(alpha: 0.3), width: 1),
                  ),
                  child: const Icon(Icons.work_rounded,
                      color: _green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: _muted, fontSize: 13, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.locationDisplay,
                        style: const TextStyle(color: _muted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: saved ? _green : _muted,
                    size: 22,
                  ),
                  tooltip: JobsStrings.saveJob(_lang),
                  onPressed: () => _toggleSave(job),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultsState {
  final List<BaJob> jobs;
  final DateTime? cachedAt;
  final bool failed;
  const _ResultsState(this.jobs, {this.cachedAt, this.failed = false});
}
