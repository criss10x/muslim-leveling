import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/quran_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('nilai default masuk akal saat belum ada yang tersimpan', () async {
    final s = QuranSettings();
    await s.load();

    expect(s.arabicFontSize, 28);
    expect(s.translationFontSize, 15);
    expect(s.showTranslation, isTrue);
    expect(s.speed, 1.0);
  });

  test('setelan bertahan lintas instance', () async {
    final a = QuranSettings();
    await a.load();
    await a.setArabicFontSize(36);
    await a.setTranslationFontSize(20);
    await a.setShowTranslation(false);
    await a.setSpeed(0.75);

    final b = QuranSettings();
    await b.load();

    expect(b.arabicFontSize, 36);
    expect(b.translationFontSize, 20);
    expect(b.showTranslation, isFalse);
    expect(b.speed, 0.75);
  });

  test('ukuran font dijepit ke rentang yang didukung', () async {
    final s = QuranSettings();
    await s.load();

    await s.setArabicFontSize(999);
    expect(s.arabicFontSize, kArabicFontMax);
    await s.setArabicFontSize(1);
    expect(s.arabicFontSize, kArabicFontMin);

    await s.setTranslationFontSize(999);
    expect(s.translationFontSize, kTranslationFontMax);
    await s.setTranslationFontSize(1);
    expect(s.translationFontSize, kTranslationFontMin);
  });

  test('perubahan memberi tahu listener', () async {
    final s = QuranSettings();
    await s.load();

    var calls = 0;
    s.addListener(() => calls++);
    await s.setArabicFontSize(30);
    await s.setShowTranslation(false);

    expect(calls, 2);
  });
}
