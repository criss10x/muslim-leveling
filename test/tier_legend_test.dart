import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/profil_tab.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:muslim_leveling/widgets/tier_avatar.dart';
import 'package:muslim_leveling/widgets/tier_legend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/app_wrap.dart';

/// Guard sistem rank.
///
/// 1. Tangga tier harus cocok dengan gelar yang benar-benar diberikan
///    GameService.getRankTitle. Kalau ambang di salah satu sisi digeser,
///    legend di Profil akan menjanjikan warna yang tidak pernah datang —
///    tes ini yang menangkapnya.
/// 2. Tombol "Sistem Rank" harus membuka sheet legend, dan legendnya membaca
///    tierLadder (bukan daftar kedua yang bisa basi).
void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  /// Ambang tier menurut GameService.getRankTitle, dibaca dari gelar yang
  /// dikembalikan — bukan konstanta yang disalin dari sumber lain.
  String? tierOfRankTitle(String title) {
    const names = [
      'Mythic Immortal',
      'Mythic Glory',
      'Mythic Honor',
      'Mythic',
      'Legend',
      'Epic',
      'Grandmaster',
      'Master',
      'Elite',
      'Warrior',
    ];
    for (final n in names) {
      if (title.startsWith('Muslim $n')) return n;
    }
    return null;
  }

  test('tangga tier cocok dengan gelar GameService di semua level 1..120', () {
    for (var level = 1; level <= 120; level++) {
      final title = GameService.getRankTitle(level);
      final fromTitle = tierOfRankTitle(title);
      expect(
        fromTitle,
        getTierName(level),
        reason: 'level $level: gelar "$title" tidak sealur dengan tangga tier',
      );
      // Legend memakai tierStartLevel untuk baris "Lv N" — pastikan tier yang
      // dipakai di level itu memang punya baris, dan ambangnya tidak bohong.
      final start = tierStartLevel(getTierName(level))!;
      expect(
        level >= start,
        isTrue,
        reason: 'level $level di bawah ambang tier ${getTierName(level)}',
      );
      final below = start - 1;
      if (below >= 1) {
        expect(
          getTierName(below),
          isNot(getTierName(level)),
          reason: 'ambang tier ${getTierName(level)} di Lv $start tidak tajam',
        );
      }
    }
  });

  test('setiap tier di tangga punya konfigurasi visual (bukan Unknown)', () {
    for (final (name, _) in tierLadder) {
      expect(
        getTierVisualConfig(name).name,
        name,
        reason: 'tier "$name" jatuh ke config default — chip warnanya salah',
      );
    }
  });

  testWidgets('tombol Sistem Rank membuka legend berisi semua tier', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'nickname': 'Pejuang',
      'onboarding_done': true,
      'city_id': 'a1',
      'city_name': 'Jakarta',
      'avatar_path': '',
    });
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      appWrap(const ProfilTab(), theme: AppTheme.dark()),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(TierLegend), findsNothing);

    // Baris rank ada setelah _stats(): tiga ProfilRowTile berurutan
    // (rank, kalender, loker). Cari lewat headernya, bukan index — index
    // bergeser begitu ada bagian baru disisipkan di Profil.
    final rankTile = find.ancestor(
      of: find.text('SISTEM RANK'),
      matching: find.byType(ProfilRowTile),
    );
    expect(rankTile, findsOneWidget);

    await tester.ensureVisible(rankTile);
    await tester.pumpAndSettle();
    await tester.tap(rankTile);
    await tester.pumpAndSettle();

    expect(find.byType(TierLegend), findsOneWidget);
    // Nama tier harus muncul; warna tidak diuji (itu urusan TierVisualConfig).
    for (final (name, _) in tierLadder) {
      expect(
        find.text(name),
        findsWidgets,
        reason: 'tier "$name" tidak muncul di legend',
      );
    }
    expect(tester.takeException(), isNull);
  });

  // Inti fitur: chip warna di legend HARUS warna tier yang sama dengan avatar.
  // Dibandingkan sebagai gradient di widget, bukan sampling piksel golden.
  testWidgets('chip warna legend = warna tier dari getTierVisualConfig', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 620);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      appWrap(
        const Scaffold(
          body: SafeArea(child: TierLegend(currentLevel: 30)),
        ),
        theme: AppTheme.dark(),
      ),
    );
    await tester.pumpAndSettle();

    // Chip = Container ber-DecorationImage? Tidak: BoxDecoration + gradient.
    // Urutan chip mengikuti tierLadder, jadi zip dengan tangga.
    final gradients = <LinearGradient>[];
    for (final element in find.byType(Container).evaluate()) {
      final deco = (element.widget as Container).decoration;
      if (deco is BoxDecoration && deco.shape == BoxShape.circle) {
        final g = deco.gradient;
        if (g is LinearGradient) gradients.add(g);
      }
    }

    expect(
      gradients.length,
      tierLadder.length,
      reason: 'jumlah chip warna tidak sama dengan jumlah tier',
    );

    for (var i = 0; i < tierLadder.length; i++) {
      final (name, _) = tierLadder[i];
      final config = getTierVisualConfig(name);
      expect(
        gradients[i].colors,
        [config.primaryColor, config.secondaryColor],
        reason: 'chip tier "$name" tidak memakai warna avatar-nya',
      );
    }
  });

  // Layar sempit: tiap baris punya 4 kolom (chip, nama, badge, divisi, Lv).
  // Kalau ada yang meluber, Row-nya melempar overflow — ditangkap di sini.
  testWidgets('legend tidak overflow di layar sempit 320dp', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      appWrap(
        const Scaffold(
          body: SafeArea(child: TierLegend(currentLevel: 95)),
        ),
        theme: AppTheme.dark(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  // Golden legend di dua tema. Warna dibaca dari AppColors, yang di-drive
  // `activeThemePreset` — BUKAN `isLightTheme` (menyetel itu saja tidak
  // mengubah satu warna pun; golden "light" jadi identik byte-per-byte dengan
  // "dark"). Setter preset juga menyetel _isLight, jadi satu assignment cukup.
  for (final (label, theme, preset) in [
    ('dark', AppTheme.dark(), AppThemePreset.darkEmerald),
    ('light', AppTheme.light(), AppThemePreset.lightEmerald),
  ]) {
    testWidgets('legend golden — $label', (tester) async {
      activeThemePreset = preset;
      addTearDown(() => activeThemePreset = AppThemePreset.darkEmerald);
      tester.view.physicalSize = const Size(412, 620);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        appWrap(
          Scaffold(
            backgroundColor: AppColors.surfaceContainerHigh,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const TierLegend(currentLevel: 30),
              ),
            ),
          ),
          theme: theme,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TierLegend),
        matchesGoldenFile('goldens/tier_legend_$label.png'),
      );
    });
  }
}
