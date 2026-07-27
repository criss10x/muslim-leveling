import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double kArabicFontMin = 20;
const double kArabicFontMax = 44;
const double kTranslationFontMin = 12;
const double kTranslationFontMax = 24;
const List<double> kSpeedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

/// Preferensi tampilan dan kecepatan murrotal. Range ayat dan jumlah
/// pengulangan sengaja tidak disimpan — keduanya khas satu sesi hafalan, dan
/// memulihkannya ke surat lain justru membingungkan.
class QuranSettings extends ChangeNotifier {
  static const _kArabic = 'quran_arabic_font';
  static const _kTranslation = 'quran_translation_font';
  static const _kShowTranslation = 'quran_show_translation';
  static const _kSpeed = 'quran_speed';

  double _arabicFontSize = 28;
  double _translationFontSize = 15;
  bool _showTranslation = true;
  double _speed = 1.0;

  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  bool get showTranslation => _showTranslation;
  double get speed => _speed;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _arabicFontSize = p.getDouble(_kArabic) ?? 28;
    _translationFontSize = p.getDouble(_kTranslation) ?? 15;
    _showTranslation = p.getBool(_kShowTranslation) ?? true;
    _speed = p.getDouble(_kSpeed) ?? 1.0;
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

  Future<void> setSpeed(double v) async {
    _speed = v;
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kSpeed, v);
    notifyListeners();
  }
}

final QuranSettings quranSettings = QuranSettings();
