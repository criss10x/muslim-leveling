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

  test('prayer area skips a kecamatan in favour of kabupaten kota', () {
    expect(
      PrayerService.prayerAreaFromAddress({
        'county': 'Kecamatan Kuta',
        'city': 'Kabupaten Badung',
      }),
      'Kabupaten Badung',
    );
  });

  test('prayer area falls back through city and town', () {
    expect(
      PrayerService.prayerAreaFromAddress({'city': 'Denpasar'}),
      'Denpasar',
    );
    expect(
      PrayerService.prayerAreaFromAddress({'town': 'Singaraja'}),
      'Singaraja',
    );
  });

  test('prayer area rejects village-only reverse geocoding', () {
    expect(PrayerService.prayerAreaFromAddress({'village': 'Kuta'}), isNull);
  });

  test('province catalog includes Bali and all Equran provinces', () {
    expect(PrayerService.provinces, contains('Bali'));
    expect(PrayerService.provinces, hasLength(34));
  });
}
