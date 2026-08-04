import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/prayer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test('prayer area maps Jakarta administrative districts to Kota Jakarta', () {
    expect(
      PrayerService.prayerAreaFromAddress({
        'county': 'Kota Administrasi Jakarta Selatan',
        'state': 'Daerah Khusus Ibukota Jakarta',
      }, ['Kab. Kepulauan Seribu', 'Kota Jakarta']),
      'Kota Jakarta',
    );
  });

  test('normalizes Jakarta labels to the Equran city name', () {
    expect(PrayerService.normalizeKabkota('Jakarta'), 'Kota Jakarta');
    expect(
      PrayerService.normalizeKabkota('Kota Administrasi Jakarta Selatan'),
      'Kota Jakarta',
    );
    expect(
      PrayerService.normalizeKabkota('Jakarta, DKI Jakarta'),
      'Kota Jakarta',
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

  test(
    'loads and saves Kota Jakarta when no location has been selected',
    () async {
      SharedPreferences.setMockInitialValues({});

      final location = await PrayerService.loadLocation();
      final prefs = await SharedPreferences.getInstance();

      expect(
        location,
        (id: 'DKI Jakarta/Kota Jakarta', name: 'Kota Jakarta'),
      );
      expect(prefs.getString('city_id'), 'DKI Jakarta/Kota Jakarta');
      expect(prefs.getString('city_name'), 'Kota Jakarta');
    },
  );
}
