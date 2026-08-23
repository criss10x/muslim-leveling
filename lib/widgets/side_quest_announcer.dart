import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/game_service.dart';
import '../screens/naik_level_screen.dart';
import 'common.dart';

/// Antrean global popup "side quest selesai" — pola sama dengan
/// AchievementAnnouncerOverlay: GameService (tanpa context) mengisi
/// pendingSideQuests, overlay ini (dipasang sekali di DashboardShell)
/// menampilkan pop-up selebrasi dari flow mana pun (dzikir/quran/hadis).
class SideQuestAnnouncerOverlay extends StatefulWidget {
  const SideQuestAnnouncerOverlay({super.key});

  @override
  State<SideQuestAnnouncerOverlay> createState() =>
      _SideQuestAnnouncerOverlayState();
}

class _SideQuestAnnouncerOverlayState
    extends State<SideQuestAnnouncerOverlay> {
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    GameService.pendingSideQuests.addListener(_drain);
    WidgetsBinding.instance.addPostFrameCallback((_) => _drain());
  }

  @override
  void dispose() {
    GameService.pendingSideQuests.removeListener(_drain);
    super.dispose();
  }

  Future<void> _drain() async {
    if (_showing) return;
    _showing = true;
    while (mounted) {
      final q = GameService.pendingSideQuests.value;
      if (q.isEmpty) break;
      GameService.pendingSideQuests.value = const [];
      for (final e in q) {
        if (!mounted) break;
        await _show(context, e.$1);
        // Claim side quest +15 XP bisa memicu naik level — rayakan setelah
        // popup quest ditutup, seperti alur claim sholat di HomeTab.
        if (mounted && e.$2 > 0) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NaikLevelScreen(levelsGained: e.$2),
            ),
          );
        }
      }
    }
    _showing = false;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Popup selebrasi side quest — gaya perayaan ala NaikLevel/medali:
/// icon besar elastis + confetti + tombol. Await sampai ditutup.
Future<void> _show(BuildContext context, String quest) async {
  final (title, desc, icon, color) = switch (quest) {
    'zikir100' => (
        'Dzikir 100x Selesai!',
        'Konsisten berdzikir hari ini. Istiqomah! ✨',
        Icons.self_improvement,
        AppColors.primary,
      ),
    'tilawah' => (
        'Baca Quran 10 Ayat Selesai!',
        'Tilawah hari ini tuntas. Lanjutkan besok! 🌙',
        Icons.menu_book,
        AppColors.tertiary,
      ),
    _ => (
        'Belajar 5 Hadis Selesai!',
        'Lima hadis baru terbaca hari ini. Terus belajar! 📖',
        Icons.auto_stories,
        AppColors.secondaryFixed,
      ),
  };

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'side quest',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
    ),
    pageBuilder: (ctx, _, __) => Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: GlassPanel(
                padding: const EdgeInsets.all(AppSpacing.xl),
                borderColor: color.withValues(alpha: 0.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SIDE QUEST SELESAI!',
                      style: AppText.labelCaps().copyWith(
                        color: color,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.6, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (_, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              color.withValues(alpha: 0.9),
                              color.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 64),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppText.displayHero(26).copyWith(
                        color: color,
                        shadows: isLightTheme
                            ? null
                            : [
                                Shadow(
                                  color: color.withValues(alpha: 0.7),
                                  blurRadius: 18,
                                ),
                              ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      desc,
                      textAlign: TextAlign.center,
                      style: AppText.bodyMd()
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '+15 XP',
                      style: AppText.headlineMd().copyWith(color: color),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    HeroButton(
                      label: 'MANTAP!',
                      trailingIcon: Icons.emoji_events,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: ConfettiBurst(particleCount: 45),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
