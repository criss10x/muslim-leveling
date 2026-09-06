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

  /// Baris indeks pencarian terjemahan. Single-flight: dibangun sekali,
  /// hanya menyimpan teks (asli + lowercase) — bukan objek [QuranAyah] penuh.
  Future<List<_IdxRow>>? _indexFuture;

  /// Cari kata di dalam terjemahan Indonesia semua ayat.
  /// Return daftar [surahNumber, ayahNumber, translation] yang match.
  /// Limit 30 hasil agar list tetap ringan.
  Future<List<QuranSearchHit>> searchVerses(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final rows = await _ensureIndex();
    final hits = <QuranSearchHit>[];
    for (final r in rows) {
      if (r.lower.contains(q)) {
        hits.add(QuranSearchHit(
          surahNumber: r.surah,
          ayahNumber: r.ayah,
          translation: r.text,
        ));
        if (hits.length >= 30) break;
      }
    }
    return hits;
  }

  Future<List<_IdxRow>> _ensureIndex() {
    final f = _indexFuture;
    if (f != null) return f; // dua panggilan bersamaan → satu build saja
    final t = _buildIndex();
    _indexFuture = t;
    return t;
  }

  Future<List<_IdxRow>> _buildIndex() async {
    final rows = <_IdxRow>[];
    // await per file membuat decode menyebar antar-frame (tidak menyendat
    // UI). 114 × ~32KB, parse per file hanya ~1-2ms.
    for (var n = 1; n <= 114; n++) {
      try {
        final raw = await rootBundle.loadString('assets/quran/surah/$n.json');
        for (final j in (jsonDecode(raw) as List).cast<Map<String, dynamic>>()) {
          final text = j['translation'] as String? ?? '';
          if (text.isEmpty) continue;
          rows.add(_IdxRow(
            n,
            j['ayah'] as int? ?? 0,
            text,
            text.toLowerCase(),
          ));
        }
      } catch (_) {
        // ponytail: lewati surat korup — satu file jelek tak menggagalkan index.
      }
    }
    return rows;
  }
}

/// Satu baris indeks pencarian terjemahan.
class _IdxRow {
  final int surah;
  final int ayah;
  final String text; // teks asli, untuk snippet & tampil
  final String lower; // sudah lowercase, untuk contains cepat
  const _IdxRow(this.surah, this.ayah, this.text, this.lower);
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
