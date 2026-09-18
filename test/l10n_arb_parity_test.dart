import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/l10n/ach_texts.g.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/services/achievement_service.dart';

/// Guard ARB: tanpa ini, key yang lupa diterjemahkan jatuh ke fallback
/// (string Indonesia muncul di UI English) dan baru ketahuan dari laporan user.
///
/// Tiga hal yang dijaga:
///   1. key app_id.arb == app_en.arb (setara, bukan cuma "ada")
///   2. jembatan ach_texts.g.dart tidak basi (semua medali punya teks)
///   3. tidak ada string English yang identik dengan Indonesia untuk label
///      pendek yang seharusnya diterjemahkan (regresi salin-tempel)
void main() {
  Map<String, dynamic> readArb(String locale) {
    final raw = File('lib/l10n/app_$locale.arb').readAsStringSync();
    return json.decode(raw) as Map<String, dynamic>;
  }

  test('key app_id.arb == app_en.arb', () {
    final id = readArb('id');
    final en = readArb('en');
    final keysId = id.keys.where((k) => !k.startsWith('@')).toSet();
    final keysEn = en.keys.where((k) => !k.startsWith('@')).toSet();

    expect(keysEn.difference(keysId), isEmpty, reason: 'key en tanpa id');
    expect(keysId.difference(keysEn), isEmpty, reason: 'key id tanpa en');
  });

  test('tidak ada nilai ARB yang kosong', () {
    for (final locale in ['id', 'en']) {
      readArb(locale).forEach((key, value) {
        if (key.startsWith('@')) return;
        expect(value, isA<String>(), reason: '$locale/$key bukan string');
        expect((value as String).trim(), isNotEmpty, reason: '$locale/$key');
      });
    }
  });

  test('setiap medali punya title+desc di kedua locale', () {
    for (final locale in AppL10n.supportedLocales) {
      final l10n = lookupAppL10n(locale);
      for (final d in AchievementService.defs) {
        expect(achText(l10n, d.id, 'title'), isNotNull,
            reason: 'ach_${d.id}_title hilang (jalankan: '
                'python3 tool/gen_medal_arb.py)');
        expect(achText(l10n, d.id, 'desc'), isNotNull,
            reason: 'ach_${d.id}_desc hilang');
      }
    }
  });

  test('prosa ARB tidak disalin mentah dari Indonesia', () {
    // Nilai yang identik id==en untuk label pendek itu wajar: HUD memang
    // berbahasa Inggris di app Indonesia ("DAILY CHEST", "XP TO NEXT RANK"),
    // dan istilah seperti "Alhamdulillah", "Ba'diyah Maghrib", "Jakarta"
    // tidak punya padanan.
    //
    // Yang TIDAK wajar: prosa Indonesia yang lolos tanpa diterjemahkan.
    // Deteksinya lewat kata fungsi bahasa Indonesia — kata yang muncul di
    // kalimat Indonesia dan tidak pernah ada di teks English. Daftar ini
    // stabil (tidak tumbuh tiap batch), beda dengan allowlist per-key.
    const indonesiaMarkers = {
      'di', 'dan', 'yang', 'untuk', 'ini', 'itu', 'hari', 'kamu', 'dengan',
      'dari', 'tidak', 'sudah', 'bisa', 'saat', 'agar', 'akan', 'adalah',
      'atau', 'karena', 'setelah', 'sebelum', 'tanpa', 'lagi', 'kak', 'nya',
      'juga', 'masih', 'hanya', 'semua', 'lebih', 'bila', 'jika',
    };

    final id = readArb('id');
    final en = readArb('en');
    final untranslated = <String>[];

    for (final entry in id.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key.startsWith('@') || value is! String || en[key] != value) continue;
      final words = value
          .replaceAll(RegExp(r'\{[a-zA-Z]+\}'), ' ')
          .toLowerCase()
          .split(RegExp(r'[^a-z]+'))
          .where((w) => w.isNotEmpty);
      if (words.any(indonesiaMarkers.contains)) {
        untranslated.add('$key = "$value"');
      }
    }

    expect(
      untranslated,
      isEmpty,
      reason: 'nilai en identik dengan id padahal isinya prosa Indonesia',
    );
  });

  test('medali tanpa unlockHint memakai kalimat fallback dari ARB', () {
    final l10n = lookupAppL10n(const Locale('en'));
    final def = AchievementService.defs
        .firstWhere((d) => d.unlockHint == null, orElse: () => throw 'kosong');
    expect(def.localizedHint(l10n), startsWith('Complete: '));
  });
}
