---
target: NaikLevelScreen
total_score: 16
max_score: 28
na_heuristics: 5,9,10
p0_count: 1
p1_count: 2
timestamp: 2026-08-23T14-50-56Z
slug: lib-screens-naik-level-screen-dart
---
Method: dual-agent (A: sa-0-8812f174 · B: sa-1-eb0cf606)

Target: lib/screens/naik_level_screen.dart (NaikLevelScreen — layar selebrasi naik level, mode Experience/celebration). Detector deterministic tidak berlaku untuk Flutter/Dart (engine hanya HTML/CSS/JS); Assessment B diganti static code audit.

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | XP chip tampil "+0" saat xpGained null — silent lie |
| 2 | Match System / Real World | 3 | Copy ID natural; "NEW" Inggris nyelip di kalimat Indonesia |
| 3 | User Control and Freedom | 2 | Multi-level sequence tak bisa di-skip; hanya KEMBALI di akhir |
| 4 | Consistency and Standards | 3 | Reuse token konsisten; BoxShadow custom (dark-only) ad hoc |
| 5 | Error Prevention | n/a | Celebration screen — tak ada input |
| 6 | Recognition Rather Than Recall | 3 | STATUS TERBARU menampilkan total saat ini, bukan delta level-up ini |
| 7 | Flexibility and Efficiency | 1 | No skip, no auto-dismiss, wajib tap LANJUT per level |
| 8 | Aesthetic and Minimalist Design | 2 | 3 chips + 3 baris status + badge + headline bersaing; panel stats = dashboard berkostum pesta |
| 9 | Error Recovery | n/a | Tak ada error path |
| 10 | Help and Documentation | n/a | Copy self-explaining |
| **Total** | | **16/28** | **Acceptable (57%)** |

## Design Specificity Verdict

**Half-generic.** Palet emerald/gold/cyan milik app, rank vocabulary milik produk. Tapi selebrasinya stock game-confetti: medali workspace_premium, confetti persegi, "NAIK LEVEL!" bisa milik app fitness mana pun. Nol signifier Islami: tak ada geometri bulan-bintang, tak ada "Barakallah", tak ada kaitan dengan amal yang memicu (sholat/dzikir/quran). Layar merayakan angka, bukan progres ibadah — itulah missed hook terbesar produk ini.

Deterministic scan: detect.mjs return [] — absence of capability untuk Dart, bukan clean bill. Static audit: 0 Semantics di file; fontSize hardcoded 20/10/12 (L200, 207, 266); stagger 250-850ms tanpa reduced-motion gate; particleCount 70 (tertinggi di app); semua warna dari token (bagus); alpha 0.1/0.5/0.6 untuk shadow/glow.

## Overall Impression

Kerangka selebrasi solid — motion grammar konsisten, theme-aware, multi-level sequencing ada. Tapi: tak punya identitas Muslim, panel stats merampok puncak emosi, dan multi-level flow terasa seperti pagination. Biggest opportunity: headline yang menyebut amal ("Subuhmu menaikkan levelmu") + hapus panel stats.

## What's Working

1. Multi-level sequencing ada (kebanyakan app skip) + counter 1/N jujur.
2. Disiplin kontras theme-aware: gold ink vs fill, tombol solid di light theme untuk AA.
3. Motion grammar konsisten: satu pola Entrance, staggered delays, elastic badge — terasa authored.

## Priority Issues

- **[P0] Nol Semantics.** Screen reader dapat fragmen teks mentah; badge icon tanpa label; chips tak terbaca sebagai unit. Fix: Semantics(header) di headline, label badge, combined chips. → /impeccable harden
- **[P1] Data mismatch mid-sequence:** _rewards/_unlocked baca GameService.current.xp (state final) di tiap step — step 1/3 menampilkan total level N, bukan level yang dirayakan. Fix: hitung dari startLevel + _step, bukan current. → /impeccable layout
- **[P1] "+0 XP" saat xpGained null** — layar reward menampilkan nol. Fix: sembunyikan chip XP bila null. → /impeccable clarify
- **[P2] Generic celebration — zero Islamic signifier.** Medali + confetti generik; tak ada kaitan ke ibadah. Fix: crescent/star geometry, copy "Masha Allah/Barakallah", headline menyebut amal pemicu. → /impeccable delight
- **[P2] Multi-level = receipt printer.** N layar identik + tap LANJUT tiap level; end lemah (panel stats lagi, anticlimax). Fix: kompres ke satu crescendo screen, closing beat lebih besar. → /impeccable animate

## Persona Red Flags

- **Jordan (first-timer):** belum tahu arti XP/rank title — tak ada kalimat konteks ("dari sholat Subuhmu"); tak tahu harus tap LANJUT 3x.
- **Casey (mobile):** fine — CTA tunggal di bawah; friction LANJUT-per-level pada multi-up berulang.
- **Sam (a11y):** worst case — nol Semantics, confetti tak bisa dimatikan (vestibular), teks label 10px di bawah floor, glow shadow di light theme belum teruji kontrasnya.

## Minor Observations

- Ikon lock_open di panel "unlocked" yang tidak membuka apa pun — barisnya stats, metafora menyesatkan.
- Random(7) deterministic — confetti sama tiap kali; fine untuk perf, membunuh kejutan.
- _unlocked hitung ulang getLevelInfo padahal info sudah ada di build.
- Badge 140px fixed + Spacer tanpa SingleChildScrollView — risiko overflow di layar pendek/landscape.

## Questions to Consider

1. Whose celebration is this — metrik app atau ibadah user? Bagaimana kalau headline menyebut amalnya?
2. levelsGained 5 = 5 layar perayaan atau struk kasir? Kompres jadi satu crescendo?
3. Perlukah panel stats di puncak emosi — atau itu tugas home tab yang berkostum pesta?
