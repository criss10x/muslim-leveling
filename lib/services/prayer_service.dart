import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ponytail: stdlib HttpClient + SharedPreferences. No dio, no riverpod.
/// Primary API: equran.id/api/v2/shalat (Kemenag proxy), Aladhan fallback.
class PrayerService {
  static const _equranBase = 'https://equran.id/api/v2/shalat';
  static const _myquranBase = 'https://api.myquran.com/v3/sholat';
  static const _aladhanBase = 'https://api.aladhan.com/v1/timingsByCity';
  static const _cacheKey = 'prayer_cache_v2';
  static final _client = HttpClient()..connectionTimeout = const Duration(seconds: 8);

  static Future<List<Map<String, dynamic>>> searchCities(String q) async {
    if (q.trim().isEmpty) return const [];
    // v3: /kabkota/cari/{keyword} (was /kota/cari/{q} in v2)
    final uri = Uri.parse('$_myquranBase/kabkota/cari/${Uri.encodeComponent(q.trim())}');
    try {
      final req = await _client.getUrl(uri);
      final res = await req.close();
      if (res.statusCode != 200) return const [];
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['status'] != true) return const [];
      final data = json['data'];
      if (data is List) return data.cast<Map<String, dynamic>>();
      if (data is Map) return [data.cast<String, dynamic>()];
      return const [];
    } catch (_) {
      return const [];
    }
  }

  /// Fetch jadwal for [date] (defaults today). Tries Equran first, Aladhan fallback.
  static Future<Map<String, String>?> fetchSchedule({
    required String cityId,
    DateTime? date,
    String? cityName,
  }) async {
    final d = date ?? DateTime.now();
    final dateStr = _dateKey(d);

    final cached = await _loadCache(cityId, dateStr);
    if (cached != null) return cached;

    final equran = await _fetchEquran(cityName: cityName ?? '', date: d);
    if (equran != null) {
      await _saveCache(cityId, dateStr, equran);
      return equran;
    }

    if (cityName != null && cityName.trim().isNotEmpty) {
      final aladhan = await _fetchAladhan(cityName: cityName.trim(), date: d);
      if (aladhan != null) {
        await _saveCache(cityId, dateStr, aladhan);
        return aladhan;
      }
    }

    // ponytail: stale cache is better than nothing
    return _loadAnyCache(cityId);
  }

  static Future<Map<String, String>?> _fetchEquran({
    required String cityName,
    required DateTime date,
  }) async {
    if (cityName.trim().isEmpty) return null;
    try {
      final prov = _extractProvinsi(cityName);
      final kota = _extractKabkota(cityName);
      final uri = Uri.parse(_equranBase);
      final req = await _client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'provinsi': prov,
        'kabkota': kota,
        'bulan': date.month,
        'tahun': date.year,
      }));
      final res = await req.close();
      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if ((json['code'] as int?) != 200) return null;
      final list = json['data'] as List?;
      if (list == null || list.isEmpty) return null;

      // Cari entry untuk tanggal hari ini
      final day = date.day;
      Map<String, dynamic>? entry;
      for (final e in list) {
        if ((e['tanggal'] as int?) == day) {
          entry = e as Map<String, dynamic>;
          break;
        }
      }
      entry ??= list.first as Map<String, dynamic>;
      String clean(String v) => (v as String?)?.replaceAll(RegExp(r' \(WIB\)'), '') ?? '--:--';
      return {
        'imsak': clean(entry['imsak']),
        'subuh': clean(entry['subuh']),
        'terbit': clean(entry['terbit']),
        'dhuha': clean(entry['dhuha']),
        'dzuhur': clean(entry['dzuhur']),
        'ashar': clean(entry['ashar']),
        'maghrib': clean(entry['maghrib']),
        'isya': clean(entry['isya']),
        'tanggal': '${date.year}-${date.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
        'lokasi': cityName,
        'daerah': prov,
      };
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>?> _fetchAladhan({
    required String cityName,
    required DateTime date,
  }) async {
    final clean = cityName
        .replaceAll(RegExp(r'(kota|kab\.|kabupaten)\s*', caseSensitive: false), '')
        .trim();
    if (clean.isEmpty) return null;
    final uri = Uri.parse(
      '$_aladhanBase?city=${Uri.encodeComponent(clean)}&country=${Uri.encodeComponent('Indonesia')}&method=11',
    );
    try {
      final req = await _client.getUrl(uri);
      final res = await req.close();
      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final timings = (json['data']?['timings']) as Map<String, dynamic>?;
      if (timings == null) return null;
      String cleanTime(String t) {
        final parts = t.trim().split(' ');
        final first = parts.isNotEmpty ? parts[0] : t.trim();
        return first.length >= 5 ? first.substring(0, 5) : first;
      }
      return {
        'imsak': '00:00',
        'subuh': cleanTime(timings['Fajr'] as String? ?? ''),
        'terbit': cleanTime(timings['Sunrise'] as String? ?? ''),
        'dhuha': '00:00',
        'dzuhur': cleanTime(timings['Dhuhr'] as String? ?? ''),
        'ashar': cleanTime(timings['Asr'] as String? ?? ''),
        'maghrib': cleanTime(timings['Maghrib'] as String? ?? ''),
        'isya': cleanTime(timings['Isha'] as String? ?? ''),
        'tanggal': _dateKey(date),
        'lokasi': cityName,
        'daerah': '',
      };
    } catch (_) {
      return null;
    }
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<Map<String, String>?> _loadCache(String cityId, String date) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['cityId'] != cityId || map['date'] != date) return null;
      return (map['timings'] as Map<String, dynamic>).cast<String, String>();
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>?> _loadAnyCache(String cityId) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['cityId'] != cityId) return null;
      return (map['timings'] as Map<String, dynamic>).cast<String, String>();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveCache(String cityId, String date, Map<String, String> timings) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_cacheKey, jsonEncode({
      'cityId': cityId,
      'date': date,
      'timings': timings,
    }));
  }

  // --- SharedPreferences helpers ---
  /// Bump setiap kali lokasi diganti. Tab home & jadwal hidup terus di
  /// IndexedStack (initState sekali), jadi mereka mendengarkan ini untuk
  /// refetch jadwal saat kota diganti dari tab lain.
  static final ValueNotifier<int> locationVersion = ValueNotifier(0);

  /// Deteksi lokasi via GPS → reverse geocode via Aladhan API.
  /// Returns (id, name) atau null jika gagal.
  static Future<({String id, String name})?> getCurrentLocation() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied) return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Reverse geocode via Aladhan API
      final uri = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?'
        'latitude=${pos.latitude}&longitude=${pos.longitude}',
      );
      final req = await _client.getUrl(uri);
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;
      final city = data?['meta']?['timezone'] as String?;
      if (city == null) return null;

      // Cari kecocokan di database kota dari API myquran
      final searchResult = await searchCities(city.replaceAll('_', ' '));
      if (searchResult.isNotEmpty) {
        final first = searchResult.first;
        return (id: first['id'] as String, name: first['lokasi'] as String);
      }

      // Fallback: simpan nama kota langsung tanpa ID
      return (id: city, name: city);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveLocation(String id, String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('city_id', id);
    await p.setString('city_name', name);
    locationVersion.value++;
  }

  static Future<({String id, String name})?> loadLocation() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getString('city_id');
    final name = p.getString('city_name');
    if (id == null || name == null) return null;
    return (id: id, name: name);
  }

  static final _provinsiList = ['Aceh', 'Sumatera Utara', 'Sumatera Barat', 'Riau',
    'Kepulauan Riau', 'Jambi', 'Bengkulu', 'Sumatera Selatan', 'Bangka Belitung',
    'Lampung', 'DKI Jakarta', 'Jawa Barat', 'Banten', 'Jawa Tengah', 'DI Yogyakarta',
    'Jawa Timur', 'Bali', 'Nusa Tenggara Barat', 'Nusa Tenggara Timur',
    'Kalimantan Barat', 'Kalimantan Tengah', 'Kalimantan Selatan', 'Kalimantan Timur',
    'Kalimantan Utara', 'Sulawesi Utara', 'Gorontalo', 'Sulawesi Tengah',
    'Sulawesi Barat', 'Sulawesi Selatan', 'Sulawesi Tenggara', 'Maluku',
    'Maluku Utara', 'Papua', 'Papua Barat'];

  static String _extractProvinsi(String city) {
    for (final p in _provinsiList) {
      if (city.contains(p)) return p;
    }
    return 'DKI Jakarta';
  }

  static String _extractKabkota(String city) {
    for (final p in _provinsiList) {
      if (city.contains(p)) {
        final rest = city.replaceAll(p, '').trim();
        return rest.isEmpty ? city : rest;
      }
    }
    return city;
  }
}
