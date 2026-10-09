# Ayat Menurut Situasi — Implementation Plan

> **For Hermes:** REQUIRED SUB-SKILL: gunakan `superpowers:subagent-driven-development`
> (rekomendasi) atau `superpowers:executing-plans` untuk mengerjakan plan ini
> task-by-task. Langkah di bawah memakai checkbox (`- [ ]`) untuk tracking.

**Goal:** Satu pintu masuk di Akses Cepat yang membuka 57 situasi hidup, masing-masing
menampilkan 3 ayat Al-Quran yang pas untuk situasi itu, dan tiap ayat bisa dibuka
lengkap di QuranReader.

**Architecture:** Konten ayat (`surah:ayah`) disimpan sebagai data terkurasi yang
**tidak bergantung bahasa** (`assets/quran_situasi.json`), sedangkan label + deskripsi
situasi adalah **chrome** yang masuk ARB 4 bahasa. Terjemahan ayat **tidak ditulis
manual** — di-resolve saat runtime lewat `quranData.ayahs(surah, english: quranUseEnglish(locale))`,
persis seperti tab Quran, Renungan, dan pembaca Quran. Layar baru mengikuti pola
`hadis_screen.dart`/`doa_screen.dart` (route pushed + `SafeArea`).

**Tech Stack:** Flutter, Dart, `rootBundle` JSON, ARB + `flutter gen-l10n`,
`flutter_test`, golden test.

---

## Fakta terukur yang menjadi dasar plan ini

Semua angka di bawah diukur di sesi ini, bukan diasumsikan.

| Fakta | Angka | Sumber |
|---|---|---|
| Ayat punya terjemahan id | 6.236 / 6.236 | `assets/quran/surah/*.json` |
| Ayat punya terjemahan en | 6.236 / 6.236 | `assets/quran/en/surah/*.json` |
| Terjemahan ms / tr | **TIDAK ADA** | hanya folder `en/` |
| `quranUseEnglish(locale)` | `locale.languageCode != 'id'` | `lib/services/quran_api.dart:28` |
| `QuranReader` bisa lompat ke ayat | ya, `initialAyah` | `lib/screens/quran_reader.dart:20-24` |
| Renungan harian pakai daftar terkurasi? | **TIDAK** — acak berbasis tanggal | `lib/services/daily_highlight.dart:110-115` |
| Ruang teks label tile @360dp | **73,3px** | JetBrainsMono-Bold 10sp + `letterSpacing 1.0` |
| Ruang teks label tile @412dp | 90,7px | idem |
| Label tile terpanjang sekarang | "Asmaul Husna" & "Hari Penting" = **84px** | idem |
| Label "Situasi" | **49px** → muat 100% di 360dp | idem |
| Tinggi daftar 57 item, 3 kolom | ~1.336dp (≈2,4 layar) | 57/3 baris × ~62dp + header |

**Konsekuensi penting:**

1. **Tidak ada terjemahan ayat ms/tr yang perlu ditulis.** Pengguna ms/tr sudah
   membaca terjemahan Inggris di seluruh app (keputusan lama yang konsisten:
   chrome → ARB, konten → id/en). Plan ini mengikuti itu, tidak mengarang
   mekanisme baru.
2. **Kurasi ayat WAJIB, pencarian kata kunci tidak cukup.** Terbukti: ayat paling
   terkenal untuk situasi sulit **tidak ketangkap** pencarian emosi —
   `94:5-6` ("sesudah kesulitan ada kemudahan") **0 hasil** untuk kata perasaan apa
   pun karena ayatnya berbicara tentang *kesulitan*, bukan *perasaan*; `93:3` ("Tuhanmu
   tiada meninggalkan kamu") dan `65:3` juga tidak ketangkap. Peta situasi→ayat harus
   dikurasi manusia, bukan diturunkan dari keyword.
3. **Istilah "tema" sudah dipakai.** Tab Quran punya chip filter **Makkiyah/Madaniyah**.
   Nama fitur ini **tidak boleh** memakai kata "tema" agar tidak bertabrakan.

---

## Design decisions — SUDAH DIJAWAB USER (2026-10-09)

### D1. Nama fitur — **"Ayat Rekomendasi"**

**Temuan yang perlu dibaca sebelum Task 7.** "Ayat Rekomendasi" = **112px**,
sedangkan ruang label tile hanya **73,3px @360dp** → `FittedBox` menyusutkannya ke
**65%**, yaitu 6,5sp dari 10sp.

Bandingkan dengan label terpanjang yang sudah ada:

| label | lebar @360dp | skala | catatan |
|---|---|---|---|
| "Ayat Rekomendasi" | **112,0px** | **65%** | di bawah ambang yang pernah dipakai |
| "Hari Penting" | 84,0px | 87% | existing worst case |
| "Asmaul Husna" | 84,0px | 87% | existing worst case |
| "Rekomendasi" | 77,0px | 95% | usulan untuk label tile |
| "Renungan" | 56,0px | 100% | |
| "Situasi" | 49,0px | 100% | |

Karena tiap tile menyusut sendiri, satu baris bisa memuat teks 10sp di sebelah teks
6,5sp. **Rekomendasi: label tile = "Rekomendasi" (95%), judul halaman + label
aksesibilitas tetap "Ayat Rekomendasi"** supaya penamaan yang dipilih user utuh di
tempat yang penting. Perlu konfirmasi user (lihat bagian "Sisa pertanyaan").

### D2. Hubungan dengan Doa — **tidak ada; tombol baru**

Keputusan user: ini tombol baru, tidak berhubungan dengan Doa maupun Dzikir.
Audit **sudah dijalankan** seperti yang dijanjikan. 22 tag Doa yang sebenarnya
(`doa_api.dart:97-120`): `ampunan, harta, hutang, jenazah, kabar, kamar mandi,
keburukan, malam, musibah, orang tua, pakaian, perjalanan, perlindungan, rezeki,
sakit, sedih, sifat buruk, sulit, syirik, tidur, umum, wudhu`.

Tumpang tindih **kata kunci** ada di ~10 situasi (`sedih`, `hutang`, `sakit`,
`musibah`, `orang tua`, `malam`, `tidur`, `perjalanan`, `rezeki`, `sulit`).
**Tidak ada konflik fitur**: artifact-nya berbeda — Doa berisi *permohonan*, fitur ini
berisi *firman*. Situasi #52 pagi & #53 malam **tetap dipertahankan**.

### D3. Kurasi dulu, baru rilis

User memilih **kurasi dulu**. Artinya: Task 3 (6 batch) diselesaikan seluruhnya
sebelum layar dirilis. Tiap batch tetap di-commit sendiri supaya state selalu hijau.

### D4. Action = **buka ayat di Quran**. Titik.

User: *"Buka ayat Quran saja, tidak ada hubungan dengan doa dan dzikir."*

Konsekuensi: **enum `SituationAction` DIHAPUS** dari desain (YAGNI — himpunan
beranggota satu tidak perlu enum). Tidak ada tombol action terpisah; **tiap kartu
ayat itu sendiri yang bisa ditap** dan membuka `QuranReader(surah:, initialAyah:)`.
Jadi "1 aksi kecil" dari konsep awal terpenuhi oleh kartu ayat itu sendiri, tanpa
menambah kontrol baru.

---

## Non-goals (YAGNI, eksplisit)

- **Tidak** membuat mesin rekomendasi/personal. Situasi dipilih manual user.
- **Tidak** menambah terjemahan Quran ms/tr. Pakai jalur `quranUseEnglish` yang ada.
- **Tidak** menyentuh `DailyHighlight` (Renungan) atau `DoaScreen`.
- **Tidak** membuat entri XP/streak/quest baru.
- **Tidak** memakai `image_generate` atau aset bitmap baru. Grid tile pakai ikon
  Phosphor yang sudah ada di `AppIcons`.
- **Tidak** membangun 57 tombol di Home. Satu tile → satu layar berisi daftar.

---

## Skema data

`assets/quran_situasi.json` — bahasa-agnostik, hanya referensi + kode:

```json
{
  "version": 1,
  "groups": [
    { "id": "kacau",  "umbrella": "shifa" },
    { "id": "ujian",  "umbrella": "dikuatkan" }
  ],
  "situations": [
    {
      "id": "sedih",
      "group": "kacau",
      "ayahs": [ { "surah": 3, "ayah": 139 }, { "surah": 9, "ayah": 40 }, { "surah": 93, "ayah": 3 } ]
    },
    {
      "id": "hutang",
      "group": "ujian",
      "ayahs": [ { "surah": 65, "ayah": 2 }, { "surah": 65, "ayah": 3 }, { "surah": 2, "ayah": 286 } ]
    }
  ]
}
```

Aturan schema (dijaga tes, bukan disiplin):

- `id` unik, `lowercase-kebab`.
- Tepat **3** ayat per situasi (sesuai permintaan user).
- Setiap `surah` ada di `assets/quran/surahs.json` dan `ayah` dalam
  `1..ayahCount` — ini yang mencegah "ayat yang tidak ada" lolos ke UI.
- `group` harus ada di `groups`.
- Tidak ada situasi yang **seluruh 3 ayatnya identik** dengan situasi lain
  (mencegah dua entri kembar).

ARB (chrome, 4 bahasa) — kunci per situasi + grup + judul layar:

```
sitTitle, sitSearchHint, sitEmpty, sitAyahCount
sitG_kacau, sitG_ujian, ...            (9 grup)
sitU_shifa, sitU_huda, ...             (4 umbrella, kalau D2 memilih tab)
sit_sedih, sit_hutang, ...             (57 label)
sit_sedih_d, sit_hutang_d, ...         (57 deskripsi 1 baris)
```

**Total chrome ≈ 137 kunci × 4 bahasa.** Ini pekerjaan nyata dan harus masuk
anggaran; lihat Task 8.

---

## Cakupan situasi (57, terverifikasi dari pesan user)

| # | Grup (umbrella) | Situasi |
|---|---|---|
| 1-9 | **Hati kacau** (shifa) | sedih · cemas/overthinking · marah & susah memaafkan · kesepian · insecure/minder · iri/hasad · putus asa · burnout · FOMO medsos |
| 10-16 | **Ujian hidup** (dikuatkan) | hutang/rezeki seret · sakit · kehilangan · gagal · dizalimi/difitnah · masalah keluarga besar · rumah tangga di ujung |
| 17-23 | **Hubungan rumit** (dikuatkan) | konflik orang tua · masalah pasangan · move on · dikhianati teman · parenting · dikucilkan · susah memaafkan |
| 24-29 | **Iman naik turun** (diingatkan) | futur · merasa jauh dari Allah · tujuan hidup · merasa munafik · was-was ibadah · baru hijrah |
| 30-35 | **Keputusan besar** (huda) | jodoh · karier/resign · merantau · kuliah vs bisnis · istikhara · quarter life crisis |
| 36-40 | **Habis berbuat salah** (shifa) | maksiat · bohong/ghibah · merasa kotor · bingung mulai taubat · takut azab |
| 41-46 | **Butuh tenaga** (dikuatkan) | keberanian · sabar ekstra · istiqomah · lawan malas · pemimpin · versi diri lebih baik |
| 47-53 | **Bahagia** (diingatkan) | rezeki datang · sembuh/lulus · jodoh/anak · tenang usai ibadah · alam/safar/hujan · pagi · malam |
| 54-57 | **Lihat dunia luar** (dikuatkan) | ketidakadilan/Palestina · lomba dunia · doomscrolling · dunia rusak |

**Pemetaan 4 umbrella (kalau D2 memilih tab):** shifa 14 · huda 6 · dikuatkan 24 ·
diingatkan 13 = 57.

### Standar mutu kurasi (WAJIB dibaca sebelum Task 4)

Ini bagian yang paling mudah jadi buruk. Aturan:

1. **Untuk situasi emosional, pilih ayat *rahmah*, bukan ayat *hukum*.** Contoh yang
   diminta user: "Sedih > Kehilangan > butuh dipeluk ayat Rahmah, bukan ayat hukum."
   Ayat tentang ancaman/azab tidak boleh muncul di grup 1, 3, dan 7.
2. **Tiga ayat harus berbeda *fungsi*:** satu yang **memvalidasi** perasaan, satu
   yang **menghibur/menjanjikan**, satu yang **menggerakkan** ke tindakan. Tiga ayat
   yang isinya sama = satu ayat diulang tiga kali.
3. **Contoh terverifikasi** (contoh mutu, sudah dicek ada di data):
   - `sedih` → `3:139` (jangan bersedih, kamu yang lebih tinggi) + `9:40` (jangan
     bersedih, Allah bersama kita) + `93:3` (Tuhanmu tidak meninggalkanmu).
     Catatan: **tiga-tiganya tidak ketangkap** pencarian keyword `sedih`; inilah
     bukti kenapa kurasi manual wajib.
   - `putus-asa` → `39:53` (jangan berputus asa dari rahmat Allah) + `12:87` +
     `94:5`.
4. **Panjang ayat dibatasi.** Ayat seperti `2:286` panjang; kalau ketiga ayat
   panjang, kartu situasi jadi dinding teks. Minimal satu ayat pendek per situasi.
5. **Tinjauan user wajib** untuk batch kurasi. Ini konten agama; agent tidak boleh
   memutuskan sendiri lalu mengklaim sudah benar.

---

## Task list

### Task 0 — Gate keputusan (JANGAN lanjut sebelum ini dijawab)

**Files:** none (hanya keputusan).

- [ ] **Step 1:** Jawab D1 (nama fitur), D2 (ambang tumpang tindih Doa — **wajib
      periksa 22 tag Doa dulu**), D3 (57 sekaligus atau bertahap), D4 (action).
- [ ] **Step 2:** Putuskan D2 dengan data: `grep -n "tag" lib/services/doa_api.dart`
      lalu baca 22 tag terkurasi yang sebenarnya.

**Verification:** keempat keputusan tertulis di plan ini (diperbarui) sebelum Task 1.

---

### Task 1 — Model + parser + guard test

**Files:**
- Create: `lib/services/quran_situasi.dart`
- Create: `assets/quran_situasi.json` (boleh mulai dengan 2 entri contoh)
- Test: `test/quran_situasi_data_test.dart`
- Modify: `pubspec.yaml` (daftarkan aset)

**Step 1: Tulis tes yang GAGAL dulu**

```dart
// test/quran_situasi_data_test.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/quran_data.dart';
import 'package:muslim_leveling/services/quran_situasi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('setiap referensi ayat benar-benar ada di aset lokal', () async {
    final surahs = await quranData.surahs();
    final byNumber = {for (final s in surahs) s.number: s};
    final list = await quranSituasi.all();

    expect(list, isNotEmpty);
    for (final s in list) {
      expect(s.ayahs.length, 3, reason: 'situasi "${s.id}" harus 3 ayat');
      for (final r in s.ayahs) {
        final surah = byNumber[r.surah];
        expect(surah, isNotNull, reason: '${s.id}: surah ${r.surah} tidak ada');
        expect(r.ayah, inInclusiveRange(1, surah!.ayahCount),
            reason: '${s.id}: ${r.surah}:${r.ayah} di luar rentang '
                '(surah ${r.surah} punya ${surah.ayahCount} ayat)');
      }
    }
  });

  test('id situasi unik dan grup dikenal', () async {
    final list = await quranSituasi.all();
    final ids = list.map((s) => s.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'ada id duplikat');
    final groups = (await quranSituasi.groups()).map((g) => g.id).toSet();
    for (final s in list) {
      expect(groups, contains(s.group), reason: '${s.id}: grup "${s.group}" tak dikenal');
    }
  });

  test('tidak ada dua situasi dengan tiga ayat yang identik', () async {
    final list = await quranSituasi.all();
    final sigs = <String, String>{};
    for (final s in list) {
      final sig = s.ayahs.map((r) => '${r.surah}:${r.ayah}').toList()..sort();
      final key = sig.join(',');
      expect(sigs.containsKey(key), isFalse,
          reason: '${s.id} kembar dengan ${sigs[key]}');
      sigs[key] = s.id;
    }
  });
}
```

**Step 2: Jalankan, pastikan GAGAL**

Run: `flutter test test/quran_situasi_data_test.dart`
Expected: FAIL — `quran_situasi.dart` belum ada (compile error).

**Step 3: Implementasi minimal**

```dart
// lib/services/quran_situasi.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SituationGroup {
  final String id;
  /// 4 alasan besar orang membuka Quran, untuk pengelompokan tingkat atas.
  final String umbrella; // shifa | huda | dikuatkan | diingatkan
  const SituationGroup({required this.id, required this.umbrella});

  factory SituationGroup.fromJson(Map<String, dynamic> j) =>
      SituationGroup(id: j['id'] as String, umbrella: j['umbrella'] as String);
}

class Situation {
  final String id;
  final String group;
  final List<({int surah, int ayah})> ayahs;
  const Situation({required this.id, required this.group, required this.ayahs});

  factory Situation.fromJson(Map<String, dynamic> j) => Situation(
        id: j['id'] as String,
        group: j['group'] as String,
        ayahs: (j['ayahs'] as List)
            .map((e) => (surah: e['surah'] as int, ayah: e['ayah'] as int))
            .toList(growable: false),
      );
}

class QuranSituasi {
  List<SituationGroup>? _groups;
  List<Situation>? _situations;

  Future<void> _ensure() async {
    if (_situations != null) return;
    final raw = await rootBundle.loadString('assets/quran_situasi.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    _groups = (j['groups'] as List)
        .map((e) => SituationGroup.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _situations = (j['situations'] as List)
        .map((e) => Situation.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<SituationGroup>> groups() async { await _ensure(); return _groups!; }
  Future<List<Situation>> all() async { await _ensure(); return _situations!; }

  /// ponytail: reset antar widget-test (singleton lintas test = flake).
  void resetForTest() { _groups = null; _situations = null; }
}

final quranSituasi = QuranSituasi();
```

**Step 4: Jalankan, pastikan LULUS**

Run: `flutter test test/quran_situasi_data_test.dart`
Expected: PASS (3 tests).

**Step 5: Commit**

```bash
git add lib/services/quran_situasi.dart assets/quran_situasi.json \
        test/quran_situasi_data_test.dart pubspec.yaml
git commit -m "feat(situasi): model + guard data situasi ayat"
```

---

### Task 2 — Kontrol negatif Task 1 (WAJIB, jangan dilewati)

- [ ] **Step 1:** Ubah satu `ayah` jadi `999` di JSON → tes harus **merah** dengan
      pesan `di luar rentang`. Kalau hijau, guard-nya bohong.
- [ ] **Step 2:** Ubah satu `surah` jadi `115` → tes harus **merah**.
- [ ] **Step 3:** Duplikat satu situasi (id beda, ayat sama) → tes kembar **merah**.
- [ ] **Step 4:** Kembalikan semuanya, jalankan lagi → **hijau**.

**Pelajaran dari sesi sebelumnya:** kontrol negatif yang gagal di tahap *load/compile*
**tidak sah** sebagai bukti. Sabotase harus seimbang kurung dan lolos `flutter analyze`
dulu, baru lihat apakah tesnya merah.

---

### Task 3 — Kurasi batch (diulang 6×)

**Files:** `assets/quran_situasi.json` (append), `test/quran_situasi_curation_test.dart`

- [ ] **Batch 1:** grup 1 (situasi 1-9) — 27 ayat
- [ ] **Batch 2:** grup 2-3 (10-23) — 42 ayat
- [ ] **Batch 3:** grup 4-5 (24-35) — 36 ayat
- [ ] **Batch 4:** grup 6-7 (36-46) — 33 ayat
- [ ] **Batch 5:** grup 8 (47-53) — 21 ayat
- [ ] **Batch 6:** grup 9 (54-57) — 12 ayat

Per batch:
- [ ] Isi ayat sesuai **standar mutu** di atas (rahmah bukan hukum; validasi +
      hibur + gerak; minimal satu ayat pendek).
- [ ] Jalankan `flutter test test/quran_situasi_data_test.dart` → hijau.
- [ ] **Minta tinjauan user** sebelum lanjut batch berikutnya. Tulis daftar
      `surah:ayah` + terjemahan singkatnya supaya user bisa menilai cepat.

---

### Task 4 — Layar daftar situasi

**Files:**
- Create: `lib/screens/situasi_screen.dart`
- Test: `test/situasi_screen_test.dart`

**Interfaces:**
- Consumes: `quranSituasi.all()`, `quranSituasi.groups()`, `AppL10n`, `AppColors`,
  `AppText`, `AppSpacing`, `AppRadius`, `AppIcons`, `AppL10n.of(context).sit*`.
- Produces: `SituasiScreen` (route pushed), key `situasi-grid`,
  key `situasi-item-<id>`, key `situasi-search`.

**Step 1: Tulis tes yang GAGAL**

```dart
// test/situasi_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/screens/situasi_screen.dart';
import 'package:muslim_leveling/services/quran_situasi.dart';
import 'helpers/app_wrap.dart';

void main() {
  setUp(() => quranSituasi.resetForTest());

  testWidgets('menampilkan semua situasi dalam satu daftar yang bisa dicari',
      (tester) async {
    await tester.pumpWidget(appWrap(const SituasiScreen(), locale: const Locale('id')));
    await tester.pumpAndSettle();

    final all = await quranSituasi.all();
    expect(find.byKey(const Key('situasi-grid')), findsOneWidget);
    // Label pertama terlihat; sisanya bisa digulir (bukan harus semua tampil).
    expect(find.byKey(Key('situasi-item-${all.first.id}')), findsOneWidget);
  });

  testWidgets('pencarian menyaring situasi', (tester) async {
    await tester.pumpWidget(appWrap(const SituasiScreen(), locale: const Locale('id')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('situasi-search')), 'sedih');
    await tester.pumpAndSettle();
    // Hanya yang cocok yang tersisa.
    final all = await quranSituasi.all();
    expect(find.byKey(Key('situasi-item-${all.first.id}')), findsOneWidget);
    expect(find.byKey(Key('situasi-item-${all.last.id}')), findsNothing);
  });
}
```

**Step 2: Jalankan, pastikan GAGAL** → compile error (layar belum ada).

**Step 3: Implementasi**

Layar mengikuti pola yang sudah ada di repo (bukan gaya baru):
- `Scaffold` + `SafeArea` biasa (route pushed — **wajib**, bukan `bottom: false`;
  lihat `references/layout-inset-testing.md`).
- Header dengan tombol back, judul `sitTitle`, dan `TextField` berkunci
  `situasi-search` (pola sama dengan `hadis_screen.dart`/`doa_screen.dart`).
- Isi: grid 2 kolom (bukan 3 — label situasi lebih panjang dari label Akses Cepat)
  di dalam `CustomScrollView`, key `situasi-grid`.
- Tiap item: ikon + label `sit_<id>`, tap → push halaman detail (Task 5).

**Step 4: Jalankan, pastikan LULUS.**

**Step 5: Commit** `feat(situasi): layar daftar situasi + pencarian`

---

### Task 5 — Halaman detail situasi (3 ayat, tiap ayat bisa ditap)

**Files:**
- Create: `lib/screens/situasi_detail_screen.dart`
- Test: `test/situasi_detail_test.dart`

**Step 1: Tulis tes yang GAGAL**

```dart
testWidgets('menampilkan tepat 3 ayat + 1 action', (tester) async {
  quranSituasi.resetForTest();
  await tester.pumpWidget(appWrap(
    const SituasiDetailScreen(situationId: 'sedih'), locale: const Locale('id')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('situasi-ayah-0')), findsOneWidget);
  expect(find.byKey(const Key('situasi-ayah-1')), findsOneWidget);
  expect(find.byKey(const Key('situasi-ayah-2')), findsOneWidget);
  expect(find.byKey(const Key('situasi-ayah-3')), findsNothing);
});

testWidgets('tiap ayat bisa ditap untuk membuka QuranReader di ayat itu',
    (tester) async {
  quranSituasi.resetForTest();
  await tester.pumpWidget(appWrap(
    const SituasiDetailScreen(situationId: 'sedih'), locale: const Locale('id')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('situasi-ayah-1')));
  await tester.pumpAndSettle();
  expect(find.byType(QuranReader), findsOneWidget);
});

testWidgets('terjemahan ayat diambil dari aset lokal sesuai locale', (tester) async {
  quranSituasi.resetForTest();
  // id  -> terjemahan Indonesia
  await tester.pumpWidget(appWrap(
    const SituasiDetailScreen(situationId: 'sedih'), locale: const Locale('id')));
  await tester.pumpAndSettle();
  expect(find.textContaining('Janganlah kamu bersikap lemah'), findsOneWidget);
});
```

**Step 2: Jalankan, pastikan GAGAL.**

**Step 3: Implementasi**

- Load ayat lewat `quranData.ayahs(surah, english: quranUseEnglish(locale))` —
  **satu jalur dengan sisa app**, jangan bikin loader baru.
- Tiap ayat: kartu berisi nomor ayat + teks Arab (`AppText.arabic`) + terjemahan,
  key `situasi-ayah-<i>`.
- Tap satu ayat → `QuranReader(surah:, initialAyah:)`.
- Wajib: `SafeArea` + daftar bisa digulir sampai bawah tanpa tertutup nav button.

**Step 4: Jalankan, pastikan LULUS.**

**Step 5: Commit** `feat(situasi): halaman detail 3 ayat + action`

---

### Task 6 — Kontrol negatif Task 4-5

- [ ] Kembalikan `SafeArea` jadi `SafeArea(bottom: false)` → tes inset harus merah.
- [ ] Tambah ayat ke-4 di JSON → tes "tepat 3 ayat" harus merah.
- [ ] Ganti `quranUseEnglish(locale)` jadi `english: false` → tes locale en harus merah.
- [ ] Kembalikan → hijau.

---

### Task 7 — Tile di Akses Cepat

**Files:**
- Modify: `lib/screens/home_tab.dart:1474-1518` (daftar `actions`)
- Test: `test/home_quick_actions_test.dart` (tambah tes)

- [ ] **Step 1:** Tambahkan entri ke `actions`:
      `(icon: AppIcons.psychology, label: AppL10n.of(context).homeQuickSituasi, onTap: () => _push(const SituasiScreen()), daily: false)`.
- [ ] **Step 2:** Tes: tile ada, label tidak ter-ellipsis di 360dp, tap → `SituasiScreen`.
- [ ] **Step 3:** Jalankan `flutter test test/home_quick_actions_test.dart` → hijau.
- [ ] **Step 4:** Commit.

**Catatan layout:** jumlah tile jadi 8 → 2 baris penuh 3 + baris terakhir 2.
Kisi `_actionRow` sudah menangani baris tidak penuh (slot kosong), jadi tidak ada
perubahan layout. Golden `home_hero*` tidak terpengaruh (di-scope ke
`Key('home-hero-card')`).

---

### Task 8 — ARB 4 bahasa (chrome)

**Files:** `lib/l10n/app_{id,en,ms,tr}.arb` + regenerate `lib/l10n/app_localizations*.dart`

- [ ] Tambah ~137 kunci × 4 bahasa. Terjemahan konten tetap aturan repo:
      chrome → ARB; konten ayat → ikut `quranUseEnglish`.
- [ ] **Nol em dash** di keempat ARB (menghindari **A-1**, lihat jebakan di bawah).
- [ ] Jalankan `flutter gen-l10n`, pastikan `app_localizations*.dart` ikut berubah.
- [ ] Jalankan `flutter test test/learning_multilang_test.dart` → hijau.
- [ ] Parity kunci 4 bahasa (repo punya tesnya).

**Jebakan:** perubahan ARB **memerahkan golden #1 di CI** (repo ini menandai ARB
sebagai pemicu golden). Alur yang benar: kerjakan di branch `feat/**`, dispatch
`update_goldens=true` di branch itu, bandingkan hasilnya, commit golden di branch
yang sama, baru ff-merge ke main. Jangan regenerate golden lokal lalu commit ke main.

---

### Task 9 — Golden + suite penuh

**Files:** `test/goldens/situasi_screen.png`, `test/situasi_golden_test.dart`

- [ ] **Step 1:** Golden layar daftar (tema gelap saja — konvensi repo: gelap adalah
      identitas utama; varian kedua hanya menggandakan permukaan CI).
- [ ] **Step 2:** Asersi judul **sebelum** `matchesGoldenFile` (pelajaran golden
      onboarding: en_1 & en_6 pernah keluar byte-identik dan tetap "lulus").
- [ ] **Step 3:** Regenerate lewat CI di branch `feat/**`, unduh artifact `goldens`,
      bandingkan (harus identik dengan lokal), lalu commit.
- [ ] **Step 4:** `flutter analyze` bersih + `flutter test` penuh hijau.
- [ ] **Step 5:** Commit + push.

---

## Verification checklist (akhir)

- [ ] `flutter analyze` → `No issues found!`
- [ ] `flutter test` → semua hijau (baseline sekarang **676**; ekspektasi naik)
- [ ] Setiap guard **terbukti merah** saat bug dikembalikan (Task 2, 6)
- [ ] Nol em dash di 4 ARB
- [ ] Parity kunci ARB 4 bahasa
- [ ] Golden baru identik lokal vs CI; nol golden lama berubah
- [ ] Tidak ada string Indonesia yang bocor di layar English
- [ ] Top 5 situasi paling sering dibuka user dites manual di HP (nav button,
      scroll sampai bawah, buka ayat, action)
- [ ] APK dibangun **hanya kalau user minta eksplisit**

---

## Risks & open questions

| Risiko | Dampak | Mitigasi |
|---|---|---|
| **Mutu kurasi ayat** — 171 ayat untuk 57 situasi emosional | Paling serius: salah pilih ayat bisa melukai user yang sedang rapuh | Standar mutu tertulis (rahmah bukan hukum) + tinjauan user per batch sebelum lanjut |
| Tumpang tindih dengan Doa (22 tag: `tidur`, `malam`) | Dua fitur terasa sama | D2 harus dijawab dengan **data tag sebenarnya**, sebelum Task 1 |
| 57 chrome label × 4 bahasa | Beban ARB besar, rawan em dash & drift | Task 8 terpisah; guard parity + em dash |
| Label + deskripsi turun ke 4 bahasa | Konsistensi istilah (mis. "insecure", "burnout" tidak punya padanan Indonesia mapan) | Perlu keputusan: pakai kata serapan atau parafrase. **Belum diputuskan** |
| Fitur jadi tidak ditemukan user | Sia-sia | Tile di Akses Cepat (precedent: Doa/Asma/Dzikir masuk lewat jalur yang sama) |
| Kurasi 57 situasi memakan banyak batch | Plan berhenti di tengah | D3: batch 6× + tiap batch punya commit sendiri, jadi selalu bisa berhenti dengan state hijau |

## Keputusan yang SUDAH dijawab (2026-10-09)

1. **D1** — nama fitur: **"Ayat Rekomendasi"**.
2. **D2** — tombol baru, **tidak berhubungan dengan Doa**. #52 pagi & #53 malam
   dipertahankan (audit 22 tag Doa sudah dijalankan, hasilnya di bagian D2).
3. **D3** — **kurasi dulu**, rilis setelah kurasi tuntas.
4. **D4** — **hanya buka ayat Quran**. Tidak ada doa, tidak ada dzikir.
   → enum `SituationAction` dihapus dari desain.
5. **Istilah** — **pakai kata serapan** untuk konsep modern (insecure, burnout,
   overthinking, doomscrolling, quarter life crisis). Tidak diparafrase.
6. **Judul halaman** — **"Ayat Rekomendasi"**, subjudul **"Kamu lagi ngerasain apa?"**.

## Sisa pertanyaan (1, butuh konfirmasi)

- **Label tile Akses Cepat.** "Ayat Rekomendasi" = 112px → `FittedBox` menyusut ke
  **65%** (6,5sp). Usul: label tile **"Rekomendasi"** (95%), sedangkan judul halaman,
  label aksesibilitas, dan subjudul tetap "Ayat Rekomendasi" / "Kamu lagi ngerasain
  apa?" supaya penamaan pilihan user utuh di tempat yang penting. Kalau user ingin
  label tile persis "Ayat Rekomendasi", konsekuensinya label itu dirender paling
  kecil di antara seluruh label tile — dan itu diterima secara sadar.
