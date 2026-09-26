// Golden PERMANEN untuk hero tab Home (bukan sekali pakai).
//
// ponytail: `home_hero_hybrid_test.dart` mengunci PROPERTI widget (7 asersi
// gradient/border/pattern/medallion), BUKAN layout — dia tidak akan menangkap
// sapaan yang ter-ellipsis, baris yang bertambah, atau tabrakan dengan
// medallion. Golden ini yang menangkap itu. Satu PNG saja, tema gelap: gelap
// adalah identitas utama app ini, dan varian kedua cuma menggandakan permukaan
// CI (tiap bump engine Flutter = PNG harus di-regenerate sebagai commit sendiri,
// lihat skill muslim-leveling-v2).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'helpers/app_wrap.dart';

/// Seed deterministik: nama tetap + XP 0 (level 1) supaya sapaan, judul rank,
/// dan bar progres semuanya stabil antar-run.
void _seed({String nickname = 'Kris'}) {
  SharedPreferences.setMockInitialValues({
    'game_state_v1': jsonEncode(
      GameState(
        highlightSwipeDate: GameService.todayStr(),
        highlightSwipeMask: 0,
      ).toMap(),
    ),
    'nickname': nickname,
  });
}

Future<void> _shot(WidgetTester tester, String path, {String? expectText}) async {
  await tester.pumpWidget(
    appWrap(
      const Scaffold(body: HomeTab()),
      theme: AppTheme.dark(),
      debugShowCheckedModeBanner: false,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));

  // ponytail: asersi judul SEBELUM matchesGoldenFile. Tanpa ini, golden bisa
  // diam-diam memotret keadaan yang salah dan tetap "lulus" (pelajaran dari
  // golden onboarding: en_1 dan en_6 keluar byte-identik).
  if (expectText != null) {
    expect(find.text(expectText), findsOneWidget,
        reason: 'teks $expectText tidak ada — golden akan memotret keadaan salah');
  }
  expect(find.byKey(const Key('home-hero-card')), findsOneWidget);

  await expectLater(
    find.byKey(const Key('home-hero-card')),
    matchesGoldenFile(path),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  activeThemePreset = AppThemePreset.darkEmerald;

  testWidgets('lihat: hero home (sapaan + nama)', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    _seed(nickname: 'Kris');
    await _shot(
      tester,
      'goldens/home_hero.png',
      expectText: 'Assalamualaikum, Kris',
    );
  });

  // Arah sebaliknya dari bug lama: dulu user tanpa nama melihat "Muslim
  // Leveling • Lv 1" (appTitle dipakai sebagai pengganti nama). Sekarang harus
  // jatuh ke onbDefaultNickname, bukan ke nama app.
  testWidgets('lihat: hero home (tanpa nama) — fallback, bukan appTitle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    _seed(nickname: '');
    await _shot(
      tester,
      'goldens/home_hero_no_name.png',
      expectText: 'Assalamualaikum, Pejuang',
    );
    expect(find.text('Muslim Leveling'), findsNothing,
        reason: 'nama app tidak boleh lagi jadi pengganti nama user');
  });
}
