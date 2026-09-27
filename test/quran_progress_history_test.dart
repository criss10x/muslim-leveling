import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/services/quran_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    quranProgress.resetForTest();
  });

  test('save 1 posisi: riwayat 1 entri, previousEntries kosong', () async {
    await quranProgress.save(2, 255);
    expect(quranProgress.hasProgress, isTrue);
    expect(quranProgress.surahNumber, 2);
    expect(quranProgress.ayah, 255);
    expect(quranProgress.previousEntries, isEmpty);
  });

  test('save 3 surat beda: 3 entri, terbaru dulu', () async {
    await quranProgress.save(2, 255);
    await quranProgress.save(18, 10);
    await quranProgress.save(36, 30);
    expect(quranProgress.surahNumber, 36);
    expect(quranProgress.previousEntries.map((e) => e.surah), [18, 2]);
  });

  test('surat ke-4 menggeser yang terlama keluar (maks 3)', () async {
    await quranProgress.save(1, 5);
    await quranProgress.save(2, 10);
    await quranProgress.save(3, 15);
    await quranProgress.save(4, 20);
    expect(quranProgress.previousEntries.map((e) => e.surah), [3, 2]);
    expect(
      quranProgress.previousEntries.any((e) => e.surah == 1),
      isFalse,
    );
  });

  test('update posisi surat yang sudah ada: naik ke depan, tidak dobel', () async {
    await quranProgress.save(2, 255);
    await quranProgress.save(18, 10);
    await quranProgress.save(2, 100);
    expect(quranProgress.surahNumber, 2);
    expect(quranProgress.ayah, 100);
    // 18 tetap, 2 tidak dobel.
    expect(quranProgress.previousEntries.map((e) => e.surah), [18]);
  });

  test('save posisi sama persis: tidak ada perubahan', () async {
    await quranProgress.save(2, 255);
    await quranProgress.save(2, 255);
    expect(quranProgress.previousEntries, isEmpty);
  });

  test('load: seed dari key tunggal lama saat riwayat belum ada', () async {
    SharedPreferences.setMockInitialValues({
      'quran_last_surah': 67,
      'quran_last_ayah': 12,
    });
    quranProgress.resetForTest();
    await quranProgress.load();
    expect(quranProgress.surahNumber, 67);
    expect(quranProgress.ayah, 12);
    expect(quranProgress.previousEntries, isEmpty);
  });

  test('save menulis key riwayat DAN key tunggal lama tetap terisi', () async {
    await quranProgress.save(18, 10);
    final p = await SharedPreferences.getInstance();
    expect(p.getString('quran_recent_positions'), isNotNull);
    expect(p.getInt('quran_last_surah'), 18);
    expect(p.getInt('quran_last_ayah'), 10);
  });

  test('load: riwayat JSON valid dipulihkan utuh', () async {
    await quranProgress.save(2, 255);
    await quranProgress.save(18, 10);
    quranProgress.resetForTest();
    await quranProgress.load();
    expect(quranProgress.surahNumber, 18);
    expect(quranProgress.previousEntries.map((e) => e.surah), [2]);
  });

  test('load: JSON rusak → kosong, tidak crash', () async {
    SharedPreferences.setMockInitialValues({
      'quran_recent_positions': '{bukan-json',
    });
    quranProgress.resetForTest();
    await quranProgress.load();
    expect(quranProgress.hasProgress, isFalse);
  });

  test('load: entri di luar rentang surah dibuang', () async {
    SharedPreferences.setMockInitialValues({
      'quran_recent_positions': '[[999,1],[2,10]]',
    });
    quranProgress.resetForTest();
    await quranProgress.load();
    expect(quranProgress.surahNumber, 2);
  });
}
