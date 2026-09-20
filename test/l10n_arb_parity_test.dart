import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/l10n/ach_texts.g.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/l10n/hijri_texts.g.dart';
import 'package:muslim_leveling/l10n/quest_texts.g.dart';
import 'package:muslim_leveling/services/achievement_service.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/hijri_service.dart';
import 'package:muslim_leveling/services/locale_service.dart';
import 'package:muslim_leveling/services/ulama_quotes.dart';

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

  /// Kode bahasa yang benar-benar dikirim app, dibaca dari satu sumber
  /// (LocaleNotifier.supported) — bukan daftar kedua yang bisa basi. Menambah
  /// bahasa otomatis masuk ke semua guard di bawah.
  final codes = [
    for (final l in LocaleNotifier.supported) l.languageCode,
  ];

  test('setiap bahasa yang didukung punya file ARB', () {
    for (final code in codes) {
      expect(
        File('lib/l10n/app_$code.arb').existsSync(),
        isTrue,
        reason: 'LocaleNotifier.supported berisi "$code" tapi app_$code.arb '
            'tidak ada — picker akan menampilkan label dengan teks Indonesia.',
      );
    }
  });

  test('key template ARB ada di SEMUA locale', () {
    // Satu arah saja (template - locale lain): key yang tidak ada di template
    // bukan masalah, tapi key yang hilang di satu bahasa = UI separuh
    // Indonesia di bahasa itu.
    final template = readArb('id');
    final keysTemplate = template.keys.where((k) => !k.startsWith('@')).toSet();

    for (final code in codes) {
      if (code == 'id') continue;
      final other = readArb(code);
      final keysOther = other.keys.where((k) => !k.startsWith('@')).toSet();
      expect(
        keysTemplate.difference(keysOther),
        isEmpty,
        reason: 'key ini ada di app_id.arb tapi hilang di app_$code.arb',
      );
    }
  });

  test('tidak ada nilai ARB yang kosong', () {
    for (final locale in codes) {
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

  test('bahasa non-id bukan salinan template (bukan salin-tempel)', () {
    // Cara lama: cari kata fungsi Indonesia (di/dan/yang/...) di nilai yang
    // identik dengan id. Itu BENAR untuk en, tapi SALAH untuk ms — Melayu dan
    // Indonesia berbagi ~80% kosakata, jadi "Lihat semua", "Tidak perlu",
    // "hari", "dalam 1 hari" memang Melayu yang sah. Diukur: 27 dari 31 kata
    // di daftar lama muncul di entri ms yang SUDAH diterjemahkan, jadi daftar
    // itu menandai terjemahan Melayu yang benar sebagai "belum diterjemahkan"
    // (149 false positive).
    //
    // Yang benar-benar berbahaya: locale yang isinya SALINAN template. Itu
    // kelihatan dari rasio, bukan dari kosakata. Dasar ambang: locale yang
    // diterjemahkan sungguhan (en 20%, tr 7%, ms 33%) vs salinan (nyaris
    // 100%). Label pendek/gelar CAPS/nama diri memang identik — di ms ada 44
    // key yang tidak berubah di tr maupun ms, itu wajar.
    const salinTempel = 0.75;
    final id = readArb('id');
    final keys = id.keys.where((k) => !k.startsWith('@')).toList();

    for (final code in codes) {
      if (code == 'id') continue;
      final other = readArb(code);
      final same = keys.where((k) => other[k] == id[k]).length;
      expect(
        same / keys.length,
        lessThan(salinTempel),
        reason: '$code: $same/${keys.length} nilai identik dengan app_id.arb '
            '— sepertinya ARB $code masih salinan template, bukan terjemahan. '
            'Jalankan: arb_ai (lihat arb_ai.yaml)',
      );
    }
  });

  test('nilai English tidak mengandung prosa Indonesia', () {
    // Nilai yang identik id==en untuk label pendek itu wajar: HUD memang
    // berbahasa Inggris di app Indonesia ("DAILY CHEST", "XP TO NEXT RANK"),
    // dan istilah seperti "Alhamdulillah", "Ba'diyah Maghrib", "Jakarta"
    // tidak punya padanan.
    //
    // Yang TIDAK wajar: prosa Indonesia yang lolos tanpa diterjemahkan.
    // Deteksinya lewat kata fungsi bahasa Indonesia — kata yang muncul di
    // kalimat Indonesia dan tidak pernah ada di teks English. Daftar ini
    // stabil (tidak tumbuh tiap batch), beda dengan allowlist per-key.
    //
    // ponytail: hanya untuk en. Untuk ms lihat tes rasio di atas — Melayu
    // punya kata fungsi yang sama sehingga daftar ini tak bisa dipakai.
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
      reason: 'nilai identik dengan id padahal isinya prosa Indonesia',
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

  test('kutipan ulama: setiap token punya teks di kedua locale', () {
    // Kutipan tidak lagi menyimpan teks di Dart; kalau key ARB hilang, halaman
    // "Kata Ulama" tampil kosong tanpa error. Guard ini yang menangkapnya.
    for (final locale in AppL10n.supportedLocales) {
      final l10n = lookupAppL10n(locale);
      final texts = ulamaQuoteTexts(l10n);
      expect(
        texts.length,
        ulamaQuoteTokens.length,
        reason: 'jumlah kutipan ($locale) != jumlah token',
      );
      for (var i = 0; i < texts.length; i++) {
        expect(
          texts[i].token,
          ulamaQuoteTokens[i],
          reason: 'urutan token bergeser di index \$i ($locale)',
        );
        expect(texts[i].text.trim(), isNotEmpty, reason: 'kutipan \$i kosong');
      }
    }
  });

  test('setiap tanggal penting punya label + tanggal Hijriah punya bulan', () {
    for (final locale in AppL10n.supportedLocales) {
      final l10n = lookupAppL10n(locale);
      for (final (m, d) in hijriImportantDates) {
        expect(
          hijriEventLabel(l10n, m, d),
          isNotNull,
          reason:
              'uq_ev_\${m}_\${d} hilang (\$locale) — '
              'jalankan: python3 tool/gen_ulama_hijri_arb.py',
        );
      }
      // 12 bulan, index 1..12; index 0 sengaja kosong.
      for (var m = 1; m <= 12; m++) {
        expect(
          hijriMonthName(l10n, m).trim(),
          isNotEmpty,
          reason: 'uq_month_\$m kosong (\$locale)',
        );
      }
      expect(hijriMonthName(l10n, 0), isEmpty);
      expect(hijriMonthName(l10n, 13), isEmpty);
    }
  });

  test('apostrof tidak digandakan (bocor ke layar sebagai \'\')', () {
    // Temuan nyata: model terjemahan menulis "Kabe''ye"/"Al-Qur''an" karena
    // escape Dart; ARB tidak butuh itu, jadi '' bocor utuh ke layar.
    for (final code in codes) {
      final arb = readArb(code);
      final bad = arb.entries
          .where((e) => !e.key.startsWith('@'))
          .where((e) => e.value is String && (e.value as String).contains("''"))
          .map((e) => e.key)
          .toList();
      expect(
        bad,
        isEmpty,
        reason: '\$code: apostrof ganda di \${bad.take(3).join(", ")} — '
            'satu apostrof saja di ARB',
      );
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
