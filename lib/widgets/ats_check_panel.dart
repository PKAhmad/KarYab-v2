import 'package:flutter/material.dart';

import '../services/ats_checker.dart';
import '../ui/karyab_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ATS check panel for the preview screens (Phase 3). Collapsed it shows a
// single "Check my CV" row; the host computes the items on first expand
// and passes them in. Tapping an item with a known section asks the host
// to jump to the fix (wizard step or personal data). The check is advice
// only - it never blocks download or sharing.
// ─────────────────────────────────────────────────────────────────────────────

String atsText(String lang, String key, {String detail = ''}) {
  switch (key) {
    case 'title':
      switch (lang) {
        case 'ps':
          return 'CV وګورئ';
        case 'fa':
          return 'بررسی رزومه';
        case 'ar':
          return 'فحص السيرة الذاتية';
        case 'ur':
          return 'میرا CV چیک کریں';
        default:
          return 'Check my CV';
      }
    case 'subtitle':
      switch (lang) {
        case 'ps':
          return 'ایا ستاسو CV د کار ورکوونکو او پروګرامونو لپاره چمتو دی؟';
        case 'fa':
          return 'آیا رزومه شما برای کارفرمایان و برنامه‌ها آماده است؟';
        case 'ar':
          return 'هل سيرتك الذاتية جاهزة لأصحاب العمل وبرامج التقديم؟';
        case 'ur':
          return 'کیا آپ کا CV نوکری دینے والوں اور درخواست کے پروگراموں کے لیے تیار ہے؟';
        default:
          return 'Is your CV ready for employers and application software?';
      }
    case 'pagesOk':
      switch (lang) {
        case 'ps':
          return 'ستاسو CV $detail مخونه لري. دا ښه ده.';
        case 'fa':
          return 'رزومه شما $detail صفحه دارد. این خوب است.';
        case 'ar':
          return 'عدد صفحات سيرتك الذاتية $detail. هذا جيد.';
        case 'ur':
          return 'آپ کے CV میں $detail صفحات ہیں۔ یہ اچھا ہے۔';
        default:
          return 'Your CV has $detail page(s). That is a good length.';
      }
    case 'pagesWarn':
      switch (lang) {
        case 'ps':
          return 'ستاسو CV $detail مخونه لري. په جرمني کې CV معمولا ۱ تر ۲ مخونه وي.';
        case 'fa':
          return 'رزومه شما $detail صفحه دارد. در آلمان رزومه معمولاً ۱ تا ۲ صفحه است.';
        case 'ar':
          return 'عدد صفحات سيرتك الذاتية $detail. في ألمانيا تكون السيرة الذاتية عادة من 1 إلى 2 صفحة.';
        case 'ur':
          return 'آپ کے CV میں $detail صفحات ہیں۔ جرمنی میں CV عام طور پر 1 سے 2 صفحات کا ہوتا ہے۔';
        default:
          return 'Your CV has $detail pages. In Germany a CV is usually 1 to 2 pages.';
      }
    case 'templateAts':
      switch (lang) {
        case 'ps':
          return 'دا کینډۍ د غوښتنلیک پروګرامونو (ATS) لپاره ښه ده: ساده بڼه، بې انځوره.';
        case 'fa':
          return 'این قالب برای برنامه‌های درخواست (ATS) خوب است: ساده و بدون عکس.';
        case 'ar':
          return 'هذا القالب جيد لبرامج التقديم (ATS): شكله بسيط وبدون صورة.';
        case 'ur':
          return 'یہ سانچہ درخواست کے پروگراموں (ATS) کے لیے اچھا ہے: سادہ شکل اور تصویر کے بغیر۔';
        default:
          return 'This template is good for application software (ATS): simple layout, no photo.';
      }
    case 'templateLayoutPhoto':
      switch (lang) {
        case 'ps':
          return 'د انځور لرونکې کینډۍ ځینې پروګرامونه (ATS) ګډوډولی شي. د انلاین غوښتنلیک لپاره ATS Blue خوندي ده.';
        case 'fa':
          return 'قالب عکس‌دار ممکن است برخی برنامه‌ها (ATS) را گیج کند. برای درخواست آنلاین ATS Blue امن‌تر است.';
        case 'ar':
          return 'القالب الذي فيه صورة قد يربك بعض البرامج (ATS). قالب ATS Blue أكثر أمانا عند التقديم عبر الإنترنت.';
        case 'ur':
          return 'تصویر والا سانچہ بعض پروگراموں (ATS) کو الجھا سکتا ہے۔ آن لائن درخواست کے لیے ATS Blue زیادہ محفوظ ہے۔';
        default:
          return 'Templates with a photo and sidebar can confuse application software (ATS). ATS Blue is safer for online applications.';
      }
    case 'templateLayout':
      switch (lang) {
        case 'ps':
          return 'دا کینډۍ بې انځوره ده. د انلاین پورټلونو لپاره ATS Blue تر ټولو خوندي انتخاب دی.';
        case 'fa':
          return 'این قالب بدون عکس است. برای پورتال‌های آنلاین ATS Blue امن‌ترین انتخاب است.';
        case 'ar':
          return 'هذا القالب بدون صورة. للبوابات عبر الإنترنت، قالب ATS Blue هو الخيار الأكثر أمانا.';
        case 'ur':
          return 'اس سانچے میں تصویر نہیں ہے۔ آن لائن پورٹلز کے لیے ATS Blue سب سے محفوظ انتخاب ہے۔';
        default:
          return 'This template has no photo. For online portals, ATS Blue is the safest choice.';
      }
    case 'emailOk':
      switch (lang) {
        case 'ps':
          return 'بریښنالیک شته.';
        case 'fa':
          return 'ایمیل موجود است.';
        case 'ar':
          return 'البريد الإلكتروني موجود.';
        case 'ur':
          return 'ای میل ایڈریس موجود ہے۔';
        default:
          return 'Email address is included.';
      }
    case 'emailMissing':
      switch (lang) {
        case 'ps':
          return 'بریښنالیک نشته. کار ورکوونکی تاسو سره اړیکه نشي نیولی.';
        case 'fa':
          return 'ایمیل موجود نیست. کارفرما نمی‌تواند با شما تماس بگیرد.';
        case 'ar':
          return 'لا يوجد بريد إلكتروني. لا يستطيع صاحب العمل التواصل معك.';
        case 'ur':
          return 'ای میل ایڈریس نہیں ہے۔ نوکری دینے والا آپ سے رابطہ نہیں کر سکتا۔';
        default:
          return 'No email address. Employers cannot contact you.';
      }
    case 'phoneOk':
      switch (lang) {
        case 'ps':
          return 'د ټیلیفون شمېره شته.';
        case 'fa':
          return 'شماره تلفن موجود است.';
        case 'ar':
          return 'رقم الهاتف موجود.';
        case 'ur':
          return 'فون نمبر موجود ہے۔';
        default:
          return 'Phone number is included.';
      }
    case 'phoneMissing':
      switch (lang) {
        case 'ps':
          return 'د ټیلیفون شمېره نشته. کار ورکوونکی تاسو سره اړیکه نشي نیولی.';
        case 'fa':
          return 'شماره تلفن موجود نیست. کارفرما نمی‌تواند با شما تماس بگیرد.';
        case 'ar':
          return 'لا يوجد رقم هاتف. لا يستطيع صاحب العمل التواصل معك.';
        case 'ur':
          return 'فون نمبر نہیں ہے۔ نوکری دینے والا آپ سے رابطہ نہیں کر سکتا۔';
        default:
          return 'No phone number. Employers cannot contact you.';
      }
    case 'skillsMissing':
      switch (lang) {
        case 'ps':
          return 'تر اوسه مهارتونه نشته. ډېر کار ورکوونکي د مهارتونو په لټه کې دي.';
        case 'fa':
          return 'هنوز مهارتی اضافه نشده است. بسیاری از کارفرمایان به دنبال مهارت‌ها می‌گردند.';
        case 'ar':
          return 'لم تضف أي مهارات بعد. كثير من أصحاب العمل يبحثون عن المهارات.';
        case 'ur':
          return 'ابھی کوئی مہارت شامل نہیں کی گئی۔ بہت سے نوکری دینے والے مہارتیں تلاش کرتے ہیں۔';
        default:
          return 'No skills added yet. Many employers search by skills.';
      }
    case 'languagesOk':
      switch (lang) {
        case 'ps':
          return 'ژبې شته.';
        case 'fa':
          return 'زبان‌ها موجود است.';
        case 'ar':
          return 'اللغات موجودة.';
        case 'ur':
          return 'زبانیں موجود ہیں۔';
        default:
          return 'Languages are included.';
      }
    case 'languagesMissing':
      switch (lang) {
        case 'ps':
          return 'تر اوسه ژبې نشته.';
        case 'fa':
          return 'هنوز زبانی اضافه نشده است.';
        case 'ar':
          return 'لم تضف أي لغة بعد.';
        case 'ur':
          return 'ابھی کوئی زبان شامل نہیں کی گئی۔';
        default:
          return 'No languages added yet.';
      }
    case 'sectionOmitted':
      switch (lang) {
        case 'ps':
          return 'برخه «$detail» تشه ده او په PDF کې به نه راځي.';
        case 'fa':
          return 'بخش «$detail» خالی است و در PDF نمی‌آید.';
        case 'ar':
          return 'القسم «$detail» فارغ ولن يظهر في ملف PDF.';
        case 'ur':
          return 'حصہ «$detail» خالی ہے اور PDF میں نہیں آئے گا۔';
        default:
          return 'The section "$detail" is empty and will not appear in the PDF.';
      }
    default:
      return key;
  }
}

/// Display name for a wizard section key (for the 'sectionOmitted' item).
String atsSectionName(String lang, String section) {
  switch (section) {
    case 'education':
      switch (lang) {
        case 'ps':
          return 'زده کړې';
        case 'fa':
          return 'تحصیلات';
        case 'ar':
          return 'التعليم';
        case 'ur':
          return 'تعلیم';
        default:
          return 'Education';
      }
    case 'skills':
      switch (lang) {
        case 'ps':
          return 'مهارتونه';
        case 'fa':
          return 'مهارت‌ها';
        case 'ar':
          return 'المهارات';
        case 'ur':
          return 'مہارتیں';
        default:
          return 'Skills';
      }
    case 'experience':
      switch (lang) {
        case 'ps':
          return 'کاري تجربه';
        case 'fa':
          return 'تجربه کاری';
        case 'ar':
          return 'الخبرة العملية';
        case 'ur':
          return 'کام کا تجربہ';
        default:
          return 'Work experience';
      }
    case 'employers':
      switch (lang) {
        case 'ps':
          return 'پخواني کار ورکوونکي';
        case 'fa':
          return 'کارفرمایان قبلی';
        case 'ar':
          return 'أصحاب العمل السابقون';
        case 'ur':
          return 'پچھلے نوکری دینے والے';
        default:
          return 'Previous employers';
      }
    case 'toolsIt':
      switch (lang) {
        case 'ps':
          return 'وسایل او کمپیوټر';
        case 'fa':
          return 'ابزار و کامپیوتر';
        case 'ar':
          return 'الأدوات والحاسوب';
        case 'ur':
          return 'اوزار اور کمپیوٹر';
        default:
          return 'Tools and IT';
      }
    case 'languages':
      switch (lang) {
        case 'ps':
          return 'ژبې';
        case 'fa':
          return 'زبان‌ها';
        case 'ar':
          return 'اللغات';
        case 'ur':
          return 'زبانیں';
        default:
          return 'Languages';
      }
    case 'availability':
      switch (lang) {
        case 'ps':
          return 'چمتووالی';
        case 'fa':
          return 'آمادگی';
        case 'ar':
          return 'الجاهزية';
        case 'ur':
          return 'دستیابی';
        default:
          return 'Availability';
      }
    case 'esco':
      switch (lang) {
        case 'ps':
          return 'مهارتونه (ESCO)';
        case 'fa':
          return 'مهارت‌ها (ESCO)';
        case 'ar':
          return 'المهارات (ESCO)';
        case 'ur':
          return 'مہارتیں (ESCO)';
        default:
          return 'Skills (ESCO)';
      }
    case 'profil':
      switch (lang) {
        case 'ps':
          return 'لنډ معرفي';
        case 'fa':
          return 'معرفی کوتاه';
        case 'ar':
          return 'نبذة قصيرة';
        case 'ur':
          return 'مختصر تعارف';
        default:
          return 'Profile summary';
      }
    default:
      return section;
  }
}

String atsItemText(String lang, AtsCheckItem item) {
  switch (item.key) {
    case 'pages':
      return atsText(lang,
          item.level == AtsLevel.ok ? 'pagesOk' : 'pagesWarn',
          detail: item.detail);
    case 'templateAts':
      return atsText(lang, 'templateAts');
    case 'templateLayoutPhoto':
      return atsText(lang, 'templateLayoutPhoto');
    case 'templateLayout':
      return atsText(lang, 'templateLayout');
    case 'email':
      return atsText(
          lang, item.level == AtsLevel.problem ? 'emailMissing' : 'emailOk');
    case 'phone':
      return atsText(
          lang, item.level == AtsLevel.problem ? 'phoneMissing' : 'phoneOk');
    case 'skills':
      return atsText(lang, 'skillsMissing');
    case 'languages':
      return atsText(lang,
          item.level == AtsLevel.ok ? 'languagesOk' : 'languagesMissing');
    case 'sectionOmitted':
      return atsText(lang, 'sectionOmitted',
          detail: atsSectionName(lang, item.detail));
    default:
      return item.key;
  }
}

class AtsCheckPanel extends StatefulWidget {
  final String language;

  /// Null until the host has computed the checks (first expand).
  final List<AtsCheckItem>? items;
  final bool loading;
  final VoidCallback onExpand;
  final ValueChanged<AtsCheckItem> onTapItem;

  const AtsCheckPanel({
    super.key,
    required this.language,
    required this.items,
    required this.onExpand,
    required this.onTapItem,
    this.loading = false,
  });

  @override
  State<AtsCheckPanel> createState() => _AtsCheckPanelState();
}

class _AtsCheckPanelState extends State<AtsCheckPanel> {
  bool _expanded = false;

  bool get _isRtl => widget.language == 'ps' || widget.language == 'fa' || widget.language == 'ar' || widget.language == 'ur';

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded && widget.items == null) widget.onExpand();
  }

  Color _dotColor(AtsLevel level) {
    switch (level) {
      case AtsLevel.ok:
        return KColors.greenDark;
      case AtsLevel.warn:
        return const Color(0xFFC77B1E);
      case AtsLevel.problem:
        return const Color(0xFFC0392B);
    }
  }

  IconData _icon(AtsLevel level) {
    switch (level) {
      case AtsLevel.ok:
        return Icons.check_circle_rounded;
      case AtsLevel.warn:
        return Icons.warning_amber_rounded;
      case AtsLevel.problem:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KGlassSurface(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: KColors.mint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fact_check_rounded,
                        color: KColors.greenDark, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atsText(widget.language, 'title'),
                          style: const TextStyle(
                            color: KColors.navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          atsText(widget.language, 'subtitle'),
                          style: const TextStyle(
                            color: KColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: KColors.green,
                    size: 22,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              if (widget.loading || widget.items == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(color: KColors.green),
                  ),
                )
              else
                for (final item in widget.items!)
                  GestureDetector(
                    onTap: item.section == null
                        ? null
                        : () => widget.onTapItem(item),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_icon(item.level),
                              color: _dotColor(item.level), size: 19),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              atsItemText(widget.language, item),
                              style: const TextStyle(
                                color: KColors.navy,
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (item.section != null)
                            const Icon(Icons.chevron_right_rounded,
                                color: KColors.textSecondary, size: 18),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
