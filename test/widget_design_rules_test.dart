import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

/// Penjaga kualitas visual widget home screen.
///
/// Widget Android tidak punya golden test: tidak ada Flutter render dan tidak
/// ada emulator di CI. Yang bisa diuji adalah **aturan** yang sudah terbukti
/// merusak tampilan saat dilanggar. Dua di antaranya ditemukan lewat pengukuran
/// pada render 4x2, bukan lewat selera:
///
/// 1. Rel kosong bilah status `#2A312E` hanya 1.35:1 terhadap kartu: bilah
///    "belum" praktis tak terlihat, jadi status hanya terbaca dari ada/tidak
///    bilah. Ambang di sini 2.5:1 — cukup terlihat sebagai rel, masih jauh di
///    bawah jade supaya urutan sinyal tetap benar.
/// 2. Jam perangkat 17sp dan jam sholat 17sp di dua tempat, keduanya besar,
///    membuat dua titik fokus yang bersaing. Readout harus lebih kecil dari isi.
void main() {
  final xml = File(
    'android/app/src/main/res/layout/quest_widget.xml',
  ).readAsStringSync();
  final kotlin = File(
    'android/app/src/main/kotlin/id/muslimleveling/muslim_leveling/'
    'QuestWidgetProvider.kt',
  ).readAsStringSync();
  final strings = File(
    'android/app/src/main/res/values/widget_strings.xml',
  ).readAsStringSync();

  double channel(int v) {
    final s = v / 255.0;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  double luminance(String hex) {
    final h = hex.replaceFirst('#', '');
    return 0.2126 * channel(int.parse(h.substring(0, 2), radix: 16)) +
        0.7152 * channel(int.parse(h.substring(2, 4), radix: 16)) +
        0.0722 * channel(int.parse(h.substring(4, 6), radix: 16));
  }

  double contrast(String a, String b) {
    final la = luminance(a), lb = luminance(b);
    final hi = math.max(la, lb), lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  String kconst(String name) {
    final m = RegExp('const val $name = "(#[0-9A-Fa-f]+)"').firstMatch(kotlin);
    expect(m, isNotNull, reason: 'konstanta $name tidak ada');
    return m!.group(1)!;
  }

  String bgColor() {
    final bg = File(
      'android/app/src/main/res/drawable/widget_bg.xml',
    ).readAsStringSync();
    return RegExp(
      r'solid android:color="(#[0-9A-Fa-f]+)"',
    ).firstMatch(bg)!.group(1)!;
  }

  test('rel kosong bilah status terlihat sebagai rel', () {
    final r = contrast(kconst('TRACK'), bgColor());
    expect(
      r,
      greaterThanOrEqualTo(2.5),
      reason:
          'TRACK hanya ${r.toStringAsFixed(2)}:1 terhadap kartu. Di bawah '
          '2.5:1 bilah "belum" tak terlihat dan status cuma terbaca dari '
          'ada/tidak bilah.',
    );
  });

  test('jade dan sian tetap jauh lebih terang dari rel kosong', () {
    final track = kconst('TRACK');
    expect(contrast(kconst('JADE'), track), greaterThan(3.0));
    expect(contrast(kconst('TIME_NOW'), track), greaterThan(3.0));
  });

  test('teks utama dan redup lolos kontras WCAG AA', () {
    final bg = bgColor();
    expect(contrast(kconst('INK'), bg), greaterThanOrEqualTo(4.5));
    expect(contrast(kconst('MUTED'), bg), greaterThanOrEqualTo(4.5));
  });

  test('jam sholat adalah readout, bukan fokus kedua', () {
    double size(String id) {
      final m = RegExp(
        'android:id="@\\+id/$id"([\\s\\S]*?)/>',
      ).firstMatch(xml);
      expect(m, isNotNull, reason: 'view $id tidak ditemukan');
      final s = RegExp(
        r'android:textSize="([\d.]+)sp"',
      ).firstMatch(m!.group(1)!);
      return double.parse(s!.group(1)!);
    }

    final name = size('now_name');
    final time = size('now_time');
    final clock = size('clock');
    expect(
      name,
      greaterThan(time),
      reason: 'nama sholat harus lebih besar dari jamnya (readout rule)',
    );
    expect(
      name,
      greaterThan(clock),
      reason:
          'jam sholat ($time sp) dan jam perangkat ($clock sp) tidak boleh '
          'mengalahkan nama sholat; dua fokus besar membuat mata bingung.',
    );
  });

  test('warna rel di layout sama dengan TRACK di Kotlin', () {
    // Dua sumber untuk satu warna: rel awal digambar layout, lalu ditimpa
    // Kotlin. Kalau keduanya berbeda, widget berkedip warna berbeda saat
    // pertama muncul. Ini kelas bug yang sama dengan nama file prefs.
    final diLayout = RegExp(
      r'android:background="(#[0-9A-Fa-f]{6})"\s*/>',
    ).allMatches(xml).map((m) => m.group(1)).toSet();
    expect(
      diLayout.contains(kconst('TRACK')),
      isTrue,
      reason:
          'rel di layout (${diLayout.join(", ")}) tidak memuat TRACK '
          '${kconst("TRACK")} yang dipakai Kotlin.',
    );
  });

  test('label HUD widget cukup pendek untuk 4 sel', () {
    final label = RegExp(
      r'name="widget_label">([^<]*)<',
    ).firstMatch(strings)!.group(1)!;
    expect(
      label.length,
      lessThanOrEqualTo(28),
      reason:
          'widget 4x2 menyisakan ~28 karakter untuk label; "$label" akan '
          'terpotong.',
    );
  });
}
