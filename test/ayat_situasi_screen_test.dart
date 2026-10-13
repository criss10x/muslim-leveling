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
import 'package:muslim_leveling/widgets/common.dart';

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

/// Pump ulang layar tingkat 1 dengan pohon yang benar-benar baru.
///
/// `pumpWidget` dengan widget bertipe sama TIDAK me-reset Navigator: `home`
/// diganti, tapi rute yang sudah di-push tetap hidup di atasnya, sehingga tes
/// berikutnya menekan elemen yang tidak ada di layar teratas (jebakan ini
/// terbukti: 3 tes gagal "found 0 widgets"). KeyedSubtree dengan key baru
/// memaksa MaterialApp-nya dibangun ulang. Terukur: pickGroup 1 -> 0.
Future<void> _pumpDaftarFresh(WidgetTester tester) async {
  await _warm(tester, null);
  await tester.pumpWidget(KeyedSubtree(
    key: UniqueKey(),
    child: appWrap(const AyatSituasiScreen()),
  ));
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

    testWidgets('semua 9 grup tetap terjangkau, tapi lewat alasannya masing-masing',
        (tester) async {
      // Sebelumnya 9 grup ada di SATU layar. Sekarang tiap grup berada di bawah
      // alasannya. Yang dijaga: tidak ada grup yang jadi yatim (tidak muncul di
      // alasan mana pun) dan tidak ada yang muncul dua kali.
      await _pumpDaftar(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      final groups = await quranSituasi.groups();
      expect(groups.length, 9);

      final reached = <String, String>{}; // grup -> alasan yang menampilkannya
      for (final u in kUmbrellas) {
        await _pumpDaftarFresh(tester);
        await tester.tap(find.text(umbrellaLabel(l10n, u)));
        await tester.pumpAndSettle();
        for (final g in groups) {
          if (find.text(groupLabel(l10n, g.id)).evaluate().isNotEmpty) {
            expect(reached.containsKey(g.id), isFalse,
                reason: 'grup "${g.id}" muncul di ${reached[g.id]} dan $u');
            reached[g.id] = u;
          }
        }
      }
      final missing = groups.map((g) => g.id).toSet()
          .difference(reached.keys.toSet());
      expect(missing, isEmpty, reason: 'grup tidak terjangkau: $missing');
    });

    testWidgets('tingkat 1: 4 alasan tampil, bukan 54 situasi', (tester) async {
      // Inti keluhan user: sebelumnya 54 situasi tampil sekaligus ("semua orang
      // jadi bingung"). Sekarang yang tampil di tingkat pertama cuma 4 alasan.
      await _pumpDaftar(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      for (final u in kUmbrellas) {
        expect(find.text(umbrellaLabel(l10n, u)), findsOneWidget,
            reason: 'alasan "$u" tidak tampil di tingkat 1');
        expect(find.text(umbrellaHint(l10n, u)), findsOneWidget,
            reason: 'kalimat bantu "$u" tidak tampil');
      }
      // Tidak ada satu pun label situasi di tingkat 1.
      for (final s in await quranSituasi.all()) {
        expect(find.text(situationLabel(l10n, s.id)), findsNothing,
            reason: '${s.id} bocor ke tingkat 1');
      }
    });

    testWidgets('tingkat 1: setiap alasan bisa ditekan dan membuka tingkat 2',
        (tester) async {
      await _pumpDaftar(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      for (final u in kUmbrellas) {
        await _pumpDaftarFresh(tester);
        await tester.tap(find.text(umbrellaLabel(l10n, u)));
        await tester.pumpAndSettle();
        // Judul jadi nama alasan itu + pertanyaan tingkat 2 terlihat.
        expect(find.text(l10n.situasiPickGroup), findsOneWidget,
            reason: 'tingkat 2 tidak terbuka untuk "$u"');
      }
    });

    testWidgets('tingkat 2 hanya menampilkan grup milik alasan itu',
        (tester) async {
      await _pumpDaftar(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      // shifa = kacau + hubungan + ampunan; tIDAK berisi iman.
      await tester.tap(find.text(umbrellaLabel(l10n, 'shifa')));
      await tester.pumpAndSettle();

      for (final g in await quranSituasi.groups()) {
        final shouldShow = g.umbrella == 'shifa';
        expect(
          find.text(groupLabel(l10n, g.id)).evaluate().isNotEmpty,
          shouldShow,
          reason: 'grup "${g.id}" (umbrella ${g.umbrella}) '
              '${shouldShow ? "tidak" : "justru"} tampil di bawah shifa',
        );
      }
      // Alasan yang dipilih jadi jejak di app bar (konteks tidak hilang).
      expect(find.text(umbrellaLabel(l10n, 'shifa')), findsWidgets);
    });

    testWidgets('tingkat 3: grup besar terbelah sub-tahap, bukan daftar polos',
        (tester) async {
      await _pumpDaftar(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      // jalur: dikuatkan -> ujian (7 situasi, 2 tahap)
      await tester.tap(find.text(umbrellaLabel(l10n, 'dikuatkan')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(groupLabel(l10n, 'ujian')));
      await tester.pumpAndSettle();

      final group = (await quranSituasi.groups())
          .firstWhere((g) => g.id == 'ujian');
      expect(group.stages.length, greaterThanOrEqualTo(2));
      for (final st in group.stages) {
        expect(find.text(stageLabel(l10n, st)), findsOneWidget,
            reason: 'penanda tahap "$st" tidak tampil');
      }
      // Semua situasi grup itu tetap bisa dijangkau (tidak ada yang hilang).
      for (final s in (await quranSituasi.all())
          .where((s) => s.group == 'ujian')) {
        expect(find.text(situationLabel(l10n, s.id)).evaluate().isNotEmpty,
            isTrue, reason: '${s.id} hilang dari tingkat 3');
      }
    });

    testWidgets('tingkat 3: grup kecil dibiarkan datar (tanpa penanda tahap)',
        (tester) async {
      await _pumpDaftar(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      // diingatkan -> dunia (4 situasi, sengaja tanpa tahap)
      await tester.tap(find.text(umbrellaLabel(l10n, 'diingatkan')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(groupLabel(l10n, 'dunia')));
      await tester.pumpAndSettle();

      for (final s in (await quranSituasi.all())
          .where((s) => s.group == 'dunia')) {
        expect(find.text(situationLabel(l10n, s.id)).evaluate().isNotEmpty,
            isTrue, reason: '${s.id} tidak tampil di grup datar');
      }
      // Tidak boleh ada penanda tahap di grup datar.
      final group = (await quranSituasi.groups())
          .firstWhere((g) => g.id == 'dunia');
      expect(group.stages, isEmpty, reason: 'dunia seharusnya datar');
    });

    testWidgets('sasaran sentuh tiap baris minimal 48dp (Android)',
        (tester) async {
      // Craft floor: baris pilihan harus bisa ditekan jari, bukan cuma terlihat.
      // Diukur, bukan diasumsikan.
      //
      // Catatan KN: versi pertama tes ini HANYA mengukur baris tingkat 1,
      // padahal baris tingkat 2/3 dirender `_row` yang berbeda -> memendekkan
      // `_row` di bawah 48dp tetap HIJAU (lubang). Sekarang ketiga tingkat diukur.
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Future<void> checkRows(String where) async {
        final cards = find.byType(FlatCard);
        expect(cards.evaluate(), isNotEmpty, reason: '$where: tidak ada baris');
        for (var i = 0; i < cards.evaluate().length; i++) {
          final h = tester.getRect(cards.at(i)).height;
          expect(h, greaterThanOrEqualTo(48),
              reason: '$where: baris ke-$i cuma ${h}dp, di bawah 48dp');
        }
      }

      // tingkat 1
      await _pumpDaftarFresh(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      await checkRows('tingkat 1');

      // tingkat 2
      await tester.tap(find.text(umbrellaLabel(l10n, 'shifa')));
      await tester.pumpAndSettle();
      await checkRows('tingkat 2');

      // tingkat 3 (grup bertahap: ada penanda tahap + baris situasi)
      await tester.tap(find.text(groupLabel(l10n, 'kacau')));
      await tester.pumpAndSettle();
      await checkRows('tingkat 3');
    });

    testWidgets('3 kali tekan dari tingkat 1 sampai ayat (bukan 4 layar)',
        (tester) async {
      // Janji UX: 4 alasan -> grup -> situasi, jadi 3 tekan untuk sampai ayat.
      // Jalur tersulit: grup bertahap (ujian punya 2 tahap -> 2 layar tingkat 3).
      await _pumpDaftar(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));

      await tester.tap(find.text(umbrellaLabel(l10n, 'dikuatkan')));   // 1
      await tester.pumpAndSettle();
      await tester.tap(find.text(groupLabel(l10n, 'ujian')));          // 2
      await tester.pumpAndSettle();
      await tester.tap(find.text(situationLabel(l10n, 'sakit')));      // 3
      await tester.pumpAndSettle();

      // Sampai di layar ayat: kedua tombolnya ada.
      expect(find.text(l10n.situasiOtherAyah), findsOneWidget,
          reason: 'belum sampai layar ayat setelah 3 tekan');
      expect(find.text(l10n.situasiOpenInQuran), findsOneWidget);
    });

    testWidgets('tap situasi membuka layar ayat untuk situasi itu',
        (tester) async {
      await _pumpDaftar(tester);
      final l10n = AppL10n.of(tester.element(find.byType(AyatSituasiScreen)));
      // sedih ada di bawah shifa -> kacau
      await tester.tap(find.text(umbrellaLabel(l10n, 'shifa')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(groupLabel(l10n, 'kacau')));
      await tester.pumpAndSettle();
      final label = situationLabel(l10n, 'sedih');
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

    testWidgets('ayat terpusat di layar, bukan menempel atas', (tester) async {
      // Terukur sebelum perbaikan @412x915: konten berhenti di 330px padahal
      // tombol mulai di 871px -> ruang mati 541px di bawah ayat, terbaca
      // seperti layar yang belum selesai memuat. Sesudah Center: selisih
      // jarak-atas dan jarak-bawah 8px di kedua tinggi layar.
      for (final h in [640.0, 915.0]) {
        tester.view.physicalSize = Size(412, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await _pumpSituasi(tester, 'sedih');

        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final refT = texts.firstWhere((t) => (t.data ?? '').startsWith('QS.'));
        // Terjemahan: teks panjang bukan Arab (ayatnya AC AK, jadi dicari
        // berdasarkan bentuk, bukan ayat tertentu).
        final trT = texts.firstWhere((t) =>
            (t.data ?? '').length > 40 &&
            !RegExp(r'[\u0600-\u06FF]').hasMatch(t.data ?? ''));
        final btnT =
            texts.firstWhere((t) => (t.data ?? '') == 'Buka di Quran');

        final appBarBottom = tester.getRect(find.byType(AppBar)).bottom;
        final gapAtas = tester.getRect(find.byWidget(refT)).top - appBarBottom;
        final gapBawah =
            tester.getRect(find.byWidget(btnT)).top -
                tester.getRect(find.byWidget(trT)).bottom;

        expect((gapAtas - gapBawah).abs(), lessThan(40),
            reason: 'h=$h: ayat tidak terpusat (atas=$gapAtas bawah=$gapBawah)');
      }
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
