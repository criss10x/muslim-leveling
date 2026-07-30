import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/prayer_service.dart';

void main() {
  test('prayer area prefers county over a Bali kecamatan', () {
    expect(
      PrayerService.prayerAreaFromAddress({
        'county': 'Kabupaten Badung',
        'village': 'Kuta',
      }),
      'Kabupaten Badung',
    );
  });

  test('prayer area falls back through city, town, and village', () {
    expect(PrayerService.prayerAreaFromAddress({'city': 'Denpasar'}), 'Denpasar');
    expect(PrayerService.prayerAreaFromAddress({'town': 'Singaraja'}), 'Singaraja');
    expect(PrayerService.prayerAreaFromAddress({'village': 'Kuta'}), 'Kuta');
  });
}
