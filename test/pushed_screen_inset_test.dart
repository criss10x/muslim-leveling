// ponytail: penjaga "footer halaman pushed tidak tenggelam di nav bar sistem".
//
// Konteks: daily_highlight_screen punya Scaffold SENDIRI (di-push, bukan anak
// DashboardShell). `SafeArea(bottom: false)` di sana mematikan inset, jadi
// footer "n dari N renungan dibaca" tertutup nav button Android.
//
// Ukur geometri render tree terhadap viewPadding (inset sistem) — bukan
// mengandalkan pesan overflow yang tidak deterministik.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/screens/daily_highlight_screen.dart';
import 'package:muslim_leveling/services/daily_highlight.dart';
import 'package:muslim_leveling/services/game_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(dailyHighlightService.resetForTest);

  testWidgets('footer Renungan berhenti di atas inset nav bar sistem (#bug)',
      (tester) async {
    // ponytail: DUA jebakan yang sudah dibuktikan bikin tes ini bohong:
    // 1. `tester.view.padding` WAJIB di-set, bukan cuma `viewPadding` —
    //    MediaQuery.padding (yang dibaca SafeArea) tidak terisi dari
    //    viewPadding (probe: hanya viewPadding → MediaQuery.padding = zero).
    // 2. FakeViewPadding nilainya FISIK, bukan logis. Dengan dpr 3, inset 72
    //    "fisik" cuma menggeser 24 logis — makanya batas aman harus dihitung
    //    dengan nilai logis, kalau tidak tes gagal walau kode benar.
    const dpr = 3.0;
    const bottomInset = 48.0; // logis (~nav bar/gesture Android)
    const topInset = 30.0; // logis (status bar)
    tester.view.physicalSize = const Size(1236, 2745);
    tester.view.devicePixelRatio = dpr;
    const insets = FakeViewPadding(
      top: topInset * dpr,
      bottom: bottomInset * dpr,
    );
    tester.view.viewPadding = insets;
    tester.view.padding = insets;
    addTearDown(tester.view.reset);

    // Footer hanya dirender kalau ada data hari ini (selain itu _empty()).
    final date = GameService.todayStr();
    SharedPreferences.setMockInitialValues({
      'daily_highlight': jsonEncode(const DailyHighlight(
        date: 'PLACEHOLDER',
        surahLatin: 'Al-Fatihah',
        ayahArabic: 'بِسْمِ اللَّهِ',
        ayahIdn: 'Dengan nama Allah',
        surahNumber: 1,
        ayahNumber: 1,
        hadisId: 5,
        hadisIdn: 'Hadis uji',
        doaNama: 'Doa uji',
        doaIdn: 'Teks doa uji',
      ).toMap()..['date'] = date),
    });

    await tester.pumpWidget(const MaterialApp(home: DailyHighlightScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Toast XP auto-claim halaman 1 hidup 1600ms — habiskan supaya ticker
    // tidak aktif saat unmount.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    final target = find.textContaining('renungan dibaca');
    expect(target.evaluate(), isNotEmpty,
        reason: 'teks footer tidak ditemukan — tes tidak menguji apa pun');

    // Batas bawah area aman = tinggi viewport - inset sistem (logis).
    final viewport = tester.getSize(find.byType(Scaffold));
    final safeBottom = viewport.height - bottomInset;

    final footerBottom = tester.getRect(target).bottom;
    expect(
      footerBottom,
      lessThanOrEqualTo(safeBottom + 1),
      reason: 'footer (${footerBottom.toStringAsFixed(1)}) menembus inset nav '
          'bar sistem (batas aman ${safeBottom.toStringAsFixed(1)}) — bagian '
          'bawahnya tertutup nav button Android',
    );
  });
}
