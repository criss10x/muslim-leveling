import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/services/game_service.dart';

/// ponytail: penjaga struktur tab Home — 5 pintasan harus ada di bawah ring
/// "RITUAL HARI INI", dan section lama yang dipindah tidak boleh muncul lagi
/// (kalau muncul = pemindahan belum bersih / ada sisa render ganda).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<void> pumpHome(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeTab())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('5 pintasan AKSES CEPAT ada di Home', (tester) async {
    await pumpHome(tester);
    await tester.scrollUntilVisible(find.text('AKSES CEPAT'), 200);

    expect(find.text('AKSES CEPAT'), findsOneWidget);
    for (final label in ['Hadis', 'Doa', 'Kiblat', 'Dzikir', 'Renungan']) {
      expect(find.text(label), findsOneWidget, reason: 'tombol $label hilang');
    }
    // 'Highlight' sengaja ditinggalkan: tabrakan 3 arti (kutipan artikel Belajar,
    // sorot hasil cari Quran, judul halaman tujuan 'Renungan Hari Ini').
    expect(find.text('Highlight'), findsNothing,
        reason: 'label Highlight seharusnya sudah jadi Renungan');
  });

  testWidgets('section lama yg dipindah tidak dirender lagi di Home',
      (tester) async {
    await pumpHome(tester);
    await tester.scrollUntilVisible(find.text('AKSES CEPAT'), 200);

    // Dipindah ke tombol / halaman baru → tidak boleh jadi section penuh.
    expect(find.text('DAILY ZIKIR'), findsNothing);
    expect(find.text('BUKA TASBIH DIGITAL'), findsNothing);
    expect(find.text('DAILY HIGHLIGHT'), findsNothing);
  });

  // ponytail: seed lewat SharedPreferences (bukan setStateForTest) supaya
  // HomeTab._load() benar-benar membaca state-nya, seperti di produksi.
  Future<void> pumpWithMask(WidgetTester tester, int mask) async {
    SharedPreferences.setMockInitialValues({
      'game_state_v1': jsonEncode(
        GameState(
          highlightSwipeDate: GameService.todayStr(),
          highlightSwipeMask: mask,
        ).toMap(),
      ),
    });
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HomeTab())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('0 blok → meta progres disembunyikan', (tester) async {
    await pumpWithMask(tester, 0);
    await tester.scrollUntilVisible(find.text('AKSES CEPAT'), 200);

    expect(find.textContaining('RENUNGAN'), findsNothing);
  });

  testWidgets('3 blok (mask 0b0111) → "RENUNGAN 3/4", bukan 7', (tester) async {
    await pumpWithMask(tester, 0x7);
    await tester.scrollUntilVisible(find.text('AKSES CEPAT'), 200);

    expect(find.text('RENUNGAN 3/4'), findsOneWidget);
    expect(find.text('RENUNGAN 7/4'), findsNothing);
  });
}
