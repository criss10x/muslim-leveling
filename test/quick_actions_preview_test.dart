// ponytail: bukan golden regression — ini ALAT LIHAT. Blok "Akses Cepat"
// dirender jadi PNG supaya bisa dinilai mata manusia (agen tidak punya vision
// di environment ini). Jalankan dgn --update-goldens lalu kirim PNG-nya.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/theme/app_theme.dart';
import 'helpers/app_wrap.dart';

/// Seed progres Renungan (bitmask) lewat prefs — sama seperti produksi.
void _seed(int mask) {
  SharedPreferences.setMockInitialValues({
    'game_state_v1': jsonEncode(
      GameState(
        highlightSwipeDate: GameService.todayStr(),
        highlightSwipeMask: mask,
      ).toMap(),
    ),
  });
}

Future<void> _shot(WidgetTester tester, String path) async {
  await tester.pumpWidget(
    appWrap(const Scaffold(body: HomeTab()), theme: AppTheme.dark(), debugShowCheckedModeBanner: false),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.scrollUntilVisible(find.text('AKSES CEPAT'), 200);
  await tester.pump();

  // Potret blok Akses Cepat: Column terdekat yang memuat header + FlatCard.
  final block = find.ancestor(
    of: find.text('AKSES CEPAT'),
    matching: find.byType(Column),
  );
  expect(block, findsWidgets, reason: 'header AKSES CEPAT tidak ditemukan');
  await expectLater(block.first, matchesGoldenFile(path));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('lihat: akses cepat (progres 0)', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    _seed(0);
    await _shot(tester, 'goldens/quick_actions_0.png');
  });

  testWidgets('lihat: akses cepat (renungan tuntas 4/4)', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // ponytail: hex, bukan 0b1111 — Dart tidak punya literal biner; `0b1111`
    // terurai jadi dua argumen (0 + b1111) dan gagal compile.
    _seed(0xF);
    await _shot(tester, 'goldens/quick_actions_done.png');
  });
}
