import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/game_service.dart';

void main() {
  test('hari game tetap tanggal sebelumnya sebelum reset pukul 03.00', () {
    expect(GameService.dailyDateKey(DateTime(2026, 8, 2, 2, 59)), '2026-08-01');
  });

  test('hari game berganti tepat pukul 03.00 waktu HP', () {
    expect(GameService.dailyDateKey(DateTime(2026, 8, 2, 3)), '2026-08-02');
  });

  test('hari game sebelum reset aman saat melewati pergantian tahun', () {
    expect(GameService.dailyDateKey(DateTime(2027, 1, 1, 1, 30)), '2026-12-31');
  });
}
