import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/l10n/hijri_texts.g.dart';
import 'package:muslim_leveling/services/hijri_service.dart';

// ponytail: runnable check — decode cache bulan & label; jalur HTTP
// diuji manual (aladhan.com, satu panggilan/bulan).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cache bulan ter-decode + hijriLabel + tanggal penting', () async {
    SharedPreferences.setMockInitialValues({
      'hijri_g2h2_2026_8': jsonEncode([
        [1, 17, 2, 1448], // 1 Safar 1448
        [2, 18, 2, 1448],
      ]),
    });
    final days = await hijriService.month(2026, 8);
    expect(days, isNotNull);
    expect(days!.length, 2);
    expect(days[0].hDay, 17);
    final id = lookupAppL10n(const Locale('id'));
    final en = lookupAppL10n(const Locale('en'));
    expect(hijriLabel(id, days[0]), '17 Safar 1448 H');
    // Nama bulan & label momen ikut locale — inilah yang dulu hardcoded.
    expect(hijriMonthName(en, 9), 'Ramadan');
    expect(hijriMonthName(id, 11), 'Zulkaidah');
    expect(hijriMonthName(en, 11), 'Dhu al-Qadah');
    expect(hijriEventLabel(id, 1, 1), 'Tahun Baru Hijriah');
    expect(hijriEventLabel(en, 1, 1), 'Hijri New Year');
    // Tanggal penting tetap 10 pasang (bulan, hari): urutannya dipakai
    // jembatan switch, jadi panjangnya punya arti.
    expect(hijriImportantDates.length, 10);
    expect(hijriImportantDates, contains((1, 1)));
  });

  test('kutipan ulama: paritas id/en & urutan token cocok', () {
    final id = lookupAppL10n(const Locale('id'));
    final en = lookupAppL10n(const Locale('en'));
    final idT = ulamaQuoteTexts(id);
    final enT = ulamaQuoteTexts(en);
    expect(idT.length, ulamaAllTokens.length);
    expect(enT.length, idT.length);
    for (var i = 0; i < idT.length; i++) {
      expect(idT[i].token, ulamaAllTokens[i]);
      expect(enT[i].token, idT[i].token);
      // Terjemahan English tidak boleh kosong (regresi salin-tempel).
      expect(enT[i].text.trim(), isNotEmpty);
    }
  });
}
