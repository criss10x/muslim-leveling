import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quran_qari.dart';

const double kArabicFontMin = 20;
const double kArabicFontMax = 44;
const double kTranslationFontMin = 12;
const double kTranslationFontMax = 24;
const List<double> kSpeedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
const List<int> kSleepOptions = [-1, 0, 15, 30, 60]; // -1 = akhir surat

/// Preferensi tampilan dan kecepatan murrotal. Range ayat dan jumlah
/// pengulangan sengaja tidak disimpan — keduanya khas satu sesi hafalan, dan
/// memulihkannya ke surat lain justru membingungkan.
class QuranSettings extends ChangeNotifier {
  static const _kArabic = 'quran_arabic_font';
  static const _kTranslation = 'quran_translation_font';
  static const _kShowTranslation = 'quran_show_translation';
  static const _kShowLatin = 'quran_show_latin';
  static const _kShowTajweed = 'quran_show_tajweed';
  static const _kSpeed = 'quran_speed';
  static const _kQari = 'quran_qari_id';
  static const _kSleepMinutes = 'quran_sleep_minutes';

  double _arabicFontSize = 28;
  double _translationFontSize = 15;
  bool _showTranslation = true;
  bool _showLatin = true;
  bool _showTajweed = false;
  double _speed = 1.0;
  String _qariId = '05';
  int _sleepMinutes = -1; // -1 = akhir surat

  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  bool get showTranslation => _showTranslation;
  bool get showLatin => _showLatin;
  bool get showTajweed => _showTajweed;
  double get speed => _speed;
  String get qariId => _qariId;
  int get sleepMinutes => _sleepMinutes;

  QuranQari get qari => kQariList.firstWhere(
        (q) => q.id == _qariId,
        orElse: () => kQariList.first,
      );

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _arabicFontSize = p.getDouble(_kArabic) ?? 28;
    _translationFontSize = p.getDouble(_kTranslation) ?? 15;
    _showTranslation = p.getBool(_kShowTranslation) ?? true;
    _showLatin = p.getBool(_kShowLatin) ?? true;
    _showTajweed = p.getBool(_kShowTajweed) ?? false;
    _speed = p.getDouble(_kSpeed) ?? 1.0;
    _qariId = p.getString(_kQari) ?? '05';
    _sleepMinutes = p.getInt(_kSleepMinutes) ?? -1;
    notifyListeners();
  }

  Future<void> setShowLatin(bool v) async {
    _showLatin = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kShowLatin, v);
    notifyListeners();
  }

  Future<void> setShowTajweed(bool v) async {
    _showTajweed = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kShowTajweed, v);
    notifyListeners();
  }

  double _clamp(double v, double lo, double hi) =>
      v < lo ? lo : (v > hi ? hi : v);

  Future<void> setArabicFontSize(double v) async {
    _arabicFontSize = _clamp(v, kArabicFontMin, kArabicFontMax);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kArabic, _arabicFontSize);
    notifyListeners();
  }

  Future<void> setTranslationFontSize(double v) async {
    _translationFontSize = _clamp(v, kTranslationFontMin, kTranslationFontMax);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kTranslation, _translationFontSize);
    notifyListeners();
  }

  Future<void> setShowTranslation(bool v) async {
    _showTranslation = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kShowTranslation, v);
    notifyListeners();
  }

  Future<void> setQari(String qariId) async {
    _qariId = qariId;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kQari, qariId);
    notifyListeners();
  }

  Future<void> setSleepMinutes(int minutes) async {
    _sleepMinutes = minutes;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kSleepMinutes, minutes);
    notifyListeners();
  }

  Future<void> setSpeed(double v) async {
    _speed = v;
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kSpeed, v);
    notifyListeners();
  }
}

final QuranSettings quranSettings = QuranSettings();
