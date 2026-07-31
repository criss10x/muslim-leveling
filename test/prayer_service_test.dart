import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/prayer_service.dart';

void main() {
  const baliAreas = [
    'Kab. Badung',
    'Kab. Bangli',
    'Kab. Buleleng',
    'Kota Denpasar',
  ];

  test('prayer area matches Badung region over Kuta Selatan town', () {
    expect(
      PrayerService.prayerAreaFromAddress({
        'town': 'Kuta Selatan',
        'region': 'Badung',
        'state': 'Bali',
      }, baliAreas),
      'Kab. Badung',
    );
  });

  test('prayer area matches Denpasar city to the catalog', () {
    expect(
      PrayerService.prayerAreaFromAddress({'city': 'Denpasar'}, baliAreas),
      'Kota Denpasar',
    );
  });

  test('prayer area normalizes kabupaten county labels', () {
    expect(
      PrayerService.prayerAreaFromAddress({
        'county': 'KABUPATEN BADUNG',
      }, baliAreas),
      'Kab. Badung',
    );
  });

  test('prayer area rejects unmatched kecamatan labels', () {
    expect(
      PrayerService.prayerAreaFromAddress({
        'town': 'Kuta Selatan',
        'village': 'Jimbaran',
      }, baliAreas),
      isNull,
    );
  });

  test('province catalog includes Bali and all Equran provinces', () {
    expect(PrayerService.provinces, contains('Bali'));
    expect(PrayerService.provinces, hasLength(34));
  });
}
