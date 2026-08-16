import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// Kalender Hijriah — konversi Gregorian → Hijriah via aladhan.com,
/// cache disk per bulan Gregorian (offline-proof setelah load pertama).
class HijriDay {
  final DateTime gDate; // tanggal Gregorian
  final int hDay, hMonth, hYear;
  const HijriDay({
    required this.gDate,
    required this.hDay,
    required this.hMonth,
    required this.hYear,
  });
}

/// Nama bulan Hijriah (penulisan Kemenag) index 1..12.
const hijriMonthNames = [
  '',
  'Muharam',
  'Safar',
  'Rabiulawal',
  'Rabiulakhir',
  'Jumadilawal',
  'Jumadilakhir',
  'Rajab',
  'Syaban',
  'Ramadan',
  'Syawal',
  'Zulkaidah',
  'Zulhijah',
];

/// Nama bulan Gregorian dalam Bahasa Indonesia.
const gregorianMonthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Nama bulan Hijriah dalam huruf Arab (aksen judul kartu).
const hijriMonthArabic = [
  '',
  'محرم',
  'صفر',
  'ربيع الأول',
  'ربيع الآخر',
  'جمادى الأولى',
  'جمادى الآخرة',
  'رجب',
  'شعبان',
  'رمضان',
  'شوال',
  'ذو القعدة',
  'ذو الحجة',
];

/// Tanggal penting statis (bulan, hari) → label. Deterministik, tanpa API.
const hijriImportantDates = <(int, int), String>{
  (1, 1): 'Tahun Baru Hijriah',
  (1, 10): 'Hari Asyura',
  (3, 12): 'Maulid Nabi',
  (7, 27): 'Isra Mikraj',
  (8, 15): 'Nisfu Syaban',
  (9, 1): 'Awal Ramadan',
  (9, 17): 'Nuzulul Quran',
  (10, 1): 'Idulfitri',
  (12, 9): 'Hari Arafah',
  (12, 10): 'Iduladha',
};

String hijriLabel(HijriDay d) =>
    '${d.hDay} ${hijriMonthNames[d.hMonth]} ${d.hYear} H';

final hijriService = HijriService();

class HijriService {
  static final _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);

  /// Semua hari dalam satu bulan Gregorian → HijriDay. Cache per bulan.
  /// ponytail: endpoint aladhan memakai urutan path {bulan}/{tahun} —
  /// {tahun}/{bulan} diam-diam mengembalikan data yang salah/statis.
  Future<List<HijriDay>?> month(int year, int month) async {
    // Key v2: cache lama (key v1) berisi data racun dari endpoint terbalik.
    final key = 'hijri_g2h2_${year}_$month';
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List).cast<List<dynamic>>();
        return list
            .map((e) => HijriDay(
                  gDate: DateTime(year, month, e[0] as int),
                  hDay: e[1] as int,
                  hMonth: e[2] as int,
                  hYear: e[3] as int,
                ))
            .toList();
      } catch (_) {}
    }
    try {
      final req = await _client.getUrl(Uri.parse(
        'https://api.aladhan.com/v1/gToHCalendar/$month/$year',
      ));
      final res = await req.close();
      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['code'] != 200) return null;
      final days = <HijriDay>[];
      final cacheRows = <List<dynamic>>[];
      for (final e in (json['data'] as List)) {
        final g = (e['gregorian'] as Map<String, dynamic>)['day'];
        final h = e['hijri'] as Map<String, dynamic>;
        final d = HijriDay(
          gDate: DateTime(year, month, int.parse(g as String)),
          hDay: int.parse(h['day'] as String),
          hMonth: (h['month'] as Map<String, dynamic>)['number'] as int,
          hYear: int.parse(h['year'] as String),
        );
        days.add(d);
        cacheRows.add([d.gDate.day, d.hDay, d.hMonth, d.hYear]);
      }
      try {
        await p.setString(key, jsonEncode(cacheRows));
      } catch (_) {}
      return days;
    } catch (_) {
      return null;
    }
  }

  /// Tanggal Hijriah hari ini (untuk strip label).
  Future<HijriDay?> today() async {
    final now = DateTime.now();
    final days = await month(now.year, now.month);
    if (days == null) return null;
    for (final d in days) {
      if (d.gDate.day == now.day) return d;
    }
    return null;
  }
}
