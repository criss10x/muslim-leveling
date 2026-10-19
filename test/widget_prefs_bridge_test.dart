import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_leveling/services/widget_snapshot.dart';

/// Penjaga jembatan Dart → native untuk widget home screen.
///
/// Widget membaca snapshot dari SharedPreferences milik app. Dua hal harus
/// cocok persis, kalau tidak widget selalu tampil "buka app" walau app sudah
/// dibuka berkali-kali, dan tap widget tidak membuka daftar quest:
///
/// 1. **Nama file** — plugin `shared_preferences_android` memakai konstanta
///    `SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"` (lihat
///    LegacySharedPreferencesPlugin.java dan SharedPreferencesPlugin.kt).
///    File `<packageName>_preferences` tidak pernah dibuat oleh plugin ini.
/// 2. **Kunci** — SharedPreferences versi Dart menambahkan prefix `flutter.`
///    pada setiap kunci sebelum dikirim ke platform.
///
/// Keduanya gagal senyap: `getString` mengembalikan null, tanpa exception dan
/// tanpa error build. Karena itu diperiksa sebagai tes, bukan diandalkan pada
/// pembacaan manual.
void main() {
  /// Seluruh kode native milik app (bukan generated plugin).
  final native = Directory(
    'android/app/src/main/kotlin/id/muslimleveling/muslim_leveling',
  )
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.kt'))
      .toList();

  String semuaKt() => native.map((f) => f.readAsStringSync()).join('\n');

  /// Buang komentar supaya penjelasan di dalam kode tidak dianggap kode.
  String kodeSaja(String src) => src
      .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
      .replaceAll(RegExp(r'//.*'), '');

  test('nama file SharedPreferences sama dengan yang dipakai plugin', () {
    final m = RegExp(
      r'const val NAME\s*=\s*"([^"]*)"',
    ).firstMatch(File('${native.first.parent.path}/WidgetPrefs.kt')
        .readAsStringSync());
    expect(m, isNotNull, reason: 'WidgetPrefs.NAME tidak ditemukan');
    expect(
      m!.group(1),
      'FlutterSharedPreferences',
      reason:
          'Plugin Flutter menulis ke file FlutterSharedPreferences. '
          'Nama lain = widget membaca file kosong dan selalu minta buka app.',
    );
  });

  test('tidak ada kode native yang membaca file prefs dengan nama lain', () {
    final salah = <String>[];
    for (final f in native) {
      final isi = kodeSaja(f.readAsStringSync());
      // Nama file hanya boleh muncul di WidgetPrefs.kt.
      if (!f.path.endsWith('WidgetPrefs.kt') &&
          isi.contains('getSharedPreferences(')) {
        salah.add(f.uri.pathSegments.last);
      }
      if (isi.contains('_preferences')) {
        salah.add('${f.uri.pathSegments.last} (nama lama _preferences)');
      }
    }
    expect(
      salah,
      isEmpty,
      reason:
          'Hanya WidgetPrefs yang boleh menyebut nama file prefs: $salah',
    );
  });

  test('kunci snapshot = prefix flutter. + prefKey Dart', () {
    final kt = semuaKt();
    expect(
      kt.contains('flutterKey("${WidgetSnapshot.prefKey}")'),
      isTrue,
      reason: 'SNAPSHOT_KEY harus dibangun dari WidgetSnapshot.prefKey',
    );
    // Kunci snapshot tidak boleh ditulis lewat literal "flutter." manual:
    // satu sumber saja (WidgetPrefs.flutterKey).
    expect(kt.contains('"flutter.${WidgetSnapshot.prefKey}"'), isFalse);
  });

  test('kunci deep link quest memakai prefix flutter.', () {
    expect(
      semuaKt().contains('flutterKey("widget_open_quests")'),
      isTrue,
      reason: 'tanpa prefix, Dart tidak akan pernah melihat penanda tap widget',
    );
  });
}
