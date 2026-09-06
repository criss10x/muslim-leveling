import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('searchVerses menemukan kata di terjemahan', () async {
    // Paksa asset bundle tersedia di test
    TestWidgetsFlutterBinding.ensureInitialized();
    // Cari kata umum yang pasti ada di terjemahan (misal "Tuhan")
    final hits = await QuranData().searchVerses('Tuhan');
    expect(hits, isNotEmpty);
    // Setiap hit punya surah & ayah valid
    for (final h in hits) {
      expect(h.surahNumber, inInclusiveRange(1, 114));
      expect(h.ayahNumber, greaterThan(0));
      expect(h.translation.toLowerCase(), contains('tuhan'));
    }
  });

  test('searchVerses kosong untuk query pendek atau tidak ada', () async {
    final empty1 = await QuranData().searchVerses('');
    expect(empty1, isEmpty);
  });

  test('searchVerses limit 30 hasil', () async {
    // Kata sangat umum, hasil > 30
    final hits = await QuranData().searchVerses('Allah');
    expect(hits.length, lessThanOrEqualTo(30));
  });
}
