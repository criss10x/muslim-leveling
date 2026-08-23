import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/game_service.dart';
import '../screens/naik_level_screen.dart';
import 'announcer_gate.dart';
import 'common.dart';

/// Popup selebrasi side quest selesai (dzikir 100x, baca Quran 10 ayat,
/// belajar 5 hadis) — pola sama dengan AchievementAnnouncerOverlay:
/// GameService mengisi pendingSideQuests, overlay ini (DashboardShell)
/// menampilkan.
///
/// Khushu'-friendly: popup fire di TENGAH ibadah (tap dzikir ke-100,
/// scroll Quran ayat ke-10), jadi selebrasi ditunda sebentar (debounce)
/// dan antrean >1 diruntuhkan jadi SATU kartu syukur "Alhamdulillah",
/// bukan N popup arcade beruntun.
class SideQuestAnnouncerOverlay extends StatefulWidget {
  const SideQuestAnnouncerOverlay({super.key});

  @override
  State<SideQuestAnnouncerOverlay> createState() =>
      _SideQuestAnnouncerOverlayState();
}

class _SideQuestAnnouncerOverlayState
    extends State<SideQuestAnnouncerOverlay> {
  bool _showing = false;

  // Jeda sebelum popup tampil: jangan menyergap tepat di tap terakhir —
  // beri napas dulu. ponytail: konstanta; tweak kalau terasa lambat/cepat.
  static const _debounce = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    GameService.pendingSideQuests.addListener(_drain);
    AnnouncerGate.busy.addListener(_drain);
    WidgetsBinding.instance.addPostFrameCallback((_) => _drain());
  }

  @override
  void dispose() {
    GameService.pendingSideQuests.removeListener(_drain);
    AnnouncerGate.busy.removeListener(_drain);
    super.dispose();
  }

  Future<void> _drain() async {
    if (_showing) return;
    _showing = true;
    while (mounted) {
      // Gerbang bersama: satu selebrasi pada satu waktu (medali & side
      // quest berbagi AnnouncerGate — logPrayerAsync bisa mengisi kedua
      // notifier sekaligus). Cek+set sinkron sebelum await = aman.
      if (AnnouncerGate.busy.value) break;
      final q = GameService.pendingSideQuests.value;
      if (q.isEmpty) break;
      AnnouncerGate.busy.value = true;

      // Debounce khushu': jangan menyela tepat di aksi terakhir.
      await Future<void>.delayed(_debounce);
      if (mounted) {
        // Ambil ulang: quest baru bisa masuk selama debounce → runtuhkan.
        final all = GameService.pendingSideQuests.value;
        GameService.pendingSideQuests.value = const [];
        if (all.isNotEmpty) {
          final levels = all.fold<int>(0, (a, e) => a + e.$2);
          await _show(context, all.map((e) => e.$1).toList());
          // Claim side quest bisa memicu naik level — rayakan setelahnya,
          // seperti alur claim sholat di HomeTab.
          if (mounted && levels > 0) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NaikLevelScreen(
                  levelsGained: levels,
                  source: switch (all.first.$1) {
                    'zikir100' => 'Dzikir 100x',
                    'tilawah' => 'Baca Quran',
                    _ => 'Belajar Hadis',
                  },
                ),
              ),
            );
          }
        }
      }
      AnnouncerGate.busy.value = false;
    }
    _showing = false;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Popup selebrasi — quest tunggal atau runtuhannya. Await sampai ditutup.
Future<void> _show(BuildContext context, List<String> quests) async {
  final reduceMotion = MediaQuery.of(context).disableAnimations;
  final combined = quests.length > 1;
  // ponytail: +15 XP per quest adalah konstanta side quest di GameService;
  // angka di sini mengikuti konstanta itu (drift-nya satu arah).
  final xp = quests.length * 15;

  final (title, desc, icon, color) = combined
      ? (
          'Alhamdulillah, ${quests.length} Quest Tuntas!',
          'Semua quest harian selesai hari ini. Semoga istiqomah!',
          Icons.military_tech,
          AppColors.secondaryFixed,
        )
      : switch (quests.single) {
          'zikir100' => (
              'Dzikir 100x Selesai!',
              'Konsisten berdzikir hari ini. Istiqomah!',
              Icons.self_improvement,
              AppColors.primary,
            ),
          'tilawah' => (
              'Baca Quran 10 Ayat Selesai!',
              'Tilawah hari ini tuntas. Lanjutkan besok!',
              Icons.menu_book,
              AppColors.tertiary,
            ),
          _ => (
              'Belajar 5 Hadis Selesai!',
              'Lima hadis baru terbaca hari ini. Terus belajar!',
              Icons.auto_stories,
              AppColors.secondaryFixed,
            ),
        };

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'side quest selesai',
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
              child: Semantics(
                label: '$title. $desc. Bonus $xp XP.',
                child: GlassPanel(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  borderColor: color.withValues(alpha: 0.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        combined ? 'QUEST HARIAN TUNTAS' : 'QUEST SELESAI',
                        style: AppText.labelCaps().copyWith(
                          color: color,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: reduceMotion ? 1.0 : 0.6, end: 1.0),
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 700),
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
                      Semantics(
                        header: true,
                        child: Text(
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
                        '+$xp XP',
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
            ),
            // Confetti dihormati preference reduced motion.
            if (!reduceMotion)
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
