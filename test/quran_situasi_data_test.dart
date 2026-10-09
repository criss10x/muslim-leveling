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
      // Minimal 3: user bisa menekan "ayat lain". Kurang dari itu, tombolnya
      // cepat terasa tidak berguna.
      expect(
        s.ayahs.length,
        greaterThanOrEqualTo(3),
        reason: 'situasi "${s.id}" cuma punya ${s.ayahs.length} ayat (min 3)',
      );
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

  // Yang benar-benar merusak pengalaman user: DUA AYAT DALAM SATU SITUASI
  // punya kalimat pembuka sama. User menekan "ayat lain", lalu membaca kalimat
  // yang sama lagi dan mengira aplikasinya mengulang. Itu cakupan tes ini:
  // antar-situasi.
  //
  // Kenapa BUKAN lintas seluruh daftar: pembuka berulang itu gaya bahasa
  // Al-Quran, bukan bug. Ar-Rum 20-25 semuanya dibuka "Dan di antara
  // tanda-tanda kekuasaan-Nya ialah", dan 3:185 & 21:35 sama-sama dibuka
  // "Tiap-tiap yang berjiwa akan merasakan mati" padahal keduanya jawaban
  // terbaik untuk situasi yang berbeda. Memaksa unik lintas daftar berarti
  // membuang ayat yang paling tepat hanya demi angka - rugi yang nyata.
  test('dalam satu situasi tidak ada dua ayat dengan pembuka sama', () async {
    final list = await quranSituasi.all();
    final problems = <String>[];
    for (final s in list) {
      final seen = <String, String>{};
      for (final r in s.ayahs) {
        final ayahs = await quranData.ayahs(r.surah);
        final text =
            ayahs[r.ayah - 1].translation.replaceAll(RegExp(r'\s+'), ' ');
        // 6 kata pertama sudah cukup menangkap kasus nyata.
        final head = text.split(' ').take(6).join(' ').toLowerCase();
        final ref = '${r.surah}:${r.ayah}';
        final prev = seen[head];
        if (prev != null) {
          problems.add('${s.id}: $ref dan $prev');
        }
        seen[head] = ref;
      }
    }
    expect(problems, isEmpty,
        reason: 'satu situasi menampilkan ayat dgn pembuka sama: '
            '${problems.join("; ")}');
  });

  test('semua situasi bisa dicari lewat id (dasar filter pencarian)', () async {
    final list = await quranSituasi.all();
    for (final s in list) {
      expect(s.id, matches(RegExp(r'^[a-z0-9-]+$')),
          reason: '${s.id}: id harus lowercase-kebab (dipakai sebagai kunci ARB)');
    }
  });

  group('pemilihan ayat acak (shuffle-bag)', () {
    test('semua ayat tampil sekali sebelum ada yang terulang', () async {
      final list = await quranSituasi.all();
      for (final s in list) {
        quranSituasi.resetForTest();
        await quranSituasi.all();
        final n = s.ayahs.length;
        final seen = <String>[];
        for (var i = 0; i < n; i++) {
          final a = quranSituasi.nextAyat(s.id, seed: 7)!;
          seen.add('${a.surah}:${a.ayah}');
        }
        // Inilah janji ke user: "klik lagi -> ayat lain", bukan ayat yang sama.
        expect(seen.toSet().length, n,
            reason: '${s.id}: ada ayat terulang dalam satu putaran: $seen');
      }
    });

    test('putaran berikutnya tetap mengeluarkan ayat yang sah', () async {
      final s = (await quranSituasi.all()).first;
      quranSituasi.resetForTest();
      await quranSituasi.all();
      quranSituasi.nextAyat(s.id, seed: 3);
      final valid = s.ayahs.map((r) => '${r.surah}:${r.ayah}').toSet();
      for (var i = 0; i < 4; i++) {
        final a = quranSituasi.nextAyat(s.id);
        expect(valid, contains('${a!.surah}:${a.ayah}'));
      }
    });

    test('ayat pertama pun tidak boleh langsung terulang', () async {
      final s = (await quranSituasi.all()).first;
      // Beberapa seed berbeda: yang penting tidak ada pasangan berurutan sama.
      for (final seed in [1, 2, 5, 11, 42]) {
        quranSituasi.resetForTest();
        await quranSituasi.all();
        final a = quranSituasi.nextAyat(s.id, seed: seed)!;
        final b = quranSituasi.nextAyat(s.id);
        expect('${a.surah}:${a.ayah}', isNot('${b!.surah}:${b.ayah}'),
            reason: 'seed $seed: ayat pertama terulang di klik kedua');
      }
    });

    test('currentAyat mengikuti ayat yang tampil', () async {
      final s = (await quranSituasi.all()).first;
      quranSituasi.resetForTest();
      await quranSituasi.all();
      expect(quranSituasi.currentAyat(s.id), isNull, reason: 'belum dipanggil');
      final a = quranSituasi.nextAyat(s.id, seed: 9)!;
      final cur = quranSituasi.currentAyat(s.id)!;
      expect('${cur.surah}:${cur.ayah}', '${a.surah}:${a.ayah}');
    });

    test('situasi tidak dikenal mengembalikan null, bukan melempar', () async {
      quranSituasi.resetForTest();
      await quranSituasi.all();
      expect(quranSituasi.nextAyat('situasi-hantu'), isNull);
      expect(quranSituasi.currentAyat('situasi-hantu'), isNull);
    });
  });
}
