import 'package:flutter/material.dart';

import '../ui/karyab_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Home dashboard (Phase 5): the navy Liquid Glass panel at the top of
// the home screen. It shows ONLY real data the host loaded from the
// data layer: the profile completion percent (services/cv_completion),
// the most recent unfinished CV document (name + percent), a Minijobs
// entry card (pure navigation into job search with the Minijob filter
// preselected) and a daily tip that rotates by calendar day.
//
// All strings follow the app pattern: Pashto and Dari cases, German
// translated (the dashboard is new, so it gets a real German case),
// English as default.
// ─────────────────────────────────────────────────────────────────────────────

String homeDashText(String lang, String key, {int percent = 0}) {
  switch (key) {
    case 'profile':
      switch (lang) {
        case 'ps':
          return 'ستاسو پروفایل';
        case 'fa':
          return 'پروفایل شما';
        case 'de':
          return 'Ihr Profil';
        default:
          return 'Your profile';
      }
    case 'percentComplete':
      switch (lang) {
        case 'ps':
          return '$percent٪ بشپړ شوی';
        case 'fa':
          return '$percent٪ تکمیل شده';
        case 'de':
          return '$percent% ausgefüllt';
        default:
          return '$percent% complete';
      }
    case 'continueHeading':
      switch (lang) {
        case 'ps':
          return 'CV ته دوام ورکړئ';
        case 'fa':
          return 'ادامه CV';
        case 'de':
          return 'Lebenslauf fortsetzen';
        default:
          return 'Continue your CV';
      }
    case 'minijobs':
      switch (lang) {
        case 'ps':
          return 'تاسو ته نږدې Minijob کارونه';
        case 'fa':
          return 'کارهای Minijob نزدیک شما';
        case 'de':
          return 'Minijobs in Ihrer Nähe';
        default:
          return 'Minijobs near you';
      }
    case 'minijobsSub':
      switch (lang) {
        case 'ps':
          return 'د Minijob فلټر سره کارونه وګورئ';
        case 'fa':
          return 'جستجو با فیلتر Minijob';
        case 'de':
          return 'Suche mit Minijob-Filter';
        default:
          return 'Search with the Minijob filter on';
      }
    case 'tipTitle':
      switch (lang) {
        case 'ps':
          return 'د ورځې لارښوونه';
        case 'fa':
          return 'نکته روز';
        case 'de':
          return 'Tipp des Tages';
        default:
          return 'Tip of the day';
      }
    default:
      return key;
  }
}

/// Application tips, one per day (rotated by day of year). Authored for
/// Phase 5 in all four app languages.
const List<({String en, String de, String ps, String fa})> kHomeTips = [
  (
    en: 'Send your CV as a PDF, never as a photo of a paper CV.',
    de: 'Senden Sie Ihren Lebenslauf als PDF, nie als Foto eines Papier-Lebenslaufs.',
    ps: 'خپل CV د PDF په بڼه واستوئ، هیڅکله د کاغذي CV عکس مه استوئ.',
    fa: 'CV خود را به صورت PDF بفرستید، هرگز عکس CV کاغذی نفرستید.',
  ),
  (
    en: 'A German CV is one or two pages. Short and clear wins.',
    de: 'Ein deutscher Lebenslauf hat ein bis zwei Seiten. Kurz und klar gewinnt.',
    ps: 'الماني CV یو یا دوه مخونه وي. لنډ او روښانه غوره دی.',
    fa: 'CV آلمانی یک یا دو صفحه است. کوتاه و روشن بهتر است.',
  ),
  (
    en: 'Name your PDF file with your name, for example Lebenslauf_Ahmad.pdf.',
    de: 'Nennen Sie Ihre PDF-Datei mit Ihrem Namen, zum Beispiel Lebenslauf_Ahmad.pdf.',
    ps: 'د PDF فایل نوم مو خپل نوم کېږدئ، لکه Lebenslauf_Ahmad.pdf.',
    fa: 'نام فایل PDF را با نام خود بگذارید، مثلاً Lebenslauf_Ahmad.pdf.',
  ),
  (
    en: 'Minijobs are part-time jobs with simple rules. Many employers look for Minijob workers.',
    de: 'Minijobs sind Teilzeitjobs mit einfachen Regeln. Viele Arbeitgeber suchen Minijob-Kräfte.',
    ps: 'Minijob ساده قواعد لري او ډېر کارورکوونکي يې لټوي.',
    fa: 'Minijob قوانین ساده دارد و بسیاری از کارفرمایان دنبال آن هستند.',
  ),
  (
    en: 'Write one cover letter for the exact job, not one letter for all jobs.',
    de: 'Schreiben Sie das Anschreiben immer für die genaue Stelle, nicht ein Schreiben für alle Stellen.',
    ps: 'د هرې دندې لپاره جلا پوښلیک ولیکئ، نه یو لیک د ټولو لپاره.',
    fa: 'برای هر شغل یک نامه جداگانه بنویسید، نه یک نامه برای همه.',
  ),
  (
    en: 'Bring your CV and your certificates to every interview.',
    de: 'Bringen Sie Ihren Lebenslauf und Ihre Zeugnisse zu jedem Vorstellungsgespräch mit.',
    ps: 'هرې مرکې ته خپل CV او سندونه له ځان سره واخلئ.',
    fa: 'به هر مصاحبه CV و مدارک خود را ببرید.',
  ),
  (
    en: 'Check new jobs in the morning. Good Minijobs go fast.',
    de: 'Prüfen Sie neue Stellen am Morgen. Gute Minijobs sind schnell weg.',
    ps: 'نوي کارونه سهار وګورئ. ښه Minijob کارونه ژر خلاصیږي.',
    fa: 'کارهای جدید را صبح بررسی کنید. Minijobهای خوب زود پر می‌شوند.',
  ),
];

String homeTipFor(String lang, DateTime day) {
  final index = day.difference(DateTime(day.year)).inDays % kHomeTips.length;
  final tip = kHomeTips[index];
  switch (lang) {
    case 'ps':
      return tip.ps;
    case 'fa':
      return tip.fa;
    case 'de':
      return tip.de;
    default:
      return tip.en;
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;

  const _RingPainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    final arc = Paint()
      ..color = KColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.2832 * fraction.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}

/// The dashboard panel. [profilePercent] is 0..100 of the user's most
/// complete CV profile; [continueName]/[continuePercent] describe the
/// newest unfinished CV document, or are null when there is none.
class HomeDashboard extends StatelessWidget {
  final String language;
  final int profilePercent;
  final String? continueName;
  final int? continuePercent;
  final VoidCallback? onContinue;
  final VoidCallback onMinijobs;
  final DateTime? day;

  const HomeDashboard({
    super.key,
    required this.language,
    required this.profilePercent,
    required this.onMinijobs,
    this.continueName,
    this.continuePercent,
    this.onContinue,
    this.day,
  });

  bool get _isRtl => language == 'ps' || language == 'fa';

  TextStyle _style(double size, FontWeight weight, Color color) {
    return TextStyle(
      fontFamily: karyabFontFamily(language),
      fontFamilyFallback: karyabFontFallback(language),
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final font = karyabFontFamily(language);
    final tip = homeTipFor(language, day ?? DateTime.now());
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: LiquidBackground(
        child: Directionality(
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile completion ring
                Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(64, 64),
                            painter:
                                _RingPainter(profilePercent / 100),
                          ),
                          Text(
                            '$profilePercent%',
                            style: _style(13, FontWeight.w800, Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            homeDashText(language, 'profile'),
                            style: _style(16, FontWeight.w800, Colors.white),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            homeDashText(language, 'percentComplete',
                                percent: profilePercent),
                            style: _style(
                                12, FontWeight.w600, KLiquid.textOnDarkSoft),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Continue card (only when an unfinished CV exists)
                if (continueName != null && onContinue != null) ...[
                  const SizedBox(height: 14),
                  KGlassPanel(
                    level: KGlassLevel.l1,
                    borderRadius: 20,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    onTap: onContinue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.play_circle_fill_rounded,
                                color: KColors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                homeDashText(language, 'continueHeading'),
                                style:
                                    _style(13, FontWeight.w800, Colors.white),
                              ),
                            ),
                            Text(
                              continueName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _style(12, FontWeight.w600,
                                  KLiquid.textOnDarkSoft),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        KLiquidProgressBar(
                          value: (continuePercent ?? 0) / 100,
                          height: 8,
                          onDark: true,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // Minijobs entry card (navigation only, honest label)
                KGlassPanel(
                  level: KGlassLevel.l1,
                  borderRadius: 20,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  onTap: onMinijobs,
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: KColors.green.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bolt_rounded,
                            color: KColors.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              homeDashText(language, 'minijobs'),
                              style:
                                  _style(13, FontWeight.w800, Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              homeDashText(language, 'minijobsSub'),
                              style: _style(11, FontWeight.w600,
                                  KLiquid.textOnDarkSoft),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isRtl
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.white54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Daily tip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_rounded,
                        color: KColors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            homeDashText(language, 'tipTitle'),
                            style: _style(
                                11, FontWeight.w800, KColors.green),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tip,
                            style: TextStyle(
                              fontFamily: font,
                              fontFamilyFallback:
                                  karyabFontFallback(language),
                              fontSize: 12.5,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              color: KLiquid.textOnDarkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
