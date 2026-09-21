// Guard layout blok header tab Quran: judul, kaligrafi, dan search field pinned.
//
// Kenapa tes ini ada: judul dan kaligrafi sama-sama dibungkus `Expanded`, jadi
// keduanya berbagi satu kolom flex dan judul hanya dapat setengah ruang sisa.
// Akibatnya "Al-Quran" terpotong "Al-Qur…" di 320dp (butuh 116,4px, dapat
// 110px) dan di semua locale begitu teks sistem membesar. Terukur 2026-09-21.
//
// PENTING soal font. `flutter_test` memakai font bawaan (Ahem: setiap glif
// selebar 1 em) yang metriknya TIDAK mencerminkan perangkat. Kalau nama family
// yang di-load di sini tidak cocok dengan yang didaftarkan `google_fonts`
// (`'<family>_<variant>'` — lihat `GoogleFontsFamilyWithVariant.toString`),
// tes diam-diam memakai Ahem dan melaporkan lebar/overflow yang palsu
// (kejadian nyata: judul "Al-Quran" terukur 226px, padahal 116,4px).
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/screens/quran_tab.dart';

import 'helpers/app_wrap.dart';

/// Judul tab per locale — dari `tabQuran` di app_{id,en,tr,ms}.arb.
const _titles = {
  'id': 'Al-Quran',
  'en': 'Quran',
  'tr': "Al-Qur'an",
  'ms': "Al-Qur'an",
};

const _khat = 'القرآن';

/// Lebar maksimum aksen kaligrafi di baris judul.
const _khatMaxWidth = 96.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final f in const [
      ['Sora_700', 'assets/google_fonts/Sora-Bold.ttf'],
      [
        'PlusJakartaSans_regular',
        'assets/google_fonts/PlusJakartaSans-Regular.ttf',
      ],
      ['AmiriQuran_400', 'assets/google_fonts/AmiriQuran-Regular.ttf'],
    ]) {
      final loader = FontLoader(f[0])..addFont(rootBundle.load(f[1]));
      await loader.load();
    }
  });

  Future<void> pumpTab(
    WidgetTester tester, {
    required double dp,
    required double scale,
    required Locale locale,
    bool withProgress = true,
  }) async {
    SharedPreferences.setMockInitialValues(
      withProgress
          ? const {'quran_last_surah': 2, 'quran_last_ayah': 286}
          : const {},
    );
    tester.view.physicalSize = Size(dp * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      appWrap(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: const Scaffold(body: QuranTab()),
        ),
        locale: locale,
      ),
    );
    await tester.pumpAndSettle();
  }

  int drainExceptions(WidgetTester tester) {
    var n = 0;
    while (tester.takeException() != null) {
      n++;
    }
    return n;
  }

  group('judul tab selalu utuh dan baris judul tidak pernah overflow', () {
    for (final dp in const [320.0, 360.0, 393.0]) {
      for (final scale in const [1.0, 1.3, 1.5, 2.0, 2.5]) {
        for (final e in _titles.entries) {
          testWidgets('${dp.toInt()}dp @${scale}x ${e.key}', (tester) async {
            await pumpTab(tester, dp: dp, scale: scale, locale: Locale(e.key));

            expect(find.text(e.value), findsOneWidget,
                reason: '${e.key}: judul tab tidak dirender');

            // FittedBox melayout Text tanpa batas lalu menskalakan saat paint.
            // Jadi: ukuran RenderParagraph = lebar intrinsik, ukuran FittedBox =
            // ruang yang tersedia. Yang bisa gagal cuma overflow barisnya.
            final fitted = find
                .ancestor(
                  of: find.text(e.value),
                  matching: find.byType(FittedBox),
                )
                .first;
            final para =
                find.text(e.value).evaluate().first.renderObject! as RenderParagraph;
            final box = tester.getSize(fitted).width;

            // Guard font: kalau aset font gagal dimuat, flutter_test diam-diam
            // memakai Ahem (tiap glif 1 em) dan semua angka di tes ini palsu.
            // Paragraf harus setuju dengan painter bergaya sama persis.
            final want = (TextPainter(
              text: TextSpan(text: para.text.toPlainText(), style: para.text.style),
              textDirection: TextDirection.ltr,
              maxLines: 1,
              textScaler: para.textScaler,
            )..layout())
                .width;
            expect(para.size.width, closeTo(want, 0.5),
                reason: '${e.key}: font aset tidak terpakai (Ahem?) — '
                    'paragraf ${para.size.width.toStringAsFixed(1)}px vs '
                    'painter ${want.toStringAsFixed(1)}px');

            // Inti regresi yang dijaga: pada skala 1,0 judul tampil PENUH. Dulu
            // "Al-Quran" terpotong jadi "Al-Qur…" karena berbagi kolom flex
            // dengan kaligrafi; sekarang aksen yang dibatasi, bukan judul.
            if (scale == 1.0) {
              expect(box, greaterThanOrEqualTo(para.size.width - 0.5),
                  reason: '${e.key} @${dp.toInt()}dp 1,0x: judul kehabisan ruang '
                      '(butuh ${para.size.width.toStringAsFixed(1)}px, '
                      'tersedia ${box.toStringAsFixed(1)}px)');
            }

            expect(drainExceptions(tester), 0,
                reason: '${e.key} @${dp.toInt()}dp ${scale}x: overflow layout');
          });
        }
      }
    }
  });

  group('kaligrafi aksen mengalah demi judul', () {
    testWidgets('tampil saat ada ruang (360dp @1,0x)', (tester) async {
      await pumpTab(tester, dp: 360, scale: 1.0, locale: const Locale('id'));
      expect(find.text(_khat), findsOneWidget);
      expect(
        tester
            .getSize(
              find.ancestor(of: find.text(_khat), matching: find.byType(FittedBox)).first,
            )
            .width,
        lessThanOrEqualTo(_khatMaxWidth + 0.5),
      );
    });

    testWidgets('disembunyikan saat judul sendiri tak muat (320dp @1,5x)',
        (tester) async {
      // Di 1,5x judul butuh ~172px sementara slotnya ~133,8px di 320dp;
      // dekorasi tidak lagi kebagian ruang, jadi ia yang mengalah.
      await pumpTab(tester, dp: 320, scale: 1.5, locale: const Locale('id'));
      expect(find.text(_khat), findsNothing);
      expect(find.text('Al-Quran'), findsOneWidget);
      expect(drainExceptions(tester), 0);
    });
  });

  testWidgets('tap target bookmark tetap 48x48 & header menempel saat digulir',
      (tester) async {
    await pumpTab(tester, dp: 360, scale: 1.0, locale: const Locale('id'));

    final btn = tester.getSize(find.byType(IconButton));
    expect(btn.width, greaterThanOrEqualTo(48.0));
    expect(btn.height, greaterThanOrEqualTo(48.0));

    // Header pinned: setelah menggulir, field menempel di atas viewport.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(TextField)).top, lessThanOrEqualTo(12.5));
    expect(find.text('Al-Quran'), findsNothing);
    expect(drainExceptions(tester), 0);
  });
}
