import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:muslim_leveling/screens/daily_highlight_screen.dart';
import 'package:muslim_leveling/services/daily_highlight.dart';
import 'package:muslim_leveling/services/game_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(dailyHighlightService.resetForTest);

  testWidgets('DailyHighlightScreen menampilkan ayat dari cache disk',
      (tester) async {
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

    await tester.pumpWidget(
      const MaterialApp(home: DailyHighlightScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // _load() auto-claim XP halaman 1 → toast XP hidup 1600ms + animasi
    // reverse. Majukan waktu sampai toast selesai, kalau tidak ticker-nya
    // masih aktif saat widget di-unmount (Overlay disposed with active Ticker).
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('DAILY HIGHLIGHT'), findsOneWidget);
    expect(find.text('QS. Al-Fatihah: 1'), findsOneWidget);
    expect(find.text('Dengan nama Allah'), findsOneWidget);
  });

  testWidgets('tanpa cache → halaman tetap render dgn pesan kosong',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: DailyHighlightScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tidak crash; header tetap ada.
    expect(find.text('DAILY HIGHLIGHT'), findsOneWidget);
  });
}
