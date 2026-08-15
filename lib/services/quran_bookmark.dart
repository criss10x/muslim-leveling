import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bookmark ayat Quran — simpan snapshot teks (arab + terjemah) di prefs,
/// jadi layar daftar render instan tanpa load per-surat.
class QuranBookmark {
  final int surah, ayah;
  final String arabic, translation;
  final DateTime addedAt;
  const QuranBookmark({
    required this.surah,
    required this.ayah,
    required this.arabic,
    required this.translation,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'surah': surah,
        'ayah': ayah,
        'arabic': arabic,
        'translation': translation,
        'addedAt': addedAt.toIso8601String(),
      };

  factory QuranBookmark.fromJson(Map<String, dynamic> j) => QuranBookmark(
        surah: j['surah'] as int,
        ayah: j['ayah'] as int,
        arabic: j['arabic'] as String,
        translation: j['translation'] as String,
        addedAt: DateTime.tryParse(j['addedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class QuranBookmarks extends ChangeNotifier {
  static const _kKey = 'quran_bookmarks_v1';
  List<QuranBookmark> _items = const [];

  List<QuranBookmark> get items => _items;
  bool isBookmarked(int surah, int ayah) =>
      _items.any((b) => b.surah == surah && b.ayah == ayah);

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getStringList(_kKey) ?? const [];
      _items = raw
          .map((s) => QuranBookmark.fromJson(
              jsonDecode(s) as Map<String, dynamic>))
          .toList(growable: false);
      notifyListeners();
    } catch (_) {
      // ponytail: gagal baca prefs → bookmark dianggap kosong.
    }
  }

  Future<void> toggle(int surah, int ayah, String arabic, String translation) async {
    if (isBookmarked(surah, ayah)) {
      _items = _items
          .where((b) => !(b.surah == surah && b.ayah == ayah))
          .toList(growable: false);
    } else {
      _items = [
        QuranBookmark(
          surah: surah,
          ayah: ayah,
          arabic: arabic,
          translation: translation,
          addedAt: DateTime.now(),
        ),
        ..._items,
      ];
    }
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _kKey, _items.map((b) => jsonEncode(b.toJson())).toList());
    } catch (_) {
      // ponytail: gagal tulis prefs → state in-memory tetap valid sesi ini.
    }
  }
}

final QuranBookmarks quranBookmarks = QuranBookmarks();
