import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/app_wrap.dart';

/// Penjaga tema terang: token INK tidak boleh dipakai sebagai LATAR solid
/// di belakang teks.
///
/// Bug 2026-10-01: pill "+15 XP" di Bonus Quest memakai `secondaryFixed`
/// sebagai latar. Di light theme token itu gold INK (0xFF9A6700, coklat tua),
/// jadi dua baris aktif jadi kotak gelap di kartu terang. Di dark theme token
/// yang sama kebetulan terang, jadi bug-nya hanya kelihatan di light.
///
/// Hanya permukaan yang cukup besar untuk membawa teks yang diperiksa; swatch
/// 8x8 (dot legenda ring) memang sah berwarna ink dan tidak dituduh.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final today = DateTime.now();
  final d = '${today.year}-${today.month.toString().padLeft(2, '0')}'
      '-${today.day.toString().padLeft(2, '0')}';

  /// Luminance relatif WCAG (gamma-correct), sama seperti yang dipakai
  /// perhitungan kontras di app.
  double luminance(Color c) {
    double lin(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
  }

  /// Token yang di light theme bernilai ink gelap.
  List<Color> lightInkTokens() => [
        AppColors.secondaryFixed, // gold INK
        AppColors.goldInk,
        AppColors.onSecondary,
        AppColors.onSecondaryFixed,
        AppColors.onSecondaryFixedVariant,
        AppColors.onSecondaryContainer,
        AppColors.onTertiaryContainer,
        AppColors.onTertiaryFixed,
        AppColors.onTertiaryFixedVariant,
        AppColors.onPrimaryContainer,
        AppColors.onPrimaryFixed,
        AppColors.onPrimaryFixedVariant,
        AppColors.onErrorContainer,
        AppColors.onSurface,
        AppColors.onBackground,
        AppColors.onSurfaceVariant,
      ];

  Future<void> pumpHome(WidgetTester tester, AppThemePreset preset) async {
    activeThemePreset = preset;
    SharedPreferences.setMockInitialValues({
      'game_state_v1': jsonEncode({
        'xp': 4800,
        'nickname': 'Kris',
        'prayerLog': [
          {'date': d, 'prayer': 'subuh', 'time': '04:35', 'onTime': true},
        ],
        'quests': [
          {
            'id': 'quest_one_sunnah',
            'desc': 'Sholat 1 sunnah',
            'xpReward': 40,
            'target': 1,
            'progress': 1,
            'completed': true,
            'claimed': false,
          },
        ],
      }),
    });
    GameService.resetForTest();
    await GameService.load();
    tester.view.physicalSize = const Size(412, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      appWrap(const Scaffold(body: HomeTab()), theme: AppTheme.light()),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// Permukaan cukup besar untuk membawa teks. Alpha < 1 dibiarkan (tint
  /// transparan di atas kartu terang tidak pernah jadi kotak gelap).
  List<Color> textBearingSurfaces(WidgetTester tester) {
    final out = <Color>[];
    final finder = find.byType(Container);
    for (var i = 0; i < finder.evaluate().length; i++) {
      final size = tester.getSize(finder.at(i));
      if (size.width < 40 || size.height < 14) continue;
      final w = finder.evaluate().elementAt(i).widget as Container;
      if (w.color != null && w.color!.a >= 0.99) out.add(w.color!);
      final deco = w.decoration;
      if (deco is BoxDecoration && deco.color != null && deco.color!.a >= 0.99) {
        out.add(deco.color!);
      }
    }
    final mats = find.byType(Material);
    for (var i = 0; i < mats.evaluate().length; i++) {
      final size = tester.getSize(mats.at(i));
      if (size.width < 40 || size.height < 14) continue;
      final m = mats.evaluate().elementAt(i).widget as Material;
      if (m.color != null && m.color!.a >= 0.99) out.add(m.color!);
    }
    return out;
  }

  /// Semua latar (termasuk tint transparan) — dipakai untuk cek tint pill.
  List<Color> allSurfaces(WidgetTester tester) {
    final out = <Color>[];
    for (final w in tester.widgetList<Widget>(find.byType(Container))) {
      final c = w as Container;
      if (c.color != null) out.add(c.color!);
      final deco = c.decoration;
      if (deco is BoxDecoration && deco.color != null) out.add(deco.color!);
    }
    return out;
  }

  for (final preset in [
    AppThemePreset.lightEmerald,
    AppThemePreset.lightMushaf,
  ]) {
    testWidgets('Home ${preset.name}: token ink tidak jadi latar', (t) async {
      await pumpHome(t, preset);
      final bgs = textBearingSurfaces(t).toSet();

      // Prasyarat: token ini memang ink gelap di tema terang.
      final inks = lightInkTokens().where((c) => luminance(c) < 0.22).toSet();
      expect(inks, contains(AppColors.secondaryFixed),
          reason: 'secondaryFixed harus tetap gold INK di tema terang');
      expect(bgs, isNotEmpty, reason: 'tidak ada permukaan terdeteksi');

      final offenders = bgs.intersection(inks);
      expect(
        offenders,
        isEmpty,
        reason: 'token ink dipakai sebagai latar di belakang teks: '
            '${offenders.map((c) => c.toARGB32().toRadixString(16)).toList()}',
      );
    });
  }

  testWidgets('pill XP berlatar tint, bukan aksen pekat', (t) async {
    await pumpHome(t, AppThemePreset.lightEmerald);

    final ink = AppColors.secondaryFixed;
    expect(luminance(ink), lessThan(0.22),
        reason: 'prasyarat: secondaryFixed memang ink gelap di light theme');

    final bgs = textBearingSurfaces(t);
    expect(bgs.contains(ink), isFalse,
        reason: 'secondaryFixed dipakai sebagai latar solid — pill jadi gelap');

    // Tint aksen tetap ada (alpha rendah di atas kartu terang).
    final tinted =
        allSurfaces(t).where((c) => c.a > 0 && c.a < 0.8).toList();
    expect(tinted, isNotEmpty, reason: 'latar pill ber-tint hilang');
  });
}
