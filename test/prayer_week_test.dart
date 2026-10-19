import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_leveling/services/prayer_service.dart';

void main() {
  test('rentang 7 hari mulai hari ini', () {
    final days = PrayerService.weekDates(DateTime(2026, 10, 19));
    expect(days.length, 7);
    expect(days.first, '2026-10-19');
    expect(days.last, '2026-10-25');
  });

  test('melewati batas bulan dan tahun', () {
    final days = PrayerService.weekDates(DateTime(2026, 12, 30));
    expect(days, [
      '2026-12-30',
      '2026-12-31',
      '2027-01-01',
      '2027-01-02',
      '2027-01-03',
      '2027-01-04',
      '2027-01-05',
    ]);
  });

  test('jumlah hari bisa diatur dan tanggal satu digit diberi nol', () {
    final days = PrayerService.weekDates(DateTime(2026, 1, 5), days: 3);
    expect(days, ['2026-01-05', '2026-01-06', '2026-01-07']);
  });

  test('tanggal benar-benar maju satu hari, bukan berulang', () {
    final days = PrayerService.weekDates(DateTime(2026, 2, 27));
    expect(days.toSet().length, days.length);
    expect(days, [
      '2026-02-27',
      '2026-02-28',
      '2026-03-01',
      '2026-03-02',
      '2026-03-03',
      '2026-03-04',
      '2026-03-05',
    ]);
  });
}
