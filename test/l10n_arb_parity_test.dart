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

  test('chrome ARB tidak disalin mentah dari Indonesia', () {
    // Yang sah identik: judul medali (nama gaya ML: "SAVAGE!"), nama tier
    // (ROOKIE…LEGENDARY), nama bahasa dalam bahasanya sendiri ("English"),
    // judul yang sudah English, dan template Semantics yang bentuknya sama.
    const allowed = {
      'appTitle',
      'localeEnglish',
      'localeIndonesian',
      'achScreenTitle',
      'achSectionTitle',
      'achSemanticsDetail',
      'shareStatLevel',
    };
    final id = readArb('id');
    final en = readArb('en');
    final lazy = <String>[];
    id.forEach((key, value) {
      if (key.startsWith('@') || allowed.contains(key)) return;
      if (key.startsWith('ach_') && key.endsWith('_title')) return;
      if (key.startsWith('achTier')) return;
      if (en[key] == value) lazy.add('$key = "$value"');
    });
    expect(lazy, isEmpty, reason: 'nilai en masih identik dengan id');
  });

  test('medali tanpa unlockHint memakai kalimat fallback dari ARB', () {
    final l10n = lookupAppL10n(const Locale('en'));
    final def = AchievementService.defs
        .firstWhere((d) => d.unlockHint == null, orElse: () => throw 'kosong');
    expect(def.localizedHint(l10n), startsWith('Complete: '));
  });
}
