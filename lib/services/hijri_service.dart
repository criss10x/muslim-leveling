import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../l10n/hijri_texts.g.dart';

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

/// Nama bulan Hijriah (penulisan Kemenag) index 1..12 ada di ARB, karena harus
/// ikut bahasa aktif — lihat `hijriMonthName(l10n, bulan)` di
/// `lib/l10n/hijri_texts.g.dart`. Index 0 tetap kosong di sana.
///
/// ponytail: `hijriMonthArabic` (aksen judul kartu), `gregorianMonthNames`,
/// dan getter `gregorianLabel` dihapus — semuanya 0 pemanggil. Nama bulan
/// Gregorian di UI sekarang dari `intl` (lihat hari_penting_screen).

/// Tanggal penting statis `(bulan, hari)` → label dibaca dari ARB.
/// Deterministik, tanpa API. Nama-nama momennya hidup di
/// `lib/l10n/app_<locale>.arb` (key `uq_ev_<bulan>_<hari>`) dan diambil lewat
/// `hijriEventLabel(l10n, bulan, hari)` — lihat `lib/l10n/hijri_texts.g.dart`.
const hijriImportantDates = <(int, int)>[
  (1, 1),
  (1, 10),
  (3, 12),
  (7, 27),
  (8, 15),
  (9, 1),
  (9, 17),
  (10, 1),
  (12, 9),
  (12, 10),
];

/// Tanggal Hijriah ringkas: "17 Safar 1448 H" — nama bulan ikut locale aktif.
String hijriLabel(AppL10n l10n, HijriDay d) =>
    hijriDateLabel(l10n, d.hDay, d.hMonth, d.hYear);

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

  /// Konversi 10 tanggal penting Hijri → Gregorian untuk tahun Hijri saat ini.
  /// Cache per tahun Hijri (354 hari, jarang berubah). Fallback: gDate null
  /// kalau API gagal — screen tetap tampilkan tanggal Hijri saja.
  Future<List<ImportantHijriDate>> importantDatesGregorian() async {
    final now = DateTime.now();
    final days = await month(now.year, now.month);
    if (days == null || days.isEmpty) {
      return _fallbackImportantDates(1447);
    }
    final todayEntry = days.firstWhere(
      (d) => d.gDate.day == now.day,
      orElse: () => days.first,
    );
    final hYear = todayEntry.hYear;

    final key = 'hijri_important_$hYear';
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        return list.map(ImportantHijriDate.fromJson).toList();
      } catch (_) {}
    }

    final results = <ImportantHijriDate>[];
    for (final (hMonth, hDay) in hijriImportantDates) {
      DateTime? gDate;
      try {
        final req = await _client.getUrl(Uri.parse(
          'https://api.aladhan.com/v1/hToG/${hDay.toString().padLeft(2, '0')}-${hMonth.toString().padLeft(2, '0')}-$hYear',
        ));
        final res = await req.close();
        if (res.statusCode == 200) {
          final body = await res.transform(utf8.decoder).join();
          final json = jsonDecode(body) as Map<String, dynamic>;
          if (json['code'] == 200) {
            final g = json['data']['gregorian'] as Map<String, dynamic>;
            final dateStr = g['date'] as String; // dd-mm-yyyy
            final parts = dateStr.split('-');
            gDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
      } catch (_) {}
      results.add(ImportantHijriDate(
        hDay: hDay,
        hMonth: hMonth,
        hYear: hYear,
        gDate: gDate,
      ));
    }

    // Sort by Gregorian date (null di akhir).
    results.sort((a, b) {
      if (a.gDate == null && b.gDate == null) return 0;
      if (a.gDate == null) return 1;
      if (b.gDate == null) return -1;
      return a.gDate!.compareTo(b.gDate!);
    });

    try {
      await p.setString(key, jsonEncode(results.map((e) => e.toJson()).toList()));
    } catch (_) {}

    return results;
  }

  /// Fallback kalau tidak bisa dapat Hijri year — tampilkan tanpa Gregorian.
  List<ImportantHijriDate> _fallbackImportantDates(int hYear) {
    return [
      for (final (hMonth, hDay) in hijriImportantDates)
        ImportantHijriDate(
          hDay: hDay,
          hMonth: hMonth,
          hYear: hYear,
          gDate: null,
        ),
    ];
  }
}

/// Model untuk satu tanggal penting Islam.
///
/// Teks tidak disimpan di sini: label momen & nama bulan diambil dari ARB lewat
/// [labelFor] / [statusText] / [hijriLabel] yang butuh [AppL10n]. Yang disimpan
/// adalah kunci (bulan, hari) + tanggalnya.
class ImportantHijriDate {
  final int hDay, hMonth, hYear;
  final DateTime? gDate; // null = API gagal

  const ImportantHijriDate({
    required this.hDay,
    required this.hMonth,
    required this.hYear,
    required this.gDate,
  });

  /// Nama momen (mis. "Idulfitri" / "Eid al-Fitr"); '' kalau tidak terdaftar.
  String labelFor(AppL10n l10n) => hijriEventLabel(l10n, hMonth, hDay) ?? '';

  /// Hari tersisa (negatif = sudah lewat). Null kalau gDate tidak tersedia.
  int? get daysUntil {
    if (gDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return gDate!.difference(today).inDays;
  }

  /// Status badge text.
  String statusText(AppL10n l10n) {
    final d = daysUntil;
    if (d == null) return '—';
    if (d == 0) return l10n.hjToday;
    if (d < 0) return l10n.hjPassed;
    return l10n.hjDaysLeft(d);
  }

  /// Tanggal Hijri formatted: "27 Rajab 1447 H".
  String hijriLabel(AppL10n l10n) =>
      hijriDateLabel(l10n, hDay, hMonth, hYear);

  Map<String, dynamic> toJson() => {
    'hDay': hDay, 'hMonth': hMonth, 'hYear': hYear,
    'gDate': gDate?.toIso8601String(),
  };

  factory ImportantHijriDate.fromJson(Map<String, dynamic> j) =>
    ImportantHijriDate(
      hDay: j['hDay'] as int,
      hMonth: j['hMonth'] as int,
      hYear: j['hYear'] as int,
      gDate: j['gDate'] != null ? DateTime.parse(j['gDate'] as String) : null,
    );
}
