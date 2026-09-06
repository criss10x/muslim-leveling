import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'quran_settings.dart';

class QuranSurah {
  final int number;
  final String nameArabic, nameLatin, meaning, revelation;
  final int ayahCount;

  const QuranSurah({
    required this.number,
    required this.nameArabic,
    required this.nameLatin,
    required this.meaning,
    required this.ayahCount,
    required this.revelation,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> j) => QuranSurah(
        number: j['number'] as int,
        nameArabic: j['nameArabic'] as String,
        nameLatin: j['nameLatin'] as String,
        meaning: j['meaning'] as String,
        ayahCount: j['ayahCount'] as int,
        revelation: j['revelation'] as String,
      );
}

class QuranAyah {
  final int ayah;
  final String arabic, translation;
  final String? latin; // optional, diisi dari transliterasi API

  const QuranAyah({
    required this.ayah,
    required this.arabic,
    required this.translation,
    this.latin,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> j) => QuranAyah(
        ayah: j['ayah'] as int,
        arabic: j['arabic'] as String,
        translation: j['translation'] as String,
        latin: j['latin'] as String?,
      );
}

/// Membaca aset Quran. Metadata dimuat sekali; ayat dimuat per surat sesuai
/// permintaan lalu disimpan di memori — satu berkas gabungan ~5MB akan
/// menyendat main thread saat di-parse.
class QuranData {
  List<QuranSurah>? _surahs;
  final Map<int, List<QuranAyah>> _ayahCache = {};

  Future<List<QuranSurah>> surahs() async {
    final cached = _surahs;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/quran/surahs.json');
    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(QuranSurah.fromJson)
        .toList(growable: false);
    _surahs = list;
    return list;
  }

  Future<List<QuranAyah>> ayahs(int surahNumber) async {
    final cached = _ayahCache[surahNumber];
    if (cached != null) return cached;

    final raw =
        await rootBundle.loadString('assets/quran/surah/$surahNumber.json');
    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(QuranAyah.fromJson)
        .toList(growable: false);
    _ayahCache[surahNumber] = list;
    return list;
  }

  /// Mencocokkan nama latin, nama Arab, arti, atau nomor surat.
  List<QuranSurah> search(List<QuranSurah> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;

    return all.where((s) {
      return s.nameLatin.toLowerCase().contains(q) ||
          s.meaning.toLowerCase().contains(q) ||
          s.nameArabic.contains(q) ||
          s.number.toString() == q;
    }).toList(growable: false);
  }

  /// Indeks terjemahan per surat (lazy, dibangun saat pencarian ayat pertama).
  Map<int, List<QuranAyah>>? _translationIndex;

  /// Cari kata di dalam terjemahan Indonesia semua ayat.
  /// Return daftar [surahNumber, ayahNumber, translation] yang match.
  /// Limit 30 hasil agar list tetap ringan.
  Future<List<QuranSearchHit>> searchVerses(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    var index = _translationIndex;
    if (index == null) {
      // Build sekali, cache di memori. Scan 114 file ≈ cepat & hanya field
      // translation (ringan). 1.8M char total tapi di-split per surat.
      index = <int, List<QuranAyah>>{};
      for (var n = 1; n <= 114; n++) {
        try {
          final raw = await rootBundle
              .loadString('assets/quran/surah/$n.json');
          final list = (jsonDecode(raw) as List)
              .cast<Map<String, dynamic>>()
              .map(QuranAyah.fromJson)
              .toList(growable: false);
          index[n] = list;
        } catch (_) {
          // Skip surat yang gagal dimuat.
        }
      }
      _translationIndex = index;
    }

    final hits = <QuranSearchHit>[];
    for (final e in index.entries) {
      for (final ayah in e.value) {
        if (ayah.translation.toLowerCase().contains(q)) {
          hits.add(QuranSearchHit(
            surahNumber: e.key,
            ayahNumber: ayah.ayah,
            translation: ayah.translation,
          ));
          if (hits.length >= 30) return hits;
        }
      }
    }
    return hits;
  }
}

/// Hasil pencarian satu ayat di terjemahan.
class QuranSearchHit {
  final int surahNumber;
  final int ayahNumber;
  final String translation;
  const QuranSearchHit({
    required this.surahNumber,
    required this.ayahNumber,
    required this.translation,
  });
}

class QuranTafsir {
  final int ayah;
  final String shortText;
  final String longText;

  String get text =>
      shortText.isNotEmpty && quranSettings.useShortTafsir
          ? shortText
          : longText;

  const QuranTafsir({
    required this.ayah,
    required this.shortText,
    required this.longText,
  });

  factory QuranTafsir.fromGading(Map<String, dynamic> j) {
    final t = j['tafsir']?['id'] as Map<String, dynamic>? ?? {};
    return QuranTafsir(
      ayah: j['number']?['inSurah'] as int? ?? 0,
      shortText: (t['short'] as String?) ?? '',
      longText: (t['long'] as String?) ?? '',
    );
  }
}

final QuranData quranData = QuranData();
