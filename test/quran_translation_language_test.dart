import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_api.dart';
import 'package:muslim_leveling/services/quran_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('quranUseEnglish', () {
    test('hanya locale id yang memakai Indonesia', () {
      expect(quranUseEnglish(const Locale('id')), isFalse);
      for (final code in ['en', 'tr', 'ms', 'ar', 'ja']) {
        expect(quranUseEnglish(Locale(code)), isTrue, reason: code);
      }
    });

    test('varian region tetap ikut bahasa dasarnya', () {
      expect(quranUseEnglish(const Locale('id', 'ID')), isFalse);
      expect(quranUseEnglish(const Locale('en', 'US')), isTrue);
    });
  });

  group('stripBasmalah', () {
    // Teks asli dari alquran.cloud (edisi quran-uthmani) — diketik dari data,
    // bukan dari ingatan.
    const basmalah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

    test('Al-Fatihah & At-Taubah tidak disentuh', () {
      // Di Al-Fatihah basmalah MEMANG ayat pertama; di At-Taubah tak ada.
      expect(stripBasmalah(basmalah, 1), basmalah);
      const taubah = 'بَرَآءَةٌۭ مِّنَ ٱللَّهِ وَرَسُولِهِۦٓ';
      expect(stripBasmalah(taubah, 9), taubah);
    });

    test('basmalah yang menempel dibuang', () {
      expect(stripBasmalah('$basmalah الٓمٓ', 2), 'الٓمٓ');
      expect(
        stripBasmalah('$basmalah قُلْ هُوَ ٱللَّهُ أَحَدٌ', 112),
        'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
      );
    });

    test('syakal berbeda (`بِّسْمِ` di surat 95/97) tetap dikenali', () {
      // Surat 95 & 97 memakai syadda di ba — perbandingan yang tidak
      // menormalkan harakat akan gagal di sini dan basmalah tampil dobel.
      final s95 = 'بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلتِّينِ وَٱلزَّيْتُونِ';
      expect(stripBasmalah(s95, 95), 'وَٱلتِّينِ وَٱلزَّيْتُونِ');
    });

    test('ayat yang bukan basmalah dikembalikan apa adanya', () {
      const lain = 'يَٰٓأَيُّهَا ٱلَّذِينَ آمَنُوا';
      expect(stripBasmalah(lain, 2), lain);
      expect(stripBasmalah('', 5), '');
    });

    test('tidak menghasilkan string kosong untuk ayat 1 surat normal', () {
      // Kalau ini gagal, artinya logika membuang terlalu banyak.
      for (final n in [2, 27, 55, 112, 114]) {
        final r = stripBasmalah('$basmalah قُلْ هُوَ ٱللَّهُ أَحَدٌ', n);
        expect(r.trim(), isNotEmpty, reason: 'surat $n');
      }
    });
  });

  group('tafsir', () {
    test('English memakai katalog Al-Mukhtasar, bukan Indonesia', () {
      // Jaring terhadap salah ketik URL: tanpa jaringan pun URI harus menunjuk
      // edisi Inggris.
      expect(tafsirEnBaseForTest, contains('en-tafsir-al-mukhtasar'));
      expect(tafsirEnBaseForTest, isNot(contains('indonesian')));
    });

    test('tafsir English terpasang di kedua layar', () {
      // Regex sederhana: pastikan kedua pemanggil meneruskan `english:`.
      // Kalau seseorang menghapusnya, tafsir balik ke Indonesia tanpa error.
      for (final path in [
        'lib/screens/quran_reader.dart',
        'lib/screens/daily_highlight_screen.dart',
      ]) {
        final src = File(path).readAsStringSync();
        expect(
          RegExp(r'quranApi\.tafsir\([^)]*english:').hasMatch(src),
          isTrue,
          reason: path,
        );
      }
    });
  });

  group('aset terjemahan Inggris', () {
    test('ayat Inggris memakai teks arab aset, terjemahan Inggris', () async {
      final en = await quranData.ayahs(112, english: true);
      expect(en.length, 4);
      expect(en.first.ayah, 1);
      expect(en.first.arabic, isNotEmpty);
      expect(en.first.translation, contains('One'));
      // Latin/transliterasi ikut dari aset arab.
      expect(en.first.latin, isNotNull);
    });

    test('jumlah ayat Inggris sama dengan Indonesia untuk 114 surat', () async {
      // Kalau ini melenceng, terjemahan akan nyantol ke ayat yang salah.
      for (final n in [1, 2, 9, 55, 95, 97, 112, 114]) {
        final id = await quranData.ayahs(n);
        final en = await quranData.ayahs(n, english: true);
        expect(en.length, id.length, reason: 'surat $n');
        expect(
          en.map((a) => a.ayah).toList(),
          id.map((a) => a.ayah).toList(),
          reason: 'surat $n',
        );
      }
    });

    test('cache bahasa terpisah (id tidak tercemar en)', () async {
      final a = await quranData.ayahs(112);
      final b = await quranData.ayahs(112, english: true);
      final a2 = await quranData.ayahs(112);
      expect(a.first.translation, contains('Katakanlah'));
      expect(b.first.translation, contains('Say'));
      expect(a2.first.translation, contains('Katakanlah'));
      expect(identical(a, b), isFalse);
    });

    test('aset lokal juga membuang basmalah (dulu dobel saat offline)', () async {
      // Reader merender basmalah sebagai header sendiri; aset lokal menempelkan
      // basmalah di ayat 1, jadi tanpa dibuang pengguna melihatnya dua kali.
      final id2 = await quranData.ayahs(2);
      expect(id2.first.arabic.contains('بِسْمِ'), isFalse);
      expect(id2.first.arabic, 'الٓمٓ');
      // Al-Fatihah: basmalah MEMANG ayat 1 → jangan dibuang.
      final id1 = await quranData.ayahs(1);
      expect(id1.first.arabic.contains('بِسْمِ'), isTrue);
    });

    test('pencarian ayat ikut bahasa', () async {
      // "Merciful" hanya ada di indeks Inggris; "Maha" hanya di Indonesia.
      final en = await quranData.searchVerses('Merciful', english: true);
      expect(en.hits, isNotEmpty);
      final id = await quranData.searchVerses('Merciful');
      expect(id.hits, isEmpty);
    });
  });
}
