import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/cosmetic_catalog.dart';
import '../theme/app_theme.dart';

/// Builds the avatar outline for a given [FrameShape]. Circle uses an oval,
/// square uses a rounded rect, shield tapers to a point at bottom-center.
/// Colors and tier effects are applied elsewhere — this is silhouette only.
Path buildFramePath(FrameShape shape, Size size, double radius) {
  final w = size.width, h = size.height;
  switch (shape) {
    case FrameShape.circle:
      return Path()..addOval(Offset.zero & size);
    case FrameShape.squareRounded:
      return Path()
        ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    case FrameShape.shieldClassic:
      final tip = h * 0.98;
      final shoulder = h * 0.62;
      return Path()
        ..moveTo(radius, 0)
        ..lineTo(w - radius, 0)
        ..arcToPoint(Offset(w, radius), radius: Radius.circular(radius))
        ..lineTo(w, shoulder)
        ..quadraticBezierTo(w, tip * 0.9, w / 2, tip)
        ..quadraticBezierTo(0, tip * 0.9, 0, shoulder)
        ..lineTo(0, radius)
        ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
        ..close();
  }
}

// ═══════════════════════════════════════════════════════════════
// TIER PROFILE AVATAR — Square rounded 16dp with progressive tier borders
//
// Tier progression (makin tinggi makin epik):
//   Warrior        — Solid 2dp purple
//   Elite          — Solid 3dp blue + corner accents
//   Master         — Gradient teal→emerald 3dp
//   Grandmaster    — Gradient gold→amber 4dp + soft glow
//   Epic           — Gradient crimson 4dp + animated glow pulse
//   Legend         — Gradient white→gold 4dp + rotating shimmer ring
//   Mythic         — Gradient crimson→gold 5dp + rotating ring + particles
//   Mythic Honor   — + double rotating ring (opposite directions)
//   Mythic Glory   — + animated sparkles on border
//   Mythic Immortal — Full legendary: crown emblem + all effects active
// ═══════════════════════════════════════════════════════════════

enum TierFrameAccent {
  none,
  sapphire,
  lavender,
  cyan,
  ultraviolet,
  magenta,
  obsidianOpal,
}

class TierVisualConfig {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final TierFrameAccent accent;
  final double borderWidth;
  final bool hasCornerAccents;
  final bool hasGlow;
  final bool hasPulsingGlow;
  final bool hasRotatingRing;
  final bool hasParticles;
  final bool hasDoubleRing;
  final bool hasSparkles;
  final bool hasCrownEmblem;
  final bool hasPartialOuterArcs;
  final bool hasFullOuterRing;
  final String? cornerEmblem;

  const TierVisualConfig({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    this.accent = TierFrameAccent.none,
    required this.borderWidth,
    this.hasCornerAccents = false,
    this.hasGlow = false,
    this.hasPulsingGlow = false,
    this.hasRotatingRing = false,
    this.hasParticles = false,
    this.hasDoubleRing = false,
    this.hasSparkles = false,
    this.hasCrownEmblem = false,
    this.hasPartialOuterArcs = false,
    this.hasFullOuterRing = false,
    this.cornerEmblem,
  });

  /// Light-safe ink for borders/icons on white cards. Dark keeps neon.
  // ponytail: map only; full dual-palette TierConfig if more roles appear.
  Color get inkPrimary => isLightTheme ? _lightInk(primaryColor, true) : primaryColor;
  Color get inkSecondary => isLightTheme ? _lightInk(secondaryColor, false) : secondaryColor;
}

// Neon → AA ink on white. Legend/Glory white becomes near-black.
Color _lightInk(Color c, bool primary) {
  final v = c.toARGB32() & 0xFFFFFF;
  switch (v) {
    case 0x8B5CF6: return const Color(0xFF5B21B6); // Warrior
    case 0x6366F1: return const Color(0xFF4338CA);
    case 0x3B82F6: return const Color(0xFF1D4ED8); // Elite
    case 0x06B6D4: return const Color(0xFF0E7490);
    case 0x14B8A6: return const Color(0xFF0F766E); // Master
    case 0x10B981: return const Color(0xFF047857);
    case 0xF59E0B: return const Color(0xFFB45309); // Grandmaster / Mythic gold
    case 0xFCD34D: return const Color(0xFFD97706);
    case 0xDC2626: return const Color(0xFFB91C1C); // Epic / Mythic red
    case 0xEC4899: return const Color(0xFFBE185D);
    case 0xFFFFFF: return primary
        ? const Color(0xFF1A1A1A) // Legend white → ink
        : const Color(0xFFB45309);
    case 0x6B7280: return const Color(0xFF4B5563);
    case 0x9CA3AF: return const Color(0xFF6B7280);
    default:
      // Fallback: darken ~35% toward black
      return Color.lerp(c, const Color(0xFF000000), 0.35)!;
  }
}

TierVisualConfig getTierVisualConfig(String tierName) {
  switch (tierName) {
    case 'Warrior':
      return const TierVisualConfig(
        name: 'Warrior',
        primaryColor: Color(0xFF8B5CF6),
        secondaryColor: Color(0xFF6366F1),
        borderWidth: 2,
      );
    case 'Elite':
      return const TierVisualConfig(
        name: 'Elite',
        primaryColor: Color(0xFF3B82F6),
        secondaryColor: Color(0xFF06B6D4),
        accent: TierFrameAccent.cyan,
        borderWidth: 3,
        hasCornerAccents: true,
        hasPartialOuterArcs: true,
      );
    case 'Master':
      return const TierVisualConfig(
        name: 'Master',
        primaryColor: Color(0xFF14B8A6),
        secondaryColor: Color(0xFF10B981),
        borderWidth: 3,
      );
    case 'Grandmaster':
      return const TierVisualConfig(
        name: 'Grandmaster',
        primaryColor: Color(0xFF2563EB),
        secondaryColor: Color(0xFF60A5FA),
        accent: TierFrameAccent.sapphire,
        borderWidth: 4,
        hasGlow: true,
      );
    case 'Epic':
      return const TierVisualConfig(
        name: 'Epic',
        primaryColor: Color(0xFFDC2626),
        secondaryColor: Color(0xFFEC4899),
        borderWidth: 4,
        hasGlow: true,
        hasPulsingGlow: true,
      );
    case 'Legend':
      return const TierVisualConfig(
        name: 'Legend',
        primaryColor: Color(0xFFA78BFA),
        secondaryColor: Color(0xFFE9D5FF),
        accent: TierFrameAccent.lavender,
        borderWidth: 4,
        hasGlow: true,
        hasRotatingRing: true,
        hasPartialOuterArcs: true,
      );
    case 'Mythic':
      return const TierVisualConfig(
        name: 'Mythic',
        primaryColor: Color(0xFF06B6D4),
        secondaryColor: Color(0xFF67E8F9),
        accent: TierFrameAccent.cyan,
        borderWidth: 5,
        hasGlow: true,
        hasRotatingRing: true,
        hasParticles: true,
        hasPartialOuterArcs: true,
      );
    case 'Mythic Honor':
      return const TierVisualConfig(
        name: 'Mythic Honor',
        primaryColor: Color(0xFF7C3AED),
        secondaryColor: Color(0xFFC084FC),
        accent: TierFrameAccent.ultraviolet,
        borderWidth: 5,
        hasGlow: true,
        hasRotatingRing: true,
        hasParticles: true,
        hasDoubleRing: true,
        hasPartialOuterArcs: true,
      );
    case 'Mythic Glory':
      return const TierVisualConfig(
        name: 'Mythic Glory',
        primaryColor: Color(0xFFDB2777),
        secondaryColor: Color(0xFFF0ABFC),
        accent: TierFrameAccent.magenta,
        borderWidth: 5,
        hasGlow: true,
        hasRotatingRing: true,
        hasParticles: true,
        hasDoubleRing: true,
        hasSparkles: true,
        hasPartialOuterArcs: true,
      );
    case 'Mythic Immortal':
      return const TierVisualConfig(
        name: 'Mythic Immortal',
        primaryColor: Color(0xFF111827),
        secondaryColor: Color(0xFFA7F3D0),
        accent: TierFrameAccent.obsidianOpal,
        borderWidth: 5,
        hasGlow: true,
        hasPulsingGlow: true,
        hasRotatingRing: true,
        hasParticles: true,
        hasDoubleRing: true,
        hasSparkles: true,
        hasCrownEmblem: true,
        hasFullOuterRing: true,
        cornerEmblem: '👑',
      );
    default:
      return const TierVisualConfig(
        name: 'Unknown',
        primaryColor: Color(0xFF6B7280),
        secondaryColor: Color(0xFF9CA3AF),
        borderWidth: 2,
      );
  }
}

/// Returns the tier name for a given level
String getTierName(int level) {
  if (level >= 95) return 'Mythic Immortal';
  if (level >= 90) return 'Mythic Glory';
  if (level >= 85) return 'Mythic Honor';
  if (level >= 80) return 'Mythic';
  if (level >= 60) return 'Legend';
  if (level >= 40) return 'Epic';
  if (level >= 30) return 'Grandmaster';
  if (level >= 20) return 'Master';
  if (level >= 10) return 'Elite';
  return 'Warrior';
}

/// Returns up to two uppercase initials, or a neutral fallback when absent.
String _displayInitials(String? displayName) {
  final words = displayName
      ?.trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words == null || words.isEmpty) return '?';
  return words.take(2).map((word) => word[0]).join().toUpperCase();
}

// ═══════════════════════════════════════════════════════════════
// TIER PROFILE AVATAR — Full animated version
// ═══════════════════════════════════════════════════════════════

class TierProfileAvatar extends StatefulWidget {
  final String? profileImagePath;
  final String? displayName;
  final bool isPro;
  final String tierName;
  final double sizeDp;
  final bool showEditBadge;
  final VoidCallback? onTap;
  final String equippedFrameId;
  final String equippedAuraId;

  const TierProfileAvatar({
    super.key,
    this.profileImagePath,
    this.displayName,
    this.isPro = false,
    required this.tierName,
    this.sizeDp = 120,
    this.showEditBadge = false,
    this.onTap,
    this.equippedFrameId = 'frame_default',
    this.equippedAuraId = 'aura_none',
  });

  @override
  State<TierProfileAvatar> createState() => _TierProfileAvatarState();
}

class _TierProfileAvatarState extends State<TierProfileAvatar>
    with TickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant TierProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tierName != widget.tierName ||
        oldWidget.equippedAuraId != widget.equippedAuraId) {
      _syncControllers();
    }
  }

  void _syncControllers() {
    if (_auraSpec != null) {
      if (!_particleController.isAnimating) _particleController.repeat();
    } else if (_particleController.isAnimating) {
      _particleController.stop();
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  FrameShape get _frameShape {
    final c = CosmeticCatalog.byId(widget.equippedFrameId);
    return c?.frameShape ?? FrameShape.circle;
  }

  AuraSpec? get _auraSpec => CosmeticCatalog.byId(widget.equippedAuraId)?.auraSpec;

  @override
  Widget build(BuildContext context) {
    final config = getTierVisualConfig(widget.tierName);
    final size = widget.sizeDp;
    final extraSize = size + 16; // space for effects
    final cornerRadius = 16.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: extraSize,
        height: extraSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Layer 1: Outer glow (Grandmaster+)
            if (config.hasGlow)
              _buildGlowLayer(config, size, cornerRadius),

            // Equipped-aura layer (independent of tier particles)
            if (_auraSpec != null)
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, _) => CustomPaint(
                  size: Size(size + 14, size + 14),
                  painter: _ParticlePainter(
                    color: _auraSpec!.goldTint
                        ? AppColors.goldFill
                        : config.inkSecondary,
                    phase: _particleController.value * 360,
                    particleCount: _auraSpec!.particleCount,
                  ),
                ),
              ),

            // Layer 2: Main avatar with a static earned-tier frame.
            _buildMainAvatar(config, size, cornerRadius),

            // Layer 3: Tier-specific static accent.
            IgnorePointer(
              child: CustomPaint(
                size: Size(size + 12, size + 12),
                painter: _TierAccentPainter(config: config),
              ),
            ),

            // Layer 4: Edit badge
            if (widget.showEditBadge)
              _buildEditBadge(size),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowLayer(TierVisualConfig config, double size, double cornerRadius) {
    if (isLightTheme) return const SizedBox.shrink();
    Widget glow(double glowAlpha) => Container(
          width: size + 12,
          height: size + 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cornerRadius + 6),
            boxShadow: [
              BoxShadow(
                color: config.inkPrimary.withValues(alpha: glowAlpha),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
        );
    return glow(0.4);
  }

  Widget _buildMainAvatar(TierVisualConfig config, double size, double cornerRadius) {
    final hasPhoto = widget.profileImagePath != null &&
        File(widget.profileImagePath!).existsSync();
    final bw = config.borderWidth;
    final p = config.inkPrimary;
    final s = config.inkSecondary;
    final light = isLightTheme;

    final content = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(bw),
      decoration: BoxDecoration(
        shape: _frameShape == FrameShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: _frameShape == FrameShape.circle
            ? null
            : BorderRadius.circular(cornerRadius),
        // Glow: dark only (light uses solid ink border, no neon halo).
        boxShadow: light
            ? null
            : [
                BoxShadow(
                  color: p.withValues(alpha: config.hasGlow ? 0.5 : 0.3),
                  blurRadius: config.hasGlow ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: s.withValues(alpha: config.hasGlow ? 0.4 : 0.2),
                  blurRadius: config.hasGlow ? 12 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
        color: light ? AppColors.surfaceContainerLow : AppColors.background,
      ),
      child: ClipPath(
        clipper: _FrameClipper(_frameShape, cornerRadius - bw),
        child: hasPhoto
            ? Image.file(
                File(widget.profileImagePath!),
                fit: BoxFit.cover,
                width: size,
                height: size,
                // Decode at display size — full-res camera photos are multi-MB.
                cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
                cacheHeight: (size * MediaQuery.devicePixelRatioOf(context)).round(),
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              )
            : Container(
                color: light ? AppColors.surfaceContainerHigh : AppColors.background,
                alignment: Alignment.center,
                child: Text(
                  _displayInitials(widget.displayName),
                  style: TextStyle(
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w700,
                    color: p,
                  ),
                ),
              ),
      ),
    );

    return CustomPaint(
      foregroundPainter: _GradientBorderPainter(
        primaryColor: p,
        secondaryColor: s,
        strokeWidth: bw,
        cornerRadius: cornerRadius,
        rotation: 0,
        shape: _frameShape,
      ),
      child: content,
    );
  }

  Widget _buildEditBadge(double size) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.goldFill],
          ),
          border: Border.all(
            color: isLightTheme ? AppColors.surfaceContainerLow : AppColors.background,
            width: 2,
          ),
          // Soft drop on dark only — light uses solid border for depth.
          boxShadow: isLightTheme
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: const Text('📷', style: TextStyle(fontSize: 14)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SMALL TIER AVATAR — Simplified version for top bars (40dp)
// Only shows border color + photo, no animations (perf-friendly)
// ═══════════════════════════════════════════════════════════════

class SmallTierAvatar extends StatelessWidget {
  final String? profileImagePath;
  final String? displayName;
  final String tierName;
  final double sizeDp;
  final String equippedFrameId;

  const SmallTierAvatar({
    super.key,
    this.profileImagePath,
    this.displayName,
    required this.tierName,
    this.sizeDp = 40,
    this.equippedFrameId = 'frame_default',
  });

  FrameShape get _frameShape {
    final c = CosmeticCatalog.byId(equippedFrameId);
    return c?.frameShape ?? FrameShape.circle;
  }

  @override
  Widget build(BuildContext context) {
    final config = getTierVisualConfig(tierName);
    final cornerRadius = 10.0;
    final effectiveBorderWidth = config.borderWidth > 2 ? 2.0 : config.borderWidth;
    final hasPhoto = profileImagePath != null &&
        File(profileImagePath!).existsSync();

    return SizedBox(
      width: sizeDp,
      height: sizeDp,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            foregroundPainter: _GradientBorderPainter(
              primaryColor: config.primaryColor,
              secondaryColor: config.secondaryColor,
              strokeWidth: effectiveBorderWidth,
              cornerRadius: cornerRadius,
              rotation: 0,
              shape: _frameShape,
            ),
            child: Container(
        width: sizeDp,
        height: sizeDp,
        padding: EdgeInsets.all(effectiveBorderWidth),
        decoration: BoxDecoration(
          shape: _frameShape == FrameShape.circle
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: _frameShape == FrameShape.circle
              ? null
              : BorderRadius.circular(cornerRadius),
          boxShadow: isLightTheme
              ? null
              : [
                  BoxShadow(
                    color: config.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
          color: isLightTheme
              ? AppColors.surfaceContainerHigh
              : AppColors.background,
        ),
        child: ClipPath(
          clipper: _FrameClipper(_frameShape, cornerRadius - effectiveBorderWidth),
          child: hasPhoto
              ? Image.file(
                  File(profileImagePath!),
                  fit: BoxFit.cover,
                  width: sizeDp,
                  height: sizeDp,
                  cacheWidth:
                      (sizeDp * MediaQuery.devicePixelRatioOf(context)).round(),
                  cacheHeight:
                      (sizeDp * MediaQuery.devicePixelRatioOf(context)).round(),
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                )
              : Center(
                  child: Text(
                    _displayInitials(displayName),
                    style: TextStyle(
                      fontSize: sizeDp * 0.32,
                      fontWeight: FontWeight.w700,
                      color: config.inkPrimary,
                    ),
                  ),
                ),
        ),
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              size: Size(sizeDp, sizeDp),
              painter: _TierAccentPainter(config: config, compact: true),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTERS — Canvas effects for tiers
// ═══════════════════════════════════════════════════════════════

class _TierAccentPainter extends CustomPainter {
  final TierVisualConfig config;
  final bool compact;

  _TierAccentPainter({required this.config, this.compact = false});

  Paint _paint(Color color, {PaintingStyle style = PaintingStyle.stroke}) => Paint()
    ..color = color
    ..style = style
    ..strokeWidth = compact ? 1.25 : 2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - (compact ? 2 : 4);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final primary = config.inkPrimary;
    final secondary = config.inkSecondary;

    if (config.hasFullOuterRing) {
      canvas.drawCircle(center, radius, _paint(primary));
      _drawImmortalCrest(canvas, center, radius, secondary);
      return;
    }
    if (config.hasPartialOuterArcs &&
        (config.name == 'Elite' || config.name == 'Mythic Honor')) {
      final paint = _paint(secondary);
      canvas.drawArc(rect, 205 * pi / 180, 55 * pi / 180, false, paint);
      canvas.drawArc(rect, 25 * pi / 180, 55 * pi / 180, false, paint);
      return;
    }

    switch (config.accent) {
      case TierFrameAccent.sapphire:
        _drawDiamond(canvas, center, radius, primary);
        break;
      case TierFrameAccent.lavender:
        _drawSeal(canvas, center, radius, primary);
        break;
      case TierFrameAccent.cyan:
        _drawCrescent(canvas, center, radius, secondary);
        break;
      case TierFrameAccent.magenta:
        _drawConstellation(canvas, center, radius, secondary);
        break;
      case TierFrameAccent.obsidianOpal:
        _drawImmortalCrest(canvas, center, radius, secondary);
        break;
      case TierFrameAccent.none:
        if (config.name == 'Epic') _drawHex(canvas, center, radius, primary);
        break;
      case TierFrameAccent.ultraviolet:
        // Mythic Honor is handled by the explicit short-arc branch above.
        break;
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double radius, Color color) {
    final r = radius * 0.9;
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r, center.dy)
      ..lineTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r, center.dy)
      ..close();
    canvas.drawPath(path, _paint(color));
  }

  void _drawHex(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    final r = radius * 0.9;
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * pi / 180;
      final point = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path..close(), _paint(color));
  }

  void _drawSeal(Canvas canvas, Offset center, double radius, Color color) {
    final paint = _paint(color);
    canvas.drawCircle(center, radius * 0.84, paint);
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final inner = Offset(
          center.dx + radius * 0.9 * cos(angle), center.dy + radius * 0.9 * sin(angle));
      final outer = Offset(
          center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.drawLine(inner, outer, paint);
    }
  }

  void _drawCrescent(Canvas canvas, Offset center, double radius, Color color) {
    final outer = Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.8));
    final inner = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(center.dx + radius * 0.34, center.dy - radius * 0.08),
          radius: radius * 0.74));
    canvas.drawPath(Path.combine(PathOperation.difference, outer, inner), _paint(color, style: PaintingStyle.fill));
  }

  void _drawConstellation(Canvas canvas, Offset center, double radius, Color color) {
    final points = [
      Offset(center.dx - radius * 0.7, center.dy + radius * 0.25),
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.45),
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.12),
      Offset(center.dx + radius * 0.72, center.dy - radius * 0.3),
    ];
    final paint = _paint(color);
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
      canvas.drawCircle(points[i], compact ? 1.5 : 2.5, _paint(color, style: PaintingStyle.fill));
    }
    canvas.drawCircle(points.last, compact ? 1.5 : 2.5, _paint(color, style: PaintingStyle.fill));
    for (final offset in [const Offset(-0.55, -0.7), const Offset(0, -0.82), const Offset(0.55, -0.68)]) {
      final star = Offset(center.dx + radius * offset.dx, center.dy + radius * offset.dy);
      canvas.drawLine(Offset(star.dx - 2, star.dy), Offset(star.dx + 2, star.dy), paint);
      canvas.drawLine(Offset(star.dx, star.dy - 2), Offset(star.dx, star.dy + 2), paint);
    }
  }

  void _drawImmortalCrest(Canvas canvas, Offset center, double radius, Color color) {
    final r = radius * 0.62;
    final path = Path()
      ..moveTo(center.dx - r, center.dy + r * 0.7)
      ..lineTo(center.dx - r, center.dy - r * 0.65)
      ..lineTo(center.dx - r * 0.35, center.dy - r * 0.05)
      ..lineTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r * 0.35, center.dy - r * 0.05)
      ..lineTo(center.dx + r, center.dy - r * 0.65)
      ..lineTo(center.dx + r, center.dy + r * 0.7)
      ..close();
    canvas.drawPath(path, _paint(color));
  }

  @override
  bool shouldRepaint(covariant _TierAccentPainter oldDelegate) =>
      oldDelegate.config.name != config.name ||
      oldDelegate.config.accent != config.accent ||
      oldDelegate.compact != compact;
}

/// Gradient border — sweep gradient stroked around the avatar frame with a
/// thin glossy highlight on top for a metallic feel. [rotation] spins the
/// gradient (used by Grandmaster+ for a shimmering border).
class _GradientBorderPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;
  final double cornerRadius;
  final double rotation;
  final FrameShape shape;

  _GradientBorderPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.rotation,
    this.shape = FrameShape.squareRounded,
  });

  /// Builds the frame path inset by [inset] on every side (mirrors the old
  /// `Rect.deflate` behavior, but for an arbitrary [FrameShape] path).
  Path _insetFramePath(Size size, double inset) {
    final w = (size.width - inset * 2).clamp(0.0, size.width);
    final h = (size.height - inset * 2).clamp(0.0, size.height);
    final r = (cornerRadius - inset).clamp(0.0, cornerRadius);
    return buildFramePath(shape, Size(w, h), r).shift(Offset(inset, inset));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          primaryColor,
          secondaryColor,
          primaryColor,
          secondaryColor,
          primaryColor,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(rect);
    canvas.drawPath(_insetFramePath(size, strokeWidth / 2), borderPaint);

    // Glossy highlight — thin white stroke fading from the top edge.
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawPath(_insetFramePath(size, strokeWidth + 0.5), highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.shape != shape;
}

/// Clips avatar content to the equipped frame's silhouette.
class _FrameClipper extends CustomClipper<Path> {
  final FrameShape shape;
  final double radius;
  _FrameClipper(this.shape, this.radius);
  @override
  Path getClip(Size size) => buildFramePath(shape, size, radius);
  @override
  bool shouldReclip(covariant _FrameClipper old) =>
      old.shape != shape || old.radius != radius;
}

class _ParticlePainter extends CustomPainter {
  final Color color;
  final double phase;
  final int particleCount;

  _ParticlePainter({
    required this.color,
    required this.phase,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbitRadius = size.width / 2 - 2;

    for (int i = 0; i < particleCount; i++) {
      final angle = (phase + i * (360 / particleCount)) * pi / 180;
      final x = center.dx + orbitRadius * cos(angle);
      final y = center.dy + orbitRadius * sin(angle);
      final pAlpha = 0.5 + 0.5 * sin((phase + i * 60) * pi / 180);
      final clampedAlpha = pAlpha.clamp(0.2, 0.9);

      final paint = Paint()
        ..color = color.withValues(alpha: clampedAlpha);

      canvas.drawCircle(Offset(x, y), 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.phase != phase;
}
