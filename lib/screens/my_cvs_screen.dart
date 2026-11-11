import 'package:flutter/material.dart';

import '../data/karyab_data.dart';
import '../data/repositories.dart';
import '../models/user_profile.dart';
import '../services/cv_completion.dart';
import '../ui/karyab_ui.dart';
import '../utils/navigation_helpers.dart';
import 'ausbildung_cv_questionnaire_screen.dart';
import 'ausbildung_document_preview_screen.dart';
import 'choose_cv_type_screen.dart';
import 'cv_preview_screen.dart';
import 'questionnaire_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// My CVs library (Phase 3, item 1): every saved cv_documents row (Job and
// Ausbildung) with name, kind and last-change date. Open = preview of
// that document, Edit = its wizard (unfinished drafts resume at their
// saved step and show a completion %), plus duplicate / rename / delete
// and create-new. The shared profile stays the working copy (Phase 2
// design): previews render the live profile map, the row carries the
// per-document template, design and wizard progress.
// ─────────────────────────────────────────────────────────────────────────────

class MyCvsScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  const MyCvsScreen({
    super.key,
    required this.language,
    this.voiceMode = false,
  });

  @override
  State<MyCvsScreen> createState() => _MyCvsScreenState();
}

class _MyCvsScreenState extends State<MyCvsScreen> {
  List<CvDocumentRecord> _docs = const [];
  bool _loading = true;

  String get _lang => widget.language;
  bool get _isRtl => _lang == 'ps' || _lang == 'fa' || _lang == 'ar' || _lang == 'ur';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final docs = await KaryabData.documents?.listCvDocuments() ??
          const <CvDocumentRecord>[];
      if (mounted) {
        setState(() {
          _docs = docs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String t(String key) {
    switch (key) {
      case 'title':
        switch (_lang) {
          case 'ps':
            return 'زما CV';
          case 'fa':
            return 'رزومه‌های من';
          case 'ar':
            return 'سيرتي الذاتية';
          case 'ur':
            return 'میرے CV';
          default:
            return 'My CVs';
        }
      case 'jobCv':
        switch (_lang) {
          case 'ps':
            return 'د دندې CV';
          case 'fa':
            return 'رزومه شغلی';
          case 'ar':
            return 'سيرة ذاتية للعمل';
          case 'ur':
            return 'نوکری کا CV';
          default:
            return 'Job CV';
        }
      case 'ausbildungCv':
        switch (_lang) {
          case 'ps':
            return 'د زده کړې CV';
          case 'fa':
            return 'رزومه کارآموزی';
          case 'ar':
            return 'سيرة ذاتية Ausbildung';
          case 'ur':
            return 'Ausbildung CV';
          default:
            return 'Ausbildung CV';
        }
      case 'updated':
        switch (_lang) {
          case 'ps':
            return 'وروستی بدلون';
          case 'fa':
            return 'آخرین تغییر';
          case 'ar':
            return 'آخر تحديث';
          case 'ur':
            return 'آخری تبدیلی';
          default:
            return 'Updated';
        }
      case 'inProgress':
        switch (_lang) {
          case 'ps':
            return 'لا بشپړ نه دی';
          case 'fa':
            return 'هنوز تمام نشده';
          case 'ar':
            return 'لم ينته بعد';
          case 'ur':
            return 'ابھی مکمل نہیں ہوا';
          default:
            return 'Not finished yet';
        }
      case 'edit':
        switch (_lang) {
          case 'ps':
            return 'سمول';
          case 'fa':
            return 'ویرایش';
          case 'ar':
            return 'تعديل';
          case 'ur':
            return 'ترمیم';
          default:
            return 'Edit';
        }
      case 'preview':
        switch (_lang) {
          case 'ps':
            return 'کتل';
          case 'fa':
            return 'مشاهده';
          case 'ar':
            return 'عرض';
          case 'ur':
            return 'دیکھیں';
          default:
            return 'View';
        }
      case 'duplicate':
        switch (_lang) {
          case 'ps':
            return 'کاپي جوړول';
          case 'fa':
            return 'کپی گرفتن';
          case 'ar':
            return 'عمل نسخة';
          case 'ur':
            return 'نقل بنائیں';
          default:
            return 'Make a copy';
        }
      case 'rename':
        switch (_lang) {
          case 'ps':
            return 'نوم بدلول';
          case 'fa':
            return 'تغییر نام';
          case 'ar':
            return 'تغيير الاسم';
          case 'ur':
            return 'نام بدلیں';
          default:
            return 'Rename';
        }
      case 'delete':
        switch (_lang) {
          case 'ps':
            return 'ړنګول';
          case 'fa':
            return 'حذف';
          case 'ar':
            return 'حذف';
          case 'ur':
            return 'حذف کریں';
          default:
            return 'Delete';
        }
      case 'deleteConfirm':
        switch (_lang) {
          case 'ps':
            return 'دا CV ړنګ شي؟ دا کړنه بیرته نه راګرځي.';
          case 'fa':
            return 'این رزومه حذف شود؟ این کار قابل بازگشت نیست.';
          case 'ar':
            return 'هل تريد حذف هذه السيرة الذاتية؟ لا يمكن التراجع عن هذا.';
          case 'ur':
            return 'یہ CV حذف کر دیں؟ یہ عمل واپس نہیں ہو سکتا۔';
          default:
            return 'Delete this CV? This cannot be undone.';
        }
      case 'cancel':
        switch (_lang) {
          case 'ps':
            return 'لغوه';
          case 'fa':
            return 'لغو';
          case 'ar':
            return 'إلغاء';
          case 'ur':
            return 'منسوخ کریں';
          default:
            return 'Cancel';
        }
      case 'save':
        switch (_lang) {
          case 'ps':
            return 'خوندي کول';
          case 'fa':
            return 'ذخیره';
          case 'ar':
            return 'حفظ';
          case 'ur':
            return 'محفوظ کریں';
          default:
            return 'Save';
        }
      case 'newCv':
        switch (_lang) {
          case 'ps':
            return 'نوی CV';
          case 'fa':
            return 'رزومه جدید';
          case 'ar':
            return 'سيرة ذاتية جديدة';
          case 'ur':
            return 'نیا CV';
          default:
            return 'New CV';
        }
      case 'empty':
        switch (_lang) {
          case 'ps':
            return 'تر اوسه CV نشته. لومړی CV جوړ کړئ.';
          case 'fa':
            return 'هنوز رزومه‌ای نیست. اولین رزومه خود را بسازید.';
          case 'ar':
            return 'لا توجد سيرة ذاتية بعد. اصنع أول سيرة ذاتية لك.';
          case 'ur':
            return 'ابھی کوئی CV نہیں ہے۔ اپنا پہلا CV بنائیں۔';
          default:
            return 'No CVs yet. Create your first CV.';
        }
      case 'whichKind':
        switch (_lang) {
          case 'ps':
            return 'کوم CV جوړوئ؟';
          case 'fa':
            return 'کدام رزومه را می‌سازید؟';
          case 'ar':
            return 'أي سيرة ذاتية تريد أن تصنع؟';
          case 'ur':
            return 'آپ کون سا CV بنانا چاہتے ہیں؟';
          default:
            return 'Which CV do you want to create?';
        }
      case 'copySuffix':
        switch (_lang) {
          case 'ps':
            return ' کاپي';
          case 'fa':
            return ' کپی';
          case 'ar':
            return ' نسخة';
          case 'ur':
            return ' نقل';
          default:
            return ' copy';
        }
      default:
        return key;
    }
  }

  String _kindLabel(String kind) =>
      kind == 'ausbildung' ? t('ausbildungCv') : t('jobCv');

  String _dateText(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  Future<UserProfile> _currentProfile() async {
    final map = await KaryabData.profile.loadProfileMap();
    return UserProfile.fromMap(map ?? const <String, dynamic>{});
  }

  Future<void> _openPreview(CvDocumentRecord rec) async {
    final profile = await _currentProfile();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => rec.kind == 'ausbildung'
            ? AusbildungDocumentPreviewScreen(
                profile: profile,
                language: _lang,
                documentId: rec.id,
              )
            : CvPreviewScreen(profile: profile, documentId: rec.id),
      ),
    );
    _reload();
  }

  Future<void> _openEdit(CvDocumentRecord rec) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => rec.kind == 'ausbildung'
            ? AusbildungCvQuestionnaireScreen(
                language: _lang,
                voiceMode: widget.voiceMode,
                isEditMode: true,
                documentId: rec.id,
              )
            : QuestionnaireScreen(
                language: _lang,
                voiceMode: widget.voiceMode,
                isEditMode: true,
                documentId: rec.id,
              ),
      ),
    );
    _reload();
  }

  Future<void> _duplicate(CvDocumentRecord rec) async {
    try {
      await KaryabData.documents?.createCvDocument(
        kind: rec.kind,
        name: '${rec.name}${t('copySuffix')}',
        payload: rec.payload,
        templateId: rec.templateId,
        accentColor: rec.accentColor,
        fontSize: rec.fontSize,
        spacing: rec.spacing,
        showPhoto: rec.showPhoto,
      );
    } catch (_) {}
    _reload();
  }

  Future<void> _rename(CvDocumentRecord rec) async {
    final controller = TextEditingController(text: rec.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('rename')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(t('save')),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == rec.name) return;
    try {
      await KaryabData.documents?.updateCvDocument(rec.id, name: newName);
    } catch (_) {}
    _reload();
  }

  Future<void> _delete(CvDocumentRecord rec) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete')),
        content: Text(t('deleteConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t('delete'),
              style: const TextStyle(color: Color(0xFFC0392B)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await KaryabData.documents?.deleteCvDocument(rec.id);
    } catch (_) {}
    _reload();
  }

  Future<void> _createNew() async {
    final kind = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('whichKind')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.work_rounded, color: KColors.green),
              title: Text(t('jobCv')),
              onTap: () => Navigator.pop(ctx, 'job'),
            ),
            ListTile(
              leading: const Icon(Icons.school_rounded, color: KColors.green),
              title: Text(t('ausbildungCv')),
              onTap: () => Navigator.pop(ctx, 'ausbildung'),
            ),
          ],
        ),
      ),
    );
    if (kind == null || !mounted) return;
    // With personal data on file, create the document right away (seeded
    // from the shared profile) and open its wizard. Without it, use the
    // standard choose-type route, which collects personal data first.
    final map = await KaryabData.profile.loadProfileMap();
    final hasPersonal =
        (map?['firstName']?.toString().trim().isNotEmpty ?? false);
    if (!hasPersonal) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChooseCvTypeScreen(
            language: _lang,
            voiceMode: widget.voiceMode,
          ),
        ),
      );
      _reload();
      return;
    }
    int? id;
    try {
      id = await KaryabData.documents?.createCvDocument(
        kind: kind,
        name: _kindLabel(kind),
        payload: Map<String, dynamic>.from(map ?? const {}),
      );
    } catch (_) {}
    if (!mounted) return;
    if (id == null) {
      _reload();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => kind == 'ausbildung'
            ? AusbildungCvQuestionnaireScreen(
                language: _lang,
                voiceMode: widget.voiceMode,
                isEditMode: true,
                documentId: id,
              )
            : QuestionnaireScreen(
                language: _lang,
                voiceMode: widget.voiceMode,
                isEditMode: true,
                documentId: id,
              ),
      ),
    );
    _reload();
  }

  void _goHome() {
    goHomeToIntroduction(context,
        language: _lang, voiceMode: widget.voiceMode);
  }

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
                            t('title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: KColors.navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        KNavButton(icon: Icons.home_rounded, onTap: _goHome),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: KColors.green),
                          )
                        : _docs.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    t('empty'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: KColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 10, 16, 16),
                                itemCount: _docs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) => _docCard(_docs[i]),
                              ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: KPrimaryCta(
                      icon: Icons.add_rounded,
                      label: t('newCv'),
                      isRtl: _isRtl,
                      isSelected: false,
                      onTap: _createNew,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docCard(CvDocumentRecord rec) {
    final finished = cvDocumentFinished(rec.payload);
    final percent = cvCompletionPercent(rec.payload, rec.kind);
    return KGlassSurface(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: KColors.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  rec.kind == 'ausbildung'
                      ? Icons.school_rounded
                      : Icons.work_rounded,
                  color: KColors.greenDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.name,
                      style: const TextStyle(
                        color: KColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_kindLabel(rec.kind)} · ${t('updated')} ${_dateText(rec.updatedAt)}',
                      style: const TextStyle(
                        color: KColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!finished) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC77B1E)
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$percent% · ${t('inProgress')}',
                              style: const TextStyle(
                                color: Color(0xFF9A5F14),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: KColors.textSecondary),
                onSelected: (v) {
                  switch (v) {
                    case 'duplicate':
                      _duplicate(rec);
                      break;
                    case 'rename':
                      _rename(rec);
                      break;
                    case 'delete':
                      _delete(rec);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'duplicate', child: Text(t('duplicate'))),
                  PopupMenuItem(value: 'rename', child: Text(t('rename'))),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      t('delete'),
                      style: const TextStyle(color: Color(0xFFC0392B)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: KGlassCard(
                  borderRadius: 14,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  onTap: () => _openEdit(rec),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit_rounded,
                          color: KColors.greenDark, size: 17),
                      const SizedBox(width: 7),
                      Text(
                        t('edit'),
                        style: const TextStyle(
                          color: KColors.greenDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KPrimaryCta(
                  icon: Icons.visibility_rounded,
                  label: t('preview'),
                  isRtl: _isRtl,
                  isSelected: false,
                  onTap: () => _openPreview(rec),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
