import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';

// ponytail: runnable check untuk pencarian "surat + nomor ayat",
// mis. "Al-Baqarah 286". Yang mudah rusak diam-diam:
//  (a) normalisasi nama — getNameLatin tak konsisten sendiri ("Ali 'Imran",
//      "Asy-Syu'ara'"), sementara user mengetik "ali imran" / "albaqarah".
//  (b) nomor ayat di luar rentang → harus null, bukan diam-diam ke ayat 1.
//  (c) nama ambigu ("nas" → An-Nas + An-Nasr) → jangan menebak.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<QuranSurah> all;
  setUpAll(() async {
    all = await quranData.surahs();
  });

  ({QuranSurah surah, int ayah})? p(String q) => QuranData.parseAyahRef(all, q);

  test('acuan contoh dari user: Al-Baqarah 286', () {
    final r = p('Al-Baqarah 286');
    expect(r, isNotNull);
    expect(r!.surah.number, 2);
    expect(r.ayah, 286);
  });

  test('contoh yang ditampilkan ke user benar-benar bisa diparse', () {
    // Hint kolom cari + pesan kosong memakai QuranData.exampleAyahRef. Kalau
    // contohnya diganti jadi format yang parser tak dukung, user diajari
    // cara yang tidak jalan — dan itu lolos semua tes lain.
    final r = p(QuranData.exampleAyahRef);
    expect(r, isNotNull, reason: 'contoh "${QuranData.exampleAyahRef}" '
        'tidak diparse parseAyahRef');
    expect(r!.surah.number, 2);
    expect(r.ayah, 286);
  });

  test('tanda baca dan pemisah nama surat dimaafkan', () {
    // User mengetik cepat: tanpa tanda hubung, tanpa spasi, pakai titik dua.
    for (final q in [
      'al-baqarah 286',
      'al baqarah 286',
      'albaqarah 286',
      'baqarah 286',
      'baqarah:286',
      'BAQARAH 286',
      'baqarah: 286',
    ]) {
      final r = p(q);
      expect(r?.surah.number, 2, reason: 'gagal untuk "$q"');
      expect(r?.ayah, 286, reason: 'gagal untuk "$q"');
    }
  });

  test('nama surat ber-apostrof ikut cocok', () {
    // getNameLatin memakai apostrof ("Ali 'Imran", "Asy-Syu'ara'") yang tidak
    // akan pernah user ketik.
    final a = p('ali imran 200');
    expect(a?.surah.number, 3);
    expect(a?.ayah, 200);

    final b = p("asy-syuara 100");
    expect(b?.surah.number, 26);
    expect(b?.ayah, 100);
  });

  test('nomor surat sebagai ganti nama', () {
    final r = p('2:286');
    expect(r?.surah.number, 2);
    expect(r?.ayah, 286);
    expect(p('2.286')?.ayah, 286);
  });

  test('nomor ayat di luar rentang → null, bukan ayat 1', () {
    // Al-Baqarah cuma 286 ayat, Al-Fatihah 7.
    expect(p('Al-Baqarah 287'), isNull);
    expect(p('Al-Baqarah 0'), isNull);
    expect(p('Al-Fatihah 8'), isNull);
    expect(p('Al-Fatihah 7')?.ayah, 7);
    // Surat tidak ada.
    expect(p('Al-Baqarah 286 999'), isNull);
  });

  test('nama ambigu tidak ditebak', () {
    // "nas" cocok dengan An-Nas DAN An-Nasr → null (bukan pilih salah satu).
    expect(p('nas 1'), isNull);
    expect(p('an-nas 1')?.surah.number, 114);
  });

  test('bukan acuan → null (jangan salah klaim)', () {
    expect(p('286'), isNull, reason: 'angka polos bisa nomor surat 2..114');
    expect(p('kehidupan akhirat'), isNull);
    expect(p(''), isNull);
    expect(p('baqarah'), isNull, reason: 'tanpa nomor ayat bukan acuan');
  });

  test('nomor ayat cocok dengan data aset yang sebenarnya', () async {
    // Mencegah parse lolos tapi ayatnya tak ada saat reader dibuka.
    final r = p('Al-Baqarah 286');
    final ayahs = await quranData.ayahs(r!.surah.number);
    expect(ayahs.length, greaterThanOrEqualTo(r.ayah));
    expect(ayahs[r.ayah - 1].ayah, 286);
  });
}
