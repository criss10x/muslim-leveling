import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/prayer_service.dart';

void main() {
  const baliAreas = [
    'Kab. Badung',
    'Kab. Bangli',
    'Kab. Buleleng',
    'Kota Denpasar',
  ];
  const bogorAreas = ['Kab. Bogor', 'Kota Bogor'];
  const bandungAreas = ['Kab. Bandung', 'Kota Bandung'];

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

  test('prayer area preserves explicit kabupaten and kota types', () {
    expect(
      PrayerService.prayerAreaFromAddress({'county': 'Kab. Bogor'}, bogorAreas),
      'Kab. Bogor',
    );
    expect(
      PrayerService.prayerAreaFromAddress({'city': 'Kota Bogor'}, bogorAreas),
      'Kota Bogor',
    );
  });

  test('prayer area rejects ambiguous prefixless catalog names', () {
    expect(
      PrayerService.prayerAreaFromAddress({'city': 'Bogor'}, bogorAreas),
      isNull,
    );
  });

  test('prayer area recognizes punctuation before administrative prefixes', () {
    expect(
      PrayerService.prayerAreaFromAddress({'county': 'Kab.Badung'}, baliAreas),
      'Kab. Badung',
    );
    expect(
      PrayerService.prayerAreaFromAddress({
        'city': 'Kota-Bandung',
      }, bandungAreas),
      'Kota Bandung',
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

  test('province state aliases keep Maluku Utara and Papua Barat specific', () {
    expect(PrayerService.provinceFromState('Maluku Utara'), 'Maluku Utara');
    expect(PrayerService.provinceFromState('Papua Barat'), 'Papua Barat');
  });
}
