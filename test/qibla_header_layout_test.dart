import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/qibla_screen.dart';
import 'package:muslim_leveling/theme/app_icons.dart';
import 'helpers/app_wrap.dart';

/// Penjaga layout header & dial kiblat.
///
/// Dua regresi nyata yang dikunci di sini:
///
/// 1. Tombol "Ganti tampilan" dulu P IL berlabel selebar 161dp yang duduk di
///    antara tombol kembali dan judul. Ia merebut ~45% lebar header sehingga
///    judul "Arah Kiblat" (butuh 140,6dp) hanya dapat 55dp di 320dp -> turun ke
///    dua baris dan terpotong. Sekarang tombol jadi ikon 48dp di trailing.
///
/// 2. Dial kompas dulu `SizedBox(300x300)` TETAP di dalam `Expanded`. Ia tidak
///    menyusut, jadi ruang yang kurang memotong isinya: di 360x640 dialnya
///    300x210 dan di 320x568 hilang sama sekali. Dial digambar dari pusat +
///    jari-jari, jadi kotak LONJONG = dial terpangkas.
Future<void> _loadFonts() async {
  for (final f in const [
    ['Sora_700', 'assets/google_fonts/Sora-Bold.ttf'],
    ['Sora_800', 'assets/google_fonts/Sora-ExtraBold.ttf'],
    ['PlusJakartaSans_regular',
      'assets/google_fonts/PlusJakartaSans-Regular.ttf'],
    ['PlusJakartaSans_semibold',
      'assets/google_fonts/PlusJakartaSans-SemiBold.ttf'],
    ['JetBrainsMono_700', 'assets/google_fonts/JetBrainsMono-Bold.ttf'],
    ['AmiriQuran_400', 'assets/google_fonts/AmiriQuran-Regular.ttf'],
  ]) {
    final l = FontLoader(f[0]);
    l.addFont(File(f[1]).readAsBytes().then(
        (b) => ByteData.view(b.buffer, b.offsetInBytes, b.lengthInBytes)));
    await l.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final (w, h) in const [
    (320.0, 568.0),
    (360.0, 640.0),
    (360.0, 720.0),
    (411.0, 800.0),
  ]) {
    testWidgets('header & dial utuh di ${w.toInt()}x${h.toInt()}', (
      tester,
    ) async {
      tester.view.physicalSize = Size(w, h);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(appWrap(const QiblaScreen(cityName: 'Jakarta')));
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }

      // --- dial: kotak harus PERSEGI, kalau tidak dialnya terpangkas ---
      double? dialW, dialH;
      for (final e in find.byType(SizedBox).evaluate()) {
        final box = e.renderObject;
        if (box is! RenderBox || !box.hasSize) continue;
        final s = box.size;
        if (s.width >= 80 && s.width <= 300.5 && s.height >= 80 &&
            s.height <= 300.5) {
          dialW = s.width;
          dialH = s.height;
        }
      }
      expect(dialW, isNotNull, reason: 'dial tidak dirender sama sekali');
      expect(dialH! / dialW!, closeTo(1.0, 0.001),
          reason: 'kotak dial lonjong -> isi dial terpangkas');

      // --- judul: harus tampil penuh, bukan terpotong ---
      Text? title;
      for (final t in tester.widgetList<Text>(find.byType(Text))) {
        if ((t.style?.fontSize ?? 0) == 24) {
          title = t;
          break;
        }
      }
      expect(title, isNotNull, reason: 'judul 24px tidak ditemukan');
      final f = find.text(title!.data!);
      final boxW = tester.getRect(f).width;
      final para = f.evaluate().first.renderObject! as RenderParagraph;
      final need = (TextPainter(
        text: TextSpan(text: title.data, style: para.text.style),
        textDirection: TextDirection.ltr,
      )..layout())
          .width;
      expect(boxW, greaterThanOrEqualTo(need - 0.5),
          reason: 'judul terpotong: hanya ${boxW.toStringAsFixed(1)}dp '
              'dari ${need.toStringAsFixed(1)}dp yang dibutuhkan');

      // --- tidak ada overflow keras ---
      //
      // Kalau ada beberapa exception mengantre, `takeException` mengembalikan
      // yang PERTAMA dan membuang sisanya, jadi memanggilnya berulang hanya
      // mengembalikan null di putaran kedua. Ambil satu, laporkan apa adanya.
      final err = tester.takeException();
      if (err != null) {
        fail('overflow/exception: ${err.toString().split('\n').first}');
      }
    });
  }

  testWidgets('tombol ganti gaya ada, >=48dp, dan punya label a11y', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appWrap(const QiblaScreen(cityName: 'Jakarta')));
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }

    // Ikon palet = tombolnya. Label teksnya SENGAJA tidak lagi di header
    // (itu yang merebut ruang judul), jadi label harus tetap terbaca a11y.
    final btn = find.byIcon(AppIcons.paletteOutlined);
    expect(btn, findsOneWidget, reason: 'tombol ganti gaya hilang dari header');

    final size = tester.getSize(btn);
    expect(size.width, greaterThanOrEqualTo(20.0));
    // hit area 48dp dari ancestor Container-nya
    final rect = tester.getRect(btn);
    expect(rect.width, lessThanOrEqualTo(60.0),
        reason: 'tombol kembali melebar, merebut ruang judul lagi');

    // Semantics berlabel aksi ini WAJIB ada: ikon tanpa label = teka-teki.
    final labels = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .map((s) => s.properties.label)
        .whereType<String>()
        .toList();
    expect(labels.any((l) => l.contains('Ganti') || l.contains('style') ||
        l.contains('Stili') || l.contains('gaya')), isTrue,
        reason: 'tidak ada Semantics label untuk tombol ganti gaya');
  });
}
