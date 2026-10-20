import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Penjaga tipe argumen RemoteViews di kode native.
///
/// RemoteViews adalah API berbasis string-refleksi: `setTextViewText(id, String)`
/// dan `setTextColor(id, Int)` tidak punya tipe bersama, jadi Kotlin tetap
/// menolak warna sebagai String saat compile. Tapi kesalahan seperti ini hanya
/// ketahuan setelah CI build berjalan penuh (2-4 menit) — dan di mesin ini
/// `flutter analyze` tidak menyentuh Kotlin sama sekali, sehingga terlihat
/// "bersih" padahal belum dikompilasi.
///
/// Tes ini murah dan menangkapnya sebelum push.
void main() {
  final kt = File(
    'android/app/src/main/kotlin/id/muslimleveling/muslim_leveling/'
    'QuestWidgetProvider.kt',
  ).readAsStringSync();

  /// Buang komentar supaya penjelasan tidak dianggap kode.
  String kode(String src) => src
      .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
      .replaceAll(RegExp(r'//.*'), '');

  final kodeBersih = kode(kt);

  test('setTextColor selalu diberi Int, bukan String warna', () {
    // Cari setiap pemanggilan setTextColor lalu periksa argumen keduanya:
    // nama konstanta warna mentah (JADE, INK, ...) atau literal "#..." = salah.
    final salah = <String>[];
    final re = RegExp(r'setTextColor\(\s*([^,]+),\s*([\s\S]*?)\)\s*,?\s*$',
        multiLine: true);
    for (final m in re.allMatches(kodeBersih)) {
      final arg = m.group(2)!.trim();
      if (RegExp(r'^(JADE|TIME_NOW|INK|MUTED|TRACK)\b').hasMatch(arg) ||
          arg.startsWith('"#')) {
        salah.add(arg.split('\n').first);
      }
    }
    expect(
      salah,
      isEmpty,
      reason:
          'setTextColor butuh Int. Bungkus dengan Color.parseColor(...): '
          '${salah.join(" | ")}',
    );
  });

  test('setInt dipakai untuk warna background, bukan setTextViewText', () {
    for (final m in RegExp(r'setInt\(([^)]*)\)').allMatches(kodeBersih)) {
      expect(
        m.group(1),
        contains('setBackgroundColor'),
        reason: 'setInt dengan nama properti tak dikenal akan gagal senyap',
      );
    }
  });

  test('semua konstanta warna berbentuk #RRGGBB yang sah', () {
    for (final m in RegExp(
      r'const val (JADE|TIME_NOW|INK|MUTED|TRACK) = "(#[0-9A-Fa-f]+)"',
    ).allMatches(kodeBersih)) {
      final hex = m.group(2)!;
      expect(hex.length, 7, reason: '${m.group(1)} harus #RRGGBB');
      expect(int.tryParse(hex.substring(1), radix: 16), isNotNull);
    }
  });

  test('id sel dan string yang dirujuk Kotlin ada di resource', () {
    final layout = File(
      'android/app/src/main/res/layout/quest_widget.xml',
    ).readAsStringSync();
    final strings = File(
      'android/app/src/main/res/values/widget_strings.xml',
    ).readAsStringSync();

    final idLayout = RegExp(r'@\+id/([a-z_]+)')
        .allMatches(layout)
        .map((m) => m.group(1)!)
        .toSet();
    // CELLS memakai R.id lewat data class, jadi ambil semua R.id apa pun bentuknya.
    final idKotlin = RegExp(r'R\.id\.([a-z_]+)')
        .allMatches(kodeBersih)
        .map((m) => m.group(1)!)
        .toSet();
    expect(idKotlin.difference(idLayout), isEmpty);

    final strDeklarasi = RegExp(r'name="([a-z_]+)"')
        .allMatches(strings)
        .map((m) => m.group(1)!)
        .toSet();
    final strKotlin = RegExp(r'R\.string\.([a-z_]+)')
        .allMatches(kodeBersih)
        .map((m) => m.group(1)!)
        .toSet();
    expect(strKotlin.difference(strDeklarasi), isEmpty);
  });
}
