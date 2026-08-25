---
target: achievement unlock + share flow
total_score: 22
max_score: 36
na_heuristics: 10
p0_count: 0
p1_count: 3
timestamp: 2026-08-25T15-01-12Z
slug: lib-widgets-achievement-medal-dart
---
# Critique: Achievement Unlock + Share Flow

Method: ⚠️ DEGRADED: single-context (Assessment A subagent crashed pada sintesis akhir setelah membaca semua sumber; Assessment A dieksekusi inline oleh parent yang juga sudah membaca semua file target. Assessment B = subagent terisolasi, sukses penuh.)

Target surfaces: `showAchievementUnlock` (achievement_medal.dart), `_SharePreviewDialog` + `_ShareCardRender` (share_card.dart), grid `AchievementsScreen` (achievements_screen.dart).

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | Spinner share ada + label berubah 'Bagikan Lagi' saat sukses, tapi semua kegagalan ditelan `catch (_) // silent` — user tidak pernah tahu share gagal |
| 2 | Match System / Real World | 3 | Bahasa Indonesia + frasa Islami ('Semoga istiqomah') + jargon MOBA (FIRST BLOOD, MVP) konsisten dengan identitas produk |
| 3 | User Control and Freedom | 3 | barrierDismissible + tombol Tutup/MANTAP!; tapi antrean multi-unlock memaksa tap satu-satu, tanpa skip/batch |
| 4 | Consistency and Standards | 3 | Warna tier konsisten medal→popup→card; tapi dua announcer (achievement vs side-quest) beda level a11y: side-quest hormati reduced-motion + Semantics, achievement tidak |
| 5 | Error Prevention | 2 | Tidak ada guard untuk string panjang di dialog/kartu; judul 19-char uppercase fontSize 22 tanpa maxLines/FittedBox |
| 6 | Recognition Rather Than Recall | 3 | Medali + label terlihat di galeri; tapi ikon share 17px tanpa label di pojok medali sulit ditemukan |
| 7 | Flexibility and Efficiency | 2 | Tidak ada cara share langsung dari popup tanpa membuka preview; antrean unlock tanpa 'skip semua' |
| 8 | Aesthetic and Minimalist Design | 3 | Kartu 9:16 komposisinya rapi (header→medal→nama→user→CTA), tier glow proporsional |
| 9 | Error Recovery | 1 | Gagal render/gagal MethodChannel/gagal intent → diam total, tanpa SnackBar, tanpa retry |
| 10 | Help and Documentation | n/a | Flow selebrasi; tidak ada konsep yang butuh dokumentasi |
| **Total** | | **22/36** | **Acceptable (61%)** |

## Design Specificity Verdict

**LLM assessment:** Autored untuk produk ini. Medali heksagon ala ML dengan tier gradient, copy 'Level Up Iman, Level Up Kehidupanmu', geometric divider, dan kartu 9:16 khusus IG Story/WA — semua khas Muslim Leveling, bukan template. Yang masih generic: popup unlock-nya sendiri (GlassPanel + Column standar) dan absennya haptic/suara di momen puncak — perayaan terasa visual-only.

**Deterministic scan:** `detect.mjs` exit 0, **0 findings** pada 4 file Dart — detector memang HTML-oriented, jadi no-op di sini. Tidak ada false positive; temuan mekanis datang dari static pass Assessment B.

**Visual overlays:** tidak berlaku (native Android, bukan browser).

## Overall Impression

Momen unlock-nya sudah jadi peak yang nyata — elastic medal 700ms + confetti + tier glow. Yang meruntuhkan: begitu user menekan 'Bagikan', pengalaman bisa mati tanpa suara (silent catch + iOS handler tidak ada), dan kartu 9:16 bisa overflow pada judul panjang karena tidak ada satupun maxLines/FittedBox di seluruh pipeline share. Peluang terbesar: bikin share path se-kokoh unlock path.

## What's Working

1. **Tier system sebagai bahasa visual tunggal** — `tierColors()` satu sumber dipakai medal, popup, label, kartu; collector/hall_of_fame dapat treatment emas-merah khusus. Konsisten dan mudah dikenali.
2. **Announcer queue + AnnouncerGate** — satu selebrasi pada satu waktu, tidak race dengan side-quest popup; mounted-guard rapi di semua async path.
3. **Kartu share sadar platform** — 9:16 (320×569, capture pixelRatio 3 → 960×1707) memang format Story; stat-line dinamis per achievement id menunjukkan data nyata user, bukan template kosong.

## Priority Issues

1. **[P1] Share gagal tanpa suara.** `catch (_) { // silent }` (share_card.dart L467) menelan kegagalan render, tulis file, MethodChannel, dan share intent. Di iOS tidak ada handler `muslim_leveling/share` sama sekali → `MissingPluginException` → diam.
   - Why it matters: tombol paling penting di flow ini bisa tidak melakukan apa-apa dan user mengira berhasil.
   - Fix: ganti silent catch dengan SnackBar 'Gagal membagikan kartu'; tampilkan SnackBar juga saat `boundary == null`/`bytes == null`.
   - Command: `/impeccable harden`
2. **[P1] Nested Expanded di preview dialog.** `_actionBtn` mengembalikan `Expanded`, lalu call-site 'Bagikan' membungkusnya dalam `Expanded` lagi (L531) → ParentDataWidget misuse, assertion error di debug, undefined di release.
   - Fix: hapus `Expanded` di dalam `_actionBtn`, biarkan call-site yang bungkus (satu call-site 'Tutup' malah tidak dibungkus → dua bug sekaligus).
   - Command: `/impeccable harden`
3. **[P1] Teks tanpa overflow guard di dialog unlock & kartu.** Judul `displayHero(30)` dan `def.desc` tanpa maxLines di Column non-scrollable; di kartu, judul fontSize 22 w900 uppercase tanpa maxLines dalam kolom fixed 569px dengan Spacer → judul panjang (e.g. 19 char) wrap dan meluber keluar kartu/terpotong di PNG hasil capture.
   - Fix: `maxLines` + `TextOverflow.ellipsis` atau FittedBox pada judul/desc di kedua tempat.
   - Command: `/impeccable harden`
4. **[P2] Asimetri aksesibilitas dua announcer.** Side-quest popup hormati `disableAnimations` + punya Semantics; achievement unlock popup: 0 MediaQuery, 0 Semantics, confetti selalu jalan.
   - Fix: tiru pola side_quest_announcer.dart (reduceMotion gate + Semantics label) ke `showAchievementUnlock`.
   - Command: `/impeccable adapt`
5. **[P2] Touch target kecil.** Ikon share di grid medali ~17px, back 40×40, tombol preview ~40px (semua < 44).
   - Fix: perbesar hit area ikon share (min 44), atau pindahkan share ke dialog detail yang sudah ada.
   - Command: `/impeccable adapt`

## Persona Red Flags

**Casey (distracted mobile user):** ikon share 17px di pojok medali (top:-2, right:-2) nyaris mustahil ter-tap satu tangan → dia buka detail dialog lalu bingung karena di detail tidak ada tombol Bagikan sama sekali (hanya di grid & popup). Tiga unlock beruntun = tiga dialog berurutan, masing-masing wajib tap 'MANTAP!' — tidak ada jalan pintas.

**Jordan (first-timer):** di grid, medali terkunci vs terbuka hanya beda warna/glyph — ikon gembok jelas, OK. Tapi begitu unlock, tombol 'Bagikan' di popup tidak menjelaskan hasilnya akan seperti apa (harus masuk preview dulu). Jika share gagal diam-diam, Jordan menyimpulkan fitur rusak dan tidak akan coba lagi.

## Minor Observations

- Kartu share hardcode 17 warna literal + 7 ukuran font literal — tidak ikut tema light/dark app (mungkin disengaja: kartu harus konsisten sebagai artefak gambar; pertahankan tapi beri komentar alasan).
- Popup unlock tidak punya haptic feedback (`HapticFeedback.mediumImpact` saat medali mendarat = 1 baris, peak-end naik).
- 'ACHIEVEMENT UNLOCKED!' di popup pakai Inggris, sisanya Indonesia — pilih satu bahasa untuk header ini atau biarkan sebagai istilah game yang konsisten dengan FIRST BLOOD/MVP.
- Grid fixed 3 kolom di semua lebar layar; acceptable untuk app ponsel-only.

## Questions to Consider

- Kalau share gagal, lebih baik jatuh ke SnackBar error atau fallback 'simpan gambar ke galeri'?
- Popup unlock tanpa suara/haptic terasa kurang untuk produk gamifikasi — berani tambah stinger audio pendek, atau biarkan silent karena dipakai saat waktu sholat?
