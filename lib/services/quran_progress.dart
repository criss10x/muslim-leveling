import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'game_service.dart';

/// Posisi baca Quran terakhir (surat + ayat) untuk tombol "Lanjutkan membaca"
/// di tab Quran. Diperbarui saat surat dibuka, saat murattal berganti ayat,
/// dan saat meninggalkan reader (ayat teratas yang terlihat).
///
/// Menyimpan riwayat sampai 3 posisi terakhir (terbaru dulu, satu entri per
/// surat) supaya tab Quran bisa menawarkan bacaan lama selain posisi paling
/// akhir. Entri pertama tetap diekspos lewat [surahNumber]/[ayah] sehingga
/// jalur XP ([GameService.noteQuranPosition]) dan reader tidak berubah.
class QuranProgress extends ChangeNotifier {
  static const _kSurah = 'quran_last_surah';
  static const _kAyah = 'quran_last_ayah';
  static const _kHistory = 'quran_recent_positions';
  static const maxEntries = 3;

  /// Riwayat posisi, terbaru dulu, maks [maxEntries], satu entri per surah.
  List<({int surah, int ayah})> _history = [];

  int? get surahNumber => _history.isEmpty ? null : _history.first.surah;
  int? get ayah => _history.isEmpty ? null : _history.first.ayah;
  bool get hasProgress => _history.isNotEmpty;

  /// Posisi lama di bawah entri teratas, untuk baris "bacaan sebelumnya".
  List<({int surah, int ayah})> get previousEntries =>
      _history.length <= 1 ? const [] : _history.sublist(1);

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _history = _decode(p.getString(_kHistory));
      if (_history.isEmpty) {
        // Auto-heal: user lama punya posisi di key tunggal sebelum riwayat ada.
        final s = p.getInt(_kSurah);
        final a = p.getInt(_kAyah);
        if (s != null && a != null) _history = [(surah: s, ayah: a)];
      }
      notifyListeners();
    } catch (_) {
      // ponytail: gagal baca prefs → abaikan, tombol tidak muncul.
    }
  }

  Future<void> save(int surahNumber, int ayah) async {
    if (_history.isNotEmpty &&
        _history.first.surah == surahNumber &&
        _history.first.ayah == ayah) {
      return;
    }
    _history = [
      (surah: surahNumber, ayah: ayah),
      // Satu entri per surat: update posisi lama menghapus entri duplikatnya.
      ..._history.where((e) => e.surah != surahNumber),
    ].take(maxEntries).toList();
    notifyListeners();
    // ponytail: satu-satunya jalur XP baca — buka reader, scroll, murattal
    // semuanya lewat sini, jadi XP tidak bisa dobel dari sumber lain.
    unawaited(GameService.noteQuranPosition(surahNumber, ayah));
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kHistory, _encode(_history));
      // Key tunggal lama dipertahankan (backup cloud lama & fallback).
      await p.setInt(_kSurah, surahNumber);
      await p.setInt(_kAyah, ayah);
    } catch (_) {
      // ponytail: gagal tulis prefs → state in-memory tetap valid sesi ini.
    }
  }

  String _encode(List<({int surah, int ayah})> h) => jsonEncode(
        [for (final e in h) [e.surah, e.ayah]],
      );

  List<({int surah, int ayah})> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      final out = <({int surah, int ayah})>[];
      for (final item in list) {
        if (item is List && item.length == 2) {
          final s = item[0];
          final a = item[1];
          if (s is int && a is int && s >= 1 && s <= 114 && a >= 1) {
            out.add((surah: s, ayah: a));
          }
        }
      }
      return out.take(maxEntries).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Hanya untuk tes: kosongkan state in-memory antar kasus.
  @visibleForTesting
  void resetForTest() {
    _history = [];
  }
}

final QuranProgress quranProgress = QuranProgress();

