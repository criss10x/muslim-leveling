import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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
}

class QuranTafsir {
  final int ayah;
  final String text;

  const QuranTafsir({required this.ayah, required this.text});
}

final QuranData quranData = QuranData();
