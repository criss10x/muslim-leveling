---
target: page bagikan ayat di tab quran saat klik icon share
total_score: 21
max_score: 40
na_heuristics: 
p0_count: 1
p1_count: 2
timestamp: 2026-08-17T21-41-44Z
slug: lib-widgets-quran-share-sheet-dart
---
# Critique — Bagikan Ayat (quran_share_sheet.dart)

**Method: dual-agent (A: sa-0-7e200b7e · B: sa-1-ec8ed0d1)**

## Design Health Score

| # | Heuristic | Skor | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 2 | `_sharing` cuma ganti label→spinner; sukses/gagal tak pernah diumumkan |
| 2 | Match System / Real World | 3 | 4 swatch semua berlabel "Solid" (l.34-41) ambigu |
| 3 | User Control & Freedom | 2 | `fullscreenDialog` tanpa close eksplisit; keluar cuma back gesture |
| 4 | Consistency & Standards | 3 | Magic number fontSize 6/8/10/11/12 + swatch 40x40 bocor dari token |
| 5 | Error Prevention | 2 | Tanpa guard overflow ayat panjang; swatch 40px < 48dp |
| 6 | Recognition > Recall | 2 | Swatch kotak warna tanpa label, user harus ingat pilihan |
| 7 | Flexibility & Efficiency | 2 | Pindah mode reset ke `first` (l.468-470), pilihan hilang |
| 8 | Aesthetic & Minimalist | 3 | Footer GP badge + app name crowded (l.259-282) |
| 9 | Error Recovery | 0 | `catch (_) { // silent }` telan semua error |
| 10 | Help & Documentation | 2 | Tanpa hint kontras bg estetik / arah RTL |
| **Total** | | **21/40** | **Acceptable** |

## Design Specificity

**LLM (A):** Authored untuk produk ini, bukan generic — palet brand (jade #0B3D2E, gold), Amiri Quran untuk Arab, identitas "Muslim Leveling · Level Up Iman", GP badge custom inline. Kekhususan malah jadi beban di beberapa titik (accent theme-dependent, footer crowding).

**Detector (B):** `detect.mjs` exit 0 + `[]` — **N/A untuk Dart** (bukan "clean"). Detector cuma parse HTML/CSS; tidak bisa baca `Colors.*` / `ThemeData` / widget Flutter.

**Visual overlay:** Tidak ada. Native Flutter Android, tanpa web target/emulator; `flutter build web` pun render ke `<canvas>`, tak bisa di-inject DOM. Tidak ada bukti visual tiruan.

## Overall Impression

Kartu 9:16 rapi dan WYSIWYG-nya akurat (FittedBox + RepaintBoundary). Celah terbesar ada di sisi non-visual: kegagalan share di-swallow diam-diam — user tak pernah tahu share gagal. Ini showstopper untuk sebuah fitur yang seluruh tujuannya adalah mengirim gambar keluar.

## What's Working

- **Scrim estetik bertingkat** (l.153-168) — gradient 0.45→0.75 jaga keterbacaan teks di `mosque_bg.jpg`.
- **WYSIWYG akurat** (l.376-392) — FittedBox + RepaintBoundary = preview persis hasil capture.
- **Tombol disable saat proses** (l.441) — cegah double-tap native share sheet.

## Priority Issues

- **[P0] Silent error** (l.354-356). Gagal share (channel hilang, permission, disk) tak terlihat sama sekali. **Fix:** ganti `catch (_) {}` dengan SnackBar via `ScaffoldMessenger` + reset `_sharing`.
- **[P1] Accent theme-bug** (l.143). `AppColors.secondaryFixed` di light theme = `#9A6700` (gold gelap untuk surface terang) → dirender di atas bg kartu yang selalu gelap → nama surah Arab kontras rendah. **Fix:** pakai `secondaryFixedDim`/`goldFill` (cerah) atau konstanta gold-terang untuk teks di kartu.
- **[P1] Seleksi mode reset** (l.468-470). Pindah mode → kembali ke `first`, pilihan user dalam mode hilang. **Fix:** simpan `_presetIdx` per-kind, restore saat balik.
- **[P2] Touch target swatch 40x40** (l.421-422). Di bawah 48dp + padding 5px menyempit area tap. **Fix:** InkWell 48x48 dengan visual 40x40 di tengah + `Semantics` label.
- **[P3] Overflow ayat Arab** (l.214-223). Tanpa `maxLines`/`overflow`; ayat panjang berisiko overflow 604px. **Fix:** `maxLines` + `TextOverflow` atau `FittedBox` khusus teks ayat.

## Persona Red Flags

- **Casey (satu tangan):** swatch 40x40 sulit di-tap jempol; footer GP badge compact 0.85 + font 6-8px tiny.
- **Jordan (first-timer):** 4 swatch berlabel sama "Solid" bingung; tak ada hint kontras bg estetik; close hanya lewat back gesture `fullscreenDialog`, tak ada petunjuk keluar.
- **Sam (a11y):** `GestureDetector` swatch tanpa `Semantics`/label (l.416); indikator terpilih cuma warna border — tak ada cue non-warna; font 6-8px tak terbaca; error silent tak diumumkan ke screen reader.

## Minor Observations

- `_bgPresets.indexOf(p)` O(n) per build (l.418, 424) — cache index.
- 4 label "Solid" duplikat (l.34-41) — beri nama unik.
- Magic number radius `20` kartu (l.148) dan `12` swatch (l.428) vs token `AppRadius`.
- `nameArabic` (l.178) tanpa `textDirection: rtl` explicit.
- File temp `ayat_*.png` tak dibersihkan (l.344-345).
- `_sharing` tanpa timeout — channel hang = spinner abadi.
