import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/daily_highlight.dart';
import 'package:muslim_leveling/services/hadis_api.dart';

/// Cek rotasi seed harian: start page hadis tidak sama tiap hari
/// (regresi yang bikin user melihat hadis yang sama setiap hari).
void main() {
  const totalPages =
      (hadisTotalCount + hadisExplorePageSize - 1) ~/ hadisExplorePageSize;

  test('highlightIndex dalam rentang dan berganti antar hari', () {
    String key(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final start = DateTime(2026, 8, 1);
    final pages = List.generate(
        30, (i) => highlightIndex(key(start.add(Duration(days: i))), totalPages));

    for (final p in pages) {
      expect(p, inInclusiveRange(0, totalPages - 1));
    }
    // 30 hari berturut-turut tidak boleh jatuh di halaman awal yang sama
    // semua — itulah bug "hadis sama setiap hari".
    expect(pages.toSet().length, greaterThan(10));
  });
}
