// ponytail: penjaga untuk font icon vendored (assets/fonts/Phosphor-*.ttf).
// Kalau codepoint salah / font tidak ke-bundle, semua icon jadi tofu yang
// IDENTIK — test ini gagal begitu itu terjadi.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/theme/app_icons.dart';

/// Render satu icon, balikan hash dari channel alpha-nya.
Future<String> _sig(WidgetTester tester, IconData icon) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: RepaintBoundary(
          key: key,
          child: Icon(icon, size: 64, color: const Color(0xFFFFFFFF)),
        ),
      ),
    ),
  );
  final bytes = await tester.runAsync(() async {
    final ro = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await ro.toImage();
    final data = await img.toByteData();
    return data!.buffer.asUint8List();
  });
  final b = bytes!;
  var filled = 0;
  var hash = 0;
  for (var i = 0; i < b.length; i += 4) {
    if (b[i + 3] > 40) {
      filled++;
      hash = (hash * 31 + i) & 0x7fffffff;
    }
  }
  // Titik ini gagal kalau glyph-nya kosong (font tidak ke-load).
  expect(filled, greaterThan(120),
      reason: 'glyph kosong untuk ${icon.codePoint.toRadixString(16)} '
          'font=${icon.fontFamily}');
  return '$filled:$hash';
}

void main() {
  // flutter_test TIDAK memuat font dari pubspec otomatis — load manual,
  // sekaligus membuktikan asset-nya ikut ke-bundle di path yang benar.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const files = {
      'Phosphor': 'assets/fonts/Phosphor-Regular.ttf',
      'PhosphorFill': 'assets/fonts/Phosphor-Fill.ttf',
    };
    for (final e in files.entries) {
      final loader = FontLoader(e.key)..addFont(rootBundle.load(e.value));
      await loader.load();
    }
  });

  testWidgets('font icon Phosphor benar-benar ter-render', (tester) async {
    // Ikon kunci yang jadi alasan pilih Phosphor (konten app).
    final key = <String, IconData>{
      'mosque': AppIcons.mosque,
      'fire': AppIcons.localFireDepartment,
      'syahadat': AppIcons.selfImprovement,
      'twilight': AppIcons.wbTwilight,
      'shield': AppIcons.shield,
      'trophy': AppIcons.emojiEvents,
    };
    final sigs = <String, String>{};
    for (final e in key.entries) {
      sigs[e.key] = await _sig(tester, e.value);
    }
    // Kalau font gagal load, semua glyph = tofu identik → sig sama semua.
    expect(sigs.values.toSet().length, key.length,
        reason: 'glyph tampak identik (tofu?) → $sigs');
  });

  testWidgets('weight Fill beda dari Regular untuk icon yang sama',
      (tester) async {
    final reg = await _sig(tester, AppIcons.homeOutlined);
    final fill = await _sig(tester, AppIcons.home);
    expect(reg, isNot(fill),
        reason: 'Fill & Regular harus beda bentuk (fase aktif/non-aktif)');
  });
}
