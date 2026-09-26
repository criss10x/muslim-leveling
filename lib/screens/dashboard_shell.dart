import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/theme_service.dart';
import '../../widgets/common.dart';
import '../../widgets/achievement_medal.dart';
import '../../widgets/side_quest_announcer.dart';
import 'home_tab.dart';
import 'jadwal_tab.dart';
import 'quran_tab.dart';
import 'belajar_tab.dart';
import 'profil_tab.dart';
import '../theme/app_icons.dart';
import '../l10n/app_localizations.dart';

/// Main shell — bottom nav with 4 tabs and the persistent top app bar.
class DashboardShell extends StatefulWidget {
  final int initialTab;
  const DashboardShell({super.key, this.initialTab = 0});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  /// Ikon saja — label dibaca dari ARB di `_navItem`, bukan disimpan di sini:
  /// dulu ke-5 label hardcoded ('HOME'/'JADWAL'/...) sehingga nav tetap
  /// Indonesia di locale en/tr/ms.
  static const _items = [
    (AppIcons.homeOutlined, AppIcons.home),
    (AppIcons.scheduleOutlined, AppIcons.schedule),
    (AppIcons.autoStoriesOutlined, AppIcons.autoStories),
    (AppIcons.menuBookOutlined, AppIcons.menuBook),
    (AppIcons.personOutline, AppIcons.person),
  ];

  /// Label nav per indeks dari ARB. Urutan wajib sama dengan [_items].
  static List<String> _labels(AppL10n l10n) => [
        l10n.tabHome,
        l10n.tabJadwal,
        l10n.tabQuran,
        l10n.tabBelajar,
        l10n.tabProfil,
      ];

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder: theme toggle rebuilds shell + non-const tabs.
    // JANGAN pakai const pada tab children — Flutter skip updateChild
    // kalau widget instance identical, jadi AppColors getter gak ke-baca ulang.
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          // ponytail: DULU `extendBody: true`. Itu bertabrakan dengan nav bar di
          // bawah: bar-nya solid (0xFF121816, sengaja tanpa BackdropFilter demi
          // perf) TAPI body-nya diletakkan di belakangnya — jadi 64dp + inset
          // navigasi tiap tab ketutup permanen. Tab yang lupa kompensasi padding
          // (Quran) kehilangan item terakhirnya; tab lain menambal dengan
          // `bottom: 100` yang angka sihirnya gampang basi.
          // Karena bar-nya opaque, extendBody tidak memberi apa pun secara visual
          // — cuma memotong konten. Di-nol-kan: Scaffold menyisakan ruang untuk
          // bar, dan padding bottom:100 yang tersisa jadi ruang napas, bukan
          // penambal.
          extendBody: false,
          body: AmbientBackground(
            child: Stack(
              fit: StackFit.expand,
              children: [
                IndexedStack(
                  index: _tab,
                  children: [
                    const HomeTab(),
                    JadwalTab(),
                    QuranTab(),
                    BelajarTab(),
                    ProfilTab(),
                  ],
                ),
                // Announcer global: popup medali unlock dari flow mana pun.
                const AchievementAnnouncerOverlay(),
                // Announcer global: popup side quest selesai (dzikir/quran/hadis).
                const SideQuestAnnouncerOverlay(),
              ],
            ),
          ),
          // Solid surface nav — no BackdropFilter (perf + light-theme contract).
          bottomNavigationBar: Container(
            key: const ValueKey('nav-bar'),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: List.generate(
                    _items.length,
                    (i) => Expanded(child: _navItem(context, i)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(BuildContext context, int i) {
    final (iconOff, iconOn) = _items[i];
    final label = _labels(AppL10n.of(context))[i].toUpperCase();
    final selected = _tab == i;
    final light = isLightTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: () => setState(() => _tab = i),
        highlightShape: BoxShape.rectangle,
        containedInkWell: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: light ? 0.12 : 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                // Glow only in dark — neon language on light = noise.
                boxShadow: selected && !light
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 14,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedScale(
                scale: selected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Icon(
                  selected ? iconOn : iconOff,
                  size: 24,
                  color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: AppText.labelCapsSm().copyWith(
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                // Text glow only in dark.
                shadows: selected && !light
                    ? [Shadow(color: AppColors.primary.withValues(alpha: 0.6), blurRadius: 8)]
                    : null,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
