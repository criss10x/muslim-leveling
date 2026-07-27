import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('surahs.json berisi 114 surat dengan field lengkap', () {
    final raw = File('assets/quran/surahs.json').readAsStringSync();
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    expect(list.length, 114);
    for (final s in list) {
      expect(s['nameLatin'], isNotEmpty, reason: 'surat ${s['number']}');
      expect(s['nameArabic'], isNotEmpty, reason: 'surat ${s['number']}');
      expect(s['meaning'], isNotEmpty, reason: 'surat ${s['number']}');
      expect(s['ayahCount'], greaterThan(0), reason: 'surat ${s['number']}');
      expect(['Makkiyah', 'Madaniyah'], contains(s['revelation']));
    }
    expect(list.first['number'], 1);
    expect(list.last['number'], 114);
  });

  test('tiap berkas surat cocok jumlah ayatnya dengan metadata', () {
    final raw = File('assets/quran/surahs.json').readAsStringSync();
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    var total = 0;
    for (final s in list) {
      final n = s['number'] as int;
      final ayahRaw = File('assets/quran/surah/$n.json').readAsStringSync();
      final ayahs = (jsonDecode(ayahRaw) as List).cast<Map<String, dynamic>>();

      expect(ayahs.length, s['ayahCount'], reason: 'surat $n');
      total += ayahs.length;

      // Nomor ayat harus berurutan 1..n tanpa lompatan.
      for (var i = 0; i < ayahs.length; i++) {
        expect(ayahs[i]['ayah'], i + 1, reason: 'surat $n indeks $i');
        expect(ayahs[i]['arabic'], isNotEmpty, reason: 'surat $n ayat ${i + 1}');
        expect(ayahs[i]['translation'], isNotEmpty,
            reason: 'surat $n ayat ${i + 1}');
      }
    }

    // Jumlah kanonik ayat Al-Quran — menangkap surat yang diam-diam terpotong.
    expect(total, 6236);
  });

  test('teks Arab bebas dari BOM', () {
    for (var n = 1; n <= 114; n++) {
      final raw = File('assets/quran/surah/$n.json').readAsStringSync();
      expect(raw.contains('﻿'), isFalse, reason: 'surat $n mengandung BOM');
    }
  });
}
