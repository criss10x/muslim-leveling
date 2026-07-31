import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:muslim_leveling/screens/quran_reader.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/services/quran_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final surah = QuranSurah(
    number: 2,
    nameArabic: 'البقرة',
    nameLatin: 'Al-Baqarah',
    meaning: 'Sapi Betina',
    ayahCount: 286,
    revelation: 'Madaniyah',
  );

  Future<void> pumpReader(WidgetTester tester, {int? initialAyah}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuranReader(
                      surah: surah,
                      initialAyah: initialAyah,
                    ),
                  ),
                ),
                child: const Text('buka'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
  }

  /// Posisi vertikal label 'Ayat N' relatif terhadap viewport list.
  double ayahDy(WidgetTester tester, int ayah) =>
      tester.getTopLeft(find.text('Ayat $ayah').first).dy;

  double listTop(WidgetTester tester) =>
      tester.getTopLeft(find.byType(ScrollablePositionedList)).dy;

  double listHeight(WidgetTester tester) => tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position
      .viewportDimension;

  testWidgets(
    'resume membuka tepat di ayat tersimpan: label ayat di garis 25%',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await quranProgress.load();
      // Panaskan cache ayat dulu: fallback aset surat 2 (~2MB) butuh I/O asli
      // yang tidak selesai dalam waktu fake test.
      await tester.runAsync(() => quranData.ayahs(2));

      await pumpReader(tester, initialAyah: 50);
      await tester.pumpAndSettle();

      // Item 50 harus ada di viewport dan berada di sekitar garis 25%.
      expect(find.text('Ayat 50'), findsWidgets);
      final expected = listTop(tester) + listHeight(tester) * 0.25;
      expect(
        (ayahDy(tester, 50) - expected).abs(),
        lessThan(60),
        reason: 'Ayat 50 harus di garis 25% viewport, bukan meleset '
            'beberapa ayat (bug estimasi scrollTo).',
      );
    },
  );

  testWidgets(
    'round trip: posisi yang disimpan dipulihkan presisi saat dibuka lagi',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await quranProgress.load();
      await tester.runAsync(() => quranData.ayahs(2));

      // Baca normal, scroll ke bawah, lalu keluar.
      await pumpReader(tester);
      await tester.drag(
        find.byType(ScrollablePositionedList),
        const Offset(0, -3000),
      );
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      final p = await SharedPreferences.getInstance();
      final savedSurah = p.getInt('quran_last_surah');
      final savedAyah = p.getInt('quran_last_ayah');
      expect(savedSurah, 2);
      expect(savedAyah, isNotNull);

      // Buka lagi lewat tombol lanjut.
      await pumpReader(tester, initialAyah: savedAyah);
      await tester.pumpAndSettle();

      final expected = listTop(tester) + listHeight(tester) * 0.25;
      expect(
        (ayahDy(tester, savedAyah!) - expected).abs(),
        lessThan(60),
        reason: 'Ayat tersimpan ($savedAyah) harus kembali ke garis 25%, '
            'bukan mundur beberapa ayat.',
      );
    },
  );
}
