import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/tier_avatar.dart';
import '../../services/game_service.dart';
import '../../services/prayer_service.dart';
import '../../services/notification_service.dart';
import '../../services/achievement_service.dart';
import '../../widgets/xp_toast.dart';
import 'naik_level_screen.dart';
import 'quest_claim_screen.dart';
import 'dzikir_screen.dart';
import 'hadis_screen.dart';
import 'doa_screen.dart';
import 'qibla_screen.dart';
import 'daily_highlight_screen.dart';
import '../theme/app_icons.dart';
import '../l10n/app_localizations.dart';

/// Baris Bonus Quest Sunnah — urut waktu ibadah.
/// ponytail: SATU daftar dipakai dua tempat (list di `_BonusQuest` dan
/// denominator ring di `_ritualRings`). Sebelumnya ring memakai literal `/8`
/// terpisah, jadi daftar bisa jadi 9 baris sementara ring tetap bilang 8 —
/// tanpa satu pun tes gagal. Panjangnya wajib == `GameService.sunnahKeys`.
/// ponytail: teks (nama + keterangan) tidak lagi di tabel — diambil dari ARB
/// lewat [_sunnahText]. Tabel ini hanya memegang kunci + ikon.
const _sunnahQuests = <(String, IconData)>[
  ('dhuha', AppIcons.wbSunny),
  ('tahajjud', AppIcons.nightsStay),
  ('rawatib_subuh_qobliyah', AppIcons.history),
  ('rawatib_dzuhur_qobliyah', AppIcons.history),
  ('rawatib_dzuhur_ba_diyyah', AppIcons.history),
  ('rawatib_ashar_qobliyah', AppIcons.history),
  ('rawatib_maghrib_ba_diyyah', AppIcons.history),
  ('rawatib_isya_ba_diyyah', AppIcons.history),
];

/// Nama + keterangan satu baris Bonus Quest, dalam bahasa aktif.
/// Kunci tak dikenal jatuh ke kunci mentah (bukan crash) — isi switch ini dan
/// tabel di atas wajib sama, dikunci `sunnah_home_ring_test`.
(String, String) _sunnahText(String key, AppL10n l10n) => switch (key) {
  'dhuha' => (l10n.sunnahDhuhaName, l10n.sunnahDhuhaDesc),
  'tahajjud' => (l10n.sunnahTahajjudName, l10n.sunnahTahajjudDesc),
  'rawatib_subuh_qobliyah' => (
    l10n.sunnahQobliyahSubuhName,
    l10n.sunnahQobliyahSubuhDesc,
  ),
  'rawatib_dzuhur_qobliyah' => (
    l10n.sunnahQobliyahDzuhurName,
    l10n.sunnahQobliyahDzuhurDesc,
  ),
  'rawatib_dzuhur_ba_diyyah' => (
    l10n.sunnahBadiyahDzuhurName,
    l10n.sunnahBadiyahDzuhurDesc,
  ),
  'rawatib_ashar_qobliyah' => (
    l10n.sunnahQobliyahAsharName,
    l10n.sunnahQobliyahAsharDesc,
  ),
  'rawatib_maghrib_ba_diyyah' => (
    l10n.sunnahBadiyahMaghribName,
    l10n.sunnahBadiyahMaghribDesc,
  ),
  'rawatib_isya_ba_diyyah' => (
    l10n.sunnahBadiyahIsyaName,
    l10n.sunnahBadiyahIsyaDesc,
  ),
  _ => (key, ''),
};

/// Nama sholat untuk UI, dari ARB. Dipakai header sheet bonus, label baris
/// WAJIB QUEST, dan sumber layar naik-level.
String _prayerName(String key, AppL10n l10n) => switch (key) {
  'subuh' => l10n.prayerSubuh,
  'dzuhur' => l10n.prayerDzuhur,
  'ashar' => l10n.prayerAshar,
  'maghrib' => l10n.prayerMaghrib,
  'isya' => l10n.prayerIsya,
  _ => key,
};

/// Home / Dashboard Utama — live game logic (port V3), design preserved.
class HomeTab extends StatefulWidget {
  final VoidCallback? onSettingsPressed;
  const HomeTab({super.key, this.onSettingsPressed});

  /// Kunci sunnah yang benar-benar dirender baris Bonus Quest. Dipakai tes
  /// untuk mengunci kesamaan dengan GameService.sunnahKeys + ring denominator.
  @visibleForTesting
  static List<String> get bonusSunnahKeys =>
      [for (final q in _sunnahQuests) q.$1];
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GameState _state = GameState();
  String _nickname = '';
  String _claimingQuestId = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    // ponytail: load in background; never block the first paint
    _load(showLoading: false);
    // Rebuild when game state changes (prayer log, quests, XP) from other tabs.
    GameService.stateVersion.addListener(_onStateChanged);
    // Kota diganti dari tab jadwal/profil → refetch timing kota baru
    // (sekalian reschedule notif adzan di _fetchTimingsSilently).
    PrayerService.locationVersion.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    GameService.stateVersion.removeListener(_onStateChanged);
    PrayerService.locationVersion.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() => _state = GameService.current);
  }

  Future<void> _onLocationChanged() async {
    await _fetchTimingsSilently();
    if (mounted) setState(() => _state = GameService.current);
  }

  Future<void> _load({bool showLoading = true}) async {
    _error = '';
    try {
      // Sequential game mutations first — runDailyCheck / ensureDailyQuests
      // write GameService.current; achievements need the post-mutation snapshot.
      await GameService.load();
      await GameService.runDailyCheck();
      await GameService.ensureDailyQuests();
      // Independent I/O after state is settled.
      late SharedPreferences p;
      await Future.wait([
        // Backfill diam-diam: progress lama (mis. streak sebelum update app)
        // langsung terisi tanpa memberondong popup saat buka.
        AchievementService.refresh(silent: true),
        _fetchTimingsSilently(),
        SharedPreferences.getInstance().then((v) => p = v),
      ]);
      if (mounted) {
        setState(() {
          _state = GameService.current;
          _nickname = p.getString('nickname') ?? '';
        });
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('HOME_LOAD_ERROR: $e\n$st');
      if (mounted) setState(() => _error = e.toString());
    } finally {
      // ponytail: no loading flag to reset
    }
  }

  Future<void> _fetchTimingsSilently() async {
    try {
      final loc = await PrayerService.loadLocation();
      if (loc == null) return;
      final j = await PrayerService.fetchSchedule(
        cityId: loc.id,
        cityName: loc.name,
      ).timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (j != null) {
        await GameService.setTimings(
          Timings(
            imsak: j['imsak'] ?? '04:30',
            subuh: j['subuh'] ?? '04:42',
            terbit: j['terbit'] ?? '05:55',
            dhuha: j['dhuha'] ?? '06:20',
            dzuhur: j['dzuhur'] ?? '12:01',
            ashar: j['ashar'] ?? '15:20',
            maghrib: j['maghrib'] ?? '17:55',
            isya: j['isya'] ?? '19:08',
          ),
        );
        // Schedule adhan reminders if enabled
        if (await NotificationService.isRemindersEnabled()) {
          await NotificationService.scheduleAdhanReminders(loc.name, {
            'imsak': j['imsak'] ?? '04:30',
            'subuh': j['subuh'] ?? '04:42',
            'terbit': j['terbit'] ?? '05:55',
            'dzuhur': j['dzuhur'] ?? '12:01',
            'ashar': j['ashar'] ?? '15:20',
            'maghrib': j['maghrib'] ?? '17:55',
            'isya': j['isya'] ?? '19:08',
          });
        }
      }
    } catch (_) {
      // ponytail: timings are optional; never let this block home
    }
  }

  Future<void> _togglePrayer(String prayer, String type) async {
    // Di luar window (mis. Subuh lewat 3 jam dari adzan) status beku —
    // tidak bisa dicentang ataupun dibatalkan lagi.
    if (type == 'wajib' &&
        !GameService.isPrayerWindowOpen(prayer, _state.timings)) {
      _toast(
        '🔒 ${GameService.wajibLockHint(prayer, _state.timings, AppL10n.of(context))}',
      );
      return;
    }
    final isLogged = GameService.isPrayerCheckedToday(prayer);
    if (isLogged) {
      final s = await GameService.unlogPrayer(prayer);
      if (!mounted) return;
      setState(() => _state = s);
      return;
    }
    if (type == 'sunnah' &&
        !GameService.isSunnahOnTime(prayer, _state.timings)) {
      _toast('⏰ ${GameService.sunnahHint(prayer, AppL10n.of(context))}');
      return;
    }
    var bonusXp = 0;
    if (type == 'wajib') {
      final chosen = await _askWajibBonus(prayer);
      if (chosen == null) return; // sheet ditutup — batalkan claim
      bonusXp = chosen;
    }
    final res = await GameService.logPrayerAsync(prayer, type, bonusXp: bonusXp);
    if (!mounted) return;
    if (res == null) {
      _toast(AppL10n.of(context).homeLogDuplicate);
      return;
    }
    setState(() => _state = res.$1);
    final (_, xp, levelsGained) = res;
    showXpToast(context, xp);
    // Medali baru → antrean announcer global (overlay DashboardShell).
    await AchievementService.refresh();
    if (levelsGained > 0 && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NaikLevelScreen(
              xpGained: xp,
              levelsGained: levelsGained,
              source: AppL10n.of(
                context,
              ).homeLevelUpSource(_prayerName(prayer, AppL10n.of(context)))),
        ),
      );
    }
  }

  /// Bottom sheet: pilih bonus XP saat claim sholat wajib.
  /// Returns bonus XP (0/15/30) atau null kalau sheet ditutup tanpa pilih.
  Future<int?> _askWajibBonus(String prayer) {
    final l10n = AppL10n.of(context);
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.homeAskWajibTitle(_prayerName(prayer, l10n)),
                style: AppText.titleLg().copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.homeAskWajibBody,
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _bonusTile(
                ctx,
                icon: AppIcons.schedule,
                title: l10n.homeBonusOnTime,
                subtitle: l10n.homeBonusOnTimeSub,
                xpLabel: '+15 XP',
                accent: AppColors.primary,
                onTap: () => Navigator.pop(ctx, GameService.timelyBonusXp),
              ),
              _bonusTile(
                ctx,
                icon: AppIcons.mosque,
                title: l10n.homeBonusJamaah,
                subtitle: l10n.homeBonusJamaahSub,
                xpLabel: '+30 XP',
                accent: AppColors.secondaryContainer,
                onTap: () => Navigator.pop(ctx, GameService.jamaahBonusXp),
              ),
              _bonusTile(
                ctx,
                icon: AppIcons.check,
                title: l10n.homeBonusPlain,
                subtitle: l10n.homeBonusPlainSub,
                xpLabel: '+0',
                accent: AppColors.onSurfaceVariant,
                onTap: () => Navigator.pop(ctx, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bonusTile(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String xpLabel,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.bodyLg().copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(xpLabel, style: AppText.labelCaps().copyWith(color: accent)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _claimQuest(Quest q) async {
    if (!q.completed || q.claimed || _claimingQuestId.isNotEmpty) return;
    setState(() => _claimingQuestId = q.id);
    final (s, levelsGained) = await GameService.claimQuest(q.id);
    if (!mounted) return;
    setState(() {
      _state = s;
      _claimingQuestId = '';
    });
    showXpToast(context, q.xpReward);
    // XP quest bisa memicu medali rank (WARRIOR..MYTHIC).
    await AchievementService.refresh();
    // Quest harian claim event: kalau level-up, NaikLevelScreen menang
    // (register riang + confetti, sudah jadi expected user feedback).
    // Kalau tidak, tampilkan QuestClaimScreen — layar singkat hangat
    // yang affirmative ("Alhamdulillah", quote islami, dorongan).
    // NaikLevelScreen lama masih jalan untuk events yang naik rank.
    if (levelsGained > 0 && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NaikLevelScreen(
              xpGained: q.xpReward,
              levelsGained: levelsGained,
              source: q.desc),
        ),
      );
    } else if (mounted) {
      final claimed = _state.quests.where((x) => x.claimed).length;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestClaimScreen(
            quest: q,
            xpGained: q.xpReward,
            claimedTodayCount: claimed,
            isHaidMode: _state.haidMode,
          ),
        ),
      );
    }
  }

  void _toast(String msg, {bool top = false}) {
    final screenHeight = MediaQuery.of(context).size.height;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: top ? EdgeInsets.only(bottom: screenHeight - 80) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = GameService.getLevelInfo(_state.xp);
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _load(showLoading: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 100),
            children: [
              _section(0, _appBar(context)),
              const SizedBox(height: AppSpacing.md),
              _section(1, _heroRank(info)),
              const SizedBox(height: AppSpacing.sm),
              _section(2, _hudStrip()),
              const SizedBox(height: AppSpacing.lg),
              _section(3, _ritualRings()),
              const SizedBox(height: AppSpacing.lg),
              _section(4, _quickActions()),
              const SizedBox(height: AppSpacing.lg),
              _section(5, _prayerQuests()),
              const SizedBox(height: AppSpacing.lg),
              _section(6, _dailyChest()),
              const SizedBox(height: AppSpacing.lg),
              if (_state.quests.isNotEmpty) _section(7, _questList()),
              if (_state.quests.isNotEmpty)
                const SizedBox(height: AppSpacing.lg),
              _section(8, _BonusQuest(state: _state, onToggle: (id) => _togglePrayer(id, 'sunnah'))),
              const SizedBox(height: AppSpacing.lg),
              _section(9, _sideQuest(context)),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'DEBUG: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wrapper — langsung tanpa Entrance.
  Widget _section(int index, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: child,
    );
  }

  // ── HUD chrome budget ─────────────────────────────────────────────
  // Redesign minimalis: glow & border HANYA di (1) hero Status Window,
  // (2) baris "aktif sekarang" (cyan hairline), (3) shimmer claimable.
  // Kartu tenang pakai FlatCard, header pakai HudHeader (common.dart).

  Widget _appBar(BuildContext context) {
    return Row(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          child: Image.asset(
            'assets/images/logo_mark.png',
            width: 22,
            height: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          AppL10n.of(context).appTitle.toUpperCase(),
          style: AppText.labelCaps().copyWith(
            color: AppColors.onSurface,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            AppIcons.settingsOutlined,
            color: AppColors.onSurfaceVariant,
          ),
          onPressed: widget.onSettingsPressed,
        ),
      ],
    );
  }

  Widget _heroRank(LevelInfo info) {
    final tier = getTierVisualConfig(getTierName(info.level));
    final light = isLightTheme;
    final tierP = tier.inkPrimary;
    final tierS = tier.inkSecondary;
    final heroAccent = light ? AppColors.primary : tier.inkPrimary;
    final heroWash = light ? AppColors.primaryContainer : tier.inkPrimary;
    return Container(
      key: const Key('home-hero-card'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: light
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.4,
                      colors: [
                        heroWash.withValues(alpha: light ? 0.62 : 0.14),
                        AppColors.surfaceContainerLow,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: light ? 0.22 : 0.45,
                      ),
                      width: light ? 1.0 : 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  key: const Key('home-hero-pattern'),
                  painter: _IslamicHeroPatternPainter(
                    color: heroAccent,
                    opacity: light ? 0.05 : 0.09,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT RANK',
                              style: AppText.labelCaps().copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Light: bright tier colors (some are white/gold)
                            // vanish on the near-white card — use solid ink.
                            // Dark: keep the tier gradient (gaming identity).
                            isLightTheme
                                ? Text(
                                    GameService.getRankTitle(info.level),
                                    style: AppText.headlineMd().copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : ShaderMask(
                                    shaderCallback: (rect) => LinearGradient(
                                      colors: [tierP, tierS],
                                    ).createShader(rect),
                                    child: Text(
                                      GameService.getRankTitle(info.level),
                                      style: AppText.headlineMd().copyWith(
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: tierP.withValues(alpha: 0.5),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                            Text(
                              '${_nickname.isEmpty ? AppL10n.of(context).appTitle : _nickname} • Lv ${info.level}',
                              style: AppText.bodyMd().copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _RankMedallion(
                        tier: tier,
                        level: info.level,
                        light: light,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'XP PROGRESS',
                          style: AppText.labelCaps().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedCount(
                        value: info.xpInCurrentLevel,
                        suffix: ' / ${info.xpNeededForNextLevel}',
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: info.progress.clamp(0.0, 1.0),
                        ),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (context, progress, child) =>
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: child,
                            ),
                        child: Container(
                          key: const Key('home-xp-progress-fill'),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [tier.inkPrimary, tier.inkSecondary],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            boxShadow: light
                                ? null
                                : [
                                    BoxShadow(
                                      color: tier.inkPrimary.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedCount(
                      value: info.xpNeededForNextLevel - info.xpInCurrentLevel,
                      suffix:
                          ' ${AppL10n.of(context).homeXpToNextRank}',
                      style: AppText.labelCaps().copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Satu strip HUD datar menggantikan 3 kartu (sholat aktif, next, streak).
  /// Cyan hanya untuk "sekarang", gold hanya untuk streak — disiplin warna.
  Widget _hudStrip() {
    final current = GameService.currentPrayerInfo(_state.timings);
    final np = GameService.nextPrayerInfo(_state.timings);
    final parts = np.split('|');
    final nextName = parts[0];
    final nextIn = parts.length > 2 ? parts[2] : '';

    Widget cell(String label, String value, String sub, Color valueColor) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppText.labelCapsSm().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.titleLg().copyWith(
                color: valueColor,
                fontSize: 16,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyMd().copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    Widget vDivider() => Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: AppColors.outlineVariant.withValues(alpha: 0.35),
    );

    return FlatCard(
      child: Row(
        children: [
          cell(
            current.label.toUpperCase(),
            current.name,
            current.time,
            AppColors.tertiary,
          ),
          vDivider(),
          cell(AppL10n.of(context).homeNext, nextName, nextIn, AppColors.onSurface),
          vDivider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STREAK',
                style: AppText.labelCapsSm().copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    AppIcons.localFireDepartment,
                    color: AppColors.goldInk,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${_state.heroStreak.current}',
                    style: AppText.titleLg().copyWith(
                      color: AppColors.goldInk,
                      fontSize: 16,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                AppL10n.of(context).homeUnitDays,
                style: AppText.bodyMd().copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ritualRings() {
    final wajib = GameService.checkedWajibToday;
    final sunnah = GameService.sunnahCountToday;
    // Side quest selesai hari ini — sync dengan _sideQuest() (4 kartu).
    final sideDone = [
      GameService.isPrayerCheckedToday('sedekah'),
      GameService.tilawahDoneToday,
      GameService.isPrayerCheckedToday('zikir100'),
      GameService.isPrayerCheckedToday('hadis5'),
    ].where((d) => d).length;
    final wProgress = (wajib / 5).clamp(0.0, 1.0);
    // ponytail: denominator dari daftar, bukan literal — ring dan baris
    // Bonus Quest tidak bisa lagi berbeda hitungan.
    final sProgress = (sunnah / _sunnahQuests.length).clamp(0.0, 1.0);
    final sqProgress = (sideDone / 4).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(AppL10n.of(context).homeRitualToday),
        FlatCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: _RingsPainter(wProgress, sProgress, sqProgress),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  children: [
                    _ringStat(
                      AppL10n.of(context).homeRingWajib,
                      '$wajib/5',
                      AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ringStat('SUNNAH', '$sunnah/${_sunnahQuests.length}',
                        AppColors.secondaryFixed),
                    const SizedBox(height: AppSpacing.sm),
                    _ringStat('SIDE QUEST', '$sideDone/4', AppColors.tertiary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ringStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        // ponytail: Expanded, bukan Text + Spacer. labelCaps() itu 12px + track
        // 1.2 ("SIDE QUEST" ≈ 100dp), sementara kolomnya cuma ~108dp di layar
        // 360dp — labelnya didorong keluar oleh Spacer dan RenderFlex overflow.
        // Expanded memberi ruang yang tersisa SETELAH value; label mengalah
        // dulu (ellipsis) alih-alih meluber. Nilainya tetap tidak pernah
        // terpotong karena tidak fleksibel.
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.labelCaps().copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(value, style: AppText.bodyMd().copyWith(color: color)),
      ],
    );
  }

  Widget _prayerQuests() {
    final wajib = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];
    final done = GameService.checkedWajibToday;
    final friday = DateTime.now().weekday == DateTime.friday;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(
          AppL10n.of(context).homeWajibQuest,
          meta: '$done/5',
          accent: done == 5 ? AppColors.primary : null,
        ),
        ...wajib.map((p) {
          final done = GameService.isPrayerCheckedToday(p);
          final t = _state.timings;
          final active = !done && GameService.isCurrentOrUpcoming(p, t);
          final locked = !done && !GameService.isPrayerWindowOpen(p, t);
          // ponytail: Jumat replaces Dzuhur label on Friday
          final isJumat = friday && p == 'dzuhur';
          final xp = isJumat
              ? 25
              : (const {
                      'subuh': 30,
                      'dzuhur': 20,
                      'ashar': 20,
                      'maghrib': 25,
                      'isya': 25,
                    }[p] ??
                    15);
          final l10n = AppL10n.of(context);
          final label = isJumat ? l10n.prayerJumat : _prayerName(p, l10n);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _prayerRow(
              isJumat ? 'jumat' : p,
              label,
              done,
              active,
              locked,
              () => _togglePrayer(p, 'wajib'),
              xp,
            ),
          );
        }),
      ],
    );
  }

  /// ponytail: one pill, three callers — wajib/sunnah/tilawah share this.
  /// Flat tint (tanpa shadow) — kosakata RPG tetap, chrome hilang.
  Widget _xpPill(
    int xp,
    Color accent,
    Color onAccent, {
    bool done = false,
    bool locked = false,
  }) {
    final muted = AppColors.onSurfaceVariant;
    final fg = locked ? muted.withValues(alpha: 0.7) : (done ? muted : accent);
    final bg = locked || done
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.6)
        : accent.withValues(alpha: 0.14);
    final label = locked ? 'LOCKED' : (done ? 'DONE' : '+$xp XP');
    final glyph = locked ? AppIcons.lock : (done ? AppIcons.check : AppIcons.bolt);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(glyph, size: 12, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppText.labelCaps().copyWith(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// ponytail: time-of-day glyph per wajib prayer — replaces generic check_circle.
  /// Color encodes state: done=primary, locked=grey, active=tertiary, else muted.
  IconData _prayerIcon(String key) => switch (key) {
    'subuh' => AppIcons.wbTwilight, // fajar
    'dzuhur' => AppIcons.wbSunny, // terik
    'jumat' => AppIcons.mosque, // Jumat spesial
    'ashar' => AppIcons.wbCloudy, // sore
    'maghrib' => AppIcons.brightness3, // senja (crescent)
    'isya' => AppIcons.nightsStay, // malam
    _ => AppIcons.circleOutlined,
  };

  Widget _prayerRow(
    String key,
    String name,
    bool done,
    bool active,
    bool locked,
    VoidCallback onTap,
    int xp,
  ) {
    final dimmed = locked && !done;
    final iconColor = done
        ? AppColors.primary
        : (locked
              ? AppColors.onSurfaceVariant
              : (active ? AppColors.tertiary : AppColors.onSurfaceVariant));
    return PressableScale(
      onTap: locked ? null : onTap,
      child: Opacity(
        opacity: dimmed ? 0.45 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            // Datar; hairline cyan HANYA di baris yang aktif sekarang —
            // satu-satunya sorotan dalam daftar.
            color: active
                ? AppColors.tertiary.withValues(alpha: 0.06)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: active
                ? Border.all(color: AppColors.tertiary.withValues(alpha: 0.5))
                : null,
          ),
          child: Row(
            children: [
              Icon(_prayerIcon(key), color: iconColor, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  name,
                  style: AppText.bodyMd().copyWith(
                    color: done
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                  ),
                ),
              ),
              _xpPill(
                xp,
                AppColors.primary,
                AppColors.onPrimary,
                done: done,
                locked: locked,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questList() {
    final claimable = _state.quests
        .where((q) => q.completed && !q.claimed)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(
          AppL10n.of(context).homeQuestDaily,
          meta: claimable > 0
              ? AppL10n.of(context).homeQuestClaimable(claimable)
              : null,
          accent: claimable > 0 ? AppColors.primary : null,
        ),
        ..._state.quests.map(
          (q) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _questCard(q),
          ),
        ),
      ],
    );
  }

  Widget _questCard(Quest q) {
    final claimable = q.completed && !q.claimed;
    final isClaiming = _claimingQuestId == q.id;
    return AnimatedScale(
      scale: isClaiming ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.elasticOut,
      child: PressableScale(
        onTap: claimable ? () => _claimQuest(q) : null,
        child: ShimmerSweep(
          enabled: claimable,
          radius: AppRadius.lg,
          color: AppColors.primary,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: q.claimed
                  ? AppColors.surfaceContainerLow.withValues(alpha: 0.5)
                  : (claimable
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.surfaceContainerLow),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: claimable
                  ? Border.all(
                      color: AppColors.primary.withValues(
                        alpha: isClaiming ? 0.9 : 0.45,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  q.claimed
                      ? AppIcons.checkCircle
                      : (q.completed
                            ? AppIcons.cardGiftcard
                            : AppIcons.radioButtonUnchecked),
                  color: q.claimed
                      ? AppColors.onSurfaceVariant
                      : AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.desc,
                        style: AppText.bodyMd().copyWith(
                          color: q.claimed
                              ? AppColors.onSurfaceVariant
                              : AppColors.onBackground,
                          decoration: q.claimed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        '${q.progress}/${q.target} • +${q.xpReward} XP',
                        style: AppText.labelCaps().copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (claimable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text(
                      'CLAIM',
                      style: AppText.labelCaps().copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 10,
                      ),
                    ),
                  )
                else if (q.claimed)
                  Icon(
                    AppIcons.check,
                    color: AppColors.onSurfaceVariant,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sideQuest(BuildContext context) {
    final sedekahDone = GameService.isPrayerCheckedToday('sedekah');
    const xp = 15;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(AppL10n.of(context).homeSideQuestTitle),
        PressableScale(
          onTap: () => _togglePrayer('sedekah', 'sedekah'),
          child: FlatCard(
            child: Row(
              children: [
                Icon(AppIcons.favorite, color: AppColors.error, size: 26),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppL10n.of(context).homeSideSedekah,
                        style: AppText.titleLg().copyWith(
                          fontSize: 16,
                          color: sedekahDone
                              ? AppColors.onSurfaceVariant
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        sedekahDone
                            ? AppL10n.of(context).homeSideDone
                            : AppL10n.of(context).homeSideSedekahSub,
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _xpPill(
                  xp,
                  AppColors.error,
                  AppColors.onError,
                  done: sedekahDone,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Baca Quran — auto-claim dari sistem XP Quran (10 ayat/hari), read-only.
        Builder(builder: (_) {
          final qx = GameService.current.quranXp;
          final ayat =
              qx.date == GameService.todayStr() ? qx.readAyatTotal : 0;
          final done = GameService.tilawahDoneToday;
          return FlatCard(
            child: Row(
              children: [
                Icon(AppIcons.menuBook, color: AppColors.tertiary, size: 26),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppL10n.of(context).homeSideQuran,
                        style: AppText.titleLg().copyWith(
                          fontSize: 16,
                          color: done
                              ? AppColors.onSurfaceVariant
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        done
                            ? AppL10n.of(context).homeSideDone
                            : AppL10n.of(context).homeSideQuranSub(
                                ayat.clamp(0, GameService.quranSideQuestAyat),
                                GameService.quranSideQuestAyat,
                              ),
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _xpPill(
                  xp,
                  AppColors.tertiary,
                  AppColors.onTertiary,
                  done: done,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSpacing.sm),
        // Dzikir 100x — auto-claim saat counter mencapai goal, read-only.
        Builder(builder: (_) {
          final count = GameService.zikirCountToday;
          final done = GameService.isPrayerCheckedToday('zikir100');
          return FlatCard(
            child: Row(
              children: [
                Icon(
                  AppIcons.selfImprovement,
                  color: AppColors.primary,
                  size: 26,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppL10n.of(context).homeSideDzikir,
                        style: AppText.titleLg().copyWith(
                          fontSize: 16,
                          color: done
                              ? AppColors.onSurfaceVariant
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        done
                            ? AppL10n.of(context).homeSideDone
                            : AppL10n.of(context).homeSideDzikirSub(
                                count,
                                GameService.zikirGoal,
                              ),
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _xpPill(
                  xp,
                  AppColors.primary,
                  AppColors.onPrimary,
                  done: done,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSpacing.sm),
        // Belajar Hadis — auto-claim 5 hadis (dwell ≥5 dtk per hadis), read-only.
        Builder(builder: (_) {
          final count = GameService.hadisReadToday;
          final done = GameService.isPrayerCheckedToday('hadis5');
          return PressableScale(
            pressedScale: 0.97,
            onTap: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const HadisScreen()));
              if (mounted) setState(() {});
            },
            child: FlatCard(
              child: Row(
                children: [
                  Icon(
                    done ? AppIcons.checkCircle : AppIcons.autoStories,
                    color: done
                        ? AppColors.secondaryFixed
                        : AppColors.onSurfaceVariant,
                    size: 26,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppL10n.of(context).homeSideHadis,
                          style: AppText.titleLg().copyWith(
                            fontSize: 16,
                            color: done
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurface,
                          ),
                        ),
                        Text(
                          done
                              ? AppL10n.of(context).homeSideDone
                              : AppL10n.of(context).homeSideHadisSub(
                                  count.clamp(
                                    0,
                                    GameService.hadisSideQuestTarget,
                                  ),
                                  GameService.hadisSideQuestTarget,
                                ),
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _xpPill(
                    xp,
                    AppColors.secondaryFixed,
                    AppColors.onSurface,
                    done: done,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Quick actions: pintasan ke Hadis / Doa / Kiblat / Dzikir / Renungan ──
  // ponytail: dulu tersebar (Hadis+Doa di tab Belajar, Kiblat di tab Jadwal,
  // Dzikir & Renungan sebagai section di Home) — sekarang dikumpulkan di satu
  // deret supaya Home ringkas dan semuanya sejangkauan jempol.

  Widget _quickActions() {
    // ponytail: label 'Renungan' (bukan 'Highlight') — halaman tujuannya sudah
    // berjudul "Renungan Hari Ini", dan 'Highlight' bertabrakan dengan kutipan
    // artikel Belajar + sorot hasil cari Quran. Ikonnya buku, bukan sparkle
    // (glyph generik "AI/ajaib").
    final actions = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: AppIcons.autoStories,
        label: AppL10n.of(context).homeQuickHadis,
        onTap: () => _push(const HadisScreen()),
      ),
      (
        icon: AppIcons.volunteerActivism,
        label: AppL10n.of(context).homeQuickDoa,
        onTap: () => _push(const DoaScreen()),
      ),
      (
        icon: AppIcons.explore,
        label: AppL10n.of(context).homeQuickKiblat,
        onTap: _openQibla,
      ),
      (
        icon: AppIcons.dotsNine,
        label: AppL10n.of(context).homeQuickDzikir,
        onTap: () => _push(const DzikirScreen()),
      ),
      (
        icon: AppIcons.menuBookOutlined,
        label: AppL10n.of(context).homeQuickRenungan,
        onTap: () => _push(const DailyHighlightScreen()),
      ),
    ];
    // Renungan satu-satunya tile dengan state harian → satu-satunya yang dapat
    // badge. Sisanya pintasan statis. ponytail: kalau nanti ada tile ke-2 yang
    // butuh progres, pindahkan angka ini ke badge per-tile.
    final renunganDone =
        GameService.bitCount(GameService.highlightSwipeClaimedToday);
    final tiles = [
      for (final a in actions)
        (
          icon: a.icon,
          label: a.label,
          onTap: a.onTap,
          done: a.label == AppL10n.of(context).homeQuickRenungan &&
              renunganDone == GameService.highlightSwipeMaxPages,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(
          AppL10n.of(context).homeQuickActions,
          meta: renunganDone > 0
              ? AppL10n.of(context).homeQuickActionsMeta(
                  renunganDone,
                  GameService.highlightSwipeMaxPages,
                )
              : null,
          accent: renunganDone == GameService.highlightSwipeMaxPages
              ? AppColors.primary
              : null,
        ),
        FlatCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              // ponytail: kisi 3 kolom, SATU jalur kode untuk semua baris.
              // Sebelumnya baris 2 dirakit manual dengan Spacer(flex: 1):
              // hasilnya tile baris 2 = 115px sedangkan baris 1 = 111px, plus
              // lubang 114px di kanan. Sekarang baris terakhir yang tidak penuh
              // dipad slot kosong → tiap tile persis 1/3 kolom, gap seragam.
              for (var i = 0; i < tiles.length; i += 3) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                _actionRow(tiles.sublist(i, (i + 3).clamp(0, tiles.length))),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Satu baris kisi 3 kolom. Baris terakhir yang tidak penuh dipad slot
  /// kosong supaya kedua tile tetap 1/3 lebar kolom (bukan melar jadi lebih
  /// lebar dari tile di atasnya).
  Widget _actionRow(
    List<({IconData icon, String label, VoidCallback onTap, bool done})> row,
  ) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: i < row.length
                ? _actionTile(
                    row[i].icon,
                    row[i].label,
                    row[i].onTap,
                    done: row[i].done,
                  )
                // ponytail: slot kosong, BUKAN Spacer. Spacer berbagi sisa
                // ruang sehingga tile sebelumnya ikut melar (115 vs 111px).
                // SizedBox.shrink (bukan .expand) — Row tinggi tak terbatas,
                // .expand minta tinggi infinity dan meledak.
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }

  /// [done] → badge cek emas di pojok chip ikon (dipakai Renungan setelah 4/4).
  Widget _actionTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool done = false,
  }) {
    return PressableScale(
      pressedScale: 0.95,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          children: [
            // ponytail: chip ikon = lapisan KEDUA (wash tile 10% → chip 18%).
            // Referensi appllama: "Icon Square Badges" (Gravl) & "Rounded
            // Feature Cards" (Quran Widgets, kartu lebih terang dari latar).
            // Glyph telanjang di atas wash terbaca datar; chip memberi
            // kedalaman tanpa shadow — AppShadow sengaja kosong, jadi
            // kedalaman HARUS dari tangga kecerahan, bukan bayangan.
            // Badge `done` pindah ke pojok chip (dulu pojok glyph 24px).
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(icon, size: 22, color: AppColors.primary),
                ),
                if (done)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Icon(
                      AppIcons.checkCircle,
                      size: 14,
                      color: AppColors.secondaryFixed,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.labelCapsSm().copyWith(color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  /// Kiblat butuh nama kota — diambil dari lokasi tersimpan (default Jakarta,
  /// sama seperti tab Jadwal).
  Future<void> _openQibla() async {
    final loc = await PrayerService.loadLocation();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QiblaScreen(
          cityName: loc?.name ?? AppL10n.of(context).homeDefaultCity,
        ),
      ),
    );
  }


  // ─── Daily Reward Chest ───
  Widget _dailyChest() {
    final l10n = AppL10n.of(context);
    final wajibDone = GameService.checkedWajibToday;
    final isOpened = GameService.isDailyChestOpened;
    final isReady = GameService.isDailyChestAvailable;
    final totalWajib = 5;

    // Determine state
    final String emoji;
    final String label;
    final String subtitle;
    final Color accent;
    final bool canTap;

    if (isOpened) {
      emoji = '📭';
      label = l10n.homeChestOpenedLabel;
      subtitle = l10n.homeChestOpenedSub;
      accent = AppColors.onSurfaceVariant;
      canTap = false;
    } else if (isReady) {
      emoji = '🎁';
      label = l10n.homeChestReadyLabel;
      subtitle = l10n.homeChestReadySub;
      accent = AppColors.tertiary;
      canTap = true;
    } else {
      emoji = '🔒';
      label = l10n.homeChestTitle;
      subtitle = l10n.homeChestLocked;
      accent = AppColors.primary;
      canTap = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HudHeader(
          l10n.homeChestTitle,
          meta: isOpened
              ? l10n.homeChestMetaOpened
              : l10n.homeChestMetaProgress(wajibDone, totalWajib),
          accent: isReady ? AppColors.tertiary : null,
        ),
        PressableScale(
          onTap: canTap ? _claimChest : null,
          child: ShimmerSweep(
            enabled: isReady,
            color: AppColors.tertiary,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isReady
                    ? AppColors.tertiary.withValues(alpha: 0.08)
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: isReady
                    ? Border.all(
                        color: AppColors.tertiary.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppText.labelCaps().copyWith(
                            color: accent,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Progress dots: 5 wajib
                        Row(
                          children: List.generate(totalWajib, (i) {
                            final done = i < wajibDone;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done
                                      ? accent
                                      : accent.withValues(alpha: 0.2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  if (canTap)
                    Icon(AppIcons.arrowForwardIos, color: accent, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _claimChest() async {
    final reveal = await GameService.claimDailyChest();
    if (!mounted || reveal == null) return;
    setState(() {});
    _showChestReveal(reveal);
  }

  void _showChestReveal(ChestRevealState reveal) {
    final accent = reveal.isCosmetic
        ? AppColors.secondaryFixed
        : reveal.isShield
            ? AppColors.tertiary
            : AppColors.primary;
    // Ditangkap sebelum showDialog: builder-nya jalan setelah gap.
    final l10n = AppL10n.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Opaque tertiary tint over surface — a translucent top stop
                  // shows the scrim through the card (washed-out in light theme).
                  Color.alphaBlend(
                    accent.withValues(alpha: 0.2),
                    AppColors.surface,
                  ),
                  AppColors.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: accent, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji reward
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      reveal.rewardEmoji,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  reveal.isCosmetic
                      ? l10n.homeRevealCosmetic
                      : reveal.isShield
                          ? l10n.homeRevealShield
                          : l10n.homeRevealReward,
                  style: AppText.labelCaps().copyWith(
                    color: accent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  reveal.rewardName,
                  style: AppText.displayHero(
                    20,
                  ).copyWith(color: AppColors.onSurface),
                  textAlign: TextAlign.center,
                ),
                if (reveal.isShield) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.homeRevealShieldBody(reveal.shieldCount),
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (!reveal.isCosmetic && !reveal.isShield) ...[
                  const SizedBox(height: AppSpacing.md),
                  // XP reward
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Text(
                      '+${reveal.xpReward} XP',
                      style: AppText.labelCaps().copyWith(
                        color: accent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (reveal.isDuplicate) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.homeRevealDuplicate,
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (reveal.levelsGained > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.homeRevealLevelUp(
                      reveal.levelsGained > 1 ? ' x${reveal.levelsGained}' : '',
                    ),
                    style: AppText.labelCaps().copyWith(
                      color: AppColors.tertiary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Text(l10n.homeRevealBtn),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}

class _RingsPainter extends CustomPainter {
  final double wajib, sunnah, sideQuest;
  _RingsPainter(this.wajib, this.sunnah, this.sideQuest);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radii = [56.0, 42.0, 28.0];
    final colors = [
      AppColors.primary,
      AppColors.secondaryFixed,
      AppColors.tertiary,
    ];
    final progresses = [wajib, sunnah, sideQuest];

    for (var i = 0; i < radii.length; i++) {
      final paintBg = Paint()
        ..color = AppColors.surfaceContainerHighest
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radii[i], paintBg);

      if (progresses[i] > 0) {
        final paintFg = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;
        final sweep = 2 * 3.14159 * progresses[i];
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radii[i]),
          -3.14159 / 2,
          sweep,
          false,
          paintFg,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) =>
      old.wajib != wajib ||
      old.sunnah != sunnah ||
      old.sideQuest != sideQuest;
}

class _RankMedallion extends StatelessWidget {
  final TierVisualConfig tier;
  final int level;
  final bool light;

  const _RankMedallion({
    required this.tier,
    required this.level,
    required this.light,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Container(
          key: const Key('home-rank-medallion'),
          width: 68,
          height: 68,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: light ? AppColors.primary : null,
            gradient: light
                ? null
                : LinearGradient(colors: [tier.inkPrimary, tier.inkSecondary]),
            boxShadow: light
                ? null
                : [
                    BoxShadow(
                      color: tier.inkPrimary.withValues(alpha: 0.28),
                      blurRadius: 12,
                    ),
                  ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: light
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainer,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.square(
                  dimension: 30,
                  child: CustomPaint(
                    painter: _IslamicHeroPatternPainter(
                      color: light ? AppColors.primary : tier.inkPrimary,
                      opacity: 1,
                      singleStar: true,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 7,
                  child: Text(
                    'LV $level',
                    style: AppText.labelCapsSm().copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IslamicHeroPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final bool singleStar;

  const _IslamicHeroPatternPainter({
    required this.color,
    required this.opacity,
    this.singleStar = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path star(Offset center, double outerRadius) {
      final path = Path();
      for (var i = 0; i < 16; i++) {
        final radius = i.isEven ? outerRadius : outerRadius * 0.42;
        final angle = -math.pi / 2 + i * math.pi / 8;
        final point = Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path..close();
    }

    final paint = Paint()
      ..style = singleStar ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1;
    if (singleStar) {
      paint.color = color.withValues(alpha: opacity);
      canvas.drawPath(
        star(
          Offset(size.width / 2, size.height / 2 - 4),
          size.shortestSide / 2,
        ),
        paint,
      );
      return;
    }

    final startX = size.width * 0.42;
    const spacing = 40.0;
    for (var y = 0.0; y <= size.height + spacing; y += spacing) {
      for (var x = startX; x <= size.width + spacing; x += spacing) {
        final fade = ((x - startX) / (size.width - startX)).clamp(0.2, 1.0);
        paint.color = color.withValues(alpha: opacity * fade);
        canvas.drawPath(star(Offset(x, y), 13), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicHeroPatternPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.singleStar != singleStar;
}

/// Bonus Quest Sunnah — collapsible. Collapsed (default) hanya menampilkan
/// row yang sedang aktif (on-time) atau sudah selesai hari ini; tap chevron
/// memperluas ke daftar lengkap. State expand in-memory saja (YAGNI persist).
class _BonusQuest extends StatefulWidget {
  final GameState state;
  final void Function(String id) onToggle;
  const _BonusQuest({required this.state, required this.onToggle});

  @override
  State<_BonusQuest> createState() => _BonusQuestState();
}

class _BonusQuestState extends State<_BonusQuest> {
  bool _expanded = false;

  static const _items = _sunnahQuests;

  @override
  Widget build(BuildContext context) {
    final t = widget.state.timings;
    final doneCount =
        _items.where((it) => GameService.isPrayerCheckedToday(it.$1)).length;

    // ponytail: collapsed = on-time ATAU selesai; kalau kosong (mis. lewat
    // tengah hari, belum ibadah), fallback tampilkan semua biar kartu tak kosong.
    var visible = _items
        .where((it) =>
            GameService.isPrayerCheckedToday(it.$1) ||
            GameService.isSunnahOnTime(it.$1, t))
        .toList();
    if (visible.isEmpty) visible = List.of(_items);
    final shown = _expanded ? _items : visible;
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Expanded(
                child: HudHeader(
                  l10n.homeBonusQuestSunnah,
                  meta: '$doneCount/${_items.length}',
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  AppIcons.expandMore,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              for (final it in shown)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _bonusRow(
                    _sunnahText(it.$1, l10n).$1,
                    _sunnahText(it.$1, l10n).$2,
                    it.$2,
                    AppColors.secondaryFixed,
                    completed: GameService.isPrayerCheckedToday(it.$1),
                    active: !GameService.isPrayerCheckedToday(it.$1) &&
                        GameService.isSunnahOnTime(it.$1, t),
                    locked: !GameService.isPrayerCheckedToday(it.$1) &&
                        !GameService.isSunnahOnTime(it.$1, t),
                    onTap: () => widget.onToggle(it.$1),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bonusRow(
    String name,
    String sub,
    IconData icon,
    Color color, {
    bool locked = false,
    bool completed = false,
    bool active = false,
    VoidCallback? onTap,
    int xp = 15,
  }) {
    final dimmed = locked && !completed;
    final iconColor = completed
        ? color
        : (locked
              ? AppColors.onSurfaceVariant
              : (active ? color : AppColors.onSurfaceVariant));
    return PressableScale(
      onTap: locked ? null : onTap,
      child: Opacity(
        opacity: dimmed ? 0.45 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: 0.06)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: active
                ? Border.all(color: color.withValues(alpha: 0.45))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppText.bodyMd().copyWith(
                        color: completed
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                      ),
                    ),
                    Text(
                      sub,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _xpPillSmall(xp, color, AppColors.onSecondary,
                  done: completed, locked: locked),
            ],
          ),
        ),
      ),
    );
  }

  Widget _xpPillSmall(int xp, Color color, Color onColor,
      {bool done = false, bool locked = false}) {
    // Sama dengan _xpPill quest wajib: DONE + centang saat sudah di-claim.
    final muted = AppColors.onSurfaceVariant;
    final fg = locked ? muted.withValues(alpha: 0.7) : (done ? muted : onColor);
    final bg = locked || done
        ? AppColors.surfaceContainerHigh.withValues(alpha: 0.6)
        : color;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done) ...[
            Icon(AppIcons.check, size: 12, color: fg),
            const SizedBox(width: 2),
          ],
          Text(
            done ? 'DONE' : '+$xp XP',
            style: AppText.labelCapsSm().copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
