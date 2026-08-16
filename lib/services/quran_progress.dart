import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'game_service.dart';

/// Posisi baca Quran terakhir (surat + ayat) untuk tombol "Lanjutkan membaca"
/// di tab Quran. Diperbarui saat surat dibuka, saat murattal berganti ayat,
/// dan saat meninggalkan reader (ayat teratas yang terlihat).
class QuranProgress extends ChangeNotifier {
  static const _kSurah = 'quran_last_surah';
  static const _kAyah = 'quran_last_ayah';

  int? _surahNumber;
  int? _ayah;

  int? get surahNumber => _surahNumber;
  int? get ayah => _ayah;
  bool get hasProgress => _surahNumber != null && _ayah != null;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _surahNumber = p.getInt(_kSurah);
      _ayah = p.getInt(_kAyah);
      notifyListeners();
    } catch (_) {
      // ponytail: gagal baca prefs → abaikan, tombol tidak muncul.
    }
  }

  Future<void> save(int surahNumber, int ayah) async {
    if (_surahNumber == surahNumber && _ayah == ayah) return;
    _surahNumber = surahNumber;
    _ayah = ayah;
    notifyListeners();
    // ponytail: satu-satunya jalur XP baca — buka reader, scroll, murattal
    // semuanya lewat sini, jadi XP tidak bisa dobel dari sumber lain.
    unawaited(GameService.noteQuranPosition(surahNumber, ayah));
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_kSurah, surahNumber);
      await p.setInt(_kAyah, ayah);
    } catch (_) {
      // ponytail: gagal tulis prefs → state in-memory tetap valid sesi ini.
    }
  }
}

final QuranProgress quranProgress = QuranProgress();
