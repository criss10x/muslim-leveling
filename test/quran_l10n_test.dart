import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/l10n/quran_texts.g.dart';
import 'package:muslim_leveling/screens/quran_tab.dart';

import 'helpers/app_wrap.dart';

/// Tab Quran pernah sepenuhnya hardcode Indonesia: chrome (hint cari, jumlah
/// hasil, tooltip) DAN arti surat + jenis wahyu dari `assets/quran/surahs.json`.
/// Tes ini mengunci keduanya ke bahasa aktif.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppL10n> l10n(WidgetTester tester, Locale locale) async {
    late AppL10n out;
    await tester.pumpWidget(
      appWrap(
        Builder(
          builder: (context) {
            out = AppL10n.of(context);
            return const SizedBox.shrink();
          },
        ),
        locale: locale,
      ),
    );
    return out;
  }

  group('arti surat + jenis wahyu ikut bahasa', () {
    testWidgets('en: arti dari API Inggris, bukan aset Indonesia', (tester) async {
      final t = await l10n(tester, const Locale('en'));
      expect(surahMeaning(t, 1), 'The Opening');
      expect(surahMeaning(t, 2), 'The Cow');
      expect(surahMeaning(t, 114), 'Mankind');
    });

    testWidgets('id: tetap arti Kemenag', (tester) async {
      final t = await l10n(tester, const Locale('id'));
      expect(surahMeaning(t, 1), 'Pembukaan');
      expect(surahMeaning(t, 2), 'Sapi');
    });

    testWidgets('nomor di luar 1..114 balik kosong, bukan melempar', (tester) async {
      final t = await l10n(tester, const Locale('id'));
      expect(surahMeaning(t, 0), '');
      expect(surahMeaning(t, 115), '');
    });

    testWidgets('jenis wahyu: makna beda per bahasa, label lama tetap dikenali',
        (tester) async {
      final id = await l10n(tester, const Locale('id'));
      expect(surahRevelation(id, 'Meccan'), 'Makkiyah');
      expect(surahRevelation(id, 'Makkiyah'), 'Makkiyah');
      expect(surahRevelation(id, 'Madaniyah'), 'Madaniyah');

      final en = await l10n(tester, const Locale('en'));
      expect(surahRevelation(en, 'Makkiyah'), 'Meccan');
      expect(surahRevelation(en, 'Meccan'), 'Meccan');
      expect(surahRevelation(en, 'Madaniyah'), 'Medinan');
    });

    testWidgets('arti tak dikenal diteruskan apa adanya', (tester) async {
      final en = await l10n(tester, const Locale('en'));
      expect(surahRevelation(en, 'Unknown'), 'Unknown');
    });
  });

  group('paritas arti surat di semua bahasa', () {
    for (final locale in const [
      Locale('id'),
      Locale('en'),
      Locale('tr'),
      Locale('ms'),
    ]) {
      testWidgets('${locale.languageCode}: 114 arti terisi, tidak ada yang kosong',
          (tester) async {
        final t = await l10n(tester, locale);
        final empty = [
          for (var n = 1; n <= 114; n++)
            if (surahMeaning(t, n).trim().isEmpty) n,
        ];
        expect(empty, isEmpty, reason: '${locale.languageCode}: arti kosong di $empty');
      });
    }

    testWidgets('tr/ms bukan salinan template Indonesia', (tester) async {
      final id = await l10n(tester, const Locale('id'));
      final tr = await l10n(tester, const Locale('tr'));
      final ms = await l10n(tester, const Locale('ms'));

      // Ambang = RASIO, bukan jumlah: Melayu serumpun dengan Indonesia, jadi
      // sebagian arti memang sah identik ("Wanita", "Hidangan", "Pembukaan").
      // Yang diperiksa: bukan salinan template utuh. Terukur 2026-09-21 —
      // tr 2/114, ms 74/114.
      int sameAs(AppL10n other) => [
        for (var n = 1; n <= 114; n++)
          if (surahMeaning(other, n) == surahMeaning(id, n)) n,
      ].length;

      expect(sameAs(tr) / 114, lessThan(0.25),
          reason: 'tr masih salinan Indonesia: ${sameAs(tr)}/114');
      expect(sameAs(ms) / 114, lessThan(0.75),
          reason: 'ms masih salinan Indonesia: ${sameAs(ms)}/114');
    });
  });

  group('chrome tab Quran ikut bahasa', () {
    testWidgets('en: subtitle, hint cari, dan tooltip jadi English', (tester) async {
      await tester.pumpWidget(
        appWrap(const Scaffold(body: QuranTab()), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('114 surahs · 30 juz'), findsOneWidget);
      expect(find.text('114 surat · 30 juz'), findsNothing);

      final field = tester.widget<TextField>(find.byType(TextField));
      final hint = field.decoration!.hintText!;
      expect(hint, contains('Search'));
      // Helper "e.g., Al-Baqarah 286" sudah DIBUANG dari field: contoh pencarian
      // ada di tombol bantuan di dalam field, jadi baris itu cuma mengulang.
      // Janji "contohnya masih tersedia" dipindah ke test tombol bantuan.
      expect(field.decoration!.helperText, isNull,
          reason: 'helper contoh harus hilang dari kotak cari');
      expect(hint.contains('Cari'), isFalse);
    });

    testWidgets('contoh ayat tetap tersedia lewat tombol bantuan',
        (tester) async {
      await tester.pumpWidget(
        appWrap(const Scaffold(body: QuranTab()), locale: const Locale('id')),
      );
      await tester.pumpAndSettle();

      // Yang dibuang cuma baris pengulangnya, bukan kemampuannya: contohnya
      // harus tetap bisa ditemukan & dipakai user.
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      expect(find.text('Al-Baqarah 286'), findsOneWidget);
    });

    testWidgets('kotak cari tidak menyisakan baris helper (muat di 320dp)',
        (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        appWrap(const Scaffold(body: QuranTab()), locale: const Locale('id')),
      );
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      final d = field.decoration!;
      // Sisa helper tidak boleh dirender lagi (dulu contohnya terpotong di sini).
      expect(d.helperText, isNull);
      final helperFinder = find.text('mis. Al-Baqarah 286');
      expect(helperFinder, findsNothing,
          reason: 'baris helper harus benar-benar hilang dari layar');
      // Hint tetap utuh di dalam field.
      final hintFinder = find.text(d.hintText!);
      final hRect = tester.getRect(hintFinder);
      expect(hRect.width, lessThan(tester.getRect(find.byType(TextField)).width),
          reason: 'hint ter-ellipsis');
    });

    testWidgets('en: arti surat di daftar jadi English', (tester) async {
      await tester.pumpWidget(
        appWrap(const Scaffold(body: QuranTab()), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('The Opening'), findsOneWidget);
      expect(find.textContaining('Pembukaan'), findsNothing);
    });

    testWidgets('id: tidak berubah dari sebelumnya', (tester) async {
      await tester.pumpWidget(
        appWrap(const Scaffold(body: QuranTab()), locale: const Locale('id')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Al-Quran'), findsOneWidget);
      expect(find.text('114 surat · 30 juz'), findsOneWidget);
      expect(find.textContaining('Pembukaan'), findsOneWidget);
    });
  });
}
