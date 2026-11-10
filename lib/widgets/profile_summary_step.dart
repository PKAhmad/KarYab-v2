import 'package:flutter/material.dart';

import '../services/profile_summary_bank.dart';
import '../ui/karyab_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// The Profil wizard step (Phase 3), shared by both CV questionnaires.
//
// The user ticks strength themes and sector experience lines (chips), the
// step composes a German profile text from the phrase bank, and the text
// stays fully editable. Chip changes re-compose automatically ONLY while
// the text is untouched (or equal to the last composed text); once the
// user edits by hand, a separate "update from selection" button appears
// so nothing the user wrote is ever overwritten silently.
//
// Chip labels are short UI labels in the app's pattern (ps / fa / default
// English). The composed sentences themselves are always German - they go
// into the CV document.
// ─────────────────────────────────────────────────────────────────────────────

typedef ProfileSummaryChanged = void Function(
  Set<String> themeKeys,
  Set<String> sectorKeys,
  String text,
);

class ProfileSummaryStep extends StatefulWidget {
  final String language;
  final bool isAusbildung;
  final String workExperience;
  final Set<String> initialThemes;
  final Set<String> initialSectors;
  final String initialText;

  /// Sector keys derived from the user's own entered data (offered first).
  final Set<String> suggestedSectors;
  final ProfileSummaryChanged onChanged;

  const ProfileSummaryStep({
    super.key,
    required this.language,
    required this.isAusbildung,
    required this.onChanged,
    this.workExperience = '',
    this.initialThemes = const {},
    this.initialSectors = const {},
    this.initialText = '',
    this.suggestedSectors = const {},
  });

  @override
  State<ProfileSummaryStep> createState() => _ProfileSummaryStepState();
}

class _ProfileSummaryStepState extends State<ProfileSummaryStep> {
  late final Set<String> _themes = {...widget.initialThemes};
  late final Set<String> _sectors = {...widget.initialSectors};
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initialText);
  String _lastComposed = '';
  bool _staleSelection = false;

  bool get _isRtl => widget.language == 'ps' || widget.language == 'fa' || widget.language == 'ar';

  @override
  void initState() {
    super.initState();
    _lastComposed = _compose();
    _ctrl.addListener(() {
      widget.onChanged(_themes, _sectors, _ctrl.text);
      final stale = _ctrl.text.trim() != _lastComposed.trim() &&
          _compose() != _lastComposed;
      if (stale != _staleSelection) {
        setState(() => _staleSelection = stale);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _compose() => composeProfileSummary(
        themeKeys: _themes,
        sectorKeys: _sectors,
        isAusbildung: widget.isAusbildung,
        workExperience: widget.workExperience,
      );

  void _toggle(Set<String> set, String key) {
    setState(() {
      if (set.contains(key)) {
        set.remove(key);
      } else {
        set.add(key);
      }
      final composed = _compose();
      final untouched =
          _ctrl.text.trim().isEmpty || _ctrl.text.trim() == _lastComposed.trim();
      if (untouched) {
        _ctrl.text = composed;
        _lastComposed = composed;
        _staleSelection = false;
      } else {
        _staleSelection = composed != _lastComposed;
      }
    });
    widget.onChanged(_themes, _sectors, _ctrl.text);
  }

  void _applyComposed() {
    final composed = _compose();
    setState(() {
      _ctrl.text = composed;
      _lastComposed = composed;
      _staleSelection = false;
    });
    widget.onChanged(_themes, _sectors, _ctrl.text);
  }

  // ── Strings ──────────────────────────────────────────────────────────────

  String get _intro {
    switch (widget.language) {
      case 'ps':
        return 'خپل قوي ټکي وټاکئ. له دې څخه به ستاسو د CV لپاره یو لنډ جرمني متن جوړ شي. متن وروسته سمولی شئ.';
      case 'fa':
        return 'نقاط قوت خود را انتخاب کنید. از آن یک متن کوتاه آلمانی برای رزومه شما ساخته می‌شود. متن را می‌توانید بعداً ویرایش کنید.';
      case 'ar':
        return 'اختر نقاط قوتك. سيتم إنشاء نص ألماني قصير لسيرتك الذاتية منها. يمكنك تعديل النص لاحقا.';
      default:
        return 'Choose your strengths. A short German text for your CV is created from them. You can edit the text afterwards.';
    }
  }

  String get _sectorTitle {
    switch (widget.language) {
      case 'ps':
        return 'په کومو برخو کې تجربه لرئ؟';
      case 'fa':
        return 'در کدام بخش‌ها تجربه دارید؟';
      case 'ar':
        return 'في أي مجالات لديك خبرة؟';
      default:
        return 'Where do you have experience?';
    }
  }

  String get _themeTitle {
    switch (widget.language) {
      case 'ps':
        return 'ستاسو قوي ټکي';
      case 'fa':
        return 'نقاط قوت شما';
      case 'ar':
        return 'نقاط قوتك';
      default:
        return 'Your strengths';
    }
  }

  String get _textTitle {
    switch (widget.language) {
      case 'ps':
        return 'ستاسو متن (جرمني)';
      case 'fa':
        return 'متن شما (آلمانی)';
      case 'ar':
        return 'نصك (بالألمانية)';
      default:
        return 'Your text (German)';
    }
  }

  String get _updateLabel {
    switch (widget.language) {
      case 'ps':
        return 'متن د ټاکنو سره تازه کړئ';
      case 'fa':
        return 'متن را با انتخاب‌ها به‌روز کنید';
      case 'ar':
        return 'تحديث النص حسب الاختيارات';
      default:
        return 'Update text from my selection';
    }
  }

  String _sectorLabel(String key) {
    switch (key) {
      case 'warehouse':
        switch (widget.language) {
          case 'ps':
            return 'ګودام / لوژستیک';
          case 'fa':
            return 'انبار / لجستیک';
          case 'ar':
            return 'المستودع / الخدمات اللوجستية';
          default:
            return 'Warehouse / Logistics';
        }
      case 'care':
        switch (widget.language) {
          case 'ps':
            return 'پاملرنه / نرسنګ';
          case 'fa':
            return 'مراقبت / پرستاری';
          case 'ar':
            return 'الرعاية / التمريض';
          default:
            return 'Care / Nursing';
        }
      case 'gastronomy':
        switch (widget.language) {
          case 'ps':
            return 'آشپزخانه / رستورانت';
          case 'fa':
            return 'آشپزخانه / رستوران';
          case 'ar':
            return 'المطبخ / المطعم';
          default:
            return 'Kitchen / Restaurant';
        }
      case 'retail':
        switch (widget.language) {
          case 'ps':
            return 'پلورنځی / سوداګري';
          case 'fa':
            return 'فروشگاه / تجارت';
          case 'ar':
            return 'المتاجر / المبيعات';
          default:
            return 'Retail / Sales';
        }
      case 'cleaning':
        switch (widget.language) {
          case 'ps':
            return 'پاکوالی';
          case 'fa':
            return 'نظافت';
          case 'ar':
            return 'التنظيف';
          default:
            return 'Cleaning';
        }
      case 'construction':
        switch (widget.language) {
          case 'ps':
            return 'ودانۍ / ساختمان';
          case 'fa':
            return 'ساختمان';
          case 'ar':
            return 'البناء';
          default:
            return 'Construction';
        }
      case 'driving':
        switch (widget.language) {
          case 'ps':
            return 'موټر چلول / لېږد';
          case 'fa':
            return 'رانندگی / حمل‌ونقل';
          case 'ar':
            return 'القيادة / النقل';
          default:
            return 'Driving / Transport';
        }
      case 'office':
        switch (widget.language) {
          case 'ps':
            return 'دفتر / کمپیوټر';
          case 'fa':
            return 'دفتر / کامپیوتر';
          case 'ar':
            return 'المكتب / الحاسوب';
          default:
            return 'Office / Computer';
        }
      default:
        return key;
    }
  }

  String _themeLabel(String key) {
    switch (key) {
      case 'reliable':
        switch (widget.language) {
          case 'ps':
            return 'د باور وړ';
          case 'fa':
            return 'قابل اعتماد';
          case 'ar':
            return 'موثوق به';
          default:
            return 'Reliable';
        }
      case 'punctualCareful':
        switch (widget.language) {
          case 'ps':
            return 'په احتیاط کار کوونکی';
          case 'fa':
            return 'دقیق و محتاط';
          case 'ar':
            return 'دقيق وحريص';
          default:
            return 'Careful and exact';
        }
      case 'team':
        switch (widget.language) {
          case 'ps':
            return 'ډله ییز کار';
          case 'fa':
            return 'کار تیمی';
          case 'ar':
            return 'العمل ضمن فريق';
          default:
            return 'Team player';
        }
      case 'independent':
        switch (widget.language) {
          case 'ps':
            return 'خپلواک کار';
          case 'fa':
            return 'کار مستقل';
          case 'ar':
            return 'العمل بشكل مستقل';
          default:
            return 'Works independently';
        }
      case 'fastLearner':
        switch (widget.language) {
          case 'ps':
            return 'ژر زده کوونکی';
          case 'fa':
            return 'سریع یاد می‌گیرم';
          case 'ar':
            return 'يتعلم بسرعة';
          default:
            return 'Learns quickly';
        }
      case 'physical':
        switch (widget.language) {
          case 'ps':
            return 'فزیکي کار کولی شم';
          case 'fa':
            return 'کار فیزیکی می‌توانم';
          case 'ar':
            return 'قادر على العمل البدني';
          default:
            return 'Physically fit';
        }
      case 'flexible':
        switch (widget.language) {
          case 'ps':
            return 'انعطاف منونکی';
          case 'fa':
            return 'انعطاف‌پذیر';
          case 'ar':
            return 'مرن';
          default:
            return 'Flexible hours';
        }
      case 'friendly':
        switch (widget.language) {
          case 'ps':
            return 'دوستانه چلند';
          case 'fa':
            return 'برخورد دوستانه';
          case 'ar':
            return 'ودود مع الزبائن';
          default:
            return 'Friendly with customers';
        }
      default:
        return key;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final suggested = widget.suggestedSectors;
    final sectors = [
      ...kProfileSectors.where((s) => suggested.contains(s.key)),
      ...kProfileSectors.where((s) => !suggested.contains(s.key)),
    ];
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: KGlassSurface(
        borderRadius: 20,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _intro,
              style: const TextStyle(
                color: KColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _groupTitle(_sectorTitle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in sectors)
                  _chip(
                    label: _sectorLabel(s.key),
                    selected: _sectors.contains(s.key),
                    suggested: suggested.contains(s.key),
                    onTap: () => _toggle(_sectors, s.key),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _groupTitle(_themeTitle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in kProfileThemes)
                  _chip(
                    label: _themeLabel(t.key),
                    selected: _themes.contains(t.key),
                    onTap: () => _toggle(_themes, t.key),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _groupTitle(_textTitle),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              minLines: 4,
              maxLines: 8,
              style: const TextStyle(
                color: KColors.navy,
                fontSize: 14,
                height: 1.45,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.75),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: KColors.borderSoft, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: KColors.borderSoft, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: KColors.green, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            if (_staleSelection) ...[
              const SizedBox(height: 10),
              KGlassCard(
                borderRadius: 16,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                onTap: _applyComposed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: KColors.greenDark, size: 17),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _updateLabel,
                        style: const TextStyle(
                          color: KColors.greenDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _groupTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: KColors.navy,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool suggested = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? KColors.green.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? KColors.green : KColors.borderSoft,
            width: selected ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, color: KColors.greenDark, size: 15),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: KColors.navy,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            if (suggested && !selected) ...[
              const SizedBox(width: 5),
              const Icon(Icons.star_rounded, color: Color(0xFFC77B1E), size: 13),
            ],
          ],
        ),
      ),
    );
  }
}
