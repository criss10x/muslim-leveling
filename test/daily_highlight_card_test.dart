import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:muslim_leveling/screens/home_tab.dart';
import 'package:muslim_leveling/services/daily_highlight.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('HomeTab menampilkan DAILY HIGHLIGHT saat cache disk valid',
      (tester) async {
    final today = DateTime.now();
    final date =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
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

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HomeTab())));
    await tester.pump(); // _load() baca cache
    await tester.pump(); // setState hasil _load
    await tester.scrollUntilVisible(find.text('DAILY HIGHLIGHT'), 200);

    expect(find.text('DAILY HIGHLIGHT'), findsOneWidget);
    expect(find.text('QS. Al-Fatihah: 1'), findsOneWidget);
  });

  testWidgets('tanpa cache → kartu sembunyi, home tetap render',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HomeTab())));
    await tester.pump();
    expect(find.text('DAILY HIGHLIGHT'), findsNothing);
  });
}
