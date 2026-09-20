import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_service.dart';
import '../l10n/app_localizations.dart';

/// ponytail: stdlib HttpClient + SharedPreferences. No dio, no riverpod.
/// Primary API: equran.id/api/v2/shalat (Kemenag proxy).
enum CurrentLocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  lookupFailed,
}

extension CurrentLocationFailureMessage on CurrentLocationFailure {
  /// Pesan siap-tampil. Service tidak punya BuildContext, jadi `l10n`
  /// diteruskan pemanggil — pola yang sama dengan GameService.sunnahHint.
  String message(AppL10n l10n) => switch (this) {
    CurrentLocationFailure.serviceDisabled => l10n.locFailureDisabled,
    CurrentLocationFailure.permissionDenied => l10n.locFailureDenied,
    CurrentLocationFailure.permissionDeniedForever => l10n.locFailureDeniedForever,
    CurrentLocationFailure.timeout => l10n.locFailureTimeout,
    CurrentLocationFailure.lookupFailed => l10n.locFailureLookup,
  };
}

class PrayerService {
  static const _equranBase = 'https://equran.id/api/v2/shalat';
  static const _myquranBase = 'https://api.myquran.com/v3/sholat';
  static const _aladhanBase = 'https://api.aladhan.com/v1';
  static const _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const _cacheKey = 'prayer_cache_v2';
  static final _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);
  // ponytail: shorter timeout for province discovery calls
  static final _discoveryClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 3);

  /// Provinsi names matching Equran API. Ordered by population density
  /// (most likely first) so discovery exits fast for Java users.
  static const _equranProvinsi = [
    'Jawa Barat',
    'Jawa Timur',
    'Jawa Tengah',
    'DKI Jakarta',
    'Banten',
    'Sumatera Utara',
    'Sumatera Selatan',
    'Lampung',
    'Riau',
    'Kepulauan Riau',
    'Sumatera Barat',
    'Aceh',
    'Jambi',
    'Bengkulu',
    'Kepulauan Bangka Belitung',
    'Kalimantan Barat',
    'Kalimantan Timur',
    'Kalimantan Selatan',
    'Kalimantan Tengah',
    'Kalimantan Utara',
    'Sulawesi Selatan',
    'Sulawesi Utara',
    'Sulawesi Tengah',
    'Sulawesi Tenggara',
    'Sulawesi Barat',
    'Gorontalo',
    'Bali',
    'Nusa Tenggara Barat',
    'Nusa Tenggara Timur',
    'Maluku',
    'Maluku Utara',
    'Papua',
    'Papua Barat',
    'D.I. Yogyakarta',
  ];

  static List<String> get provinces => _equranProvinsi;

  // ponytail: in-memory city→provinsi cache
  static final Map<String, String> _provCache = {};

  static Future<List<Map<String, dynamic>>> searchCities(String q) async {
    if (q.trim().isEmpty) return const [];
    final uri = Uri.parse(
      '$_myquranBase/kabkota/cari/${Uri.encodeComponent(q.trim())}',
    );
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

  /// Fetch jadwal for [date] (defaults today). Pake Equran API.
  static Future<Map<String, String>?> fetchSchedule({
    required String cityId,
    DateTime? date,
    String? cityName,
  }) async {
    final d = date ?? DateTime.now();
    final dateStr = _dateKey(d);

    final cached = await _loadCache(cityId, dateStr);
    if (cached != null) return cached;

    // Cabang wilayah: luar negeri → Aladhan (cityId = "lat,lon").
    if (await isAbroad()) {
      final coords = _parseCoords(cityId);
      if (coords != null) {
        final abroad = await _fetchAladhan(
          lat: coords.$1,
          lon: coords.$2,
          date: d,
          label: cityName ?? '',
        );
        if (abroad != null) {
          await _saveCache(cityId, dateStr, abroad);
          return abroad;
        }
      }
      return _loadAnyCache(cityId);
    }

    final equran = await _fetchEquran(cityName: cityName ?? '', date: d);
    if (equran != null) {
      await _saveCache(cityId, dateStr, equran);
      return equran;
    }

    // ponytail: stale cache is better than nothing
    return _loadAnyCache(cityId);
  }

  /// Fetch full month jadwal from Equran. Returns list of raw entries or null.
  static Future<List<Map<String, dynamic>>?> fetchMonthlySchedule({
    required String cityName,
    required int year,
    required int month,
  }) async {
    if (cityName.trim().isEmpty) return null;
    try {
      final prov = await _resolveProvinsi(cityName);
      final kota = normalizeKabkota(cityName);
      final uri = Uri.parse(_equranBase);
      final req = await _client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(
        jsonEncode({
          'provinsi': prov,
          'kabkota': kota,
          'bulan': month,
          'tahun': year,
        }),
      );
      final res = await req.close();
      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if ((json['code'] as int?) != 200) return null;
      final data = json['data'];
      final jadwal = (data is Map ? data['jadwal'] : data) as List?;
      if (jadwal == null || jadwal.isEmpty) return null;
      return jadwal.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  /// Penanda mode wilayah. `true` = pakai Aladhan (luar negeri), `false` =
  /// equran.id (Indonesia).
  ///
  /// Lokal saja, sama seperti city_id — CloudSync hanya menyinkron blob
  /// game/learning/achievements, bukan lokasi. Ganti HP = pilih ulang.
  static const _abroadKey = 'prayer_abroad';

  static Future<bool> isAbroad() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_abroadKey) ?? false;
  }

  static Future<void> setAbroad(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_abroadKey, value);
  }

  /// Turunkan mode dari bentuk cityId. Kota Indonesia = "Provinsi/Kota",
  /// luar negeri = "lat,lon". Dipakai saat restore cloud menulis city_id
  /// langsung — tanpa ini mode dan lokasi bisa tidak cocok, dan jadwal luar
  /// negeri dicari lewat equran (selalu gagal).
  static bool deriveAbroad(String cityId) => _parseCoords(cityId) != null;

  /// Jadwal luar negeri via Aladhan (keyless). Nama kunci sengaja sama
  /// (subuh/dzuhur/...) supaya seluruh layar jadwal tidak perlu tahu API mana
  /// yang mengisi — Aladhan memakai Fajr/Dhuhr/Asr/Maghrib/Isha.
  ///
  /// `method` TIDAK dikirim: Aladhan memilih otomatis dari koordinat
  /// (Jakarta→Kemenag RI, London→MWL, New York→ISNA, Makkah→Umm Al-Qura),
  /// jadi tidak ada metode yang perlu ditebak atau dipilih user.
  static Future<Map<String, String>?> _fetchAladhan({
    required double lat,
    required double lon,
    required DateTime date,
    required String label,
  }) async {
    try {
      final d =
          '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      final uri = Uri.parse('$_aladhanBase/timings/$d').replace(
        queryParameters: {'latitude': '$lat', 'longitude': '$lon'},
      );
      final req = await _client.getUrl(uri);
      req.headers.set('User-Agent', 'MuslimLeveling/1.1');
      final res = await req.close();
      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if ((json['code'] as int?) != 200) return null;
      final data = json['data'] as Map<String, dynamic>;
      final t = data['timings'] as Map<String, dynamic>;
      final mapped = mapAladhanTimings(t);
      return {
        ...mapped,
        'tanggal':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'lokasi': label,
        'daerah': '',
      };
    } catch (_) {
      return null;
    }
  }

  /// Petakan kunci Aladhan → kunci equran. Murni & publik supaya bisa diuji
  /// tanpa jaringan — inilah bagian yang paling gampang salah diam-diam.
  ///
  /// Aladhan mengembalikan '04:49 (BST)' / '02:32 (+1)'; ambil HANYA pola jam
  /// di depan, kalau tidak seluruh jadwal jadi '--:--'.
  static Map<String, String> mapAladhanTimings(Map<String, dynamic> t) {
    String clean(Object? v) {
      final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch('${v ?? ''}');
      if (m == null) return '--:--';
      return '${m.group(1)!.padLeft(2, '0')}:${m.group(2)}';
    }

    return {
      'imsak': clean(t['Imsak']),
      'subuh': clean(t['Fajr']),
      'terbit': clean(t['Sunrise']),
      // Aladhan tidak menyediakan Dhuha; equran punya. Pakai terbit + 25m
      // agar quest Dhuha di Home tetap punya jendela waktu.
      'dhuha': _dhuhaFrom(clean(t['Sunrise'])),
      'dzuhur': clean(t['Dhuhr']),
      'ashar': clean(t['Asr']),
      'maghrib': clean(t['Maghrib']),
      'isya': clean(t['Isha']),
    };
  }

  /// Dhuha ≈ 25 menit setelah terbit. ponytail: offset tetap; equran memakai
  /// ~15-25 menit, dan jendela Dhuha memang longgar sampai sebelum dzuhur.
  static String _dhuhaFrom(String terbit) {
    final parts = terbit.split(':');
    if (parts.length != 2) return terbit;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return terbit;
    final total = (h * 60 + m + 25) % (24 * 60);
    return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
  }

  /// Cari kota luar negeri → koordinat, lewat Nominatim (peta yang sama sudah
  /// dipakai reverse-geocode GPS; tanpa API key).
  ///
  /// Kembalian `(id, name)` dengan id = "lat,lon" supaya jalur simpan/cache
  /// tetap satu bentuk dengan mode Indonesia.
  static Future<List<({String id, String name})>> searchAbroadCities(
    String query,
  ) async {
    final q = query.trim();
    if (q.length < 3) return const [];
    try {
      final uri = Uri.parse('$_nominatimBase/search').replace(
        queryParameters: {
          'q': q,
          'format': 'json',
          'limit': '8',
          'addressdetails': '1',
        },
      );
      final req = await _client.getUrl(uri);
      req.headers.set('User-Agent', 'MuslimLeveling/1.1');
      final res = await req.close();
      if (res.statusCode != 200) return const [];
      final body = await res.transform(utf8.decoder).join();
      final list = jsonDecode(body) as List;
      final out = <({String id, String name})>[];
      for (final raw in list) {
        final m = raw as Map<String, dynamic>;
        final lat = m['lat'] as String?;
        final lon = m['lon'] as String?;
        if (lat == null || lon == null) continue;
        final addr = m['address'] as Map<String, dynamic>?;
        // Nama pendek lebih enak dibaca daripada display_name penuh
        // ("Greater London, England, United Kingdom").
        final city =
            (addr?['city'] ?? addr?['town'] ?? addr?['village'] ?? addr?['state'] ?? m['name'])
                as String?;
        final country = addr?['country'] as String?;
        final name = [
          if (city != null && city.isNotEmpty) city,
          if (country != null && country.isNotEmpty) country,
        ].join(', ');
        out.add((id: '$lat,$lon', name: name.isEmpty ? '$city' : name));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  /// cityId mode luar negeri berbentuk "lat,lon".
  static (double, double)? _parseCoords(String id) {
    final parts = id.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0]);
    final lon = double.tryParse(parts[1]);
    if (lat == null || lon == null) return null;
    if (lat.abs() > 90 || lon.abs() > 180) return null;
    return (lat, lon);
  }

  static Future<Map<String, String>?> _fetchEquran({
    required String cityName,
    required DateTime date,
  }) async {
    if (cityName.trim().isEmpty) return null;
    try {
      final prov = await _resolveProvinsi(cityName);
      final kota = normalizeKabkota(cityName);
      final uri = Uri.parse(_equranBase);
      final req = await _client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(
        jsonEncode({
          'provinsi': prov,
          'kabkota': kota,
          'bulan': date.month,
          'tahun': date.year,
        }),
      );
      final res = await req.close();
      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if ((json['code'] as int?) != 200) return null;
      final data = json['data'];
      final list = (data is Map ? data['jadwal'] : data) as List?;
      if (list == null || list.isEmpty) return null;

      final day = date.day;
      Map<String, dynamic>? entry;
      for (final e in list) {
        if ((e['tanggal'] as int?) == day) {
          entry = e as Map<String, dynamic>;
          break;
        }
      }
      entry ??= list.first as Map<String, dynamic>;
      String clean(String v) =>
          (v as String?)?.replaceAll(RegExp(r' \\(WIB\\)'), '') ?? '--:--';
      return {
        'imsak': clean(entry['imsak']),
        'subuh': clean(entry['subuh']),
        'terbit': clean(entry['terbit']),
        'dhuha': clean(entry['dhuha']),
        'dzuhur': clean(entry['dzuhur']),
        'ashar': clean(entry['ashar']),
        'maghrib': clean(entry['maghrib']),
        'isya': clean(entry['isya']),
        'tanggal':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
        'lokasi': cityName,
        'daerah': prov,
      };
    } catch (_) {
      return null;
    }
  }

  /// Find province for [city]. Uses cached result if available.
  /// Tries heuristic first; if that fails, iterates provinces via
  /// Equran's kabkota endpoint until one matches — cached for next time.
  static Future<String> _resolveProvinsi(String city) async {
    final norm = city.toLowerCase().trim();
    if (norm.isEmpty) return 'DKI Jakarta';

    // In-memory cache
    if (_provCache.containsKey(norm)) return _provCache[norm]!;

    // SharedPrefs cache
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('prov_$norm');
    if (cached != null) {
      _provCache[norm] = cached;
      return cached;
    }

    // Try heuristic first (works for "Jakarta, DKI Jakarta" etc.)
    final guess = _extractProvinsi(city);
    if (guess.isNotEmpty && await _cityInProvinsi(guess, city)) {
      _provCache[norm] = guess;
      await prefs.setString('prov_$norm', guess);
      return guess;
    }

    // Jakarta special case: "Jakarta Selatan" (Nominatim) tidak ada di
    // Equran list; harus "Kota Jakarta". Simpan mapping sekali.
    if (norm.contains('jakarta') && !norm.contains('kota jakarta')) {
      _provCache[norm] = 'DKI Jakarta';
      await prefs.setString('prov_$norm', 'DKI Jakarta');
      return 'DKI Jakarta';
    }

    // ponytail: iterate provinces until one matches. Only happens once
    // per unique city, and exits fast for Java (ordered by population).
    final kotaNorm = normalizeKabkota(city).toLowerCase().trim();
    for (final p in _equranProvinsi) {
      if (p == guess) continue;
      if (await _cityInProvinsi(p, kotaNorm)) {
        _provCache[norm] = p;
        await prefs.setString('prov_$norm', p);
        return p;
      }
    }

    // ponytail: fallback
    _provCache[norm] = 'DKI Jakarta';
    await prefs.setString('prov_$norm', 'DKI Jakarta');
    return 'DKI Jakarta';
  }

  /// Daftar kabupaten/kota untuk [province].
  ///
  /// `null` = panggilan gagal (koneksi/timeout), `[]` = provinsi memang tidak
  /// punya entri. Dulu kegagalan transport juga mengembalikan `[]`, jadi user
  /// offline membaca "Kabupaten/kota tidak ditemukan. Coba pilih provinsi lain."
  /// dan mencoba provinsi lain selamanya, padahal masalahnya koneksi.
  static Future<List<String>?> citiesForProvince(String province) async {
    if (province.trim().isEmpty) return const [];
    try {
      final uri = Uri.parse('$_equranBase/kabkota');
      final req = await _discoveryClient.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({'provinsi': province}));
      final res = await req.close();
      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final list = json['data'] as List?;
      return list?.whereType<String>().toList() ?? const [];
    } catch (_) {
      return null;
    }
  }

  /// Check if [city] belongs to [provinsi] via Equran's kabkota list.
  ///
  /// ponytail: `null` (gagal konek) diperlakukan "tidak cocok" — di sini itu
  /// jawaban yang aman karena pemanggilnya iterasi provinsi lain sebagai
  /// fallback. Tanpa `?? false`, null jadi `Null check operator used on a null
  /// value` di `.any()`.
  static Future<bool> _cityInProvinsi(String provinsi, String city) async {
    final q = city.toLowerCase().trim();
    final list = await citiesForProvince(provinsi);
    return list?.any((name) => name.toLowerCase().trim() == q) ?? false;
  }

  /// Normalize city names to the labels accepted by the Equran API.
  @visibleForTesting
  static String normalizeKabkota(String city) {
    // Equran has one city-wide schedule for all Jakarta administrative cities.
    if (city.toLowerCase().contains('jakarta')) return 'Kota Jakarta';

    var s = city;
    for (final p in _equranProvinsi) {
      s = _removeProvName(s, p);
    }
    s = _removeProvName(s, 'DI Yogyakarta');
    s = _removeProvName(s, 'Yogyakarta');
    if (s.trim().isEmpty) s = city;
    // Title case
    return s
        .split(' ')
        .map((w) {
          if (w.isEmpty) return w;
          if (w == w.toUpperCase() && w.length > 2) {
            return w[0].toUpperCase() + w.substring(1).toLowerCase();
          }
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(' ')
        .trim();
  }

  static String _removeProvName(String s, String name) {
    final lc = s.toLowerCase();
    final n = name.toLowerCase();
    int idx;
    while ((idx = lc.indexOf(n)) != -1) {
      // Remove the province name and surrounding separators
      var before = idx > 0 ? s.substring(0, idx) : '';
      var after = s.substring(idx + name.length);
      // Clean up separators
      if (before.endsWith(',') || before.endsWith('-')) {
        before = before.substring(0, before.length - 1);
      }
      if (after.startsWith(',') || after.startsWith('-')) {
        after = after.substring(1);
      }
      s = '$before $after'.trim();
      if (s == before) break; // prevent infinite loop
    }
    return s;
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<Map<String, String>?> _loadCache(
    String cityId,
    String date,
  ) async {
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

  static Future<void> _saveCache(
    String cityId,
    String date,
    Map<String, String> timings,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _cacheKey,
      jsonEncode({'cityId': cityId, 'date': date, 'timings': timings}),
    );
  }

  // --- SharedPreferences helpers ---
  static final ValueNotifier<int> locationVersion = ValueNotifier(0);

  static String _normalizedAreaName(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
    return normalized
        .replaceFirst(RegExp(r'^(kabupaten|kab|kota)\s+'), '')
        .trim();
  }

  static String? _areaType(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
    final match = RegExp(r'^(kabupaten|kab|kota)\s+').firstMatch(normalized);
    if (match == null) return null;
    return match.group(1) == 'kota' ? 'kota' : 'kab';
  }

  static String? prayerAreaFromAddress(
    Map<String, dynamic>? address,
    List<String> validAreas,
  ) {
    // Jakarta special case: Nominatim can put "Jakarta Selatan" etc. in
    // county, city, or municipality. Equran only accepts "Kota Jakarta".
    final isJakarta = const [
      'county',
      'region',
      'state_district',
      'state',
      'city',
      'municipality',
      'town',
      'village',
    ].any((key) {
      final value = address?[key];
      return value is String && value.toLowerCase().contains('jakarta');
    });
    if (isJakarta) {
      for (final area in validAreas) {
        if (area.toLowerCase() == 'kota jakarta') return area;
      }
    }

    for (final key in const [
      'county',
      'region',
      'state_district',
      'city',
      'municipality',
      'town',
    ]) {
      final value = address?[key] as String?;
      if (value == null || value.trim().isEmpty) continue;
      final candidate = _normalizedAreaName(value);
      final matches = validAreas
          .where((area) => _normalizedAreaName(area) == candidate)
          .toList();
      final type = _areaType(value);
      if (type != null) {
        for (final area in matches) {
          if (_areaType(area) == type) return area.trim();
        }
      } else if (matches.length == 1) {
        return matches.single.trim();
      }
    }
    return null;
  }

  static Future<({String? id, String? name, CurrentLocationFailure? failure})>
  getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return (
        id: null,
        name: null,
        failure: CurrentLocationFailure.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return (
        id: null,
        name: null,
        failure: CurrentLocationFailure.permissionDenied,
      );
    }
    if (permission == LocationPermission.deniedForever) {
      return (
        id: null,
        name: null,
        failure: CurrentLocationFailure.permissionDeniedForever,
      );
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      final geoUri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${pos.latitude}&lon=${pos.longitude}'
        '&format=json&accept-language=id',
      );
      final geoReq = await _client.getUrl(geoUri);
      geoReq.headers.set('User-Agent', 'MuslimLeveling/1.0');
      final geoRes = await geoReq.close();
      if (geoRes.statusCode != 200) {
        return (
          id: null,
          name: null,
          failure: CurrentLocationFailure.lookupFailed,
        );
      }
      final geoBody = await geoRes.transform(utf8.decoder).join();
      final geoJson = jsonDecode(geoBody) as Map<String, dynamic>;
      final address = geoJson['address'] as Map<String, dynamic>?;
      final countryCode =
          (address?['country_code'] as String?)?.toLowerCase() ?? '';
      // Luar negeri: tidak ada provinsi/kabkota Indonesia, jadi jalur equran
      // tidak mungkin cocok. Simpan koordinat dan pakai Aladhan.
      if (countryCode.isNotEmpty && countryCode != 'id') {
        final label = [
          (address?['city'] ?? address?['town'] ?? address?['state']),
          address?['country'],
        ].whereType<String>().where((s) => s.isNotEmpty).join(', ');
        final coords = '${pos.latitude},${pos.longitude}';
        final name = label.isEmpty
            ? geoJson['display_name'] as String? ?? ''
            : label;
        await saveLocation(coords, name, abroad: true);
        // id/name dikembalikan terisi: pemanggil memakai `result.id!`, dan
        // null di sini adalah crash — bukan "sudah disimpan di dalam".
        return (id: coords, name: name, failure: null);
      }
      final state = address?['state'] as String? ?? '';
      final province = provinceFromState(state);
      if (province.isEmpty) {
        return (
          id: null,
          name: null,
          failure: CurrentLocationFailure.lookupFailed,
        );
      }

      final validAreas = await citiesForProvince(province);
      // null = koneksi gagal: itu lookupFailed juga, dan pesannya
      // ("periksa koneksi atau pilih kota manual") memang menyarankan begitu.
      final area = validAreas == null
          ? null
          : prayerAreaFromAddress(address, validAreas);
      if (area == null) {
        return (
          id: null,
          name: null,
          failure: CurrentLocationFailure.lookupFailed,
        );
      }

      final areaKey = area.toLowerCase().trim();
      _provCache[areaKey] = province;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('prov_$areaKey', province);
      return (id: area, name: area, failure: null);
    } on TimeoutException {
      return (id: null, name: null, failure: CurrentLocationFailure.timeout);
    } catch (_) {
      return (
        id: null,
        name: null,
        failure: CurrentLocationFailure.lookupFailed,
      );
    }
  }

  /// simpan mode wilayah + lokasi sekaligus. [abroad] null = jangan ubah mode
  /// (dipakai pemanggil lama yang hanya mengganti kota dalam mode yang sama).
  static Future<void> saveLocation(
    String id,
    String name, {
    bool? abroad,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('city_id', id);
    await p.setString('city_name', name);
    if (abroad != null) await p.setBool(_abroadKey, abroad);
    locationVersion.value++;
    // Sync ke GameState supaya ikut cloud backup.
    await GameService.updateLocation(id, name);
  }

  /// ponytail: default Jakarta kalau belum ada lokasi tersimpan.
  /// Equran API pakai "Kota Jakarta" + "DKI Jakarta".
  /// NOTE: tidak menulis default ke prefs — onboarding bertugas resolve
  /// lokasi asli. Caller yang belum onboarding akan tetap dapat default ini.
  static const _defaultId = 'DKI Jakarta/Kota Jakarta';
  static const _defaultName = 'Kota Jakarta';

  static Future<({String id, String name})?> loadLocation() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getString('city_id');
    final name = p.getString('city_name');
    if (id == null || name == null) {
      return (id: _defaultId, name: _defaultName);
    }
    return (id: id, name: name);
  }

  /// Nama kota yang benar-benar dipilih user, atau null kalau belum ada.
  ///
  /// Beda dengan [loadLocation] yang memberi default "Kota Jakarta": di sini
  /// null berarti "belum dijawab" — dipakai onboarding untuk tahu halaman
  /// lokasi masih perlu diisi atau sudah selesai.
  static Future<String?> savedCityName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('city_name');
  }

  /// Legacy alias list for heuristic province extraction.
  /// Order matters: more specific names first to avoid false matches.
  static final _aliasProvinsi = [
    'Kepulauan Bangka Belitung',
    'Kepulauan Riau',
    'Nusa Tenggara Barat',
    'Nusa Tenggara Timur',
    'Kalimantan Barat',
    'Kalimantan Tengah',
    'Kalimantan Selatan',
    'Kalimantan Timur',
    'Kalimantan Utara',
    'Sulawesi Utara',
    'Sulawesi Tengah',
    'Sulawesi Barat',
    'Sulawesi Selatan',
    'Sulawesi Tenggara',
    'Sumatera Utara',
    'Sumatera Barat',
    'Sumatera Selatan',
    'DKI Jakarta',
    'DI Yogyakarta',
    'Jawa Barat',
    'Jawa Tengah',
    'Jawa Timur',
    'Bangka Belitung',
    'Aceh',
    'Bali',
    'Banten',
    'Bengkulu',
    'Gorontalo',
    'Jambi',
    'Lampung',
    'Maluku Utara',
    'Maluku',
    'Papua Barat',
    'Papua',
    'Riau',
    'Yogyakarta',
    'Jakarta',
  ];

  static String _extractProvinsi(String city) {
    final lc = city.toLowerCase();
    for (final p in _aliasProvinsi) {
      if (lc.contains(p.toLowerCase())) {
        if (p == 'Jakarta' || p == 'DKI Jakarta') return 'DKI Jakarta';
        if (p == 'Yogyakarta' || p == 'DI Yogyakarta') return 'D.I. Yogyakarta';
        if (p == 'Bangka Belitung') return 'Kepulauan Bangka Belitung';
        return p;
      }
    }
    return '';
  }

  static String provinceFromState(String state) => _extractProvinsi(state);
}
