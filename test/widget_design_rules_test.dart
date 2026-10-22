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

  test('logo memakai bentuk yang terlihat di atas kartu gelap', () {
    // Sumber aslinya silhouette HITAM di atas transparan. Ditempel langsung ke
    // kartu #121816, kontrasnya ~1:1 dan logonya lenyap. Yang dipakai widget
    // harus PNG ber-tint yang sudah disiapkan per kerapatan.
    for (final bucket in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      final f = File(
        'android/app/src/main/res/drawable-$bucket/widget_logo.png',
      );
      expect(f.existsSync(), isTrue, reason: 'logo $bucket tidak ada');
      expect(
        f.lengthSync(),
        greaterThan(200),
        reason: 'logo $bucket terlalu kecil, kemungkinan kosong/transparan',
      );
    }
    // Layout tidak boleh menunjuk sumber asli berwarna hitam.
    expect(
      RegExp(r'android:src="@drawable/widget_logo"').hasMatch(xml),
      isTrue,
      reason: 'layout harus memakai @drawable/widget_logo, bukan aset mentah',
    );
    // Logo adalah tanda pemilik, bukan sinyal progres: tint-nya harus netral,
    // bukan jade/sian/emas yang punya arti status.
    final netral = {'#85948C', '#DCEDE5'};
    final dipakai = RegExp(
      r'android:textColor="(#[0-9A-Fa-f]{6})"',
    ).allMatches(xml).map((m) => m.group(1)!).toSet();
    expect(
      dipakai.contains(kconst('MUTED')),
      isTrue,
      reason: 'MUTED harus dipakai di layout agar logo dan teks redup seirama',
    );
    expect(netral.isNotEmpty, isTrue);
  });

  test('tipografi widget memakai font milik app, bukan font sistem', () {
    // DESIGN.md menetapkan Sora untuk display dan JetBrains Mono untuk
    // readout. Widget yang memakai font sistem terlihat seperti app lain.
    final fonts = RegExp(
      r'android:fontFamily="@font/([a-z_]+)"',
    ).allMatches(xml).map((m) => m.group(1)!).toSet();
    expect(
      fonts.containsAll({'sora_bold', 'jetbrains_mono_bold'}),
      isTrue,
      reason: 'font yang dipakai: ${fonts.join(", ")}',
    );
    for (final f in fonts) {
      expect(
        File('android/app/src/main/res/font/$f.ttf').existsSync(),
        isTrue,
        reason: 'res/font/$f.ttf tidak ada, build akan gagal',
      );
    }
  });

  test('tinggi konten widget tidak melebihi tinggi sel 4x2', () {
    // Kalau konten lebih tinggi dari targetCellHeight=2 (148dp minus padding),
    // launcher memotong bilah bawah. Rasio line-height ini diukur dari metrik
    // font sebenarnya (ascent+descent), bukan tebakan: Sora-Bold 25sp -> 31.50dp
    // = 1.26x, JetBrainsMono-Bold 8sp -> 10.75dp = 1.34x.
    const soraLine = 1.26;
    const monoLine = 1.34;

    double sizeOf(String id) {
      final m = RegExp(
        'android:id="@\\+id/$id"([\\s\\S]*?)/>',
      ).firstMatch(xml)!;
      return double.parse(
        RegExp(r'android:textSize="([\d.]+)sp"').firstMatch(m.group(1)!)!.group(1)!,
      );
    }

    double marginOf(String marker, String attr) {
      final m = RegExp(
        'android:id="@\\+id/$marker"([\\s\\S]*?)/>',
      ).firstMatch(xml)!;
      final v = RegExp('android:$attr="([\\d.]+)dp"').firstMatch(m.group(1)!);
      return v == null ? 0 : double.parse(v.group(1)!);
    }

    final content =
        18.0 + // logo 18dp (baris kepala)
        marginOf('now_name', 'layout_marginTop') +
        sizeOf('now_name') * soraLine +
        marginOf('next', 'layout_marginTop') +
        sizeOf('next') * 1.5 + // Jakarta 11sp -> 14.00dp
        9.0 + 1.0 + 9.0 + // hairline + margin
        sizeOf('name_subuh') * monoLine +
        marginOf('time_subuh', 'layout_marginTop') +
        sizeOf('time_subuh') * soraLine +
        marginOf('bar_subuh', 'layout_marginTop') +
        3.0;

    expect(
      content,
      lessThanOrEqualTo(124.0),
      reason:
          'konten ${content.toStringAsFixed(1)}dp melebihi 124dp '
          '(148 sel - padding 24); bilah bawah akan terpotong',
    );
    // Batas bawah: kalau konten jauh lebih pendek, ada ruang menganggur yang
    // membuat komposisi terasa belum selesai.
    expect(
      content,
      greaterThan(100.0),
      reason:
          'konten hanya ${content.toStringAsFixed(1)}dp dari 124dp; '
          'widget akan terasa top-heavy dengan ruang kosong di bawah',
    );
  });
}
