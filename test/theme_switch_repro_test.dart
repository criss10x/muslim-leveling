import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/screens/dashboard_shell.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/theme_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reproduksi bug: ganti tema saat runtime, lalu pindah tab.
///
/// Laporan: "saat ganti theme dari dark ke light, saat pindah ke tab home dari
/// tab profil, beberapa tampilan di home masih hitam, begitu juga sebaliknya."
///
/// Ukurannya fraksi piksel gelap di seluruh layar: AmbientBackground nyaris
/// hitam di dark theme dan terang di light theme, jadi satu angka cukup untuk
/// memisahkan "ikut tema baru" dari "masih tema lama".
///
/// CATATAN cakupan: tes ini menangkap kelas bug "subtree tab tidak dibangun
/// ulang" (const children). Ia TIDAK menangkap `CustomPainter` basi, karena
/// ganti tema menandai dirty satu layer render bersama, jadi painter ikut
/// repaint meski `shouldRepaint`-nya mengabaikan warna. Kasus itu ditutup
/// langsung di shouldRepaint masing-masing painter, bukan oleh tes ini.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final today = DateTime.now();
  final d = '${today.year}-${today.month.toString().padLeft(2, '0')}'
      '-${today.day.toString().padLeft(2, '0')}';

  final boundaryKey = GlobalKey();

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> pumpShell(WidgetTester tester) async {
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
        'qadhaLog': [],
      }),
    });
    GameService.resetForTest();
    await GameService.load();
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: ListenableBuilder(
          listenable: themeNotifier,
          builder: (context, _) => MaterialApp(
            locale: const Locale('id'),
            supportedLocales: AppL10n.supportedLocales,
            localizationsDelegates: AppL10n.localizationsDelegates,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeNotifier.mode,
            home: const DashboardShell(),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<double> darkFraction() async {
    final bytes = await TestWidgetsFlutterBinding.instance.runAsync(() async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await boundary.toImage();
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      return data!.buffer.asUint8List();
    });
    var dark = 0, total = 0;
    for (var i = 0; i + 3 < bytes!.length; i += 4) {
      final lum =
          0.2126 * bytes[i] + 0.7152 * bytes[i + 1] + 0.0722 * bytes[i + 2];
      if (lum < 70) dark++;
      total++;
    }
    return dark / total;
  }

  /// Tap tab ke-[index] (0=Home..4=Profil) lewat posisi, biar tidak bergantung
  /// pada ikon nav.
  Future<void> tapTab(WidgetTester tester, int index) async {
    final w = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final h = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(w * (index + 0.5) / 5, h - 32));
    await settle(tester);
  }

  testWidgets('dark → light, pindah Profil → Home', (t) async {
    await pumpShell(t);
    themeNotifier.setPreset(AppThemePreset.darkEmerald);
    await settle(t);
    final darkHome = await darkFraction();

    await tapTab(t, 4); // Profil
    themeNotifier.setPreset(AppThemePreset.lightEmerald);
    await settle(t);
    await tapTab(t, 0); // Home

    final lightHome = await darkFraction();
    expect(lightHome, lessThan(darkHome / 3),
        reason: 'Home masih gelap setelah ganti ke tema terang: '
            'dark=$darkHome light=$lightHome');
  });

  testWidgets('light → dark, pindah Profil → Home', (t) async {
    await pumpShell(t);
    themeNotifier.setPreset(AppThemePreset.lightEmerald);
    await settle(t);
    final lightHome = await darkFraction();

    await tapTab(t, 4);
    themeNotifier.setPreset(AppThemePreset.darkEmerald);
    await settle(t);
    await tapTab(t, 0);

    final darkHome = await darkFraction();
    expect(darkHome, greaterThan(lightHome * 2),
        reason: 'Home masih terang setelah ganti ke tema gelap: '
            'light=$lightHome dark=$darkHome');
  });
}
