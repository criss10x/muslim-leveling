import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';

void main() {
  // Diperlukan agar rootBundle bisa membaca aset di lingkungan test.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('surahs() memuat 114 surat', () async {
    final list = await quranData.surahs();
    expect(list.length, 114);
    expect(list.first.nameLatin, 'Al-Fatihah');
    expect(list.first.meaning, 'Pembukaan');
    expect(list.first.ayahCount, 7);
    expect(list.first.revelation, 'Makkiyah');
  });

  test('ayahs() memuat ayat surat tertentu', () async {
    final ayahs = await quranData.ayahs(1);
    expect(ayahs.length, 7);
    expect(ayahs.first.ayah, 1);
    expect(ayahs.first.arabic, isNotEmpty);
    expect(ayahs.first.translation, contains('Allah'));
  });

  test('ayahs() memuat surat panjang sepenuhnya', () async {
    final ayahs = await quranData.ayahs(2);
    expect(ayahs.length, 286);
    expect(ayahs.last.ayah, 286);
  });

  test('search() mencocokkan nama latin, arti, dan nomor', () async {
    final all = await quranData.surahs();

    expect(quranData.search(all, 'baqarah').single.number, 2);
    // Case-insensitive.
    expect(quranData.search(all, 'BAQARAH').single.number, 2);
    // Nomor surat.
    expect(quranData.search(all, '114').single.nameLatin, 'An-Nas');
    // Arti bahasa Indonesia.
    expect(quranData.search(all, 'Pembukaan').single.number, 1);
    // Query kosong mengembalikan semuanya.
    expect(quranData.search(all, '').length, 114);
  });
}
