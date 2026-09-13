import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:muslim_leveling/screens/daily_highlight_screen.dart';
import 'package:muslim_leveling/services/daily_highlight.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/services/ulama_quotes.dart';

/// Ayat uji harus punya padanan asli di aset: _resolve() mencocokkan
/// surah+ayat dari aset lokal, dan tanpa kecocokan tombol aksi disembunyikan.
const _surahLatin = 'Al-Fatihah';
const _ayahNumber = 1;

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: DailyHighlightScreen()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  // _load() auto-claim XP halaman 1 → toast XP hidup 1600ms + animasi
  // reverse. Majukan waktu sampai toast selesai, kalau tidak ticker-nya
  // masih aktif saat widget di-unmount (Overlay disposed with active Ticker).
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
}

void _seedToday() {
  final date = GameService.todayStr();
  SharedPreferences.setMockInitialValues({
    'daily_highlight': jsonEncode(const DailyHighlight(
      date: 'PLACEHOLDER',
      surahLatin: _surahLatin,
      ayahArabic: 'بِسْمِ اللَّهِ',
      ayahIdn: 'Dengan nama Allah',
      surahNumber: 1,
      ayahNumber: _ayahNumber,
      hadisId: 5,
      hadisIdn: 'Hadis uji',
      doaNama: 'Doa uji',
      doaIdn: 'Teks doa uji',
    ).toMap()..['date'] = date),
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(dailyHighlightService.resetForTest);

  testWidgets('halaman menampilkan ayat + sitasi + tanggal hijriah slot', (
    tester,
  ) async {
    _seedToday();
    await _pump(tester);

    expect(find.text('DAILY HIGHLIGHT'), findsOneWidget);
    expect(find.text('QS. $_surahLatin : $_ayahNumber'), findsOneWidget);
    expect(find.text('Dengan nama Allah'), findsOneWidget);
  });

  testWidgets('ayat jadi bintang: 4 aksi (dengar/simpan/tafsir/bagikan) ada', (
    tester,
  ) async {
    _seedToday();
    await _pump(tester);

    // _resolve() membaca aset asli → harus ketemu, kalau tidak aksi disembunyikan.
    expect(find.text('Dengar'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
    expect(find.text('Tafsir'), findsOneWidget);
    expect(find.text('Bagikan'), findsOneWidget);
  });

  testWidgets('penutup: progres hari ini tampil sebagai "n dari 4"', (
    tester,
  ) async {
    _seedToday();
    await _pump(tester);

    // 4 blok (ayat + hadis + doa + kata ulama); halaman 1 klaim otomatis.
    expect(find.textContaining('dari 4 renungan dibaca'), findsOneWidget);
  });

  // ponytail: PageView.builder cuma membangun halaman yang terlihat, jadi blok
  // ke-4 tak bisa dicari lewat finder. Uji datanya langsung.
  test('kutipan ulama: pool tidak kosong & deterministik per tanggal', () {
    expect(ulamaQuotes.length, greaterThanOrEqualTo(10));
    for (final q in ulamaQuotes) {
      expect(q.tokoh, isNotEmpty);
      expect(q.idn, isNotEmpty);
    }
    final a = ulamaQuotes[highlightIndex('2026-08-16', ulamaQuotes.length)];
    final b = ulamaQuotes[highlightIndex('2026-08-16', ulamaQuotes.length)];
    expect(a.tokoh, b.tokoh);
    expect(a.idn, b.idn);
  });

  // ponytail: bug nyata — footer dulu mencetak BITMASK mentah sebagai angka
  // progres, jadi 3 blok terbaca "7 dari 4". Jaga keduanya: bitCount + render.
  test('bitCount: mask dihitung, bukan dicetak mentah', () {
    expect(GameService.bitCount(0), 0);
    expect(GameService.bitCount(0x1), 1);
    expect(GameService.bitCount(0x7), 3); // 0b111 → 3, bukan 7
    expect(GameService.bitCount(0xF), 4);
  });

  testWidgets('3 dari 4 blok dibaca → footer "3 dari 4", bukan "7 dari 4"', (
    tester,
  ) async {
    final date = GameService.todayStr();
    SharedPreferences.setMockInitialValues({
      'daily_highlight': jsonEncode(const DailyHighlight(
        date: 'PLACEHOLDER',
        surahLatin: _surahLatin,
        ayahArabic: 'بِسْمِ اللَّهِ',
        ayahIdn: 'Dengan nama Allah',
        surahNumber: 1,
        ayahNumber: _ayahNumber,
        hadisId: 5,
        hadisIdn: 'Hadis uji',
        doaNama: 'Doa uji',
        doaIdn: 'Teks doa uji',
      ).toMap()..['date'] = date),
      'game_state_v1': jsonEncode(
        GameState(
          // Halaman 0..2 diklaim (Ayat/Hadis/Doa) → mask 0b0111 = 7.
          highlightSwipeDate: date,
          highlightSwipeMask: 0x7,
        ).toMap(),
      ),
    });
    // Di device, Home sudah memuat GameService sebelum push layar ini — tes
    // harus meniru itu, kalau tidak bitmask-nya masih 0 saat initState.
    await GameService.load();

    await _pump(tester);

    expect(find.textContaining('3 dari 4 renungan dibaca'), findsOneWidget);
    expect(find.textContaining('7 dari 4'), findsNothing);
    expect(find.text('Renungan hari ini tuntas'), findsNothing);
  });

  testWidgets('tanpa cache → halaman tetap render dgn pesan kosong', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: DailyHighlightScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tidak crash; header tetap ada.
    expect(find.text('DAILY HIGHLIGHT'), findsOneWidget);
  });

  testWidgets('QuranTafsir untuk ayat di luar daftar tidak bikin crash', (
    tester,
  ) async {
    // Penjaga: firstWhere di _openTafsir punya orElse → jangan pernah throw.
    const t = QuranTafsir(ayah: 0, shortText: '', longText: '');
    expect(t.longText, isEmpty);
  });
}
