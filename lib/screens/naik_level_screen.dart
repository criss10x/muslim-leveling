import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';
import '../theme/app_icons.dart';

/// Naik Level — selebrasi rank-up, satu layar crescendo.
/// Multi-level (levelsGained > 1) dikompres jadi satu layar "+N LEVEL",
/// bukan N layar berurutan — selebrasi, bukan struk kasir.
/// [source] opsional: amal pemicu ("Sholat Subuh", "Dzikir 100x") untuk
/// mengaitkan selebrasi dengan ibadahnya, bukan cuma angkanya.
class NaikLevelScreen extends StatefulWidget {
  final int? xpGained;
  final int levelsGained;
  final String? source;

  const NaikLevelScreen(
      {super.key, this.xpGained, this.levelsGained = 1, this.source});

  @override
  State<NaikLevelScreen> createState() => _NaikLevelScreenState();
}

class _NaikLevelScreenState extends State<NaikLevelScreen> {
  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final state = GameService.current;
    final info = GameService.getLevelInfo(state.xp);
    final level = info.level;
    final rankTitle = GameService.getRankTitle(level);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical -
                      AppSpacing.md * 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Semantics: screen reader mengumumkan momen sebagai satu
                    // kesatuan, bukan fragmen angka acak.
                    Semantics(
                      header: true,
                      child: Entrance(
                        delay: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        child: Text(
                          'NAIK LEVEL!',
                          textAlign: TextAlign.center,
                          style: AppText.displayHero(40).copyWith(
                            color: AppColors.secondaryFixed,
                            shadows: isLightTheme
                                ? null
                                : [
                                    Shadow(
                                      color: AppColors.secondaryFixed
                                          .withValues(alpha: 0.6),
                                      blurRadius: 20,
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Semantics(
                      label: 'Bulan sabit emas, lambang naik level',
                      child: Entrance(
                        delay: Duration.zero, // badge langsung terlihat dulu
                        child: const _CrescentBadge(size: 150),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Entrance(
                      delay: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 400),
                      child: Text(
                        'Masha Allah, kamu mencapai $rankTitle — Level $level',
                        textAlign: TextAlign.center,
                        style: AppText.bodyLg().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (widget.source != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Entrance(
                        delay: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 480),
                        child: Text(
                          'dari ${widget.source}',
                          textAlign: TextAlign.center,
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Entrance(
                      delay: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 550),
                      child: _rewards(level, rankTitle),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Entrance(
                      delay: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 700),
                      child: _closing(level),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Entrance(
                      delay: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 850),
                      child: HeroButton(
                        label: 'KEMBALI',
                        trailingIcon: AppIcons.arrowForward,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Confetti dihormati preference reduced motion.
          if (!reduceMotion)
            const Positioned.fill(child: ConfettiBurst(particleCount: 70)),
        ],
      ),
    );
  }

  /// Baris reward — semua angka milik level-up INI (satu layar crescendo,
  /// tidak ada mismatch step-1-dari-3 seperti versi lama).
  /// Chip XP disembunyikan bila xpGained null — jangan pernah tampil "+0".
  Widget _rewards(int level, String rankTitle) {
    return Semantics(
      label: widget.xpGained != null
          ? 'Hadiah: tambah ${widget.xpGained} XP, level $level, gelar baru $rankTitle'
          : 'Hadiah: level $level, gelar baru $rankTitle',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          if (widget.xpGained != null)
            _rewardChip('+${widget.xpGained}', 'XP', AppColors.primary, AppIcons.bolt),
          if (widget.levelsGained > 1)
            _rewardChip('+${widget.levelsGained} LEVEL', 'Lonjakan',
                AppColors.tertiary, AppIcons.doubleArrow),
          _rewardChip('Lv $level', 'Level', AppColors.secondaryFixed, AppIcons.trendingUp),
          _rewardChip(rankTitle, 'GELAR BARU', AppColors.tertiary, AppIcons.autoAwesome),
        ],
      ),
    );
  }

  Widget _rewardChip(String value, String label, Color color, IconData icon) {
    final light = isLightTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: light
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: AppText.headlineMd()
                      .copyWith(color: color, fontSize: 20)),
            ),
          ),
          Text(
            label,
            style: AppText.labelCaps().copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12, // ≥12: di atas floor keterbacaan
            ),
          ),
        ],
      ),
    );
  }

  /// Closing beat menggantikan panel "STATUS TERBARU" lama: satu baris
  /// progres menuju level berikutnya, bukan dashboard berkostum pesta.
  Widget _closing(int level) {
    final info = GameService.getLevelInfo(GameService.current.xp);
    final progress = info.xpNeededForNextLevel > 0
        ? info.xpInCurrentLevel / info.xpNeededForNextLevel
        : 0.0;
    return Semantics(
      label:
          'Menuju level ${level + 1}: ${info.xpInCurrentLevel} dari ${info.xpNeededForNextLevel} XP',
      child: Column(
        children: [
          Text(
            'Barakallah — terus istiqomah, level berikutnya menantimu ✨',
            textAlign: TextAlign.center,
            style:
                AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level ${level + 1}',
                        style: AppText.labelCaps()
                            .copyWith(color: AppColors.primary)),
                    Text(
                      '${info.xpInCurrentLevel}/${info.xpNeededForNextLevel} XP',
                      style: AppText.labelCaps()
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor:
                        AppColors.onSurface.withValues(alpha: 0.12),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bulan sabit + bintang emas — signifier identitas Muslim, digambar vektor
/// (tanpa asset), menggantikan medali workspace_premium generik.
class _CrescentBadge extends StatelessWidget {
  final double size;
  const _CrescentBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    final light = isLightTheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [AppColors.secondaryFixed, AppColors.secondaryContainer],
          ),
          boxShadow: light
              ? null
              : [
                  BoxShadow(
                    color: AppColors.secondaryFixed.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
        ),
        child: CustomPaint(painter: _CrescentPainter()),
      ),
    );
  }
}

/// Crescent = lingkaran besar dikurangi lingkaran offset (Path.combine),
/// plus bintang 4-sudut kecil di bukaan sabit.
class _CrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ink = AppColors.onSecondaryContainer;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.30;

    final outer = Path()..addOval(Rect.fromCircle(center: c, radius: r));
    final cut = Path()
      ..addOval(Rect.fromCircle(
          center: c + Offset(r * 0.45, -r * 0.25), radius: r * 0.85));
    final crescent = Path.combine(PathOperation.difference, outer, cut);
    canvas.drawPath(crescent, Paint()..color = ink);

    // Bintang kecil di bukaan sabit (kanan-atas).
    final star = c + Offset(r * 0.55, -r * 0.35);
    final sr = r * 0.22;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = (45 * i - 90) * math.pi / 180;
      final len = i.isEven ? sr : sr * 0.4;
      final p = star + Offset(len * math.cos(angle), len * math.sin(angle));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = ink);
  }

  @override
  bool shouldRepaint(covariant _CrescentPainter old) => false;
}
