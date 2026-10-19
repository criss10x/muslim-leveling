# Android Home Widget: Jam + Sholat + Quest Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Widget home screen 4x2 yang menampilkan jam, sholat sekarang + sholat berikutnya, dua quest teratas (sekarang & berikutnya) dengan progress dan status, yang bila di-tap membuka app langsung ke daftar quest.

**Architecture:** Flutter menulis **snapshot siap-tampil** (sudah terlokalisasi, sudah terhitung) ke SharedPreferences; Kotlin hanya membaca snapshot itu dan menggambarnya dengan RemoteViews. Kotlin tidak pernah menyentuh `game_state_v1` dan tidak pernah menghitung XP. Tap pada widget = PendingIntent ke deep link `id.muslimleveling.muslim_leveling://quests`, bukan aksi tulis.

**Tech Stack:** Flutter 3.x (Dart), Android App Widget (RemoteViews + AppWidgetProvider), MethodChannel, SharedPreferences (dipakai bersama Dart & Kotlin), `flutter_test`.

## Global Constraints

- **Nol dependency baru.** `shared_preferences` sudah ada; `MainActivity.kt` sudah ada. Jangan tambah `home_widget` atau `workmanager`.
- **Kotlin tidak boleh menulis state permainan.** Satu-satunya penulis `game_state_v1` adalah `GameService._save()`. Widget read-only.
- **Snapshot ditulis dari satu pintu**: `WidgetSnapshot.push()`, dipanggil dari `GameService._save()`, setelah `GameService.load()`, dan saat app `resumed`.
- **Tidak ada emoji di widget** (craft floor). Status pakai warna + teks.
- **Tidak ada em dash (U+2014)** di copy mana pun.
- **Waktu sholat di widget harus berasal dari 7 hari ke depan**, bukan `GameState.timings` saja — cache `prayer_cache_v2` hanya menyimpan SATU hari dan ditimpa tiap fetch, jadi tidak bisa dipakai lintas hari.
- **Data basi tidak boleh ditampilkan sebagai fakta.** Kalau snapshot bukan untuk tanggal hari ini, widget menampilkan ajakan membuka app, bukan angka kemarin.
- Semua string Kotlin hanya dari snapshot. Tidak ada teks Indonesia hardcoded di Kotlin.
- `flutter analyze` harus "No issues found!" dan seluruh `flutter test` hijau sebelum commit.

## Konteks yang sudah diverifikasi

- 5 quest/hari, rotasi deterministik: `pool.shuffle(Random(todayStr().hashCode))` lalu `take(5)` (`game_service.dart:1760`). Seed = tanggal batas 03:00 (`dailyDateKey`, `game_service.dart:775`).
- Quest **selesai otomatis** dari aksi nyata (`_reevaluateQuests`); yang manual hanya **claim** (`claimQuest`, `game_service.dart:1518`).
- `_save()` (`game_service.dart:619`) adalah satu-satunya penulis `game_state_v1`; sudah memanggil `CloudSync.saveGame` fire-and-forget.
- `Quest.localizedDesc(AppL10n)` (`game_service.dart:277`) → teks quest hidup di ARB (`quest_texts.g.dart`), tersedia 4 bahasa. **Tidak ada emoji** di deskripsi ARB (sudah dicek).
- Teks jam sholat: `GameService.currentPrayerInfo` (`:1052`) dan `nextPrayerInfo` (`:2353`). `nextPrayerInfo` sudah mengembalikan record dan memakai ARB (`jdCountdown*`).
- Jadwal: `PrayerService.fetchSchedule({cityId, date, cityName})` (`prayer_service.dart:110`) **menerima `date`** → bisa mengambil hari mana pun. Cache internal (`_saveCache`, `:573`) hanya menampung **satu** tanggal, jadi jangan andalkan cache untuk rentang.
- Lokasi: `PrayerService.loadLocation()` (`:797`) → `({id, name})`; `isAbroad()` (`:191`) untuk cabang Aladhan.
- `MainActivity.kt` sudah punya pola registrasi channel (`ShareUtil`, `AdzanSoundBridge`) → ikuti pola yang sama.
- `main.dart` memanggil `GameService.load()` di `:91` sebelum UI.
- `SplashScreen` → `DashboardShell` (`initialTab`, `dashboard_shell.dart:17`). **Tidak ada `navigatorKey`** di `MaterialApp` → harus ditambahkan untuk navigasi dari channel.
- `minSdk` efektif **24** (dari merged manifest AAB), `compileSdk 36`, Java 17. `<TextClock>` butuh API 17 → aman.
- Android prefs yang ditulis `shared_preferences` ada di file **`<packageName>_preferences`** dengan prefix `flutter.` pada nama kunci. Kotlin harus membaca file dan prefix yang sama persis, atau widget akan selalu kosong.

## Desain keputusan (jangan diubah tanpa alasan)

1. **Snapshot, bukan parse.** Kotlin tidak bisa `AppL10n.of(context)`. Flutter yang menerjemahkan; Kotlin menampilkan string jadi.
2. **Quest "sekarang"** = quest yang bisa di-claim lebih dulu (`completed && !claimed`), lalu yang progress-nya paling dekat selesai. **Quest "berikutnya"** = kandidat urutan kedua. Yang sudah `claimed` tidak pernah muncul.
3. **Sholat "sekarang"** = interval wajib yang sedang berjalan (Subuh→Dzuhur→Ashar→Maghrib→Isya, Isya membungkus lewat tengah malam). **Dhuha sengaja tidak ditampilkan** di widget: menambah cabang waktu yang tidak sepadan untuk 4x2.
4. **Jam pakai `<TextClock>`** — Android menggambar sendiri tiap menit, nol biaya update.
5. **Pergantian sholat dijadwalkan sendiri oleh widget** lewat `AlarmManager` pada batas waktu berikutnya. `updatePeriodMillis` tidak dipakai (minimum 30 menit = label bisa salah sampai setengah jam).
6. **Tanggal tidak cocok → jangan tampilkan angka lama.** Widget menulis "Buka app untuk perbarui" daripada menampilkan jadwal kemarin.

---

## Task 1: Payload snapshot + pemilih quest

**Objective:** Satu kelas Dart yang mengubah `GameState` + `Timings` menjadi JSON siap-tampil, dengan aturan pemilihan 2 quest yang bisa diuji.

**Files:**
- Create: `lib/services/widget_snapshot.dart`
- Test: `test/widget_snapshot_test.dart`

**Step 1: Tulis tes yang gagal**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/l10n/app_localizations.dart';
import 'package:muslim_leveling/services/game_service.dart';
import 'package:muslim_leveling/services/widget_snapshot.dart';

Quest _q(String id, {int progress = 0, int target = 1,
        bool completed = false, bool claimed = false}) =>
    Quest(id: id, desc: 'fallback $id', xpReward: 50, target: target,
        progress: progress, completed: completed, claimed: claimed);

void main() {
  final l10n = lookupAppL10n(const Locale('id'));

  test('quest yang bisa di-claim tampil lebih dulu', () {
    final picks = WidgetSnapshot.pickQuests([
      _q('a', progress: 0, target: 3),
      _q('b', progress: 1, target: 1, completed: true),
      _q('c', progress: 2, target: 3),
      _q('d', progress: 0, target: 1),
    ], l10n);
    expect(picks.map((e) => e['id']), ['b', 'c']);
  });

  test('quest claimed tidak pernah muncul', () {
    final picks = WidgetSnapshot.pickQuests([
      _q('a', completed: true, claimed: true),
      _q('b', progress: 1, target: 2),
    ], l10n);
    expect(picks.map((e) => e['id']), ['b']);
  });

  test('semua sudah di-claim menghasilkan daftar kosong', () {
    final picks = WidgetSnapshot.pickQuests([
      _q('a', completed: true, claimed: true),
      _q('b', completed: true, claimed: true),
    ], l10n);
    expect(picks, isEmpty);
  });

  test('deskripsi memakai bahasa aktif, bukan desc tersimpan', () {
    final picks = WidgetSnapshot.pickQuests([
      _q('quest_five_rings', progress: 1, target: 1),
    ], lookupAppL10n(const Locale('en')));
    expect(picks.first['desc'], contains('5/5'));
    expect(picks.first['desc'], isNot(contains('fallback')));
  });

  test('payload memuat 5 sholat dan tanggal', () {
    final s = WidgetSnapshot.build(
      timings: Timings(),
      quests: [_q('a', progress: 1, target: 2)],
      l10n: l10n,
      now: DateTime(2026, 10, 19, 9, 30),
    );
    expect(s['today'], '2026-10-19');
    expect((s['prayers'] as List).length, 5);
    expect(s['quests'], isNotEmpty);
  });
}
```

**Step 2: Jalankan, pastikan gagal**

Run: `flutter test test/widget_snapshot_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:muslim_leveling/services/widget_snapshot.dart'`

**Step 3: Implementasi minimal**

```dart
import 'dart:convert';

import '../l10n/app_localizations.dart';
import 'game_service.dart';

/// Snapshot siap-tampil untuk home screen widget Android.
///
/// Kotlin TIDAK mem-parsing `game_state_v1`: ia membaca JSON ini apa adanya.
/// Alasannya: teks quest hidup di ARB (4 bahasa) dan tidak bisa diterjemahkan
/// dari sisi native. Semua keputusan yang butuh konteks Flutter selesai di sini.
class WidgetSnapshot {
  static const prefKey = 'widget_snapshot_v1';
  static const channelName = 'ml/widget';

  /// Urutan tampil quest: yang bisa di-claim dulu, lalu yang paling dekat
  /// selesai. `claimed` tidak pernah masuk. Maksimal 2 (sekarang + berikutnya).
  static List<Map<String, dynamic>> pickQuests(
    List<Quest> quests,
    AppL10n l10n, {
    int limit = 2,
  }) {
    final alive = quests.where((q) => !q.claimed).toList()
      ..sort((a, b) {
        if (a.completed != b.completed) return a.completed ? -1 : 1;
        if (a.completed && b.completed) return b.xpReward.compareTo(a.xpReward);
        final ar = a.target == 0 ? 0.0 : a.progress / a.target;
        final br = b.target == 0 ? 0.0 : b.progress / b.target;
        return br.compareTo(ar);
      });
    return alive.take(limit).map((q) => {
          'id': q.id,
          'desc': q.localizedDesc(l10n),
          'progress': q.progress,
          'target': q.target,
          'xp': q.xpReward,
          'completed': q.completed,
          'claimed': q.claimed,
        }).toList();
  }

  /// Lima sholat wajib. Dhuha sengaja tidak ada: menambah cabang waktu yang
  /// tidak sepadan untuk widget 4x2, dan bukan kewajiban.
  static List<Map<String, String>> prayersOf(Timings t, AppL10n l10n) => [
        {'key': 'subuh', 'label': l10n.prayerSubuh, 'time': t.subuh},
        {'key': 'dzuhur', 'label': l10n.prayerDzuhur, 'time': t.dzuhur},
        {'key': 'ashar', 'label': l10n.prayerAshar, 'time': t.ashar},
        {'key': 'maghrib', 'label': l10n.prayerMaghrib, 'time': t.maghrib},
        {'key': 'isya', 'label': l10n.prayerIsya, 'time': t.isya},
      ];

  static Map<String, dynamic> build({
    required Timings timings,
    required List<Quest> quests,
    required AppL10n l10n,
    required DateTime now,
    Map<String, List<Map<String, String>>>? week,
  }) {
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return {
      'v': 1,
      'today': today,
      'prayers': prayersOf(timings, l10n),
      'days': week ?? {today: prayersOf(timings, l10n)},
      'quests': pickQuests(quests, l10n),
    };
  }
}
```

**Step 4: Jalankan sampai hijau**

Run: `flutter test test/widget_snapshot_test.dart`
Expected: PASS (5 tests)

**Step 5: Commit**

```bash
git add lib/services/widget_snapshot.dart test/widget_snapshot_test.dart
git commit -m "feat(widget): payload snapshot siap-tampil + pemilih quest"
```

---

## Task 2: Push snapshot ke prefs + channel

**Objective:** Snapshot ditulis ke SharedPreferences dan widget diminta refresh, dari satu fungsi.

**Files:**
- Modify: `lib/services/widget_snapshot.dart`
- Test: `test/widget_snapshot_push_test.dart`

**Step 1: Tes channel (palsukan MethodChannel)**

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslim_leveling/services/widget_snapshot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(WidgetSnapshot.channelName),
      (call) async {
        calls.add(call);
        return null;
      },
    );
  });

  test('payload tersimpan di prefs dan channel dipanggil sekali', () async {
    await WidgetSnapshot.pushRaw({'today': '2026-10-19', 'quests': []});
    final p = await SharedPreferences.getInstance();
    expect(p.getString(WidgetSnapshot.prefKey), contains('2026-10-19'));
    expect(calls.single.method, 'refresh');
  });

  test('gagal channel tidak melempar (widget bukan jalur kritis)', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(WidgetSnapshot.channelName),
      (call) async => throw PlatformException(code: 'x'),
    );
    await expectLater(
        WidgetSnapshot.pushRaw({'today': '2026-10-19'}), completes);
  });
}
```

**Step 2: Jalankan, pastikan gagal**

Run: `flutter test test/widget_snapshot_push_test.dart`
Expected: FAIL — `pushRaw` belum ada

**Step 3: Implementasi**

Tambahkan ke `widget_snapshot.dart`:

```dart
  static const _channel = MethodChannel(channelName);

  /// Tulis snapshot lalu minta widget menggambar ulang.
  ///
  /// Tidak pernah melempar: widget adalah fitur tambahan, kegagalannya tidak
  /// boleh membatalkan penyimpanan game.
  static Future<void> pushRaw(Map<String, dynamic> payload) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(prefKey, jsonEncode(payload));
    } catch (_) {
      return;
    }
    try {
      await _channel.invokeMethod('refresh');
    } catch (_) {
      // iOS / unit test / channel belum terdaftar: abaikan.
    }
  }
```

Tambah import `package:flutter/services.dart`.

**Step 4: Jalankan sampai hijau**

Run: `flutter test test/widget_snapshot_push_test.dart`
Expected: PASS (2 tests)

**Step 5: Commit**

```bash
git add lib/services/widget_snapshot.dart test/widget_snapshot_push_test.dart
git commit -m "feat(widget): tulis snapshot ke prefs + panggil refresh channel"
```

---

## Task 3: Jendela 7 hari waktu sholat

**Objective:** Widget tetap benar walau app tidak dibuka berhari-hari.

**Files:**
- Modify: `lib/services/prayer_service.dart` (tambah `fetchWeek`, setelah `fetchSchedule`)
- Test: `test/prayer_week_test.dart`

**Step 1: Tes dengan HTTP dipalsukan**

Tes ini menguji **pemetaan tanggal → timings**, bukan jaringan. Karena `_fetchEquran` memakai `HttpClient` statis, tes cukup menguji helper murni yang menyusun rentang tanggal:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/prayer_service.dart';

void main() {
  test('rentang 7 hari mulai hari ini, format tanggal konsisten', () {
    final days = PrayerService.weekDates(DateTime(2026, 10, 19));
    expect(days.length, 7);
    expect(days.first, '2026-10-19');
    expect(days.last, '2026-10-25');
  });

  test('melewati batas bulan dan tahun', () {
    final days = PrayerService.weekDates(DateTime(2026, 12, 30));
    expect(days, ['2026-12-30', '2026-12-31', '2027-01-01', '2027-01-02',
                  '2027-01-03', '2027-01-04', '2027-01-05']);
  });
}
```

**Step 2: Jalankan, pastikan gagal**

Run: `flutter test test/prayer_week_test.dart`
Expected: FAIL — `weekDates` belum ada

**Step 3: Implementasi**

Di `prayer_service.dart`, tepat setelah `fetchSchedule`:

```dart
  /// Kunci tanggal untuk snapshot widget (sama bentuknya dengan [_dateKey]).
  static String dateKey(DateTime d) => _dateKey(d);

  /// Tujuh tanggal mulai [from] (inklusif), sebagai kunci `yyyy-MM-dd`.
  static List<String> weekDates(DateTime from, {int days = 7}) => [
        for (var i = 0; i < days; i++)
          _dateKey(DateTime(from.year, from.month, from.day + i)),
      ];

  /// Jadwal [days] hari ke depan untuk widget.
  ///
  /// [fetchSchedule] menyimpan cache hanya untuk SATU tanggal, jadi loop ini
  /// sengaja memanggilnya per hari; nilai yang dikembalikan dikumpulkan di sini.
  /// Hari yang gagal diambil dilewati, bukan disimpan sebagai nilai palsu.
  static Future<Map<String, Map<String, String>>> fetchWeek({
    required String cityId,
    String? cityName,
    DateTime? from,
    int days = 7,
  }) async {
    final start = from ?? DateTime.now();
    final out = <String, Map<String, String>>{};
    for (var i = 0; i < days; i++) {
      final d = DateTime(start.year, start.month, start.day + i);
      final t = await fetchSchedule(cityId: cityId, date: d, cityName: cityName);
      if (t != null) out[_dateKey(d)] = t;
    }
    return out;
  }
```

**Step 4: Jalankan sampai hijau**

Run: `flutter test test/prayer_week_test.dart`
Expected: PASS (2 tests)

**Step 5: Commit**

```bash
git add lib/services/prayer_service.dart test/prayer_week_test.dart
git commit -m "feat(widget): jadwal sholat 7 hari untuk snapshot widget"
```

---

## Task 4: Sambungkan ke siklus hidup app

**Objective:** Snapshot segar setiap kali state berubah, app dibuka, dan app kembali ke depan. Jangan fetch 7 hari lebih dari sekali sehari.

**Files:**
- Modify: `lib/services/game_service.dart` (`_save`, ~:619)
- Modify: `lib/main.dart` (setelah `GameService.load()`, ~:91)
- Create: `lib/services/widget_sync.dart`
- Test: `test/widget_sync_test.dart`

**Step 1: Tes guard harian**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/widget_sync.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('fetch jadwal hanya sekali per hari', () async {
    var fetches = 0;
    Future<int> fakeFetch() async => ++fetches;

    await WidgetSync.ensureWeek(fetch: fakeFetch, today: '2026-10-19');
    await WidgetSync.ensureWeek(fetch: fakeFetch, today: '2026-10-19');
    expect(fetches, 1);

    await WidgetSync.ensureWeek(fetch: fakeFetch, today: '2026-10-20');
    expect(fetches, 2);
  });
}
```

**Step 2: Jalankan, pastikan gagal**

Run: `flutter test test/widget_sync_test.dart`
Expected: FAIL — file belum ada

**Step 3: Implementasi `lib/services/widget_sync.dart`**

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// Orkestrasi snapshot widget. Dipisah dari [WidgetSnapshot] supaya bisa
/// diuji tanpa Android dan tanpa jaringan.
class WidgetSync {
  static const weekStampKey = 'widget_week_fetched_on';

  /// Panggil [fetch] hanya kalau [today] berbeda dari hari terakhir fetch.
  /// Hasil fetch dibiarkan ke pemanggil (yang menyusun payload).
  ///
  /// Tidak pernah melempar: kegagalan fetch jadwal tidak boleh mengganggu app.
  static Future<void> ensureWeek({
    required Future<int> Function() fetch,
    required String today,
  }) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getString(weekStampKey) == today) return;
      await fetch();
      await p.setString(weekStampKey, today);
    } catch (_) {
      // diam: snapshot akan memakai jadwal hari ini yang sudah ada
    }
  }
}
```

**Step 4: Panggil dari `_save`**

Di `game_service.dart`, di dalam `_save` setelah `stateVersion.value++`:

```dart
    // Widget home screen: tulis snapshot siap-tampil. Fire-and-forget —
    // kegagalan widget tidak boleh menggagalkan penyimpanan game.
    unawaited(WidgetSnapshot.push(_snapshotPayload(s)));
```

Tambahkan ke `GameService`:

```dart
  /// Payload widget dari state saat ini. Memakai bahasa aktif & jadwal yang
  /// sudah tersimpan; jadwal 7 hari diisi [WidgetSync] saat startup.
  static Map<String, dynamic> _snapshotPayload(GameState s,
      {Map<String, List<Map<String, String>>>? week}) {
    // `effectiveLocale` = pilihan user atau hasil resolusi locale HP, algoritma
    // yang sama dengan MaterialApp. Global, jadi aman dipanggil tanpa context.
    final l10n = lookupAppL10n(localeNotifier.effectiveLocale);
    return WidgetSnapshot.build(
      timings: s.timings,
      quests: s.quests,
      l10n: l10n,
      now: DateTime.now(),
      week: week,
    );
  }
```

**Catatan locale (SUDAH DIVERIFIKASI):** `localeNotifier` adalah instance global
di `lib/services/locale_service.dart:105`, dan `LocaleNotifier.effectiveLocale`
(`:53-58`) memakai `basicLocaleListResolution` yang sama dengan `MaterialApp`.
Import `services/locale_service.dart` di `game_service.dart` dan pakai itu.
**Jangan** mengarang `SettingsLocale.current`; jangan memakai `Localizations.localeOf`
karena `_save` tidak punya `BuildContext`.

**Step 5: Panggil saat startup**

Di `main.dart` setelah `GameService.load()`:

```dart
    // Widget: jadwal 7 hari (sekali sehari) lalu snapshot pertama.
    unawaited(WidgetSync.ensureWeek(
      fetch: () async { /* lihat Step 6 */ return 0; },
      today: GameService.todayStr(),
    ));
    unawaited(GameService.refreshWidget());
```

**Step 6: Isi fetch jadwal**

```dart
  static Future<int> fetchWeekForWidget() async {
    final loc = await PrayerService.loadLocation();
    if (loc == null) return 0;
    final week = await PrayerService.fetchWeek(
      cityId: loc.id,
      cityName: loc.name,
    );
    if (week.isEmpty) return 0;
    _widgetWeek = {
      for (final e in week.entries)
        e.key: WidgetSnapshot.prayersFromTimings(Timings.fromMap(e.value), _l10n),
    };
    await refreshWidget();
    return week.length;
  }
```

`WidgetSnapshot.prayersFromTimings` = alias tipis `prayersOf`. Simpan `_widgetWeek` sebagai field statis di `GameService` dan teruskan ke `_snapshotPayload`.

**Step 7: Jalankan tes + analyze**

Run: `flutter test test/widget_sync_test.dart && flutter analyze lib/`
Expected: PASS, "No issues found!"

**Step 8: Commit**

```bash
git add lib/services/widget_sync.dart lib/services/game_service.dart lib/main.dart test/widget_sync_test.dart
git commit -m "feat(widget): sinkronkan snapshot saat save, startup, dan resume"
```

---

## Task 5: Provider Kotlin

**Objective:** Membaca snapshot dan menggambar widget. Nol logika permainan.

**Files:**
- Create: `android/app/src/main/kotlin/id/muslimleveling/muslim_leveling/QuestWidgetProvider.kt`
- Modify: `android/app/src/main/kotlin/id/muslimleveling/muslim_leveling/MainActivity.kt`

**Step 1: Tulis provider**

```kotlin
package id.muslimleveling.muslim_leveling

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * Widget home screen: jam, sholat sekarang + berikutnya, dua quest teratas.
 *
 * TIDAK menghitung XP dan TIDAK menulis `game_state_v1`. Semua teks sudah
 * diterjemahkan Flutter dan datang lewat snapshot `widget_snapshot_v1`.
 */
class QuestWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray,
    ) {
        ids.forEach { id -> manager.updateAppWidget(id, buildViews(context)) }
        scheduleNextBoundary(context)
    }

    /** Dipanggil dari MainActivity saat Flutter minta refresh. */
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_REFRESH) {
            updateAll(context)
        }
    }

    companion object {
        const val ACTION_REFRESH = "id.muslimleveling.muslim_leveling.WIDGET_REFRESH"
        private const val PREFS_SUFFIX = "_preferences"
        private const val SNAPSHOT_KEY = "flutter.widget_snapshot_v1"
        private const val PREF_ALARM_KEY = "widget_next_boundary"

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, QuestWidgetProvider::class.java)
            )
            ids.forEach { id -> manager.updateAppWidget(id, buildViews(context)) }
            scheduleNextBoundary(context)
        }

        private fun prefs(context: Context) =
            context.getSharedPreferences(
                context.packageName + PREFS_SUFFIX,
                Context.MODE_PRIVATE,
            )

        private fun buildViews(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.quest_widget)
            val raw = prefs(context).getString(SNAPSHOT_KEY, null)

            val openApp = PendingIntent.getActivity(
                context, 0,
                Intent(context, MainActivity::class.java).apply {
                    data = Uri.parse("id.muslimleveling.muslim_leveling://quests")
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, openApp)

            if (raw == null) {
                views.setTextViewText(R.id.prayer_now, "—")
                views.setTextViewText(R.id.prayer_next, "Buka app sekali untuk mengaktifkan")
                views.setTextViewText(R.id.quest_now, "Belum ada data quest")
                views.setTextViewText(R.id.quest_next, "")
                return views
            }

            val snap = runCatching { JSONObject(raw) }.getOrNull()
            if (snap == null) return views

            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(java.util.Date())
            val days = snap.optJSONObject("days")
            val dayKey = if (days?.has(today) == true) today else null

            if (dayKey == null) {
                // Snapshot bukan untuk hari ini: tampilkan ajakan, JANGAN angka
                // kemarin — jam sholat yang salah lebih buruk daripada kosong.
                views.setTextViewText(R.id.prayer_now, "Buka app untuk memperbarui")
                views.setTextViewText(R.id.prayer_next, "")
            } else {
                val list = days.getJSONArray(dayKey)
                val now = SimpleDateFormat("HH:mm", Locale.US)
                    .format(java.util.Date())
                val (current, next) = currentAndNext(list, now)
                views.setTextViewText(
                    R.id.prayer_now,
                    if (current == null) "—" else "${current.first} ${current.second}",
                )
                views.setTextViewText(
                    R.id.prayer_next,
                    if (next == null) "" else "Berikutnya ${next.first} ${next.second}",
                )
            }

            val quests = snap.optJSONArray("quests")
            if (quests == null || quests.length() == 0) {
                views.setTextViewText(R.id.quest_now, "Semua quest hari ini selesai")
                views.setTextViewText(R.id.quest_next, "")
            } else {
                val q0 = quests.getJSONObject(0)
                views.setTextViewText(R.id.quest_now, questLine(q0))
                views.setTextViewText(R.id.quest_status, statusOf(q0))
                views.setTextViewText(
                    R.id.quest_next,
                    if (quests.length() > 1) questLine(quests.getJSONObject(1)) else "",
                )
            }
            return views
        }

        private fun questLine(q: JSONObject): String {
            val desc = q.optString("desc")
            val target = q.optInt("target", 1)
            val progress = q.optInt("progress", 0)
            return if (target > 1) "$desc  $progress/$target" else desc
        }

        private fun statusOf(q: JSONObject): String = when {
            q.optBoolean("completed") && !q.optBoolean("claimed") -> "+${q.optInt("xp")} XP"
            else -> ""
        }

        /**
         * Sholat yang sedang berjalan dan berikutnya.
         *
         * Cermin dari GameService.currentPrayerInfo/nextPrayerInfo untuk lima
         * sholat wajib. Isya membungkus lewat tengah malam. Dhuha tidak
         * ditampilkan (lihat rencana, keputusan 3).
         */
        private fun currentAndNext(
            list: org.json.JSONArray,
            now: String,
        ): Pair<Pair<String, String>?, Pair<String, String>?> {
            val items = (0 until list.length()).map {
                val o = list.getJSONObject(it)
                Triple(o.getString("key"), o.getString("label"), o.getString("time"))
            }
            var next: Triple<String, String, String>? = null
            for (i in items.indices) {
                if (items[i].third > now) { next = items[i]; break }
            }
            val nextPair = next?.let { it.second to it.third }
            if (next == null) {
                // Lewat Isya: yang aktif Isya, berikutnya Subuh besok.
                val isya = items.lastOrNull()
                return (isya?.let { it.second to it.third }) to null
            }
            val idx = items.indexOf(next)
            val current = if (idx == 0) items.lastOrNull() else items[idx - 1]
            return (current?.let { it.second to it.third }) to nextPair
        }

        /** Bangunkan widget tepat saat batas sholat berikutnya, bukan tiap 30 menit. */
        private fun scheduleNextBoundary(context: Context) {
            val raw = prefs(context).getString(SNAPSHOT_KEY, null) ?: return
            val snap = runCatching { JSONObject(raw) }.getOrNull() ?: return
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(java.util.Date())
            val days = snap.optJSONObject("days") ?: return
            val list = days.optJSONArray(today) ?: return

            val nowMs = System.currentTimeMillis()
            var best: Long? = null
            for (i in 0 until list.length()) {
                val o = list.getJSONObject(i)
                val parts = o.getString("time").split(":")
                val cal = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, parts[0].toInt())
                    set(Calendar.MINUTE, parts[1].toInt())
                    set(Calendar.SECOND, 5)
                }
                val at = cal.timeInMillis
                if (at > nowMs && (best == null || at < best!!)) best = at
            }
            val target = best ?: return
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val pi = PendingIntent.getBroadcast(
                context, 0,
                Intent(context, QuestWidgetProvider::class.java)
                    .setAction(ACTION_REFRESH),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    am.setExactAndAllowWhileIdle(AlarmManager.RTC, target, pi)
                } else {
                    am.setExact(AlarmManager.RTC, target, pi)
                }
            } catch (_: SecurityException) {
                // Exact alarm ditolak user: pakai inexact, label bisa telat
                // beberapa menit. Lebih baik daripada tidak pernah update.
                am.set(AlarmManager.RTC, target, pi)
            }
            prefs(context).edit().putLong(PREF_ALARM_KEY, target).apply()
        }
    }
}
```

**Step 2: Daftarkan channel di `MainActivity`**

```kotlin
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ml/widget")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "refresh" -> {
                        QuestWidgetProvider.updateAll(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
```

Tambah import `io.flutter.plugin.common.MethodChannel`.

**Step 3: Commit**

```bash
git add android/app/src/main/kotlin/id/muslimleveling/muslim_leveling/
git commit -m "feat(widget): provider RemoteViews + channel refresh"
```

---

## Task 6: Layout + metadata + manifest

**Objective:** Widget bisa dipasang dari launcher.

**Files:**
- Create: `android/app/src/main/res/layout/quest_widget.xml`
- Create: `android/app/src/main/res/xml/quest_widget_info.xml`
- Create: `android/app/src/main/res/values/widget_strings.xml`
- Modify: `android/app/src/main/AndroidManifest.xml`

**Step 1: Layout 4x2** (teks saja, tanpa emoji)

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/widget_root"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="12dp"
    android:background="@drawable/widget_bg">

    <TextClock
        android:id="@+id/clock"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:format12Hour="hh:mm"
        android:format24Hour="HH:mm"
        android:textColor="#FFFFFF"
        android:textSize="28sp"
        android:textStyle="bold" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:layout_marginTop="2dp">

        <TextView
            android:id="@+id/prayer_now"
            android:layout_width="0dp"
            android:layout_weight="1"
            android:layout_height="wrap_content"
            android:textColor="#F97316"
            android:textSize="13sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/prayer_next"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="#B3FFFFFF"
            android:textSize="12sp" />
    </LinearLayout>

    <View
        android:layout_width="match_parent"
        android:layout_height="1dp"
        android:layout_marginTop="6dp"
        android:layout_marginBottom="6dp"
        android:background="#33FFFFFF" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal">

        <TextView
            android:id="@+id/quest_now"
            android:layout_width="0dp"
            android:layout_weight="1"
            android:layout_height="wrap_content"
            android:maxLines="1"
            android:ellipsize="end"
            android:textColor="#FFFFFF"
            android:textSize="12sp" />

        <TextView
            android:id="@+id/quest_status"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textColor="#F97316"
            android:textSize="12sp"
            android:textStyle="bold" />
    </LinearLayout>

    <TextView
        android:id="@+id/quest_next"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:maxLines="1"
        android:ellipsize="end"
        android:textColor="#80FFFFFF"
        android:textSize="11sp" />
</LinearLayout>
```

**Step 2: Background drawable** — `android/app/src/main/res/drawable/widget_bg.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#0A0A0C" />
    <corners android:radius="20dp" />
</shape>
```

**Step 3: Metadata widget**

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="110dp"
    android:targetCellWidth="4"
    android:targetCellHeight="2"
    android:updatePeriodMillis="0"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:initialLayout="@layout/quest_widget"
    android:description="@string/widget_description" />
```

`updatePeriodMillis="0"` disengaja: refresh datang dari Flutter (channel) dan dari alarm batas sholat. Nol = tidak ada bangun periodik yang boros.

**Step 4: Daftarkan receiver di `AndroidManifest.xml`** (di dalam `<application>`)

```xml
        <receiver
            android:name=".QuestWidgetProvider"
            android:exported="false">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
                <action android:name="id.muslimleveling.muslim_leveling.WIDGET_REFRESH" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/quest_widget_info" />
        </receiver>
```

**Step 5: Deep link intent-filter** (di dalam `<activity>` yang sama dengan `login-callback`)

```xml
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="id.muslimleveling.muslim_leveling"
                    android:host="quests" />
            </intent-filter>
```

**Step 6: Commit**

```bash
git add android/app/src/main/res/ android/app/src/main/AndroidManifest.xml
git commit -m "feat(widget): layout 4x2, metadata, receiver, deep link quests"
```

---

## Task 7: Deep link → daftar quest

**Objective:** Tap widget membuka app langsung ke quest, tanpa mengubah aturan claim.

**Files:**
- Modify: `lib/main.dart` (tambah `navigatorKey`)
- Modify: `lib/screens/home_tab.dart` (scroll ke quest saat diminta)
- Create: `lib/services/widget_link.dart`

**Step 1: Sinyal niat**

```dart
import 'package:flutter/foundation.dart';

/// Niat yang datang dari widget. Home membaca ini lalu menggulir ke daftar
/// quest. Sengaja bukan aksi "claim": claim butuh konfirmasi visual & toast XP.
class WidgetLink {
  static const deepLinkHost = 'quests';
  static final wantsQuests = ValueNotifier<bool>(false);

  static void requestQuests() => wantsQuests.value = true;
  static void consume() => wantsQuests.value = false;
}
```

**Step 2: Tangkap intent di Flutter**

Karena `MainActivity` memakai `FlutterActivity` biasa, cara termurah tanpa dependency: tulis penanda ke prefs dari Kotlin saat `onNewIntent`/`onCreate`, lalu Flutter membacanya saat startup dan saat `resumed`.

Di `MainActivity`:

```kotlin
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        markIfQuestLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        markIfQuestLink(intent)
        IntentFlutterBridge.emit(this, "openQuests")
    }

    private fun markIfQuestLink(intent: Intent?) {
        if (intent?.data?.host == "quests") {
            getSharedPreferences(packageName + "_preferences", MODE_PRIVATE)
                .edit().putBoolean("widget_open_quests", true).apply()
        }
    }
```

`IntentFlutterBridge` cukup `MethodChannel` statis `ml/intent` dengan handler yang dipasang `MainActivity`; Flutter mendengarkan `openQuests`. (Kalau lebih sederhana: Flutter memeriksa prefs `flutter.widget_open_quests` saat `resumed`, lalu menghapusnya. **Pilih yang kedua** — nol channel, nol state hilang saat process death. Tapi ingat prefix `flutter.` wajib di sisi Dart saat membaca kunci yang ditulis Kotlin tanpa prefix.)

**Step 3: Konsumsi di app**

Di `main.dart`: tambah `navigatorKey` global dan observer lifecycle yang, saat `resumed`, membaca penanda lalu memanggil `WidgetLink.requestQuests()`.

Di `home_tab.dart`, `initState` + `didChangeDependencies`: dengarkan `WidgetLink.wantsQuests`; saat `true`, gulir ke daftar quest memakai `GlobalKey` pada section quest lalu `Scrollable.ensureVisible`, dan `WidgetLink.consume()`.

**Step 4: Tes**

```dart
test('permintaan dari widget dikonsumsi sekali', () {
  WidgetLink.requestQuests();
  expect(WidgetLink.wantsQuests.value, isTrue);
  WidgetLink.consume();
  expect(WidgetLink.wantsQuests.value, isFalse);
});
```

Run: `flutter test test/widget_link_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/services/widget_link.dart lib/main.dart lib/screens/home_tab.dart test/widget_link_test.dart
git commit -m "feat(widget): tap widget membuka daftar quest"
```

---

## Task 8: Verifikasi build + kirim

**Step 1:** `flutter analyze lib/ test/` → "No issues found!"
**Step 2:** `flutter test` → semua hijau (baseline repo 748 tes)
**Step 3:** push `main`, tunggu CI, unduh APK artifact, verifikasi seperti biasa (SHA-256, `apksigner verify`, 3 encoding untuk string baru)
**Step 4:** Cek layout benar-benar terkompilasi: `aapt2` tidak ada di VPS, jadi pakai bukti alternatif — `unzip -l app-release.apk | grep quest_widget` harus memuat `res/layout/quest_widget.xml` dan `res/xml/quest_widget_info.xml`.
**Step 5:** Kirim APK, minta user memasang widget dan melaporkan tampilannya.

---

## Files likely to change

**Baru (Dart):** `lib/services/widget_snapshot.dart`, `lib/services/widget_sync.dart`, `lib/services/widget_link.dart`
**Baru (Kotlin/Android):** `QuestWidgetProvider.kt`, `res/layout/quest_widget.xml`, `res/drawable/widget_bg.xml`, `res/xml/quest_widget_info.xml`, `res/values/widget_strings.xml`
**Diubah:** `lib/services/game_service.dart`, `lib/services/prayer_service.dart`, `lib/main.dart`, `lib/screens/home_tab.dart`, `MainActivity.kt`, `AndroidManifest.xml`
**Tes baru:** `test/widget_snapshot_test.dart`, `test/widget_snapshot_push_test.dart`, `test/prayer_week_test.dart`, `test/widget_sync_test.dart`, `test/widget_link_test.dart`

## Testing strategy

Dart bisa diuji penuh (payload, aturan pemilihan quest, guard harian, sinyal deep link). **Kotlin tidak bisa diuji di VPS ini** — tidak ada Android SDK penuh dan tidak ada launcher. Kompensasi:

1. Logika `currentAndNext` dibuat sesederhana mungkin dan ditulis sebagai cermin 1:1 dari `GameService` untuk lima sholat wajib.
2. Verifikasi yang bisa dibuktikan: APK ter-build, layout XML ada di dalam APK, channel terdaftar, tidak ada crash saat `MainActivity` dibuat.
3. Tampilan akhir **wajib** diverifikasi user di HP. Itu bukan formalitas: widget adalah satu-satunya fitur di app ini yang tidak bisa dirender di lingkungan ini.

## Risks

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Nama file prefs salah (`<pkg>_preferences`) | Widget selalu kosong | Dicek di Task 5; kalau kosong, log nama file dari `context.getSharedPreferences` |
| Prefix `flutter.` lupa | Kunci tidak ditemukan | Kunci di Kotlin ditulis lengkap `flutter.widget_snapshot_v1` |
| Alarm exact ditolak | Label sholat telat | Fallback `am.set()` inexact |
| Jadwal 7 hari gagal fetch (offline) | `days` kosong → widget minta buka app | Tidak menampilkan angka lama; coba lagi saat resume berikutnya |
| Quest basi setelah tengah malam tanpa buka app | Menampilkan quest kemarin | `today` dibandingkan dengan tanggal device; kalau beda, widget minta buka app |
| OEM (Xiaomi/Oppo) membunuh alarm | Widget tidak ganti label | Sama seperti notif adzan: sudah ada onboarding pengecualian baterai |
| Locale widget tidak ikut berubah | Bahasa campur | Snapshot ditulis ulang tiap `_save` dan tiap resume |

## Open questions (jawab sebelum Task 4)

1. ~~**Locale aktif** dibaca dari mana~~ **SUDAH TERJAWAB:** `localeNotifier.effectiveLocale`
   (`lib/services/locale_service.dart:105` + `:53`). Global, tanpa context, algoritma
   sama dengan `MaterialApp`. Tidak perlu channel atau state tambahan.
2. **Warna widget**: pakai `#0A0A0C` (ink gelap) + oranye `#F97316` sesuai brand. Kalau user mau widget mengikuti tema app (light/dark), itu kerja tambahan terpisah.
3. **Widget saat `haidMode` aktif**: quest sholat tidak relevan. Untuk MVP, widget tetap menampilkan waktu sholat (informasi, bukan kewajiban pribadi) dan quest apa adanya. Kalau user mau widget menampilkan pesan khusus saat haid, itu keputusan produk terpisah.
