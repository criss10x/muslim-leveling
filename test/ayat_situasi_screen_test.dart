// Layar Ayat Rekomendasi.
//
// Keputusan user yang dijaga tes ini:
//  - "1 ayat, tiap situasi punya banyak ayat dan itu keluar random" -> layar
//    situasi menampilkan SATU ayat; tombol "ayat lain" mengganti ayat, tidak
//    menambah daftar.
//  - "Buka ayat Quran saja" -> satu tombol aksi, membuka QuranReader.
//  - label situasi diambil dari ARB per-id, jadi 54 situasi wajib punya
//    terjemahan di 4 bahasa.
//
// Kontrol negatif untuk tes ini ada di catatan commit; guard yang tidak pernah
// terbukti merah tidak boleh dipercaya.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_leveling/screens/ayat_situasi_screen.dart';
import 'package:muslim_leveling/screens/quran_reader.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/services/quran_situasi.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';

import 'helpers/app_wrap.dart';

/// I/O aset TIDAK selesai di dalam `testWidgets`: fake clock tidak memajukan
/// I/O sungguhan, dan menunggunya bikin runner menggantung. Karena itu cache
/// dipanaskan lewat `runAsync` (pola yang sudah dipakai
/// `quran_ayah_ref_tab_test.dart`), lalu widget di-pump.
Future<void> _warm(WidgetTester tester, String? id) async {
  await tester.runAsync(() async {
    await quranSituasi.all();
    await quranSituasi.groups();
    final surahs = await quranData.surahs();
    if (id != null) {
      final sit = await quranSituasi.byId(id);
      for (final ref in sit?.ayahs ?? const <({int surah, int ayah})>[]) {
        await quranData.ayahs(ref.surah);
      }
    } else {
      // Semua surah yang dipakai situasi mana pun (dipakai mode daftar).
      final all = await quranSituasi.all();
      for (final n in {for (final s in all) for (final r in s.ayahs) r.surah}) {
        await quranData.ayahs(n);
      }
    }
    expect(surahs, isNotEmpty);
  });
}

Future<void> _pumpDaftar(WidgetTester tester) async {
  await _warm(tester, null);
  await tester.pumpWidget(appWrap(const AyatSituasiScreen()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _pumpSituasi(WidgetTester tester, String id) async {
  await _warm(tester, id);
  await tester.pumpWidget(appWrap(AyatSituasiScreen(situationId: id)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(quranSituasi.resetForTest);

  group('layar daftar situasi', () {
    testWidgets('menampilkan judul dari ARB, bukan teks hardcode',
        (tester) async {
      await _pumpDaftar(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      expect(find.text(l10n.situasiTitle), findsOneWidget);
    });

    testWidgets('semua 54 situasi muncul sebagai label yang bisa dibaca',
        (tester) async {
      await _pumpDaftar(tester);
      final list = await quranSituasi.all();
      expect(list.length, 54);
      // Setiap situasi harus punya label ARB yang tidak kosong; kalau ada kunci
      // yang lupa ditambahkan, ARB generator akan menggagalkan build, tapi
      // daftar yang kosong lolos compile. Jadi diperiksa di sini.
      final ctx = tester.element(find.byType(AyatSituasiScreen));
      for (final s in list) {
        expect(situationLabel(AppL10n.of(ctx), s.id), isNotEmpty,
            reason: '${s.id}: label ARB kosong');
      }
    });

    testWidgets('semua 9 grup bisa dijangkau dengan menggulir', (tester) async {
      await _pumpDaftar(tester);
      final ctx = tester.element(find.byType(AyatSituasiScreen));
      final l10n = AppL10n.of(ctx);
      final groups = await quranSituasi.groups();
      expect(groups.length, 9);

      // ponytail: ListView mem-virtualisasi anaknya, jadi menghitung yang
      // terender SEKARANG selalu gagal walau daftarnya benar. Yang diuji
      // perilakunya: semua grup benar-benar bisa dicapai user dengan menggulir.
      final found = <String>{};
      for (var i = 0; i < 40; i++) {
        for (final g in groups) {
          if (find.text(groupLabel(l10n, g.id)).evaluate().isNotEmpty) {
            found.add(g.id);
          }
        }
        if (found.length == groups.length) break;
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump();
      }
      expect(found.length, groups.length,
          reason: 'grup tidak terjangkau: ${groups.map((g) => g.id).toSet().difference(found)}');
    });

    testWidgets('semua 54 situasi bisa dijangkau dengan menggulir',
        (tester) async {
      await _pumpDaftar(tester);
      final ctx = tester.element(find.byType(AyatSituasiScreen));
      final l10n = AppL10n.of(ctx);
      final all = await quranSituasi.all();
      final found = <String>{};
      for (var i = 0; i < 120; i++) {
        for (final s in all) {
          if (find.text(situationLabel(l10n, s.id)).evaluate().isNotEmpty) {
            found.add(s.id);
          }
        }
        if (found.length == all.length) break;
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump();
      }
      expect(found.length, all.length,
          reason: 'situasi tidak terjangkau: ${all.map((s) => s.id).toSet().difference(found)}');
    });

    testWidgets('tap situasi membuka layar ayat untuk situasi itu',
        (tester) async {
      await _pumpDaftar(tester);
      final ctx = tester.element(find.byType(AyatSituasiScreen));
      final label = situationLabel(AppL10n.of(ctx), 'sedih');
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(QuranReader), findsNothing);
      // Layar ayat menggantikan daftar: judul situasinya harus masih terlihat.
      expect(find.text(label), findsWidgets);
    });
  });

  group('layar ayat (1 ayat, acak)', () {
    testWidgets('menampilkan teks ayat dari situasi itu (Arab + terjemahan)',
        (tester) async {
      await _pumpSituasi(tester, 'sedih');
      final ref = quranSituasi.currentAyat('sedih')!;
      final ayah = (await quranData.ayahs(ref.surah))[ref.ayah - 1];
      // Terjemahan yang tampil harus milik ayat yang sedang dipilih, bukan
      // ayat lain: ini yang membedakan "ayat berganti" dari "layar ganti".
      expect(find.textContaining(ayah.translation.substring(0, 40)),
          findsOneWidget);
    });

    testWidgets('tombol "ayat lain" mengganti ayat, tidak menumpuk',
        (tester) async {
      await _pumpSituasi(tester, 'sedih');
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      final before = quranSituasi.currentAyat('sedih')!;
      await tester.tap(find.text(l10n.situasiOtherAyah));
      await tester.pump(const Duration(milliseconds: 50));
      final after = quranSituasi.currentAyat('sedih')!;
      expect('${after.surah}:${after.ayah}', isNot('${before.surah}:${before.ayah}'),
          reason: 'ayat tidak berganti setelah menekan "ayat lain"');
    });

    testWidgets('tombol buka Quran ada dan membuka QuranReader', (tester) async {
      await _pumpSituasi(tester, 'sedih');
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      expect(find.text(l10n.situasiOpenInQuran), findsOneWidget);
      await tester.tap(find.text(l10n.situasiOpenInQuran));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(QuranReader), findsOneWidget);
    });

    testWidgets('membuka di QuranReader memakai ayat yang SEDANG tampil',
        (tester) async {
      await _pumpSituasi(tester, 'sedih');
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      // Majukan beberapa ayat supaya bukan ayat pertama.
      await tester.tap(find.text(l10n.situasiOtherAyah));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tap(find.text(l10n.situasiOtherAyah));
      await tester.pump(const Duration(milliseconds: 30));
      final shown = quranSituasi.currentAyat('sedih')!;
      await tester.tap(find.text(l10n.situasiOpenInQuran));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final reader = tester.widget<QuranReader>(find.byType(QuranReader));
      expect(reader.surah.number, shown.surah);
      expect(reader.initialAyah, shown.ayah,
          reason: 'yang dibuka bukan ayat yang sedang tampil');
    });

    testWidgets('situasi tidak dikenal tidak crash, hanya kosong',
        (tester) async {
      await _pumpSituasi(tester, 'situasi-hantu');
      expect(tester.takeException(), isNull);
      expect(find.byType(QuranReader), findsNothing);
    });
  });

  group('label ARB 4 bahasa', () {
    testWidgets('label situasi beda antar bahasa (bukan hardcode Indonesia)',
        (tester) async {
      final idLabel = <String, String>{};
      final enLabel = <String, String>{};
      await _warm(tester, null);
      for (final loc in [const Locale('id'), const Locale('en')]) {
        await tester.pumpWidget(appWrap(const AyatSituasiScreen(), locale: loc));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
        final target = loc.languageCode == 'id' ? idLabel : enLabel;
        for (final s in await quranSituasi.all()) {
          target[s.id] = situationLabel(l10n, s.id);
        }
      }
      final same = idLabel.entries
          .where((e) => enLabel[e.key] == e.value)
          .map((e) => e.key)
          .toList();
      // Beberapa label memang sama (mis. "Kiblat"-style kata serapan), jadi
      // yang dijaga: mayoritas BEDA. Kalau semua sama, berarti kuncinya belum
      // masuk ARB dan yang terender adalah teks Indonesia.
      expect(same.length, lessThan(idLabel.length ~/ 2),
          reason: 'terlalu banyak label identik id==en: $same');
    });

    testWidgets('tidak ada em dash di label manapun', (tester) async {
      await _warm(tester, null);
      for (final loc in [
        const Locale('id'),
        const Locale('en'),
        const Locale('ms'),
        const Locale('tr'),
      ]) {
        await tester.pumpWidget(appWrap(const AyatSituasiScreen(), locale: loc));
        await tester.pump();
        final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
        final texts = <String>[
          l10n.situasiTitle,
          l10n.situasiOtherAyah,
          l10n.situasiOpenInQuran,
          for (final g in await quranSituasi.groups())
            groupLabel(l10n, g.id),
          for (final s in await quranSituasi.all())
            situationLabel(l10n, s.id),
        ];
        for (final t in texts) {
          expect(t.contains('\u2014'), isFalse,
              reason: '${loc.languageCode}: em dash di "$t"');
        }
      }
    });
  });
}
