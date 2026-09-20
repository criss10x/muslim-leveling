import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/l10n/ach_texts.g.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/l10n/quest_texts.g.dart';
import 'package:muslim_leveling/services/achievement_service.dart';
import 'package:muslim_leveling/services/game_service.dart';

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
        expect(
          achText(l10n, d.id, 'title'),
          isNotNull,
          reason:
              'ach_${d.id}_title hilang (jalankan: '
              'python3 tool/gen_medal_arb.py)',
        );
        expect(
          achText(l10n, d.id, 'desc'),
          isNotNull,
          reason: 'ach_${d.id}_desc hilang',
        );
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
      'di',
      'dan',
      'yang',
      'untuk',
      'ini',
      'itu',
      'hari',
      'kamu',
      'dengan',
      'dari',
      'tidak',
      'sudah',
      'bisa',
      'saat',
      'agar',
      'akan',
      'adalah',
      'atau',
      'karena',
      'setelah',
      'sebelum',
      'tanpa',
      'lagi',
      'kak',
      'nya',
      'juga',
      'masih',
      'hanya',
      'semua',
      'lebih',
      'bila',
      'jika',
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

  test('setiap quest punya desc di kedua locale', () {
    // Sama seperti guard medali: desc quest dicari dari Quest.id lewat
    // jembatan quest_texts.g.dart. Kalau key ARB hilang, UI jatuh ke teks
    // Indonesia yang tersimpan di disk — halaman English jadi separuh.
    for (final locale in AppL10n.supportedLocales) {
      final l10n = lookupAppL10n(locale);
      // SEMUA id, bukan pool hari ini: pool cuma 5 dari 21 (shuffle harian),
      // jadi quest di luar pool tak pernah diperiksa dan case yang hilang
      // di jembatan lolos tanpa ketahuan.
      for (final id in questAllIds) {
        expect(
          questDesc(l10n, id, zikirGoal: GameService.zikirGoal),
          isNotNull,
          reason:
              'quest_${id}_desc hilang '
              '(jalankan: python3 tool/gen_quest_arb.py)',
        );
      }
    }
  });

  test('desc quest English tidak mengandung prosa Indonesia', () {
    // Negatif-kontrol untuk jembatan: kalau questDesc diam-diam mengembalikan
    // `desc` Dart (jalur fallback), tes ini yang gagal — guard di atas lolos
    // palsu karena `desc` selalu ada.
    final l10n = lookupAppL10n(const Locale('en'));
    final leaks = <String>[];
    for (final id in questAllIds) {
      final text = questDesc(l10n, id, zikirGoal: GameService.zikirGoal)!;
      for (final marker in [
        'Sholat',
        'hari ini',
        'Baca ',
        'Jangan ',
        'Kerjakan',
        'Lengkapin',
        'Tuntaskan',
        'Pertahanin',
      ]) {
        if (text.contains(marker)) leaks.add('$id: "$text"');
      }
    }
    expect(leaks, isEmpty, reason: 'desc quest masih Indonesia di locale en');
  });

  test('pool copy quest lengkap di kedua locale', () {
    for (final locale in AppL10n.supportedLocales) {
      final l10n = lookupAppL10n(locale);
      for (final cat in [
        'sholat',
        'sunnah',
        'zikir',
        'quran',
        'hadis',
        'fiveRings',
        'subuhIsya',
      ]) {
        for (var i = 0; i < questCopyPoolSize; i++) {
          expect(
            questCopy(l10n, cat, i),
            isNotNull,
            reason: 'questCopy_${cat}_${i + 1} hilang',
          );
        }
      }
      for (var i = 0; i < questCopyPoolSize; i++) {
        expect(
          questCopy(l10n, 'sholat', i, haid: true),
          isNotNull,
          reason: 'questHaid_${i + 1} hilang',
        );
      }
      // Index di luar jangkauan harus di-modulo, bukan crash.
      expect(questCopy(l10n, 'sholat', 99), isNotNull);
      // Kategori tak dikenal → null (pemanggil punya fallback).
      expect(questCopy(l10n, 'tidakAda', 0), isNull);
    }
  });

  test('medali tanpa unlockHint memakai kalimat fallback dari ARB', () {
    final l10n = lookupAppL10n(const Locale('en'));
    final def = AchievementService.defs.firstWhere(
      (d) => d.unlockHint == null,
      orElse: () => throw 'kosong',
    );
    expect(def.localizedHint(l10n), startsWith('Complete: '));
  });
}
