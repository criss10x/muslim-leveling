import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';

/// Panduan "cara mencari" di bawah kotak cari tab Quran.
///
/// Yang dijaga di sini bukan teksnya, melainkan JANJI-nya: setiap contoh yang
/// ditampilkan ke user harus benar-benar menghasilkan sesuatu lewat jalur
/// pencarian yang sebenarnya. Contoh yang tidak menghasilkan apa pun lebih
/// buruk daripada tidak ada panduan sama sekali.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('contoh panduan benar-benar menghasilkan', () {
    test('acuan ayat: "Al-Baqarah 286" diparse parser produksi', () async {
      final all = await quranData.surahs();
      final ref = QuranData.parseAyahRef(all, QuranData.exampleAyahRef);
      expect(ref, isNotNull,
          reason: 'contoh panduan "${QuranData.exampleAyahRef}" tidak '
              'menghasilkan apa-apa');
      expect(ref!.surah.nameLatin, 'Al-Baqarah');
      expect(ref.ayah, 286);
    });

    test('acuan nomor: "2:286" menghasilkan Al-Baqarah 286', () async {
      final all = await quranData.surahs();
      final ref = QuranData.parseAyahRef(all, '2:286');
      expect(ref, isNotNull,
          reason: 'contoh panduan "2:286" tidak menghasilkan apa-apa');
      expect(ref!.surah.nameLatin, 'Al-Baqarah');
      expect(ref.ayah, 286);
    });

    test('acuan nomor dengan titik "2.286" juga bekerja', () async {
      final all = await quranData.surahs();
      final ref = QuranData.parseAyahRef(all, '2.286');
      expect(ref, isNotNull);
      expect(ref!.surah.nameLatin, 'Al-Baqarah');
      expect(ref.ayah, 286);
    });

    test('acuan nomor di luar jumlah ayat ditolak, bukan menebak', () async {
      final all = await quranData.surahs();
      // Al-Baqarah hanya 286 ayat.
      expect(QuranData.parseAyahRef(all, '2:999'), isNull);
      // Surat 115 tidak ada.
      expect(QuranData.parseAyahRef(all, '115:1'), isNull);
    });

    test('kata terjemahan: "kesabaran" ketemu di ayat', () async {
      final res = await quranData.searchVerses('kesabaran', english: false);
      expect(res.hits, isNotEmpty,
          reason: 'contoh panduan "kesabaran" tidak ketemu di terjemahan ID');
      // Hasil pertama harus benar-benar memuat kata itu (bukan false positive
      // akibat index salah bahasa).
      expect(res.hits.first.translation.toLowerCase(), contains('kesabaran'));
    });

    test('arti surat: "sapi" menemukan Al-Baqarah', () async {
      final all = await quranData.surahs();
      final hits = quranData.search(all, 'sapi');
      expect(hits.length, 1,
          reason: '"sapi" harus menemukan tepat satu surat');
      expect(hits.first.nameLatin, 'Al-Baqarah');
    });

    test('nama surat: "baqarah" juga ketemu (tanpa awalan Al-)', () async {
      final all = await quranData.surahs();
      expect(quranData.search(all, 'baqarah').first.nameLatin, 'Al-Baqarah');
    });
  });

  group('contoh Inggris tetap sah saat bahasa app Inggris', () {
    test('"patience" ketemu di terjemahan Inggris', () async {
      final res = await quranData.searchVerses('patience', english: true);
      expect(res.hits, isNotEmpty);
      expect(res.hits.first.translation.toLowerCase(), contains('patience'));
    });

    /// Panduan memakai contoh yang sama di semua bahasa (kata "kesabaran",
    /// "sapi", dan acuan ayat). Kalau app berbahasa Inggris, contoh itu tetap
    /// harus bekerja: nama surat & arti tidak berubah (keduanya dari aset yang
    /// sama), dan terjemahannya dicari di indeks bahasa aktif.
    test('acuan ayat & nama surat tidak bergantung bahasa', () async {
      final all = await quranData.surahs();
      expect(QuranData.parseAyahRef(all, QuranData.exampleAyahRef), isNotNull);
      expect(quranData.search(all, 'sapi'), isNotEmpty);
      expect(quranData.search(all, 'cow'), isEmpty,
          reason: 'arti surat hanya tersedia dalam bahasa Indonesia; panduan '
              'tidak boleh menjanjikan "cow"');
    });
  });
}
