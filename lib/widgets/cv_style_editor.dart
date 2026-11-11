import 'package:flutter/material.dart';

import '../models/cv_style.dart';
import '../ui/karyab_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Per-CV design editor (Phase 3): accent colour from the print-safe
// palette, font size, spacing density and the photo on/off switch.
//
// Used as a bottom sheet from both preview screens; every change is
// reported live through [onChanged] so the preview behind the sheet can
// regenerate and the host can persist immediately. Strings follow the
// app pattern (ps / fa / default English).
// ─────────────────────────────────────────────────────────────────────────────

String cvStyleText(String lang, String key) {
  switch (key) {
    case 'design':
      switch (lang) {
        case 'ps':
          return 'ډیزاین';
        case 'fa':
          return 'طراحی';
        case 'ar':
          return 'التصميم';
        case 'ur':
          return 'ڈیزائن';
        default:
          return 'Design';
      }
    case 'change':
      switch (lang) {
        case 'ps':
          return 'بدل کړئ';
        case 'fa':
          return 'تغییر';
        case 'ar':
          return 'تغيير';
        case 'ur':
          return 'تبدیل کریں';
        default:
          return 'Change';
      }
    case 'accent':
      switch (lang) {
        case 'ps':
          return 'رنګ';
        case 'fa':
          return 'رنگ';
        case 'ar':
          return 'اللون';
        case 'ur':
          return 'رنگ';
        default:
          return 'Colour';
      }
    case 'templateDefault':
      switch (lang) {
        case 'ps':
          return 'د کینډۍ رنګ';
        case 'fa':
          return 'رنگ قالب';
        case 'ar':
          return 'لون القالب';
        case 'ur':
          return 'سانچے کا رنگ';
        default:
          return 'Template colour';
      }
    case 'fontSize':
      switch (lang) {
        case 'ps':
          return 'د لیک اندازه';
        case 'fa':
          return 'اندازه متن';
        case 'ar':
          return 'حجم النص';
        case 'ur':
          return 'متن کا سائز';
        default:
          return 'Text size';
      }
    case 'compact':
      switch (lang) {
        case 'ps':
          return 'وړوکی';
        case 'fa':
          return 'فشرده';
        case 'ar':
          return 'مضغوط';
        case 'ur':
          return 'مختصر';
        default:
          return 'Compact';
      }
    case 'normal':
      switch (lang) {
        case 'ps':
          return 'نورمال';
        case 'fa':
          return 'معمولی';
        case 'ar':
          return 'عادي';
        case 'ur':
          return 'عام';
        default:
          return 'Normal';
      }
    case 'large':
      switch (lang) {
        case 'ps':
          return 'لوی';
        case 'fa':
          return 'بزرگ';
        case 'ar':
          return 'كبير';
        case 'ur':
          return 'بڑا';
        default:
          return 'Large';
      }
    case 'spacing':
      switch (lang) {
        case 'ps':
          return 'واټن';
        case 'fa':
          return 'فاصله';
        case 'ar':
          return 'التباعد';
        case 'ur':
          return 'فاصلہ';
        default:
          return 'Spacing';
      }
    case 'photo':
      switch (lang) {
        case 'ps':
          return 'انځور په CV کې';
        case 'fa':
          return 'عکس در رزومه';
        case 'ar':
          return 'الصورة في السيرة الذاتية';
        case 'ur':
          return 'CV میں تصویر';
        default:
          return 'Photo in the CV';
      }
    case 'done':
      switch (lang) {
        case 'ps':
          return 'بشپړ شو';
        case 'fa':
          return 'تمام';
        case 'ar':
          return 'تم';
        case 'ur':
          return 'ہو گیا';
        default:
          return 'Done';
      }
    default:
      return key;
  }
}

/// One-line summary of a customisation for the preview screens' design row,
/// e.g. "Colour: Template colour · Text: Normal · Spacing: Normal".
String cvStyleSummary(String lang, CvCustomisation style) {
  final accent = style.accentColorHex == null
      ? cvStyleText(lang, 'templateDefault')
      : kCvAccentPalette
            .firstWhere(
              (o) => o.hex == style.accentColorHex,
              orElse: () => CvAccentOption(style.accentColorHex!, ''),
            )
            .labelDe;
  final font = cvStyleText(lang, style.fontSize);
  final spacing = cvStyleText(lang, style.spacing);
  return '$accent · $font · $spacing';
}

Future<void> showCvStyleEditor(
  BuildContext context, {
  required String language,
  required CvCustomisation current,
  required ValueChanged<CvCustomisation> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _CvStyleSheet(
      language: language,
      initial: current,
      onChanged: onChanged,
    ),
  );
}

class _CvStyleSheet extends StatefulWidget {
  final String language;
  final CvCustomisation initial;
  final ValueChanged<CvCustomisation> onChanged;

  const _CvStyleSheet({
    required this.language,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<_CvStyleSheet> createState() => _CvStyleSheetState();
}

class _CvStyleSheetState extends State<_CvStyleSheet> {
  late CvCustomisation _style = widget.initial;

  bool get _isRtl => widget.language == 'ps' || widget.language == 'fa' || widget.language == 'ar' || widget.language == 'ur';
  String t(String key) => cvStyleText(widget.language, key);

  void _update(CvCustomisation next) {
    setState(() => _style = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    // Overflow fix (Phase 10): this content used to be a plain,
    // non-scrolling Column. Its natural height (swatch wrap + two
    // segmented rows + photo row + CTA) exceeds the sheet area on
    // shorter phones and at larger accessibility text scales, which
    // threw a RenderFlex overflow on the View/Download My CV screens.
    // Same remedy as the template pickers: cap the height and scroll.
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: Color(0xFFF7FAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: KSheetHandle()),
                const SizedBox(height: 14),
                Text(
                  t('design'),
                  style: const TextStyle(
                    color: KColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _label(t('accent')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _swatch(
                      color: null,
                      selected: _style.accentColorHex == null,
                      label: t('templateDefault'),
                      onTap: () => _update(_style.copyWith(clearAccent: true)),
                    ),
                    for (final option in kCvAccentPalette)
                      _swatch(
                        color: Color(
                          int.parse(option.hex.replaceFirst('#', '0xFF')),
                        ),
                        selected: _style.accentColorHex == option.hex,
                        label: option.labelDe,
                        onTap: () => _update(
                          _style.copyWith(accentColorHex: option.hex),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _label(t('fontSize')),
                const SizedBox(height: 8),
                _segmented(
                  values: const ['compact', 'normal', 'large'],
                  current: _style.fontSize,
                  onPick: (v) => _update(_style.copyWith(fontSize: v)),
                ),
                const SizedBox(height: 18),
                _label(t('spacing')),
                const SizedBox(height: 8),
                _segmented(
                  values: const ['compact', 'normal'],
                  current: _style.spacing,
                  onPick: (v) => _update(_style.copyWith(spacing: v)),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.photo_camera_rounded,
                      color: KColors.navy,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t('photo'),
                        style: const TextStyle(
                          color: KColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Switch(
                      value: _style.showPhoto,
                      activeTrackColor: KColors.green.withValues(alpha: 0.45),
                      activeThumbColor: KColors.greenDark,
                      onChanged: (v) => _update(_style.copyWith(showPhoto: v)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                KPrimaryCta(
                  icon: Icons.check_rounded,
                  label: t('done'),
                  isRtl: _isRtl,
                  isSelected: false,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: KColors.navy,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _swatch({
    required Color? color,
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color ?? Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? KColors.green : KColors.borderSoft,
                width: selected ? 3.0 : 1.2,
              ),
            ),
            child: color == null
                ? const Icon(
                    Icons.auto_awesome_rounded,
                    color: KColors.textSecondary,
                    size: 18,
                  )
                : (selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : null),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 56,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? KColors.navy : KColors.textSecondary,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmented({
    required List<String> values,
    required String current,
    required ValueChanged<String> onPick,
  }) {
    return Row(
      children: [
        for (final v in values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onPick(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: current == v
                      ? KColors.green.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: KColors.glassFillAlpha),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: current == v ? KColors.green : KColors.borderSoft,
                    width: current == v ? 2.0 : 1.2,
                  ),
                ),
                child: Text(
                  t(v),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: KColors.navy,
                    fontSize: 13,
                    fontWeight: current == v
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (v != values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

/// The preview screens' design row: current summary + Change action.
class CvStyleRow extends StatelessWidget {
  final String language;
  final CvCustomisation style;
  final VoidCallback onChange;

  const CvStyleRow({
    super.key,
    required this.language,
    required this.style,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Row(
        children: [
          const Icon(
            Icons.palette_rounded,
            color: KColors.textSecondary,
            size: 15,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${cvStyleText(language, 'design')}: ${cvStyleSummary(language, style)}',
              style: const TextStyle(
                color: KColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onChange,
            child: Text(
              cvStyleText(language, 'change'),
              style: const TextStyle(
                color: KColors.green,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                decorationColor: KColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
