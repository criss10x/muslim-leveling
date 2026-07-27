# Quran & Murrotal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menambahkan modul Al-Quran ke aplikasi — 114 surat dengan teks Arab dan terjemahan Indonesia offline, ditambah pemutaran murrotal per ayat yang bisa diatur range, pengulangan, kecepatan, dan ukuran fontnya.

**Architecture:** Teks di-bundle sebagai aset JSON per surat, dihasilkan sekali oleh script generator dan di-commit ke repo. Audio di-stream per ayat dari CDN Quran.com melalui `just_audio`, dengan playlist yang dibangun dari (surat, range, repeat) dan cache lokal agar pengulangan tidak mengunduh ulang. Logika playlist dipisah ke file murni tanpa dependensi audio supaya bisa diuji tanpa device.

**Tech Stack:** Flutter, `just_audio` + `just_audio_background` + `audio_session`, `scrollable_positioned_list`, `wakelock_plus`, `shared_preferences`, `google_fonts`.

**Spec:** `docs/superpowers/specs/2026-07-27-quran-murrotal-design.md`

## Global Constraints

- Bahasa UI: Indonesia. Semua label, pesan error, dan teks tombol berbahasa Indonesia.
- Semua warna dan tipografi memakai token dari `lib/theme/app_theme.dart` (`AppColors`, `AppText`, `AppRadius`, `AppSpacing`). Jangan menulis nilai warna literal.
- `AppColors` adalah getter yang bergantung pada tema aktif. Widget tab/screen **tidak boleh** dibuat `const`, karena Flutter melewati `updateChild` bila instance identik sehingga warna tidak ikut berganti saat tema di-toggle. Pola ini sudah tertulis sebagai peringatan di `lib/screens/dashboard_shell.dart:37-39`.
- Service singleton mengikuti pola `lib/services/theme_service.dart`: `ChangeNotifier` + variabel global di akhir file + `load()` async yang membaca `SharedPreferences`.
- Base URL audio: `https://verses.quran.com/Alafasy/mp3` (terverifikasi 2026-07-27).
- Qari tunggal: Alafasy. Tidak ada selector qari di UI.
- Repeat tak terbatas diwakili konstanta `kRepeatInfinite = -1`.
- Setiap task diakhiri commit. Jalankan `flutter analyze` sebelum commit; nol error adalah syarat.

## Lingkungan Kerja

**Mesin ini tidak punya Flutter maupun Dart SDK** — proyek dibangun lewat GitHub Actions. Konsekuensinya:

- Perintah `flutter test`, `flutter analyze`, dan `flutter run` **tidak bisa dijalankan lokal**. Verifikasi terjadi di CI, dan Task 1 menambahkan langkah test ke workflow agar itu mungkin.
- Script generator data ditulis untuk **Node.js**, bukan Dart, supaya aset bisa dihasilkan tanpa SDK. Node tersedia di mesin ini.
- Bila pengerjaan dilakukan di lingkungan lain yang punya Flutter SDK, perintah `flutter *` di rencana ini bisa dijalankan langsung dan hasilnya harus sama.

Alur verifikasi tiap task: commit → push branch → CI menjalankan `flutter test` dan `flutter analyze` → periksa hasilnya sebelum lanjut ke task berikutnya.

---

### Task 1: Fondasi — CI test dan aset data Quran

Dua prasyarat untuk seluruh rencana: workflow yang benar-benar menjalankan test, dan aset teks Quran. Tidak ada kode aplikasi di task ini.

**Files:**
- Modify: `.github/workflows/flutter.yml`
- Create: `tool/fetch_quran.mjs`
- Create (generated): `assets/quran/surahs.json`, `assets/quran/surah/1.json` … `assets/quran/surah/114.json`
- Modify: `pubspec.yaml` (bagian `flutter/assets`)
- Test: `test/quran_assets_test.dart`

**Interfaces:**
- Consumes: —
- Produces: Format aset yang dibaca Task 2.
  - `surahs.json`: array objek `{"number": int, "nameArabic": String, "nameLatin": String, "meaning": String, "ayahCount": int, "revelation": "Makkiyah"|"Madaniyah"}`
  - `surah/{n}.json`: array objek `{"ayah": int, "arabic": String, "translation": String}`

- [ ] **Step 1: Aktifkan test di CI**

Workflow saat ini hanya menjalankan `analyze` lalu membangun APK, dan hanya terpicu pada `main`. Tanpa perubahan ini, seluruh test dalam rencana tidak akan pernah dijalankan di mana pun — mesin kerja tidak punya Flutter SDK.

Di `.github/workflows/flutter.yml`, ubah blok `on:` agar mencakup branch fitur dan pull request:

```yaml
on:
  push:
    branches: [main, 'feat/**']
  pull_request:
  workflow_dispatch:
```

Lalu sisipkan langkah test tepat sebelum langkah `Analyze`:

```yaml
      - name: Test
        run: flutter test
```

Build APK dan unggah rilis tetap seperti sebelumnya — keduanya sudah dijaga `if: github.ref == 'refs/heads/main'` pada langkah rilis, sehingga branch fitur hanya menjalankan test, analyze, dan build.

- [ ] **Step 2: Tulis script generator**

Buat `tool/fetch_quran.mjs`. Ditulis untuk Node, bukan Dart, agar aset bisa dihasilkan tanpa Dart SDK.

```javascript
// Generator aset Quran. Jalankan manual saat data perlu diperbarui:
//   node tool/fetch_quran.mjs
// Outputnya di-commit ke repo agar build tidak butuh jaringan.
import { writeFile, mkdir } from 'node:fs/promises';

const META_URL = 'https://equran.id/api/v2/surat';
const ayahUrl = (n) =>
  `https://api.alquran.cloud/v1/surah/${n}/editions/quran-uthmani,id.indonesian`;

// Teks Arab dari alquran.cloud kadang diawali BOM (U+FEFF). Kalau lolos, ia
// tampil sebagai glyph liar di awal ayat.
const clean = (s) => s.replace(/﻿/g, '').trim();

async function getJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status} untuk ${url}`);
  return res.json();
}

const write = (path, data) =>
  writeFile(path, JSON.stringify(data, null, 2), 'utf8');

async function main() {
  await mkdir('assets/quran/surah', { recursive: true });

  // ── Metadata (satu permintaan untuk 114 surat) ──
  console.log('Mengambil metadata surat...');
  const meta = await getJson(META_URL);
  if (meta.data.length !== 114) {
    throw new Error(`Metadata tidak lengkap: ${meta.data.length} surat`);
  }

  const surahs = meta.data.map((s) => ({
    number: s.nomor,
    nameArabic: s.nama,
    nameLatin: s.namaLatin,
    meaning: s.arti,
    ayahCount: s.jumlahAyat,
    // equran.id memakai "Mekah"/"Madinah"; UI memakai istilah klasik.
    revelation: s.tempatTurun === 'Mekah' ? 'Makkiyah' : 'Madaniyah',
  }));

  await write('assets/quran/surahs.json', surahs);

  // ── Ayat, satu berkas per surat ──
  for (let n = 1; n <= 114; n++) {
    const data = await getJson(ayahUrl(n));
    const [arabicEd, indoEd] = data.data;
    const arabic = arabicEd.ayahs;
    const indo = indoEd.ayahs;

    if (arabic.length !== indo.length) {
      throw new Error(`Surat ${n}: jumlah ayat Arab dan terjemahan tidak sama`);
    }

    const ayahs = arabic.map((a, i) => ({
      ayah: a.numberInSurah,
      arabic: clean(a.text),
      translation: clean(indo[i].text),
    }));

    await write(`assets/quran/surah/${n}.json`, ayahs);
    console.log(`Surat ${n} selesai (${ayahs.length} ayat)`);
  }

  console.log('Selesai. 114 surat tertulis ke assets/quran/');
}

main().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
```

- [ ] **Step 3: Jalankan script**

```bash
node tool/fetch_quran.mjs
```

Expected: 115 baris progres, diakhiri "Selesai. 114 surat tertulis ke assets/quran/". Butuh koneksi internet dan berlangsung sekitar 1–3 menit.

Verifikasi hasilnya tanpa Flutter:

```bash
ls assets/quran/surah | wc -l
```

Expected: `114`.

- [ ] **Step 4: Daftarkan aset di pubspec**

Di `pubspec.yaml`, pada bagian `flutter/assets`, tambahkan dua baris setelah `- assets/google_fonts/`:

```yaml
    - assets/quran/
    - assets/quran/surah/
```

Flutter tidak memindai subdirektori secara rekursif, jadi keduanya harus disebut terpisah.

- [ ] **Step 5: Tulis test validasi aset**

Buat `test/quran_assets_test.dart`. Test ini menangkap data tidak lengkap saat build, bukan saat pengguna membukanya.

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('surahs.json berisi 114 surat dengan field lengkap', () {
    final raw = File('assets/quran/surahs.json').readAsStringSync();
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    expect(list.length, 114);
    for (final s in list) {
      expect(s['nameLatin'], isNotEmpty, reason: 'surat ${s['number']}');
      expect(s['nameArabic'], isNotEmpty, reason: 'surat ${s['number']}');
      expect(s['meaning'], isNotEmpty, reason: 'surat ${s['number']}');
      expect(s['ayahCount'], greaterThan(0), reason: 'surat ${s['number']}');
      expect(['Makkiyah', 'Madaniyah'], contains(s['revelation']));
    }
    expect(list.first['number'], 1);
    expect(list.last['number'], 114);
  });

  test('tiap berkas surat cocok jumlah ayatnya dengan metadata', () {
    final raw = File('assets/quran/surahs.json').readAsStringSync();
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    for (final s in list) {
      final n = s['number'] as int;
      final ayahRaw = File('assets/quran/surah/$n.json').readAsStringSync();
      final ayahs = (jsonDecode(ayahRaw) as List).cast<Map<String, dynamic>>();

      expect(ayahs.length, s['ayahCount'], reason: 'surat $n');
      // Nomor ayat harus berurutan 1..n tanpa lompatan.
      for (var i = 0; i < ayahs.length; i++) {
        expect(ayahs[i]['ayah'], i + 1, reason: 'surat $n indeks $i');
        expect(ayahs[i]['arabic'], isNotEmpty, reason: 'surat $n ayat ${i + 1}');
        expect(ayahs[i]['translation'], isNotEmpty,
            reason: 'surat $n ayat ${i + 1}');
      }
    }
  });

  test('teks Arab bebas dari BOM', () {
    for (var n = 1; n <= 114; n++) {
      final raw = File('assets/quran/surah/$n.json').readAsStringSync();
      expect(raw.contains('﻿'), isFalse, reason: 'surat $n mengandung BOM');
    }
  });
}
```

- [ ] **Step 6: Commit dan verifikasi lewat CI**

```bash
git add .github/workflows/flutter.yml tool/fetch_quran.mjs assets/quran pubspec.yaml test/quran_assets_test.dart
git commit -m "feat: aset teks Quran 114 surat dengan terjemahan Indonesia"
git push -u origin HEAD
```

Buka tab Actions di GitHub dan tunggu job selesai.

Expected: langkah "Test" hijau dengan 3 test PASS, langkah "Analyze" hijau.

Bila test BOM gagal, jalankan ulang Step 3 — artinya `clean()` tidak terpakai di suatu tempat. Bila langkah "Test" tidak muncul sama sekali, perubahan `on:` di Step 1 belum benar dan branch ini tidak memicu workflow.

---

### Task 2: Service data Quran

Layer baca aset. Tidak tahu apa pun soal audio maupun widget.

**Files:**
- Create: `lib/services/quran_data.dart`
- Test: `test/quran_data_test.dart`

**Interfaces:**
- Consumes: format aset dari Task 1.
- Produces:
  - `class QuranSurah { final int number; final String nameArabic, nameLatin, meaning, revelation; final int ayahCount; }`
  - `class QuranAyah { final int ayah; final String arabic, translation; }`
  - `class QuranData` dengan `Future<List<QuranSurah>> surahs()`, `Future<List<QuranAyah>> ayahs(int surahNumber)`, `List<QuranSurah> search(List<QuranSurah> all, String query)`
  - Global `final QuranData quranData = QuranData();`

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/quran_data_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';

void main() {
  // Diperlukan agar rootBundle bisa membaca aset di lingkungan test.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('surahs() memuat 114 surat', () async {
    final list = await quranData.surahs();
    expect(list.length, 114);
    expect(list.first.nameLatin, 'Al-Fatihah');
    expect(list.first.meaning, 'Pembukaan');
    expect(list.first.ayahCount, 7);
    expect(list.first.revelation, 'Makkiyah');
  });

  test('ayahs() memuat ayat surat tertentu', () async {
    final ayahs = await quranData.ayahs(1);
    expect(ayahs.length, 7);
    expect(ayahs.first.ayah, 1);
    expect(ayahs.first.arabic, isNotEmpty);
    expect(ayahs.first.translation, contains('Allah'));
  });

  test('ayahs() memuat surat panjang sepenuhnya', () async {
    final ayahs = await quranData.ayahs(2);
    expect(ayahs.length, 286);
    expect(ayahs.last.ayah, 286);
  });

  test('search() mencocokkan nama latin, arti, dan nomor', () async {
    final all = await quranData.surahs();

    expect(quranData.search(all, 'baqarah').single.number, 2);
    // Case-insensitive.
    expect(quranData.search(all, 'BAQARAH').single.number, 2);
    // Nomor surat.
    expect(quranData.search(all, '114').single.nameLatin, 'An-Nas');
    // Arti bahasa Indonesia.
    expect(quranData.search(all, 'Pembukaan').single.number, 1);
    // Query kosong mengembalikan semuanya.
    expect(quranData.search(all, '').length, 114);
  });
}
```

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

```bash
flutter test test/quran_data_test.dart
```

Expected: FAIL saat kompilasi — `Target of URI doesn't exist: 'package:muslim_leveling/services/quran_data.dart'`.

Bila nama paket berbeda, cek `name:` di `pubspec.yaml` dan sesuaikan import di seluruh test.

- [ ] **Step 3: Tulis implementasi**

Buat `lib/services/quran_data.dart`:

```dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuranSurah {
  final int number;
  final String nameArabic, nameLatin, meaning, revelation;
  final int ayahCount;

  const QuranSurah({
    required this.number,
    required this.nameArabic,
    required this.nameLatin,
    required this.meaning,
    required this.ayahCount,
    required this.revelation,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> j) => QuranSurah(
        number: j['number'] as int,
        nameArabic: j['nameArabic'] as String,
        nameLatin: j['nameLatin'] as String,
        meaning: j['meaning'] as String,
        ayahCount: j['ayahCount'] as int,
        revelation: j['revelation'] as String,
      );
}

class QuranAyah {
  final int ayah;
  final String arabic, translation;

  const QuranAyah({
    required this.ayah,
    required this.arabic,
    required this.translation,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> j) => QuranAyah(
        ayah: j['ayah'] as int,
        arabic: j['arabic'] as String,
        translation: j['translation'] as String,
      );
}

/// Membaca aset Quran. Metadata dimuat sekali; ayat dimuat per surat sesuai
/// permintaan lalu disimpan di memori — satu berkas gabungan ~5MB akan
/// menyendat main thread saat di-parse.
class QuranData {
  List<QuranSurah>? _surahs;
  final Map<int, List<QuranAyah>> _ayahCache = {};

  Future<List<QuranSurah>> surahs() async {
    final cached = _surahs;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/quran/surahs.json');
    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(QuranSurah.fromJson)
        .toList(growable: false);
    _surahs = list;
    return list;
  }

  Future<List<QuranAyah>> ayahs(int surahNumber) async {
    final cached = _ayahCache[surahNumber];
    if (cached != null) return cached;

    final raw =
        await rootBundle.loadString('assets/quran/surah/$surahNumber.json');
    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(QuranAyah.fromJson)
        .toList(growable: false);
    _ayahCache[surahNumber] = list;
    return list;
  }

  /// Mencocokkan nama latin, nama Arab, arti, atau nomor surat.
  List<QuranSurah> search(List<QuranSurah> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;

    return all.where((s) {
      return s.nameLatin.toLowerCase().contains(q) ||
          s.meaning.toLowerCase().contains(q) ||
          s.nameArabic.contains(q) ||
          s.number.toString() == q;
    }).toList(growable: false);
  }
}

final QuranData quranData = QuranData();
```

- [ ] **Step 4: Jalankan test untuk memastikan lulus**

```bash
flutter test test/quran_data_test.dart
```

Expected: PASS, 4 test.

- [ ] **Step 5: Commit**

```bash
git add lib/services/quran_data.dart test/quran_data_test.dart
git commit -m "feat: service pembaca aset Quran"
```

---

### Task 3: Logika playlist murrotal (murni, tanpa audio)

Semua aturan range dan pengulangan hidup di sini, tanpa menyentuh `just_audio`, sehingga bisa diuji penuh tanpa device.

**Files:**
- Create: `lib/services/quran_playlist.dart`
- Test: `test/quran_playlist_test.dart`

**Interfaces:**
- Consumes: —
- Produces:
  - `const int kRepeatInfinite = -1;`
  - `String ayahAudioUrl(int surah, int ayah)`
  - `class AyahRef { final int surah, ayah; }` — dengan `==` dan `hashCode`
  - `class PlaybackRange { final int surah, from, to, ayahCount; PlaybackRange.full({surah, ayahCount}); PlaybackRange withFrom(int); PlaybackRange withTo(int); }`
  - `List<AyahRef> buildQueue({required PlaybackRange range, required int repeat})`

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/quran_playlist_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_playlist.dart';

void main() {
  group('ayahAudioUrl', () {
    test('memberi nomor berpadding tiga digit', () {
      expect(ayahAudioUrl(1, 1),
          'https://verses.quran.com/Alafasy/mp3/001001.mp3');
      expect(ayahAudioUrl(2, 286),
          'https://verses.quran.com/Alafasy/mp3/002286.mp3');
      expect(ayahAudioUrl(114, 6),
          'https://verses.quran.com/Alafasy/mp3/114006.mp3');
    });
  });

  group('PlaybackRange', () {
    test('full() mencakup seluruh surat', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7);
      expect(r.from, 1);
      expect(r.to, 7);
    });

    test('withFrom melewati to akan mendorong to ikut naik', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withTo(3);
      final moved = r.withFrom(5);
      expect(moved.from, 5);
      expect(moved.to, 5);
    });

    test('withTo di bawah from akan menarik from ikut turun', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withFrom(4);
      final moved = r.withTo(2);
      expect(moved.from, 2);
      expect(moved.to, 2);
    });

    test('nilai di luar batas surat dijepit', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7);
      expect(r.withTo(99).to, 7);
      expect(r.withFrom(0).from, 1);
    });
  });

  group('buildQueue', () {
    test('repeat 1 menghasilkan tiap ayat sekali', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withFrom(1).withTo(3);
      final q = buildQueue(range: r, repeat: 1);
      expect(q, [
        const AyahRef(1, 1),
        const AyahRef(1, 2),
        const AyahRef(1, 3),
      ]);
    });

    test('repeat N menggandakan tiap ayat berurutan', () {
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withFrom(1).withTo(2);
      final q = buildQueue(range: r, repeat: 3);
      expect(q, [
        const AyahRef(1, 1),
        const AyahRef(1, 1),
        const AyahRef(1, 1),
        const AyahRef(1, 2),
        const AyahRef(1, 2),
        const AyahRef(1, 2),
      ]);
    });

    test('repeat tak terbatas menghasilkan tiap ayat sekali', () {
      // Mode tak terbatas dijalankan LoopMode.one di player, bukan lewat
      // playlist — playlist tak-hingga tidak mungkin dibangun.
      final r = PlaybackRange.full(surah: 1, ayahCount: 7).withFrom(1).withTo(3);
      final q = buildQueue(range: r, repeat: kRepeatInfinite);
      expect(q.length, 3);
    });

    test('range di tengah surat tidak menyertakan ayat sebelumnya', () {
      final r = PlaybackRange.full(surah: 2, ayahCount: 286)
          .withFrom(5)
          .withTo(10);
      final q = buildQueue(range: r, repeat: 1);
      expect(q.first, const AyahRef(2, 5));
      expect(q.last, const AyahRef(2, 10));
      expect(q.length, 6);
    });
  });
}
```

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

```bash
flutter test test/quran_playlist_test.dart
```

Expected: FAIL saat kompilasi — file `quran_playlist.dart` belum ada.

- [ ] **Step 3: Tulis implementasi**

Buat `lib/services/quran_playlist.dart`:

```dart
/// Logika murrotal yang tidak bergantung pada pemutar audio maupun widget,
/// supaya seluruh aturan range dan pengulangan bisa diuji tanpa device.

/// Menandai pengulangan tanpa batas. Dijalankan lewat LoopMode.one di player,
/// bukan dengan membangun playlist tak-hingga.
const int kRepeatInfinite = -1;

const String kQuranAudioBase = 'https://verses.quran.com/Alafasy/mp3';

String _pad3(int n) => n.toString().padLeft(3, '0');

String ayahAudioUrl(int surah, int ayah) =>
    '$kQuranAudioBase/${_pad3(surah)}${_pad3(ayah)}.mp3';

class AyahRef {
  final int surah, ayah;
  const AyahRef(this.surah, this.ayah);

  String get audioUrl => ayahAudioUrl(surah, ayah);

  @override
  bool operator ==(Object other) =>
      other is AyahRef && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => 'AyahRef($surah:$ayah)';
}

/// Rentang ayat dalam satu surat. Invarian: 1 <= from <= to <= ayahCount,
/// sehingga rentang tidak pernah kosong.
class PlaybackRange {
  final int surah, from, to, ayahCount;

  const PlaybackRange._({
    required this.surah,
    required this.from,
    required this.to,
    required this.ayahCount,
  });

  factory PlaybackRange.full({required int surah, required int ayahCount}) =>
      PlaybackRange._(surah: surah, from: 1, to: ayahCount, ayahCount: ayahCount);

  int _clamp(int v) => v < 1 ? 1 : (v > ayahCount ? ayahCount : v);

  /// Menaikkan `to` bila `from` melewatinya — rentang kosong tidak pernah valid.
  PlaybackRange withFrom(int value) {
    final f = _clamp(value);
    return PlaybackRange._(
      surah: surah,
      from: f,
      to: to < f ? f : to,
      ayahCount: ayahCount,
    );
  }

  /// Menurunkan `from` bila `to` jatuh di bawahnya — cerminan dari withFrom.
  PlaybackRange withTo(int value) {
    final t = _clamp(value);
    return PlaybackRange._(
      surah: surah,
      from: from > t ? t : from,
      to: t,
      ayahCount: ayahCount,
    );
  }

  int get length => to - from + 1;
}

/// Membangun antrean ayat. Untuk repeat 1..N tiap ayat digandakan di tempat,
/// supaya hitungan berhenti tepat lalu maju sendiri ke ayat berikutnya.
List<AyahRef> buildQueue({
  required PlaybackRange range,
  required int repeat,
}) {
  final times = repeat == kRepeatInfinite ? 1 : repeat;
  final out = <AyahRef>[];
  for (var a = range.from; a <= range.to; a++) {
    for (var i = 0; i < times; i++) {
      out.add(AyahRef(range.surah, a));
    }
  }
  return out;
}
```

- [ ] **Step 4: Jalankan test untuk memastikan lulus**

```bash
flutter test test/quran_playlist_test.dart
```

Expected: PASS, 9 test.

- [ ] **Step 5: Commit**

```bash
git add lib/services/quran_playlist.dart test/quran_playlist_test.dart
git commit -m "feat: logika playlist murrotal (range, repeat, url audio)"
```

---

### Task 4: Service setelan Quran

Preferensi tampilan dan kecepatan yang bertahan lintas sesi.

**Files:**
- Create: `lib/services/quran_settings.dart`
- Test: `test/quran_settings_test.dart`

**Interfaces:**
- Consumes: —
- Produces: `class QuranSettings extends ChangeNotifier` dengan properti `double arabicFontSize` (default 28), `double translationFontSize` (default 15), `bool showTranslation` (default true), `double speed` (default 1.0); setter async `setArabicFontSize`, `setTranslationFontSize`, `setShowTranslation`, `setSpeed`; `Future<void> load()`. Global `final QuranSettings quranSettings = QuranSettings();`
- Batas: `kArabicFontMin = 20`, `kArabicFontMax = 44`, `kTranslationFontMin = 12`, `kTranslationFontMax = 24`, `kSpeedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]`.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/quran_settings_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/quran_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('nilai default masuk akal saat belum ada yang tersimpan', () async {
    final s = QuranSettings();
    await s.load();

    expect(s.arabicFontSize, 28);
    expect(s.translationFontSize, 15);
    expect(s.showTranslation, isTrue);
    expect(s.speed, 1.0);
  });

  test('setelan bertahan lintas instance', () async {
    final a = QuranSettings();
    await a.load();
    await a.setArabicFontSize(36);
    await a.setTranslationFontSize(20);
    await a.setShowTranslation(false);
    await a.setSpeed(0.75);

    final b = QuranSettings();
    await b.load();

    expect(b.arabicFontSize, 36);
    expect(b.translationFontSize, 20);
    expect(b.showTranslation, isFalse);
    expect(b.speed, 0.75);
  });

  test('ukuran font dijepit ke rentang yang didukung', () async {
    final s = QuranSettings();
    await s.load();

    await s.setArabicFontSize(999);
    expect(s.arabicFontSize, kArabicFontMax);
    await s.setArabicFontSize(1);
    expect(s.arabicFontSize, kArabicFontMin);

    await s.setTranslationFontSize(999);
    expect(s.translationFontSize, kTranslationFontMax);
    await s.setTranslationFontSize(1);
    expect(s.translationFontSize, kTranslationFontMin);
  });

  test('perubahan memberi tahu listener', () async {
    final s = QuranSettings();
    await s.load();

    var calls = 0;
    s.addListener(() => calls++);
    await s.setArabicFontSize(30);
    await s.setShowTranslation(false);

    expect(calls, 2);
  });
}
```

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

```bash
flutter test test/quran_settings_test.dart
```

Expected: FAIL saat kompilasi — file belum ada.

- [ ] **Step 3: Tulis implementasi**

Buat `lib/services/quran_settings.dart`, mengikuti pola `theme_service.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double kArabicFontMin = 20;
const double kArabicFontMax = 44;
const double kTranslationFontMin = 12;
const double kTranslationFontMax = 24;
const List<double> kSpeedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

/// Preferensi tampilan dan kecepatan murrotal. Range ayat dan jumlah
/// pengulangan sengaja tidak disimpan — keduanya khas satu sesi hafalan, dan
/// memulihkannya ke surat lain justru membingungkan.
class QuranSettings extends ChangeNotifier {
  static const _kArabic = 'quran_arabic_font';
  static const _kTranslation = 'quran_translation_font';
  static const _kShowTranslation = 'quran_show_translation';
  static const _kSpeed = 'quran_speed';

  double _arabicFontSize = 28;
  double _translationFontSize = 15;
  bool _showTranslation = true;
  double _speed = 1.0;

  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  bool get showTranslation => _showTranslation;
  double get speed => _speed;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _arabicFontSize = p.getDouble(_kArabic) ?? 28;
    _translationFontSize = p.getDouble(_kTranslation) ?? 15;
    _showTranslation = p.getBool(_kShowTranslation) ?? true;
    _speed = p.getDouble(_kSpeed) ?? 1.0;
    notifyListeners();
  }

  double _clamp(double v, double lo, double hi) =>
      v < lo ? lo : (v > hi ? hi : v);

  Future<void> setArabicFontSize(double v) async {
    _arabicFontSize = _clamp(v, kArabicFontMin, kArabicFontMax);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kArabic, _arabicFontSize);
    notifyListeners();
  }

  Future<void> setTranslationFontSize(double v) async {
    _translationFontSize = _clamp(v, kTranslationFontMin, kTranslationFontMax);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kTranslation, _translationFontSize);
    notifyListeners();
  }

  Future<void> setShowTranslation(bool v) async {
    _showTranslation = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kShowTranslation, v);
    notifyListeners();
  }

  Future<void> setSpeed(double v) async {
    _speed = v;
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kSpeed, v);
    notifyListeners();
  }
}

final QuranSettings quranSettings = QuranSettings();
```

- [ ] **Step 4: Jalankan test untuk memastikan lulus**

```bash
flutter test test/quran_settings_test.dart
```

Expected: PASS, 4 test.

- [ ] **Step 5: Muat setelan saat aplikasi start**

Di `lib/main.dart`, di dalam `_initAsync()`, tambahkan setelah blok inisialisasi `SharedPreferences` yang sudah ada:

```dart
  try {
    await quranSettings.load();
  } catch (_) {}
```

Tambahkan importnya di bagian atas berkas:

```dart
import 'services/quran_settings.dart';
```

Pola `try`/`catch (_)` mengikuti gaya `_initAsync` yang sudah ada — kegagalan init tidak boleh menghalangi UI muncul.

- [ ] **Step 6: Commit**

```bash
git add lib/services/quran_settings.dart lib/main.dart test/quran_settings_test.dart
git commit -m "feat: setelan tampilan dan kecepatan murrotal"
```

---

### Task 5: Dependensi audio, font Arab, dan pemutar

Task ini menambahkan seluruh dependensi runtime dan membungkus `just_audio`. Konfigurasi native dijadikan satu di sini karena pemutar tidak berfungsi tanpanya.

**Files:**
- Modify: `pubspec.yaml`
- Create (unduh): `assets/google_fonts/AmiriQuran-Regular.ttf`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `lib/services/quran_audio_service.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `quran_playlist.dart` (Task 3), `quran_settings.dart` (Task 4).
- Produces: `class QuranAudioService extends ChangeNotifier` dengan:
  - `AyahRef? get current` — ayat yang sedang berbunyi, `null` bila tidak ada sesi
  - `bool get isPlaying`
  - `PlaybackRange? get range`, `int get repeat` (default 1), `bool get repeatAll` (default false)
  - `Stream<Duration> get position`, `Stream<Duration?> get duration`
  - `Future<void> start({required PlaybackRange range, int? startAyah})`
  - `Future<void> toggle()`, `Future<void> next()`, `Future<void> previous()`, `Future<void> stop()`
  - `Future<void> setRange(PlaybackRange value)`, `Future<void> setRepeat(int value)`, `Future<void> setRepeatAll(bool value)`, `Future<void> setSpeed(double value)`
  - `Future<void> retry()` — membangun ulang sumber audio setelah gagal
  - `String? get error` — pesan error terakhir, dikosongkan saat `start()` berhasil
  - Global `final QuranAudioService quranAudio = QuranAudioService();`

- [ ] **Step 1: Tambahkan dependensi**

Di `pubspec.yaml`, bagian `dependencies`, tambahkan setelah `google_sign_in`:

```yaml
  just_audio: ^0.9.42
  just_audio_background: ^0.0.1-beta.13
  audio_session: ^0.1.21
  scrollable_positioned_list: ^0.3.8
  wakelock_plus: ^1.2.8
```

Lalu:

```bash
flutter pub get
```

Expected: "Got dependencies!" tanpa konflik versi. Bila ada konflik, jalankan `flutter pub upgrade --major-versions` hanya untuk paket yang bentrok dan catat versi hasilnya.

- [ ] **Step 2: Unduh font Arab**

Repo sudah membundel font Google secara lokal di `assets/google_fonts/`, dan paket `google_fonts` otomatis memakai berkas di sana alih-alih mengunduh saat runtime. Font Arab mengikuti pola yang sama.

```bash
curl -L -o assets/google_fonts/AmiriQuran-Regular.ttf https://github.com/google/fonts/raw/main/ofl/amiriquran/AmiriQuran-Regular.ttf
```

Verifikasi berkas benar-benar font, bukan halaman error HTML:

```bash
ls -l assets/google_fonts/AmiriQuran-Regular.ttf && file assets/google_fonts/AmiriQuran-Regular.ttf
```

Expected: ukuran di atas 100 KB dan tipe "TrueType Font data". Bila yang terunduh HTML, cari berkas di https://fonts.google.com/specimen/Amiri+Quran (lisensi OFL) dan letakkan dengan nama persis `AmiriQuran-Regular.ttf` — paket `google_fonts` mencocokkan berdasarkan nama berkas.

Versi `google_fonts` yang ter-lock di repo ini adalah 6.3.3, dan pemanggilan `GoogleFonts.amiriQuran()` di Task 7 mengandalkan metode itu tersedia di sana. Metode ini belum bisa diverifikasi karena paket belum pernah diunduh di mesin ini. Bila `flutter analyze` di CI melaporkan `amiriQuran` tidak dikenal, ganti dengan pendaftaran font manual: pindahkan berkas ke `assets/fonts/`, deklarasikan di `pubspec.yaml` dengan `family: AmiriQuran`, lalu ganti tiap `GoogleFonts.amiriQuran(...)` menjadi `TextStyle(fontFamily: 'AmiriQuran', ...)` dengan parameter yang sama. Hanya dua berkas yang memanggilnya: `quran_ayah_card.dart` dan `quran_display_sheet.dart`.

- [ ] **Step 3: Izinkan pemutaran background di Android**

Di `android/app/src/main/AndroidManifest.xml`, tambahkan di dalam `<manifest>` sebelum `<application>`:

```xml
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
```

Lalu di dalam `<application>`, tambahkan service dan receiver yang dibutuhkan `just_audio_background`:

```xml
        <service
            android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>

        <receiver
            android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
            </intent-filter>
        </receiver>
```

- [ ] **Step 4: Inisialisasi audio background di main**

Di `lib/main.dart`, ubah `main()` menjadi:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MuslimLevelingApp());
  _initAsync();
}
```

menjadi bentuk yang menginisialisasi audio lebih dulu — `JustAudioBackground.init` harus dipanggil sebelum pemutar dipakai, tetapi tetap tidak boleh menahan tampilnya UI:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MuslimLevelingApp());
  _initAsync();
}

Future<void> _initAudio() async {
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.muslimleveling.audio',
      androidNotificationChannelName: 'Murrotal',
      androidNotificationOngoing: true,
    );
  } catch (_) {}
}
```

Lalu panggil `await _initAudio();` sebagai baris pertama di dalam `_initAsync()`, dan tambahkan import:

```dart
import 'package:just_audio_background/just_audio_background.dart';
```

- [ ] **Step 5: Tulis service pemutar**

Buat `lib/services/quran_audio_service.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'quran_playlist.dart';
import 'quran_settings.dart';

/// Membungkus just_audio. Menerima angka (surat, range, repeat) dan
/// mengeluarkan posisi — tidak tahu apa pun soal widget.
class QuranAudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<AyahRef> _queue = const [];
  PlaybackRange? _range;
  int _repeat = 1;
  bool _repeatAll = false;
  String? _error;

  QuranAudioService() {
    // Indeks playlist berubah → ayat aktif berubah.
    _player.currentIndexStream.listen((_) => notifyListeners());
    _player.playerStateStream.listen((_) => notifyListeners());
    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace _) {
        _error = 'Gagal memuat audio, periksa koneksi';
        notifyListeners();
      },
    );
  }

  PlaybackRange? get range => _range;
  int get repeat => _repeat;
  bool get repeatAll => _repeatAll;
  String? get error => _error;
  bool get isPlaying => _player.playing;

  Stream<Duration> get position => _player.positionStream;
  Stream<Duration?> get duration => _player.durationStream;

  AyahRef? get current {
    final i = _player.currentIndex;
    if (i == null || i < 0 || i >= _queue.length) return null;
    return _queue[i];
  }

  /// Mode tak terbatas per ayat menang atas "ulangi semua": LoopMode.one
  /// membuat pemutaran tidak pernah mencapai akhir range, sehingga
  /// pengulangan range tidak pernah berlaku selama mode ini aktif.
  LoopMode get _loopMode {
    if (_repeat == kRepeatInfinite) return LoopMode.one;
    return _repeatAll ? LoopMode.all : LoopMode.off;
  }

  Future<void> start({required PlaybackRange range, int? startAyah}) async {
    _range = range;
    await _rebuild(startAyah: startAyah ?? range.from);
    if (_error == null) await _player.play();
  }

  Future<void> _rebuild({int? startAyah}) async {
    final r = _range;
    if (r == null) return;

    _queue = buildQueue(range: r, repeat: _repeat);
    final target = startAyah ?? current?.ayah ?? r.from;
    final index = _queue.indexWhere((a) => a.ayah == target);

    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children: _queue
              // LockCachingAudioSource menyimpan berkas saat pertama diputar.
              // Tanpa ini, "ulangi 10x" mengunduh berkas yang sama 10 kali.
              .map((a) => LockCachingAudioSource(Uri.parse(a.audioUrl)))
              .toList(),
        ),
        initialIndex: index < 0 ? 0 : index,
      );
      await _player.setLoopMode(_loopMode);
      await _player.setSpeed(quranSettings.speed);
      _error = null;
    } catch (_) {
      _error = 'Gagal memuat audio, periksa koneksi';
    }
    notifyListeners();
  }

  Future<void> toggle() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> next() async {
    // Dalam mode tak terbatas, LoopMode.one menahan ayat; next harus tetap maju.
    if (_repeat == kRepeatInfinite) {
      await _player.setLoopMode(LoopMode.off);
      await _player.seekToNext();
      await _player.setLoopMode(LoopMode.one);
      return;
    }
    await _player.seekToNext();
  }

  Future<void> previous() async {
    if (_repeat == kRepeatInfinite) {
      await _player.setLoopMode(LoopMode.off);
      await _player.seekToPrevious();
      await _player.setLoopMode(LoopMode.one);
      return;
    }
    await _player.seekToPrevious();
  }

  Future<void> stop() async {
    await _player.stop();
    _range = null;
    _queue = const [];
    notifyListeners();
  }

  /// Mengubah range membangun ulang playlist dan memulai dari awal range.
  Future<void> setRange(PlaybackRange value) async {
    _range = value;
    await _rebuild(startAyah: value.from);
    if (_error == null) await _player.play();
  }

  Future<void> setRepeat(int value) async {
    _repeat = value;
    await _rebuild(startAyah: current?.ayah);
    if (_error == null) await _player.play();
  }

  /// Tidak membangun ulang playlist — hanya mengubah perilaku di ujung antrean.
  Future<void> setRepeatAll(bool value) async {
    _repeatAll = value;
    await _player.setLoopMode(_loopMode);
    notifyListeners();
  }

  /// Diterapkan langsung tanpa menghentikan audio.
  Future<void> setSpeed(double value) async {
    await quranSettings.setSpeed(value);
    await _player.setSpeed(value);
    notifyListeners();
  }

  Future<void> retry() async {
    _error = null;
    await _rebuild(startAyah: current?.ayah);
    if (_error == null) await _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final QuranAudioService quranAudio = QuranAudioService();
```

- [ ] **Step 6: Verifikasi kompilasi**

```bash
flutter analyze
```

Expected: "No issues found!". Bila ada peringatan API `just_audio` yang berbeda versi, sesuaikan dengan dokumentasi versi yang benar-benar ter-resolve di `pubspec.lock`.

Lalu pastikan test yang sudah ada tidak rusak:

```bash
flutter test
```

Expected: seluruh test lama PASS.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock assets/google_fonts/AmiriQuran-Regular.ttf android/app/src/main/AndroidManifest.xml lib/services/quran_audio_service.dart lib/main.dart
git commit -m "feat: pemutar murrotal dengan cache audio dan font Arab"
```

---

### Task 6: Tab Quran dan daftar surat

**Files:**
- Create: `lib/screens/quran_tab.dart`
- Modify: `lib/screens/dashboard_shell.dart`
- Test: `test/quran_tab_test.dart`

**Interfaces:**
- Consumes: `quranData.surahs()`, `quranData.search()` (Task 2).
- Produces: `class QuranTab extends StatefulWidget` tanpa parameter wajib. Tap pada baris surat membuka `QuranReader` (Task 8) — sampai task itu ada, tap belum melakukan apa pun.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/quran_tab_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/quran_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('menampilkan daftar surat', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah'), findsOneWidget);
    // Arti digabung dengan tempat turun dan jumlah ayat dalam satu subtitle.
    expect(find.textContaining('Pembukaan'), findsOneWidget);
  });

  testWidgets('pencarian memfilter daftar', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'baqarah');
    await tester.pumpAndSettle();

    expect(find.text('Al-Baqarah'), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsNothing);
  });

  testWidgets('pencarian tanpa hasil menampilkan pesan kosong', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pumpAndSettle();

    expect(find.text('Surat tidak ditemukan'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

```bash
flutter test test/quran_tab_test.dart
```

Expected: FAIL saat kompilasi — `quran_tab.dart` belum ada.

- [ ] **Step 3: Tulis implementasi**

Buat `lib/screens/quran_tab.dart`:

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';

class QuranTab extends StatefulWidget {
  const QuranTab({super.key});

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  List<QuranSurah> _all = const [];
  String _query = '';
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await quranData.surahs();
      if (!mounted) return;
      setState(() {
        _all = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Gagal memuat data Quran',
            style: AppText.bodyLg().copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    final list = quranData.search(_all, _query);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Cari surat, arti, atau nomor',
                hintStyle: AppText.bodyMd()
                    .copyWith(color: AppColors.onSurfaceVariant),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'Surat tidak ditemukan',
                      style: AppText.bodyMd()
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _SurahRow(surah: list[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SurahRow extends StatelessWidget {
  final QuranSurah surah;
  const _SurahRow({required this.surah});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Reader dipasang di Task 8.
      },
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          '${surah.number}',
          style: AppText.labelCapsSm().copyWith(color: AppColors.primary),
        ),
      ),
      title: Text(
        surah.nameLatin,
        style: AppText.titleLg().copyWith(color: AppColors.onSurface),
      ),
      subtitle: Text(
        '${surah.meaning} · ${surah.revelation} · ${surah.ayahCount} ayat',
        style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
      ),
      trailing: Text(
        surah.nameArabic,
        style: AppText.titleLg().copyWith(color: AppColors.primary),
      ),
    );
  }
}
```

- [ ] **Step 4: Jalankan test untuk memastikan lulus**

```bash
flutter test test/quran_tab_test.dart
```

Expected: PASS, 3 test.

- [ ] **Step 5: Pasang sebagai tab kelima**

Di `lib/screens/dashboard_shell.dart`, tambahkan import:

```dart
import 'quran_tab.dart';
```

Ubah `_items` menjadi lima entri, dengan Quran di posisi ketiga:

```dart
  static const _items = [
    (Icons.home_outlined, Icons.home, 'HOME'),
    (Icons.schedule_outlined, Icons.schedule, 'JADWAL'),
    (Icons.auto_stories_outlined, Icons.auto_stories, 'QURAN'),
    (Icons.menu_book_outlined, Icons.menu_book, 'BELAJAR'),
    (Icons.person_outline, Icons.person, 'PROFIL'),
  ];
```

Tambahkan konstanta indeks tepat di bawahnya, supaya lompatan antar tab tidak memakai angka telanjang:

```dart
  static const _profilTab = 4;
```

Ubah daftar children `IndexedStack` agar urutannya sama persis dengan `_items`:

```dart
              children: [
                HomeTab(onSettingsPressed: () => setState(() => _tab = _profilTab)),
                JadwalTab(),
                QuranTab(),
                BelajarTab(),
                ProfilTab(),
              ],
```

Perubahan `_tab = 3` menjadi `_tab = _profilTab` wajib: tanpa itu tombol setelan di Home diam-diam membuka Belajar, karena Profil bergeser dari indeks 3 ke 4.

- [ ] **Step 6: Jalankan seluruh test**

```bash
flutter test
```

Expected: semua PASS. Perhatikan `test/widget_test.dart` dan test golden — bila ada golden yang memotret bottom nav, ia akan gagal karena kini ada lima ikon. Perbarui golden dengan:

```bash
flutter test --update-goldens
```

Lalu periksa hasil perubahan gambar sebelum melanjutkan.

- [ ] **Step 7: Commit**

```bash
git add lib/screens/quran_tab.dart lib/screens/dashboard_shell.dart test/quran_tab_test.dart test/goldens
git commit -m "feat: tab Quran dengan daftar surat dan pencarian"
```

---

### Task 7: Kartu ayat dan sheet setelan tampilan

**Files:**
- Create: `lib/widgets/quran_ayah_card.dart`
- Create: `lib/widgets/quran_display_sheet.dart`
- Test: `test/quran_ayah_card_test.dart`

**Interfaces:**
- Consumes: `QuranAyah` (Task 2), `quranSettings` (Task 4).
- Produces:
  - `class QuranAyahCard extends StatelessWidget` dengan parameter `{required QuranAyah ayah, required bool active, required VoidCallback onPlay}`
  - `Future<void> showQuranDisplaySheet(BuildContext context)`

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/quran_ayah_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/services/quran_settings.dart';
import 'package:muslim_leveling/widgets/quran_ayah_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await quranSettings.load();
  });

  const ayah = QuranAyah(
    ayah: 1,
    arabic: 'بِسْمِ ٱللَّهِ',
    translation: 'Dengan menyebut nama Allah',
  );

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('menampilkan teks Arab dan terjemahan', (tester) async {
    await tester.pumpWidget(wrap(
      QuranAyahCard(ayah: ayah, active: false, onPlay: () {}),
    ));

    expect(find.text('بِسْمِ ٱللَّهِ'), findsOneWidget);
    expect(find.text('Dengan menyebut nama Allah'), findsOneWidget);
  });

  testWidgets('menyembunyikan terjemahan sesuai setelan', (tester) async {
    await quranSettings.setShowTranslation(false);
    await tester.pumpWidget(wrap(
      QuranAyahCard(ayah: ayah, active: false, onPlay: () {}),
    ));
    await tester.pumpAndSettle();

    expect(find.text('بِسْمِ ٱللَّهِ'), findsOneWidget);
    expect(find.text('Dengan menyebut nama Allah'), findsNothing);
  });

  testWidgets('ukuran font Arab mengikuti setelan', (tester) async {
    await quranSettings.setArabicFontSize(40);
    await tester.pumpWidget(wrap(
      QuranAyahCard(ayah: ayah, active: false, onPlay: () {}),
    ));
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text('بِسْمِ ٱللَّهِ'));
    expect(text.style?.fontSize, 40);
  });

  testWidgets('tombol play memanggil callback', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(wrap(
      QuranAyahCard(ayah: ayah, active: false, onPlay: () => tapped++),
    ));

    await tester.tap(find.byIcon(Icons.play_arrow));
    expect(tapped, 1);
  });
}
```

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

```bash
flutter test test/quran_ayah_card_test.dart
```

Expected: FAIL saat kompilasi.

- [ ] **Step 3: Tulis kartu ayat**

Buat `lib/widgets/quran_ayah_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_settings.dart';

class QuranAyahCard extends StatelessWidget {
  final QuranAyah ayah;
  final bool active;
  final VoidCallback onPlay;

  const QuranAyahCard({
    super.key,
    required this.ayah,
    required this.active,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quranSettings,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.10)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: active
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.45))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Ayat ${ayah.ayah}',
                      style: AppText.labelCapsSm()
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_arrow),
                    color: AppColors.primary,
                    tooltip: 'Putar dari ayat ini',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Font mushaf wajib di-bundle: font sistem Android salah
              // merender harakat Uthmani.
              Text(
                ayah.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiriQuran(
                  fontSize: quranSettings.arabicFontSize,
                  height: 2.0,
                  color: AppColors.onSurface,
                ),
              ),
              if (quranSettings.showTranslation) ...[
                const SizedBox(height: 12),
                Text(
                  ayah.translation,
                  style: AppText.bodyMd().copyWith(
                    fontSize: quranSettings.translationFontSize,
                    height: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 4: Jalankan test untuk memastikan lulus**

```bash
flutter test test/quran_ayah_card_test.dart
```

Expected: PASS, 4 test.

- [ ] **Step 5: Tulis sheet setelan tampilan**

Buat `lib/widgets/quran_display_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/quran_settings.dart';

/// Setelan tampilan — diatur saat membaca, terpisah dari setelan murrotal
/// yang diatur saat menghafal.
Future<void> showQuranDisplaySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => const _DisplaySheet(),
  );
}

class _DisplaySheet extends StatelessWidget {
  const _DisplaySheet();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quranSettings,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Tampilan',
                    style: AppText.headlineMd()
                        .copyWith(color: AppColors.onSurface)),
                const SizedBox(height: 16),

                // Pratinjau ikut berubah saat slider digeser.
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiriQuran(
                          fontSize: quranSettings.arabicFontSize,
                          height: 2.0,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (quranSettings.showTranslation) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Dengan menyebut nama Allah Yang Maha Pemurah lagi '
                          'Maha Penyayang.',
                          style: AppText.bodyMd().copyWith(
                            fontSize: quranSettings.translationFontSize,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text('Ukuran teks Arab',
                    style: AppText.labelCaps()
                        .copyWith(color: AppColors.onSurfaceVariant)),
                Slider(
                  value: quranSettings.arabicFontSize,
                  min: kArabicFontMin,
                  max: kArabicFontMax,
                  divisions: (kArabicFontMax - kArabicFontMin).round(),
                  label: quranSettings.arabicFontSize.round().toString(),
                  onChanged: (v) => quranSettings.setArabicFontSize(v),
                ),

                Text('Ukuran terjemahan',
                    style: AppText.labelCaps()
                        .copyWith(color: AppColors.onSurfaceVariant)),
                Slider(
                  value: quranSettings.translationFontSize,
                  min: kTranslationFontMin,
                  max: kTranslationFontMax,
                  divisions:
                      (kTranslationFontMax - kTranslationFontMin).round(),
                  label:
                      quranSettings.translationFontSize.round().toString(),
                  onChanged: (v) => quranSettings.setTranslationFontSize(v),
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: quranSettings.showTranslation,
                  onChanged: (v) => quranSettings.setShowTranslation(v),
                  title: Text('Tampilkan terjemahan',
                      style: AppText.bodyLg()
                          .copyWith(color: AppColors.onSurface)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 6: Verifikasi analisis**

```bash
flutter analyze
```

Expected: "No issues found!".

- [ ] **Step 7: Commit**

```bash
git add lib/widgets/quran_ayah_card.dart lib/widgets/quran_display_sheet.dart test/quran_ayah_card_test.dart
git commit -m "feat: kartu ayat dan setelan tampilan Quran"
```

---

### Task 8: Reader surat dengan auto-scroll dan wakelock

**Files:**
- Create: `lib/screens/quran_reader.dart`
- Modify: `lib/screens/quran_tab.dart` (mengaktifkan tap baris surat)
- Test: `test/quran_reader_test.dart`

**Interfaces:**
- Consumes: `quranData.ayahs()` (Task 2), `QuranAyahCard` + `showQuranDisplaySheet` (Task 7), `quranAudio` (Task 5), `PlaybackRange` (Task 3).
- Produces: `class QuranReader extends StatefulWidget` dengan parameter `{required QuranSurah surah}`.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/quran_reader_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/services/quran_settings.dart';
import 'package:muslim_leveling/screens/quran_reader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await quranSettings.load();
  });

  const surah = QuranSurah(
    number: 1,
    nameArabic: 'الفاتحة',
    nameLatin: 'Al-Fatihah',
    meaning: 'Pembukaan',
    ayahCount: 7,
    revelation: 'Makkiyah',
  );

  testWidgets('menampilkan nama surat dan ayat-ayatnya', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranReader(surah: surah)));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.textContaining('Ayat 1'), findsOneWidget);
  });

  testWidgets('tombol Aa membuka sheet setelan tampilan', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranReader(surah: surah)));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Setelan tampilan'));
    await tester.pumpAndSettle();

    expect(find.text('Tampilan'), findsOneWidget);
    expect(find.text('Tampilkan terjemahan'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

```bash
flutter test test/quran_reader_test.dart
```

Expected: FAIL saat kompilasi.

- [ ] **Step 3: Tulis reader**

Buat `lib/screens/quran_reader.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_audio_service.dart';
import '../services/quran_playlist.dart';
import '../widgets/quran_ayah_card.dart';
import '../widgets/quran_display_sheet.dart';

class QuranReader extends StatefulWidget {
  final QuranSurah surah;
  const QuranReader({super.key, required this.surah});

  @override
  State<QuranReader> createState() => _QuranReaderState();
}

class _QuranReaderState extends State<QuranReader> {
  // ScrollablePositionedList, bukan ListView: auto-scroll harus melompat ke
  // indeks ayat sementara tinggi tiap kartu berbeda-beda.
  final ItemScrollController _scrollController = ItemScrollController();

  List<QuranAyah> _ayahs = const [];
  bool _loading = true;
  int? _lastScrolledAyah;

  @override
  void initState() {
    super.initState();
    _load();
    quranAudio.addListener(_onAudioChanged);
  }

  @override
  void dispose() {
    quranAudio.removeListener(_onAudioChanged);
    quranAudio.stop();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await quranData.ayahs(widget.surah.number);
    if (!mounted) return;
    setState(() {
      _ayahs = list;
      _loading = false;
    });
  }

  void _onAudioChanged() {
    if (!mounted) return;

    // Layar tetap menyala selama murrotal berjalan — orang membaca sambil
    // mendengarkan, dan layar mati di tengah bacaan mengganggu.
    if (quranAudio.isPlaying) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    final current = quranAudio.current;
    if (current != null &&
        current.surah == widget.surah.number &&
        current.ayah != _lastScrolledAyah) {
      _lastScrolledAyah = current.ayah;
      if (_scrollController.isAttached) {
        _scrollController.scrollTo(
          index: current.ayah - 1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          alignment: 0.25,
        );
      }
    }

    setState(() {});
  }

  void _playFrom(int ayah) {
    quranAudio.start(
      range: PlaybackRange.full(
        surah: widget.surah.number,
        ayahCount: widget.surah.ayahCount,
      ),
      startAyah: ayah,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = quranAudio.current;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text(
          widget.surah.nameLatin,
          style: AppText.headlineMd().copyWith(color: AppColors.onSurface),
        ),
        actions: [
          IconButton(
            tooltip: 'Setelan tampilan',
            icon: const Icon(Icons.text_fields),
            onPressed: () => showQuranDisplaySheet(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              padding: const EdgeInsets.only(bottom: 120, top: 8),
              itemCount: _ayahs.length,
              itemBuilder: (_, i) {
                final a = _ayahs[i];
                return QuranAyahCard(
                  ayah: a,
                  active: current != null &&
                      current.surah == widget.surah.number &&
                      current.ayah == a.ayah,
                  onPlay: () => _playFrom(a.ayah),
                );
              },
            ),
    );
  }
}
```

- [ ] **Step 4: Jalankan test untuk memastikan lulus**

```bash
flutter test test/quran_reader_test.dart
```

Expected: PASS, 2 test.

- [ ] **Step 5: Sambungkan dari daftar surat**

Di `lib/screens/quran_tab.dart`, tambahkan import:

```dart
import 'quran_reader.dart';
```

Ubah `_SurahRow` agar menerima context untuk navigasi — ganti `onTap` yang masih kosong menjadi:

```dart
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QuranReader(surah: surah)),
      ),
```

- [ ] **Step 6: Jalankan seluruh test**

```bash
flutter test
```

Expected: semua PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/screens/quran_reader.dart lib/screens/quran_tab.dart test/quran_reader_test.dart
git commit -m "feat: reader surat dengan auto-scroll dan wakelock"
```

---

### Task 9: Player bar dan sheet setelan murrotal

Task penutup — menyambungkan seluruh kontrol pemutaran ke UI.

**Files:**
- Create: `lib/widgets/quran_player_bar.dart`
- Create: `lib/widgets/quran_playback_sheet.dart`
- Modify: `lib/screens/quran_reader.dart`
- Test: `test/quran_playback_sheet_test.dart`

**Interfaces:**
- Consumes: `quranAudio` (Task 5), `PlaybackRange` + `kRepeatInfinite` (Task 3), `kSpeedOptions` (Task 4).
- Produces:
  - `class QuranPlayerBar extends StatelessWidget` dengan parameter `{required QuranSurah surah}`
  - `Future<void> showQuranPlaybackSheet(BuildContext context, {required QuranSurah surah})`

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/quran_playback_sheet_test.dart`. Test ini menguji aturan presedensi yang mudah salah diimplementasikan:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_playlist.dart';

void main() {
  test('mode tak terbatas tidak menggandakan antrean', () {
    final r = PlaybackRange.full(surah: 1, ayahCount: 7).withTo(3);
    expect(buildQueue(range: r, repeat: kRepeatInfinite).length, 3);
  });

  test('antrean repeat mengikuti panjang range dikali pengulangan', () {
    final r =
        PlaybackRange.full(surah: 2, ayahCount: 286).withFrom(5).withTo(10);
    expect(r.length, 6);
    expect(buildQueue(range: r, repeat: 4).length, 24);
  });
}
```

- [ ] **Step 2: Jalankan test**

```bash
flutter test test/quran_playback_sheet_test.dart
```

Expected: PASS — logikanya sudah ada sejak Task 3. Test ini mengunci perilaku agar tidak rusak saat UI menyentuhnya.

- [ ] **Step 3: Tulis sheet setelan murrotal**

Buat `lib/widgets/quran_playback_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_audio_service.dart';
import '../services/quran_playlist.dart';
import '../services/quran_settings.dart';

Future<void> showQuranPlaybackSheet(
  BuildContext context, {
  required QuranSurah surah,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => _PlaybackSheet(surah: surah),
  );
}

class _PlaybackSheet extends StatelessWidget {
  final QuranSurah surah;
  const _PlaybackSheet({required this.surah});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quranAudio,
      builder: (context, _) {
        final range = quranAudio.range ??
            PlaybackRange.full(surah: surah.number, ayahCount: surah.ayahCount);
        final infinite = quranAudio.repeat == kRepeatInfinite;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Setelan Murrotal',
                    style: AppText.headlineMd()
                        .copyWith(color: AppColors.onSurface)),
                const SizedBox(height: 16),

                // ── Range ayat ──
                Text('Rentang ayat',
                    style: AppText.labelCaps()
                        .copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _AyahDropdown(
                        label: 'Dari',
                        value: range.from,
                        max: surah.ayahCount,
                        onChanged: (v) =>
                            quranAudio.setRange(range.withFrom(v)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AyahDropdown(
                        label: 'Sampai',
                        value: range.to,
                        max: surah.ayahCount,
                        onChanged: (v) => quranAudio.setRange(range.withTo(v)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Ulangi per ayat ──
                Text('Ulangi tiap ayat',
                    style: AppText.labelCaps()
                        .copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final n in [1, 2, 3, 5, 7, 10])
                      ChoiceChip(
                        label: Text('${n}x'),
                        selected: quranAudio.repeat == n,
                        onSelected: (_) => quranAudio.setRepeat(n),
                      ),
                    ChoiceChip(
                      label: const Text('∞'),
                      selected: infinite,
                      onSelected: (_) =>
                          quranAudio.setRepeat(kRepeatInfinite),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Ulangi semua ──
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: quranAudio.repeatAll,
                  onChanged: (v) => quranAudio.setRepeatAll(v),
                  title: Text('Ulangi rentang',
                      style: AppText.bodyLg()
                          .copyWith(color: AppColors.onSurface)),
                  subtitle: Text(
                    infinite
                        // Presedensi: ∞ per ayat menahan pemutaran sehingga
                        // akhir rentang tidak pernah tercapai.
                        ? 'Berlaku setelah pengulangan ∞ dimatikan'
                        : 'Kembali ke ayat ${range.from} setelah ayat '
                            '${range.to} selesai',
                    style: AppText.bodyMd()
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Kecepatan ──
                Text('Kecepatan',
                    style: AppText.labelCaps()
                        .copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final s in kSpeedOptions)
                      ChoiceChip(
                        label: Text('${s}x'),
                        selected: quranSettings.speed == s,
                        onSelected: (_) => quranAudio.setSpeed(s),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AyahDropdown extends StatelessWidget {
  final String label;
  final int value, max;
  final ValueChanged<int> onChanged;

  const _AyahDropdown({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceContainerHigh,
          style: AppText.bodyLg().copyWith(color: AppColors.onSurface),
          items: [
            for (var i = 1; i <= max; i++)
              DropdownMenuItem(value: i, child: Text('$i')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Tulis player bar**

Buat `lib/widgets/quran_player_bar.dart`:

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_data.dart';
import '../services/quran_audio_service.dart';
import 'quran_playback_sheet.dart';

class QuranPlayerBar extends StatelessWidget {
  final QuranSurah surah;
  const QuranPlayerBar({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quranAudio,
      builder: (context, _) {
        final current = quranAudio.current;
        if (current == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<Duration>(
                    stream: quranAudio.position,
                    builder: (context, snap) {
                      return StreamBuilder<Duration?>(
                        stream: quranAudio.duration,
                        builder: (context, durSnap) {
                          final pos = snap.data ?? Duration.zero;
                          final dur = durSnap.data ?? Duration.zero;
                          final value = dur.inMilliseconds == 0
                              ? 0.0
                              : (pos.inMilliseconds / dur.inMilliseconds)
                                  .clamp(0.0, 1.0);
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: AppColors.surfaceContainerLow,
                            color: AppColors.primary,
                            minHeight: 3,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'QS ${surah.nameLatin} : ${current.ayah}',
                          style: AppText.bodyLg()
                              .copyWith(color: AppColors.onSurface),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Ayat sebelumnya',
                        icon: const Icon(Icons.skip_previous),
                        color: AppColors.onSurface,
                        onPressed: quranAudio.previous,
                      ),
                      IconButton(
                        tooltip: quranAudio.isPlaying ? 'Jeda' : 'Putar',
                        icon: Icon(quranAudio.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill),
                        iconSize: 40,
                        color: AppColors.primary,
                        onPressed: quranAudio.toggle,
                      ),
                      IconButton(
                        tooltip: 'Ayat berikutnya',
                        icon: const Icon(Icons.skip_next),
                        color: AppColors.onSurface,
                        onPressed: quranAudio.next,
                      ),
                      IconButton(
                        tooltip: 'Setelan murrotal',
                        icon: const Icon(Icons.tune),
                        color: AppColors.onSurface,
                        onPressed: () =>
                            showQuranPlaybackSheet(context, surah: surah),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 5: Pasang player bar dan penanganan error di reader**

Di `lib/screens/quran_reader.dart`, tambahkan import:

```dart
import '../widgets/quran_player_bar.dart';
```

Tambahkan `bottomNavigationBar` pada `Scaffold`, tepat setelah properti `body`:

```dart
      bottomNavigationBar: QuranPlayerBar(surah: widget.surah),
```

Lalu tampilkan error audio sebagai snackbar. Di dalam `_onAudioChanged`, tambahkan sebelum `setState(() {});`:

```dart
    final err = quranAudio.error;
    if (err != null && err != _shownError) {
      _shownError = err;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          action: SnackBarAction(
            label: 'Coba lagi',
            onPressed: () {
              _shownError = null;
              quranAudio.retry();
            },
          ),
        ),
      );
    }
```

Dan tambahkan field di `_QuranReaderState`, di bawah `_lastScrolledAyah`:

```dart
  String? _shownError;
```

Penjagaan `_shownError` mencegah snackbar yang sama muncul berulang, karena listener terpanggil setiap kali state pemutar berubah.

- [ ] **Step 6: Jalankan seluruh test dan analisis**

```bash
flutter analyze && flutter test
```

Expected: "No issues found!" dan seluruh test PASS.

- [ ] **Step 7: Verifikasi manual di device**

Pemutaran audio sungguhan tidak bisa dibuktikan lewat mock. Jalankan aplikasi di perangkat Android nyata dan periksa:

```bash
flutter run
```

Daftar periksa:
1. Tab QURAN muncul sebagai tab ketiga; tombol setelan di HOME tetap membuka PROFIL, bukan BELAJAR.
2. Buka Al-Fatihah, tekan play pada ayat 1 — audio berbunyi, kartu ayat ter-highlight, dan daftar auto-scroll saat berpindah ayat.
3. Buka setelan murrotal, set rentang 2–4, ulangi tiap ayat 3x — pemutaran mengikuti pola 2,2,2,3,3,3,4,4,4 lalu berhenti.
4. Nyalakan "Ulangi rentang" — setelah ayat 4, kembali ke ayat 2.
5. Set pengulangan ∞ — ayat berulang terus, subtitle "Ulangi rentang" berubah menjadi keterangan bahwa ia berlaku setelah ∞ dimatikan, dan tombol next tetap bisa memaksa maju.
6. Ubah kecepatan ke 0.5x dan 2x saat audio berjalan — kecepatan berubah tanpa audio terhenti.
7. Buka setelan tampilan, geser ukuran font — pratinjau dan kartu ayat ikut berubah; tutup dan buka ulang aplikasi, ukuran font bertahan.
8. Matikan internet lalu putar ayat yang belum pernah diputar — muncul snackbar "Gagal memuat audio, periksa koneksi" dengan tombol Coba lagi, sementara teks tetap terbaca.
9. Putar ulang ayat yang tadi sudah pernah dibunyikan dalam keadaan internet mati — tetap berbunyi karena diambil dari cache.
10. Selama audio berjalan, layar tidak padam sendiri; setelah dijeda, layar kembali normal.

Catat kegagalan apa pun dan perbaiki sebelum commit terakhir.

- [ ] **Step 8: Commit**

```bash
git add lib/widgets/quran_player_bar.dart lib/widgets/quran_playback_sheet.dart lib/screens/quran_reader.dart test/quran_playback_sheet_test.dart
git commit -m "feat: player bar dan setelan murrotal"
```

---

## Catatan Implementasi

**Urutan task tidak bisa ditukar sembarangan.** Task 1 menghasilkan aset yang dibaca Task 2. Task 3 dan 4 saling bebas dan boleh dikerjakan paralel. Task 5 membutuhkan keduanya. Task 6–9 berurutan karena tiap task memasang UI di atas yang sebelumnya.

**Bila `just_audio` gagal di-resolve** karena batas versi Flutter di lingkungan ini, catat versi yang benar-benar ter-resolve di `pubspec.lock` dan sesuaikan pemakaian API-nya. `ConcatenatingAudioSource` sudah ditandai deprecated pada `just_audio` 0.10 ke atas dan digantikan `AudioSource.playlist`; bila versi yang ter-resolve setinggi itu, ganti pemanggilan di `_rebuild` tanpa mengubah struktur lain.

**Bila CDN Quran.com bermasalah**, spec mencatat fallback `https://cdn.islamic.network/quran/audio/128/ar.alafasy/{n}.mp3` dengan `{n}` sebagai nomor ayat global 1–6236. Perpindahan hanya menyentuh `ayahAudioUrl` di `quran_playlist.dart`, tetapi menuntut tabel offset kumulatif per surat.
