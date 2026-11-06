import 'dart:ui';

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared KarYab UI kit. Every value here is lifted unchanged from
// lib/screens/introduction_screen.dart, the design reference, so that screens
// can stop carrying their own private copies. Nothing in this file is a
// redesign.
// ─────────────────────────────────────────────────────────────────────────────

// ── Tokens ───────────────────────────────────────────────────────────────────

class KColors {
  KColors._();

  // Brand
  static const Color navy = Color(0xFF091733);
  static const Color green = Color(0xFF39EA2B);
  static const Color mint = Color(0xFFEAFBE9);
  static const Color mintBadge = Color(0xFFE9FFE6);
  static const Color greenDark = Color(0xFF0E7A20);
  static const Color greenDarkBadge = Color(0xFF147C20);

  // Accents used for tile icons
  static const Color blue = Color(0xFF2D6BE4);
  static const Color purple = Color(0xFF9C27B0);

  // Text and lines
  static const Color textSecondary = Color(0xFF65738A);
  static const Color border = Color(0xFFDDE4EF);
  // The reference screen itself uses these two slightly different greys.
  static const Color borderSoft = Color(0xFFE4EAF5);
  static const Color handle = Color(0xFFD1D9E6);

  // Page
  static const Color pageBase = Color(0xFFF7FAFF);
  static const Color gradientTop = Color(0xFFF9FBFF);
  static const Color gradientMid = Color(0xFFEFF6FF);
  static const Color gradientBottom = Color(0xFFF7FFF2);

  // Glow orbs (ARGB)
  static const Color orbGreenA = Color(0x6639EA2B);
  static const Color orbOrange = Color(0x44FFB86B);
  static const Color orbGreenB = Color(0x3339EA2B);
  static const Color orbGreenC = Color(0x5539EA2B);
  static const Color orbPink = Color(0x30FF8FA3);

  // Primary button gradient
  static const Color ctaStart = Color(0xFF081532);
  static const Color ctaEnd = Color(0xFF07112B);
}

// ── Background ───────────────────────────────────────────────────────────────

class KOrb extends StatelessWidget {
  final double size;
  final Color color;

  const KOrb({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// Page gradient plus the 5 glow orbs. [accent], when given, replaces the
// orange orb (the second one), for screens that carry their own accent.
class KBackgroundGlow extends StatelessWidget {
  final Color? accent;

  const KBackgroundGlow({super.key, this.accent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                KColors.gradientTop,
                KColors.gradientMid,
                KColors.gradientBottom,
              ],
            ),
          ),
          child: SizedBox.expand(),
        ),
        const Positioned(
            top: 70, left: -42, child: KOrb(size: 170, color: KColors.orbGreenA)),
        Positioned(
            top: 135,
            right: -65,
            child: KOrb(size: 170, color: accent ?? KColors.orbOrange)),
        const Positioned(
            bottom: 95, left: -60, child: KOrb(size: 210, color: KColors.orbGreenB)),
        const Positioned(
            bottom: -30, right: 14, child: KOrb(size: 145, color: KColors.orbGreenC)),
        const Positioned(
            top: 20, left: 30, child: KOrb(size: 170, color: KColors.orbPink)),
      ],
    );
  }
}

// ── Glass surface ────────────────────────────────────────────────────────────

class KGlassSurface extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const KGlassSurface({
    super.key,
    required this.child,
    this.width,
    this.height,
    required this.borderRadius,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: width ?? double.infinity,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.85), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.9),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Nav / top icon button ────────────────────────────────────────────────────

// 44x44 glass icon button. [active] turns the icon green (voice on);
// [hintPulse] shows the navy pulse background behind it.
class KNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool hintPulse;

  const KNavButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.hintPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: hintPulse
            ? KColors.navy.withValues(alpha: 0.85)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: KGlassSurface(
        width: 44,
        height: 44,
        borderRadius: 14,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: Icon(icon,
                  color: active ? KColors.green : KColors.navy, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

// The reference calls this widget "top button"; it is the same widget.
typedef KTopButton = KNavButton;

// ── Language pill (visual only) ──────────────────────────────────────────────

// Navy pill with the language code and a chevron. What happens on tap
// (opening the picker, switching language) is up to the caller.
class KLangPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const KLangPill({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: KColors.navy,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: KColors.navy.withValues(alpha: 0.20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Primary button ───────────────────────────────────────────────────────────

// Full-width navy gradient button: 64 high, radius 22, two shadows, green icon
// circle on the left, green arrow on the right.
class KPrimaryCta extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isRtl;
  final bool isSelected;
  final bool showSpeaker;
  final VoidCallback? onSpeaker;
  final VoidCallback onTap;

  const KPrimaryCta({
    super.key,
    required this.icon,
    required this.label,
    required this.isRtl,
    required this.isSelected,
    this.showSpeaker = false,
    this.onSpeaker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isSelected ? 0.75 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [KColors.ctaStart, KColors.ctaEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: KColors.ctaEnd.withValues(alpha: 0.30),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: KColors.green.withValues(alpha: 0.20),
              blurRadius: 26,
              offset: const Offset(14, 14),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                textDirection:
                    isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: KColors.green.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: KColors.green, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  if (showSpeaker && onSpeaker != null)
                    IconButton(
                      onPressed: onSpeaker,
                      icon: const Icon(Icons.volume_up, color: KColors.green),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  Icon(
                    isRtl
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_forward_rounded,
                    color: KColors.green,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Glass grid tile ──────────────────────────────────────────────────────────

// Translucent (not blurred) tile for the 2-column action grid: icon in a
// tinted circle over a short label. [compact] is the smaller size used when
// the grid holds 5 tiles.
class KGridTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isRtl;
  final bool showSpeaker;
  final VoidCallback? onSpeaker;
  final VoidCallback onTap;
  final bool compact;

  const KGridTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isRtl,
    this.showSpeaker = false,
    this.onSpeaker,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double iconBox  = compact ? 34 : 40;
    final double iconSize = compact ? 16 : 20;
    final double gap      = compact ? 6  : 8;
    final double pad      = compact ? 8  : 10;
    final double fontSize = compact ? 11 : 12;

    return Stack(
      children: [
        // SizedBox.expand forces the tile to fill the exact grid cell
        // regardless of label length.
        SizedBox.expand(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: iconBox,
                        height: iconBox,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: iconSize),
                      ),
                      SizedBox(height: gap),
                      Text(
                        label,
                        textDirection:
                            isRtl ? TextDirection.rtl : TextDirection.ltr,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: KColors.navy,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showSpeaker && onSpeaker != null)
          Positioned(
            top: 2,
            right: isRtl ? null : 2,
            left: isRtl ? 2 : null,
            child: IconButton(
              onPressed: onSpeaker,
              icon: const Icon(Icons.volume_up, color: KColors.green),
              iconSize: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
      ],
    );
  }
}

// ── Glass card ───────────────────────────────────────────────────────────────

// Translucent (not blurred) card with the same decoration as [KGridTile]:
// white 0.62 fill, white 0.85 border at 1.2, one black 0.06 shadow. Safe to
// use inside lists, because it never uses a BackdropFilter. [selected] gives
// the 2.0 green border and a 0.07 green tint.
class KGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;

  const KGlassCard({
    super.key,
    required this.child,
    required this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected
            ? KColors.green.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: selected ? KColors.green : Colors.white.withValues(alpha: 0.85),
          width: selected ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

// ── Snackbar ─────────────────────────────────────────────────────────────────

enum KSnackKind { info, success, error }

// Navy floating snackbar with radius 12 and white text. [success] and [error]
// only change the background (green with navy text, red with white text).
void kSnack(
  BuildContext context,
  String message, {
  KSnackKind kind = KSnackKind.info,
  Duration duration = const Duration(seconds: 4),
}) {
  final Color bg;
  final Color fg;
  switch (kind) {
    case KSnackKind.success:
      bg = KColors.green;
      fg = KColors.navy;
      break;
    case KSnackKind.error:
      bg = Colors.redAccent;
      fg = Colors.white;
      break;
    case KSnackKind.info:
      bg = KColors.navy;
      fg = Colors.white;
      break;
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: TextStyle(color: fg)),
    duration: duration,
    backgroundColor: bg,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));
}

// ═══════════════════════════════════════════════════════════════════════════
// Liquid Glass v2 (Phase 5)
//
// The dark-side counterpart of the light glass above: the blueprint's
// navy liquid backdrop + three glass levels for use ON that backdrop
// (home hero, floating dock, sheets over the hero). The light kit
// (KGlassSurface / KGlassCard) stays the system for the light form/list
// screens; both share the same accent, radii and blur language.
//
// Guardrails baked in (blueprint §4.3, CEO's own v1 rule):
//  * NO BackdropFilter inside scrolling list items - list items use the
//    translucent-solid variant ([KGlassPanel.inList] or [KGlassCard]).
//  * BackdropFilter only on static / hero / dock / sheet surfaces and
//    always inside a RepaintBoundary.
//  * Low-tier devices (see [KDeviceTier]) get half blur and a frozen
//    backdrop; form text always sits on a minimum-opacity floor.
// ═══════════════════════════════════════════════════════════════════════════

// ── Tokens ───────────────────────────────────────────────────────────────────

class KLiquid {
  KLiquid._();

  // Backdrop gradient (blueprint §4.1)
  static const Color navyTop = Color(0xFF091733);
  static const Color navyBottom = Color(0xFF0D2450);

  // Animated colour fields over the gradient
  static const Color fieldGreen = Color(0x0F39EA2B); // green at 6%
  static const Color fieldBlue = Color(0x1A2D6BE4); // blue at 10%

  // Glass levels on the dark backdrop: fill / border
  static const Color l1Fill = Color(0x1AFFFFFF); // white 10%
  static const Color l1Border = Color(0x2EFFFFFF); // white 18%
  static const Color l2Fill = Color(0x29FFFFFF); // white 16%
  static const Color l2Border = Color(0x3DFFFFFF); // white 24%
  static const Color l3Fill = Color(0x14FFFFFF); // white 8%
  static const Color l3Border = Color(0x2EFFFFFF); // white 18%

  static const double l1Blur = 18;
  static const double l2Blur = 26;
  static const double l3Blur = 30;

  // Text on the dark backdrop
  static const Color textOnDark = Colors.white;
  static const Color textOnDarkSoft = Color(0xFFDCE6F5);

  /// Minimum-opacity floor for glass that carries form text on the dark
  /// backdrop: the fill is composited over navy until it reaches this
  /// effective opacity, so text stays readable outdoors.
  static const double formTextFloor = 0.32;

  // Floating dock: navy-tinted L2 glass (reads as one system with the
  // navy CTA buttons and the language pill).
  static const Color dockFill = Color(0xD9091733); // navy at 85%
  static const Color dockBorder = Color(0x3DFFFFFF); // white 24%
  static const Color dockPillFill = Color(0x2E39EA2B); // green at 18%
  static const Color dockPillBorder = Color(0x5939EA2B); // green at 35%

  // Radii
  static const double radiusCard = 24;
  static const double radiusDock = 28;
  static const double radiusPill = 20;
}

/// Font family for a language code: Pashto/Dari render in the bundled
/// Noto Naskh Arabic, everything else in Roboto. Wired app-wide through
/// the MaterialApp theme (main.dart) and explicitly by the Phase 5
/// widgets (dock, dashboard) whose hosts build their own text styles.
String karyabFontFamily(String language) =>
    (language == 'ps' || language == 'fa') ? 'NotoNaskhArabic' : 'Roboto';

/// Fallback chain behind [karyabFontFamily]: Arabic first for ps/fa
/// (Latin digits/glyphs fall back to Roboto), Roboto first otherwise.
List<String> karyabFontFallback(String language) =>
    (language == 'ps' || language == 'fa')
        ? const ['Roboto']
        : const ['NotoNaskhArabic'];

// ── Device tier ──────────────────────────────────────────────────────────────

/// Heuristic performance tier, deliberately simple and channel-free.
///
/// A device counts as low tier when the OS asks for reduced animations
/// (accessibility or battery-saver driven) OR when its physical display
/// is in the 2.1 MP class or below (720p/900p panels, the weakest GPUs
/// KarYab ships to). 1080p devices (e.g. Redmi 9T) run the full glass;
/// even there, list items never blur (see [KGlassPanel.inList]).
/// [debugOverride] exists for tests and support builds.
class KDeviceTier {
  KDeviceTier._();

  static bool? debugOverride;

  static bool isLowTier(BuildContext context) {
    if (debugOverride != null) return debugOverride!;
    final mq = MediaQuery.of(context);
    if (mq.disableAnimations) return true;
    final physical = mq.size * mq.devicePixelRatio;
    return physical.width * physical.height <= 2100000;
  }

  /// Blur sigma for this device: full on standard tier, halved when low.
  static double blurFor(BuildContext context, double base) =>
      isLowTier(context) ? base / 2 : base;

  /// True when continuous animation must not run (system reduced motion
  /// or low tier).
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.of(context).disableAnimations || isLowTier(context);
}

// ── Liquid background ────────────────────────────────────────────────────────

/// The Phase 5 backdrop: navy gradient with two soft colour fields that
/// drift slowly against each other. The animation freezes (static first
/// frame) under reduced motion / low tier, and the whole layer is one
/// RepaintBoundary so the drift never repaints the content above it.
class LiquidBackground extends StatefulWidget {
  final Widget? child;

  const LiquidBackground({super.key, this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _fields(double t) {
    // t in [0,1]: fields ease between two resting positions.
    return Stack(
      children: [
        Positioned(
          top: -70 + 26 * t,
          left: -60 + 18 * t,
          child: const KOrb(size: 230, color: KLiquid.fieldGreen),
        ),
        Positioned(
          bottom: -80 + 20 * (1 - t),
          right: -50 + 24 * t,
          child: const KOrb(size: 260, color: KLiquid.fieldBlue),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduced = KDeviceTier.reduceMotion(context);
    if (reduced) {
      _controller?.stop();
    } else if (_controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 16),
      )..repeat(reverse: true);
    } else if (!_controller!.isAnimating) {
      _controller!.repeat(reverse: true);
    }
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [KLiquid.navyTop, KLiquid.navyBottom],
              ),
            ),
          ),
          if (reduced)
            _fields(0.35)
          else
            AnimatedBuilder(
              animation: _controller!,
              builder: (context, _) => _fields(
                Curves.easeInOut.transform(_controller!.value),
              ),
            ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

// ── Glass panel (dark backdrop levels) ───────────────────────────────────────

enum KGlassLevel { l1, l2, l3 }

/// A glass surface for the dark backdrop, at one of the three blueprint
/// levels. Use [inList] inside scrolling lists: the panel then renders
/// as a translucent solid (same fill/border/shadow, NO BackdropFilter),
/// per the performance guardrail.
class KGlassPanel extends StatelessWidget {
  final Widget child;
  final KGlassLevel level;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool inList;
  final VoidCallback? onTap;

  const KGlassPanel({
    super.key,
    required this.child,
    this.level = KGlassLevel.l1,
    this.borderRadius = KLiquid.radiusCard,
    this.padding = EdgeInsets.zero,
    this.inList = false,
    this.onTap,
  });

  (Color, Color, double) get _spec {
    switch (level) {
      case KGlassLevel.l1:
        return (KLiquid.l1Fill, KLiquid.l1Border, KLiquid.l1Blur);
      case KGlassLevel.l2:
        return (KLiquid.l2Fill, KLiquid.l2Border, KLiquid.l2Blur);
      case KGlassLevel.l3:
        return (KLiquid.l3Fill, KLiquid.l3Border, KLiquid.l3Blur);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fill, border, blur) = _spec;
    final decoration = BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: border, width: 1),
      boxShadow: level == KGlassLevel.l1
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
    );
    final Widget surface;
    if (inList) {
      surface = Container(
        padding: padding,
        decoration: decoration,
        child: child,
      );
    } else {
      surface = RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: KDeviceTier.blurFor(context, blur),
              sigmaY: KDeviceTier.blurFor(context, blur),
            ),
            child: Container(
              padding: padding,
              decoration: decoration,
              child: child,
            ),
          ),
        ),
      );
    }
    if (onTap == null) return surface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: surface,
      ),
    );
  }
}

// ── Liquid progress bar ──────────────────────────────────────────────────────

/// Liquid-fill progress bar: the fill animates to [value] with a
/// three-stop green gradient (dark edge, bright crest) that reads as a
/// liquid surface. Direction-aware: in RTL the fill grows from the
/// right. Reduced motion snaps instead of animating. [onDark] switches
/// the track to a white-based tone for the navy backdrop.
class KLiquidProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final bool onDark;

  const KLiquidProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final reduced = MediaQuery.of(context).disableAnimations;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: onDark
            ? Colors.white.withValues(alpha: 0.16)
            : KColors.green.withValues(alpha: 0.15),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: clamped),
          duration:
              reduced ? Duration.zero : const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: v,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0E7A20),
                      KColors.green,
                      Color(0xFF8CF582),
                    ],
                    stops: [0.0, 0.75, 1.0],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Press scale ──────────────────────────────────────────────────────────────

/// Wraps a tappable child with a subtle press scale (0.97). Purely
/// visual: it listens without consuming gestures, so the child's own
/// InkWell/onTap behaviour is unchanged. Reduced motion disables it.
class KPressScale extends StatefulWidget {
  final Widget child;

  const KPressScale({super.key, required this.child});

  @override
  State<KPressScale> createState() => _KPressScaleState();
}

class _KPressScaleState extends State<KPressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (!reduced) setState(() => _down = true);
      },
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: reduced ? Duration.zero : const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

// ── Glass skeleton (loading placeholder) ─────────────────────────────────────

/// One shimmering placeholder row for job/document lists, in glass tone.
/// Attach it to a REAL loading state only. The sweep is a slow opacity
/// pulse of the highlight band; reduced motion renders it static.
class KGlassSkeletonRow extends StatefulWidget {
  const KGlassSkeletonRow({super.key});

  @override
  State<KGlassSkeletonRow> createState() => _KGlassSkeletonRowState();
}

class _KGlassSkeletonRowState extends State<KGlassSkeletonRow>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _bar(double width, double height, double alpha) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: KColors.navy.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    if (!reduced && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat(reverse: true);
    }
    if (reduced) _controller?.stop();

    Widget content(double pulse) {
      return KGlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: KColors.navy.withValues(alpha: 0.06 + 0.05 * pulse),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(150, 12, 0.10 + 0.06 * pulse),
                  const SizedBox(height: 8),
                  _bar(100, 10, 0.07 + 0.05 * pulse),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (reduced || _controller == null) return content(0.5);
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, _) => content(_controller!.value),
    );
  }
}

// ── Floating glass dock ──────────────────────────────────────────────────────

class KDockItem {
  final IconData icon;
  final String label;

  const KDockItem({required this.icon, required this.label});
}

/// Floating L2 glass bottom dock with a sliding green glass pill behind
/// the active item. Purely presentational: the host owns navigation and
/// [currentIndex]. Direction-aware: pass the ambient [textDirection]
/// (RTL mirrors item order and pill travel automatically).
class KGlassDock extends StatelessWidget {
  final List<KDockItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final TextDirection textDirection;
  final String fontFamily;

  const KGlassDock({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.textDirection = TextDirection.ltr,
    this.fontFamily = 'Roboto',
  });

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return Directionality(
      textDirection: textDirection,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(KLiquid.radiusDock),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: KDeviceTier.blurFor(context, KLiquid.l2Blur),
              sigmaY: KDeviceTier.blurFor(context, KLiquid.l2Blur),
            ),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: KLiquid.dockFill,
                borderRadius: BorderRadius.circular(KLiquid.radiusDock),
                border: Border.all(color: KLiquid.dockBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / items.length;
                  return Stack(
                    children: [
                      AnimatedPositionedDirectional(
                        duration: reduced
                            ? Duration.zero
                            : const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        start: currentIndex * itemWidth + 6,
                        top: 7,
                        bottom: 7,
                        width: itemWidth - 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: KLiquid.dockPillFill,
                            borderRadius:
                                BorderRadius.circular(KLiquid.radiusPill),
                            border: Border.all(
                                color: KLiquid.dockPillBorder, width: 1),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      KLiquid.radiusPill),
                                  onTap: () => onTap(i),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        items[i].icon,
                                        size: 22,
                                        color: i == currentIndex
                                            ? KColors.green
                                            : Colors.white70,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        items[i].label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: fontFamily,
                                          fontSize: 10,
                                          fontWeight: i == currentIndex
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: i == currentIndex
                                              ? Colors.white
                                              : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet ─────────────────────────────────────────────────────────────

// White sheet with a 24 top radius. Use as the decoration of the sheet's
// outer Container (the route itself stays transparent) and put a
// [KSheetHandle] at the top of its content.
const BoxDecoration kSheetDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
);

// The 36x4 grab handle at the top of a sheet.
class KSheetHandle extends StatelessWidget {
  const KSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: KColors.handle,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
