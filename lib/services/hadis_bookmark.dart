import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_sync.dart';

/// Bookmark hadis — simpan snapshot teks (arab + terjemahan + grade/takhrij)
/// di prefs, jadi layar daftar tersimpan render instan tanpa request jaringan.
///
/// Pola dan kuncinya sengaja dibuat sama dengan [QuranBookmarks]: satu model
/// per item, simpan snapshot, sinkron ke cloud, lokal yang menang.
class HadisBookmark {
  final int id;
  final String arabic;
  final String translation;

  /// Boleh kosong: hasil `cari/` tidak mengirim grade/takhrij.
  final String grade;
  final String takhrij;
  final String? hikmah;
  final DateTime addedAt;

  const HadisBookmark({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.addedAt,
    this.grade = '',
    this.takhrij = '',
    this.hikmah,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'translation': translation,
        'grade': grade,
        'takhrij': takhrij,
        'hikmah': hikmah,
        'addedAt': addedAt.toIso8601String(),
      };

  factory HadisBookmark.fromJson(Map<String, dynamic> j) => HadisBookmark(
        id: (j['id'] as num?)?.toInt() ?? 0,
        arabic: j['arabic'] as String? ?? '',
        translation: j['translation'] as String? ?? '',
        grade: j['grade'] as String? ?? '',
        takhrij: j['takhrij'] as String? ?? '',
        hikmah: j['hikmah'] as String?,
        addedAt: DateTime.tryParse(j['addedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class HadisBookmarks extends ChangeNotifier {
  static const _kKey = 'hadis_bookmarks_v1';
  List<HadisBookmark> _items = const [];

  List<HadisBookmark> get items => _items;

  bool isBookmarked(int id) => _items.any((b) => b.id == id);

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getStringList(_kKey) ?? const [];
      _items = raw
          .map((s) => HadisBookmark.fromJson(
              jsonDecode(s) as Map<String, dynamic>))
          .toList(growable: false);
      notifyListeners();
    } catch (_) {
      // ponytail: gagal baca prefs -> bookmark dianggap kosong.
    }
  }

  /// Pulihkan dari dokumen cloud yang sudah di tangan (jalur login). Lokal yang
  /// sudah ada menang; cloud cuma mengisi kekosongan setelah reinstall.
  Future<void> restoreFromRemote(Map<String, dynamic>? doc) async {
    if (_items.isNotEmpty) return;
    final list = doc?['hadisBookmarks'];
    if (list is! List || list.isEmpty) return;
    try {
      _items = list
          .whereType<Map>()
          .map((m) => HadisBookmark.fromJson(Map<String, dynamic>.from(m)))
          .toList(growable: false);
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _kKey, _items.map((b) => jsonEncode(b.toJson())).toList());
      notifyListeners();
    } catch (_) {
      // ponytail: payload cloud rusak -> biarkan lokal apa adanya.
    }
  }

  Future<void> toggle(HadisBookmark item) async {
    if (isBookmarked(item.id)) {
      _items = _items.where((b) => b.id != item.id).toList(growable: false);
    } else {
      _items = [item, ..._items];
    }
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _kKey, _items.map((b) => jsonEncode(b.toJson())).toList());
      CloudSync.saveHadisBookmarks(
          _items.map((b) => b.toJson()).toList()); // fire-and-forget
    } catch (_) {
      // ponytail: gagal tulis prefs -> state in-memory tetap valid sesi ini.
    }
  }
}

final HadisBookmarks hadisBookmarks = HadisBookmarks();
