// Guard data Ayat Rekomendasi.
//
// Invariant yang dijaga file ini SEMUANYA pernah jadi jalur bug nyata:
//  - referensi ayat di luar rentang (mis. surah 2 cuma punya 286 ayat) bisa lolos
//    ke UI dan menampilkan layar kosong / crash saat QuranReader membuka ayat itu;
//  - id dobel membuat satu situasi menimpa situasi lain di daftar;
//  - dua situasi dengan ayat yang sama persis membuat fitur terasa mengulang.
//
// Kontrol negatif untuk tiap tes ada di Task 2 plan; guard yang tidak pernah
// terbukti merah saat bug-nya dikembalikan tidak boleh dipercaya.
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/services/quran_situasi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => quranSituasi.resetForTest());

  test('setiap referensi ayat benar-benar ada di aset lokal', () async {
    final surahs = await quranData.surahs();
    final byNumber = {for (final s in surahs) s.number: s};
    final list = await quranSituasi.all();

    expect(list, isNotEmpty, reason: 'data situasi kosong');
    for (final s in list) {
      expect(s.ayahs.length, 3, reason: 'situasi "${s.id}" harus 3 ayat');
      for (final r in s.ayahs) {
        final surah = byNumber[r.surah];
        expect(surah, isNotNull, reason: '${s.id}: surah ${r.surah} tidak ada');
        expect(
          r.ayah,
          inInclusiveRange(1, surah!.ayahCount),
          reason:
              '${s.id}: ${r.surah}:${r.ayah} di luar rentang '
              '(surah ${r.surah} punya ${surah.ayahCount} ayat)',
        );
      }
    }
  });

  test('id situasi unik dan grupnya dikenal', () async {
    final list = await quranSituasi.all();
    final ids = list.map((s) => s.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'ada id situasi duplikat');

    final groups = (await quranSituasi.groups()).map((g) => g.id).toSet();
    for (final s in list) {
      expect(
        groups,
        contains(s.group),
        reason: '${s.id}: grup "${s.group}" tidak ada di daftar groups',
      );
    }
  });

  test('umbrella grup hanya dari 4 alasan yang dikenal', () async {
    const known = {'shifa', 'huda', 'dikuatkan', 'diingatkan'};
    for (final g in await quranSituasi.groups()) {
      expect(
        known,
        contains(g.umbrella),
        reason: 'grup "${g.id}" punya umbrella tak dikenal: ${g.umbrella}',
      );
    }
  });

  test('tidak ada dua situasi dengan tiga ayat yang identik', () async {
    final list = await quranSituasi.all();
    final sigs = <String, String>{};
    for (final s in list) {
      final sig = s.ayahs.map((r) => '${r.surah}:${r.ayah}').toList()..sort();
      final key = sig.join(',');
      expect(
        sigs.containsKey(key),
        isFalse,
        reason: '"${s.id}" kembar dengan "${sigs[key]}" (ayat sama persis)',
      );
      sigs[key] = s.id;
    }
  });

  test('semua situasi bisa dicari lewat id (dasar filter pencarian)', () async {
    final list = await quranSituasi.all();
    for (final s in list) {
      expect(s.id, matches(RegExp(r'^[a-z0-9-]+$')),
          reason: '${s.id}: id harus lowercase-kebab (dipakai sebagai kunci ARB)');
    }
  });
}
