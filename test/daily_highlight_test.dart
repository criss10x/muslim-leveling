import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/daily_highlight.dart';

void main() {
  test('same date → same pick; index selalu dalam 0..len-1', () {
    expect(highlightIndex('2026-08-16', 2260), highlightIndex('2026-08-16', 2260));
    expect(highlightIndex('2026-08-16', 10), inInclusiveRange(0, 9));
    for (var i = 1; i < 28; i++) {
      expect(highlightIndex('2026-01-${i.toString().padLeft(2, '0')}', 7), inInclusiveRange(0, 6));
    }
  });

  test('toMap/fromMap round-trip; tanggal beda → cache invalid', () {
    const m = {'date': '2026-08-16', 'surahLatin': 'Al-Fatihah', 'ayahArabic': 'x',
      'ayahIdn': 'y', 'surahNumber': 1, 'ayahNumber': 1,
      'hadisId': 5, 'hadisIdn': 'h', 'doaNama': 'd', 'doaIdn': 'i'};
    final h = DailyHighlight.fromMap(m);
    expect(h.toMap(), equals(m));
    expect(h.isFor('2026-08-16'), isTrue);
    expect(h.isFor('2026-08-17'), isFalse);
  });
}
