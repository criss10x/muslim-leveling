import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('searchVerses menemukan kata di terjemahan', () async {
    // Cari kata umum yang pasti ada di terjemahan (misal "Tuhan")
    final res = await QuranData().searchVerses('Tuhan');
    expect(res.hits, isNotEmpty);
    // Setiap hit punya surah & ayah valid
    for (final h in res.hits) {
      expect(h.surahNumber, inInclusiveRange(1, 114));
      expect(h.ayahNumber, greaterThan(0));
      expect(h.translation.toLowerCase(), contains('tuhan'));
    }
  });

  test('searchVerses kosong untuk query pendek atau tidak ada', () async {
    final empty1 = await QuranData().searchVerses('');
    expect(empty1.hits, isEmpty);
    expect(empty1.truncated, isFalse);
  });

  test('searchVerses limit 30 + truncated untuk kata sangat umum', () async {
    // Kata sangat umum, hasil > 30
    final res = await QuranData().searchVerses('Allah');
    expect(res.hits.length, lessThanOrEqualTo(30));
    // "Allah" ada di >30 ayat → pasti terpotong
    expect(res.truncated, isTrue);
  });

  test('truncated false saat hasil pas 30 atau kurang', () async {
    // Kata langka: hasil sedikit, tidak terpotong
    final res = await QuranData().searchVerses('neraka jahanam');
    expect(res.truncated, isFalse);
    expect(res.hits.length, lessThan(30));
  });
}
