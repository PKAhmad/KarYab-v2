import 'package:flutter/material.dart';

import '../ui/karyab_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Wizard chrome shared by both CV questionnaires (Phase 3): a liquid
// progress header ("Step X of Y" + animated gradient fill + completion %)
// and a bottom navigation bar (Back / Skip / Continue + Preview access).
//
// Localisation follows the app's existing per-screen pattern: Pashto and
// Dari cases, English as the default (German falls through to English,
// exactly like the questionnaire screens do today).
// ─────────────────────────────────────────────────────────────────────────────

String wizardText(String lang, String key,
    {int step = 0, int total = 0, int percent = 0}) {
  switch (key) {
    case 'stepOf':
      switch (lang) {
        case 'ps':
          return 'ګام $step د $total';
        case 'fa':
          return 'مرحله $step از $total';
        default:
          return 'Step $step of $total';
      }
    case 'back':
      switch (lang) {
        case 'ps':
          return 'شاته';
        case 'fa':
          return 'بازگشت';
        default:
          return 'Back';
      }
    case 'continue':
      switch (lang) {
        case 'ps':
          return 'مخکې لاړ شئ';
        case 'fa':
          return 'ادامه';
        default:
          return 'Continue';
      }
    case 'skip':
      switch (lang) {
        case 'ps':
          return 'پرېږدئ';
        case 'fa':
          return 'رد کردن';
        default:
          return 'Skip';
      }
    case 'preview':
      switch (lang) {
        case 'ps':
          return 'مخکتنه';
        case 'fa':
          return 'پیش‌نمایش';
        default:
          return 'Preview';
      }
    case 'percentDone':
      switch (lang) {
        case 'ps':
          return '$percent٪ ډک شوی';
        case 'fa':
          return '$percent٪ تکمیل شده';
        default:
          return '$percent% done';
      }
    default:
      return key;
  }
}

/// Short wizard step titles per section key.
String wizardSectionTitle(String lang, String section) {
  switch (section) {
    case 'education':
      switch (lang) {
        case 'ps':
          return 'زده کړې';
        case 'fa':
          return 'تحصیلات';
        default:
          return 'Education';
      }
    case 'skills':
    case 'esco':
      switch (lang) {
        case 'ps':
          return 'مهارتونه';
        case 'fa':
          return 'مهارت‌ها';
        default:
          return section == 'esco' ? 'Skills (ESCO)' : 'Skills';
      }
    case 'experience':
      switch (lang) {
        case 'ps':
          return 'کاري تجربه';
        case 'fa':
          return 'تجربه کاری';
        default:
          return 'Work experience';
      }
    case 'toolsIt':
      switch (lang) {
        case 'ps':
          return 'وسایل او کمپیوټر';
        case 'fa':
          return 'ابزار و کامپیوتر';
        default:
          return 'Tools and IT';
      }
    case 'languages':
      switch (lang) {
        case 'ps':
          return 'ژبې';
        case 'fa':
          return 'زبان‌ها';
        default:
          return 'Languages';
      }
    case 'availability':
      switch (lang) {
        case 'ps':
          return 'چمتووالی';
        case 'fa':
          return 'آمادگی';
        default:
          return 'Availability';
      }
    case 'profil':
      switch (lang) {
        case 'ps':
          return 'لنډ معرفي';
        case 'fa':
          return 'معرفی کوتاه';
        default:
          return 'Profile summary';
      }
    default:
      return section;
  }
}

/// Animated liquid-style progress bar: a gradient fill whose width
/// animates to [value] (0..1), with a soft highlight sweep. Static (no
/// continuous animation) so it stays cheap on low-end phones.
class LiquidProgressBar extends StatelessWidget {
  final double value;
  final double height;

  const LiquidProgressBar({super.key, required this.value, this.height = 10});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(
            height: height,
            color: KColors.green.withValues(alpha: 0.15),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            height: height,
            width: MediaQuery.of(context).size.width * clamped,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E7A20), KColors.green],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header shown above the current wizard step: step title, step counter,
/// completion percent, liquid progress, and the always-available Preview
/// action (opens the live PDF preview of the current draft).
class WizardStepHeader extends StatelessWidget {
  final String language;
  final String section;
  final int stepIndex;
  final int stepCount;
  final int percent;
  final VoidCallback onPreview;

  const WizardStepHeader({
    super.key,
    required this.language,
    required this.section,
    required this.stepIndex,
    required this.stepCount,
    required this.percent,
    required this.onPreview,
  });

  bool get _isRtl => language == 'ps' || language == 'fa';

  @override
  Widget build(BuildContext context) {
    return KGlassSurface(
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Directionality(
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wizardSectionTitle(language, section),
                        style: const TextStyle(
                          color: KColors.navy,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${wizardText(language, 'stepOf', step: stepIndex + 1, total: stepCount)}'
                        ' · ${wizardText(language, 'percentDone', percent: percent)}',
                        style: const TextStyle(
                          color: KColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                KGlassCard(
                  borderRadius: 20,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onTap: onPreview,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility_rounded,
                          color: KColors.greenDark, size: 17),
                      const SizedBox(width: 6),
                      Text(
                        wizardText(language, 'preview'),
                        style: const TextStyle(
                          color: KColors.greenDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LiquidProgressBar(
              value: stepCount == 0 ? 0 : (stepIndex + 1) / stepCount,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom navigation for the wizard: Back (previous step), Skip (only for
/// optional steps), Continue (next step). On the last step the host screen
/// keeps its own finish button instead of this bar's Continue.
class WizardBottomBar extends StatelessWidget {
  final String language;
  final bool showBack;
  final bool showSkip;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final VoidCallback? onContinue;

  const WizardBottomBar({
    super.key,
    required this.language,
    this.showBack = true,
    this.showSkip = false,
    this.onBack,
    this.onSkip,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          if (showBack)
            Expanded(
              child: SizedBox(
                height: 52,
                child: KGlassCard(
                  borderRadius: 22,
                  onTap: onBack,
                  child: Center(
                    child: Text(
                      wizardText(language, 'back'),
                      style: const TextStyle(
                        color: KColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showBack) const SizedBox(width: 10),
          if (showSkip)
            Expanded(
              child: SizedBox(
                height: 52,
                child: KGlassCard(
                  borderRadius: 22,
                  onTap: onSkip,
                  child: Center(
                    child: Text(
                      wizardText(language, 'skip'),
                      style: const TextStyle(
                        color: KColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showSkip) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: KPrimaryCta(
              icon: Icons.arrow_forward_rounded,
              label: wizardText(language, 'continue'),
              isRtl: language == 'ps' || language == 'fa',
              isSelected: false,
              onTap: onContinue ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}
