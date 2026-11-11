import 'package:flutter/material.dart';

import '../data/karyab_data.dart';
import '../data/repositories.dart';
import '../services/letter_model.dart';
import '../ui/karyab_ui.dart';
import '../utils/navigation_helpers.dart';
import 'letter_editor_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// My Letters library (Phase 4, item 1): every saved letter_documents row
// with company, job title and last-change date. v2 letters open in the
// block editor; the seeded v1 letter (payload has no v2 blocks) surfaces
// as a legacy entry that can be deleted or replaced by a fresh letter.
// Duplicate follows the blueprint rule: block texts are kept, company,
// job title, reference and date are reset for the new job.
// ─────────────────────────────────────────────────────────────────────────────

class MyLettersScreen extends StatefulWidget {
  final String language;
  final bool voiceMode;

  const MyLettersScreen({
    super.key,
    required this.language,
    this.voiceMode = false,
  });

  @override
  State<MyLettersScreen> createState() => _MyLettersScreenState();
}

class _MyLettersScreenState extends State<MyLettersScreen> {
  List<LetterDocumentRecord> _docs = const [];
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
      final docs =
          await KaryabData.documents?.listLetterDocuments() ??
          const <LetterDocumentRecord>[];
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
            return 'زما لیکونه';
          case 'fa':
            return 'نامه‌های من';
          case 'ar':
            return 'رسائلي';
          case 'ur':
            return 'میرے خطوط';
          default:
            return 'My Letters';
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
      case 'open':
        switch (_lang) {
          case 'ps':
            return 'پرانیستل';
          case 'fa':
            return 'باز کردن';
          case 'ar':
            return 'فتح';
          case 'ur':
            return 'کھولیں';
          default:
            return 'Open';
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
            return 'دا لیک ړنګ شي؟ دا کړنه بیرته نه راګرځي.';
          case 'fa':
            return 'این نامه حذف شود؟ این کار قابل بازگشت نیست.';
          case 'ar':
            return 'هل تريد حذف هذه الرسالة؟ لا يمكن التراجع عن هذا.';
          case 'ur':
            return 'یہ خط حذف کر دیں؟ یہ عمل واپس نہیں ہو سکتا۔';
          default:
            return 'Delete this letter? This cannot be undone.';
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
      case 'newLetter':
        switch (_lang) {
          case 'ps':
            return 'نوی لیک';
          case 'fa':
            return 'نامه جدید';
          case 'ar':
            return 'رسالة جديدة';
          case 'ur':
            return 'نیا خط';
          default:
            return 'New letter';
        }
      case 'empty':
        switch (_lang) {
          case 'ps':
            return 'تر اوسه لیک نشته. لومړی پوښتنلیک مو جوړ کړئ.';
          case 'fa':
            return 'هنوز نامه‌ای نیست. اولین نامه پوششی خود را بسازید.';
          case 'ar':
            return 'لا توجد رسالة بعد. اصنع أول رسالة لك.';
          case 'ur':
            return 'ابھی کوئی خط نہیں ہے۔ اپنا پہلا کور لیٹر بنائیں۔';
          default:
            return 'No letters yet. Create your first cover letter.';
        }
      case 'legacyBadge':
        switch (_lang) {
          case 'ps':
            return 'زاړه بڼه';
          case 'fa':
            return 'نسخه قدیمی';
          case 'ar':
            return 'نسخة قديمة';
          case 'ur':
            return 'پرانا ورژن';
          default:
            return 'Old version';
        }
      case 'legacyNote':
        switch (_lang) {
          case 'ps':
            return 'دا لیک په زاړه بڼه کې جوړ شوی و. متن یې دلته نه پرانیستل کېږي.';
          case 'fa':
            return 'این نامه در نسخه قدیمی ساخته شده بود. متن آن اینجا باز نمی‌شود.';
          case 'ar':
            return 'تم صنع هذه الرسالة في النسخة القديمة. لا يمكن فتح نصها هنا.';
          case 'ur':
            return 'یہ خط پرانے ورژن میں بنایا گیا تھا۔ اس کا متن یہاں نہیں کھل سکتا۔';
          default:
            return 'This letter was created in the old version. Its text cannot be opened here.';
        }
      case 'createNewInstead':
        switch (_lang) {
          case 'ps':
            return 'پر ځای یې نوی لیک جوړ کړئ';
          case 'fa':
            return 'به جای آن نامه جدید بسازید';
          case 'ar':
            return 'اصنع رسالة جديدة بدلا منها';
          case 'ur':
            return 'اس کی جگہ نیا خط بنائیں';
          default:
            return 'Create a new letter instead';
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
      case 'noCompany':
        switch (_lang) {
          case 'ps':
            return 'تر اوسه شرکت نشته';
          case 'fa':
            return 'هنوز شرکتی نیست';
          case 'ar':
            return 'لا توجد شركة بعد';
          case 'ur':
            return 'ابھی کوئی کمپنی نہیں';
          default:
            return 'No company yet';
        }
      default:
        return key;
    }
  }

  String _dateText(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  bool _isV2(LetterDocumentRecord rec) =>
      LetterData.fromPayload(rec.payload) != null;

  Future<void> _open(LetterDocumentRecord rec) async {
    if (!_isV2(rec)) {
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
              t('legacyBadge'),
              style: const TextStyle(
                color: KColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              t('legacyNote'),
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
                  t('cancel'),
                  style: const TextStyle(
                    color: KColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _createNew();
                },
                child: Text(
                  t('createNewInstead'),
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
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LetterEditorScreen(
          language: _lang,
          voiceMode: widget.voiceMode,
          recordId: rec.id,
        ),
      ),
    );
    _reload();
  }

  Future<void> _createNew() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LetterEditorScreen(language: _lang, voiceMode: widget.voiceMode),
      ),
    );
    _reload();
  }

  Future<void> _duplicate(LetterDocumentRecord rec) async {
    final repo = KaryabData.documents;
    if (repo == null) return;
    if (_isV2(rec)) {
      // Blueprint duplicate: texts kept, company/title/reference/date reset.
      final payload = letterPayloadForNewJob(rec.payload);
      final data = LetterData.fromPayload(payload);
      await repo.createLetterDocument(
        name: '${rec.name}${t('copySuffix')}',
        payload: payload,
        company: data?.companyName,
        jobTitle: data?.jobTitle,
      );
    } else {
      // A legacy letter has no reusable blocks; its copy is a fresh letter.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              LetterEditorScreen(language: _lang, voiceMode: widget.voiceMode),
        ),
      );
    }
    _reload();
  }

  Future<void> _rename(LetterDocumentRecord rec) async {
    final ctrl = TextEditingController(text: rec.name);
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
            t('rename'),
            style: const TextStyle(
              color: KColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: ctrl,
            autofocus: true,
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
    final name = ctrl.text.trim();
    ctrl.dispose();
    if (ok != true || name.isEmpty) return;
    await KaryabData.documents?.updateLetterDocument(rec.id, name: name);
    _reload();
  }

  Future<void> _delete(LetterDocumentRecord rec) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Text(
            t('deleteConfirm'),
            style: const TextStyle(
              color: KColors.navy,
              fontSize: 13,
              height: 1.4,
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
                t('delete'),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await KaryabData.documents?.deleteLetterDocument(rec.id);
    _reload();
  }

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
                        ? const Center(child: CircularProgressIndicator())
                        : _docs.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                t('empty'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: KColors.navy,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _docs.length,
                            itemBuilder: (_, i) => _docCard(_docs[i]),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: KPrimaryCta(
                      icon: Icons.add_rounded,
                      label: t('newLetter'),
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

  Widget _docCard(LetterDocumentRecord rec) {
    final v2 = _isV2(rec);
    final company = (rec.company ?? '').trim();
    final job = (rec.jobTitle ?? '').trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: KGlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rec.name,
                    style: const TextStyle(
                      color: KColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!v2)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t('legacyBadge'),
                      style: const TextStyle(
                        color: KColors.navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: KColors.navy),
                  onSelected: (v) {
                    if (v == 'duplicate') _duplicate(rec);
                    if (v == 'rename') _rename(rec);
                    if (v == 'delete') _delete(rec);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Text(t('duplicate')),
                    ),
                    PopupMenuItem(value: 'rename', child: Text(t('rename'))),
                    PopupMenuItem(value: 'delete', child: Text(t('delete'))),
                  ],
                ),
              ],
            ),
            if (company.isNotEmpty || job.isNotEmpty)
              Text(
                [job, company].where((s) => s.isNotEmpty).join(' · '),
                style: const TextStyle(color: KColors.navy, fontSize: 13),
              )
            else
              Text(
                t('noCompany'),
                style: const TextStyle(color: KColors.navy, fontSize: 13),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${t('updated')}: ${_dateText(rec.updatedAt)}',
                    style: TextStyle(
                      color: KColors.navy.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _open(rec),
                  icon: const Icon(Icons.mail_outline_rounded, size: 18),
                  label: Text(t('open')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
