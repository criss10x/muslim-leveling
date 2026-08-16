import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'quran_data.dart';
import 'hadis_api.dart';
import 'doa_api.dart';

/// Daily Highlight — renungan harian konsisten per tanggal (seed YYYYMMDD).
/// ponytail: ayat dari aset lokal (offline native); hadis+doa di-cache disk
/// per-tanggal di key _kCache sehingga seharian offline-proof setelah load.
int highlightIndex(String todayStr, int len) {
  final seed = int.parse(todayStr.replaceAll('-', ''));
  return seed % len;
}

class DailyHighlight {
  final String date, surahLatin, ayahArabic, ayahIdn, hadisIdn, doaNama, doaIdn;
  final int surahNumber, ayahNumber, hadisId; // hadisId=0 & hadisIdn='' → offline
  const DailyHighlight({
    required this.date, required this.surahLatin, required this.ayahArabic,
    required this.ayahIdn, required this.surahNumber, required this.ayahNumber,
    this.hadisId = 0, this.hadisIdn = '', this.doaNama = '', this.doaIdn = '',
  });

  bool isFor(String todayStr) => date == todayStr;

  Map<String, dynamic> toMap() => {
    'date': date, 'surahLatin': surahLatin, 'ayahArabic': ayahArabic,
    'ayahIdn': ayahIdn, 'surahNumber': surahNumber, 'ayahNumber': ayahNumber,
    'hadisId': hadisId, 'hadisIdn': hadisIdn, 'doaNama': doaNama, 'doaIdn': doaIdn,
  };
  factory DailyHighlight.fromMap(Map<String, dynamic> m) => DailyHighlight(
    date: m['date'] ?? '', surahLatin: m['surahLatin'] ?? '',
    ayahArabic: m['ayahArabic'] ?? '', ayahIdn: m['ayahIdn'] ?? '',
    surahNumber: m['surahNumber'] ?? 0, ayahNumber: m['ayahNumber'] ?? 0,
    hadisId: m['hadisId'] ?? 0, hadisIdn: m['hadisIdn'] ?? '',
    doaNama: m['doaNama'] ?? '', doaIdn: m['doaIdn'] ?? '',
  );
}

final dailyHighlightService = DailyHighlightService();

class DailyHighlightService {
  static const _kCache = 'daily_highlight';
  DailyHighlight? _mem;
  String? _memDate;

  // ponytail: reset cache memori antar widget-test (singleton lintas test = flake).
  void resetForTest() { _mem = null; _memDate = null; }

  Future<DailyHighlight> forToday(String todayStr) async {
    if (_mem != null && _memDate == todayStr) return _mem!;
    // 1) cache disk — seharian offline setelah load pertama.
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_kCache);
      if (raw != null) {
        final h = DailyHighlight.fromMap(jsonDecode(raw) as Map<String, dynamic>);
        if (h.isFor(todayStr)) { _mem = h; _memDate = todayStr; return h; }
      }
    } catch (_) {}
    // 2) fetch: ayat (lokal) + doa + hadis (deterministik; gagal → kosong).
    final surahs = await quranData.surahs();
    final surah = surahs[highlightIndex(todayStr, surahs.length)];
    final ayahs = await quranData.ayahs(surah.number);
    final ayah = ayahs[highlightIndex(todayStr, ayahs.length)];
    final doas = await doaApi.fetchAll();
    final doa = doas[highlightIndex(todayStr, doas.length)];
    var hadisId = 0; var hadisIdn = '';
    try {
      final hd = await hadisApi.show(highlightIndex(todayStr, 2260) + 1);
      hadisId = hd.id; hadisIdn = hd.idn;
    } catch (_) {
      // ponytail: offline → hadis kosong, kartu tetap tampil ayat+doa.
    }
    final h = DailyHighlight(
      date: todayStr, surahLatin: surah.nameLatin,
      ayahArabic: ayah.arabic, ayahIdn: ayah.translation,
      surahNumber: surah.number, ayahNumber: ayah.ayah,
      hadisId: hadisId, hadisIdn: hadisIdn, doaNama: doa.nama, doaIdn: doa.idn,
    );
    _mem = h; _memDate = todayStr;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kCache, jsonEncode(h.toMap()));
    } catch (_) {}
    return h;
  }
}
