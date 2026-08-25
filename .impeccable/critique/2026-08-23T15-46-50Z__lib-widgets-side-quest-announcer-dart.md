---
target: SideQuestAnnouncerOverlay
total_score: 20
max_score: 28
na_heuristics: 5,9,10
p0_count: 0
p1_count: 3
timestamp: 2026-08-23T15-46-50Z
slug: lib-widgets-side-quest-announcer-dart
---
Method: dual-agent (A: sa-0-47729678 · B: sa-1-a84ec932)

Target: lib/widgets/side_quest_announcer.dart (SideQuestAnnouncerOverlay — popup selebrasi side quest auto-complete, mode Experience/celebration). Detector deterministic tidak berlaku untuk Flutter/Dart (engine hanya HTML/CSS/JS); Assessment B = static code audit.

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 4 | +15 XP jelas, queue ter-drain visible |
| 2 | Match System / Real World | 3 | "Istiqomah"/"Tilawah" bagus; "SIDE QUEST" jargon gamer tak diterjemahkan |
| 3 | User Control and Freedom | 3 | barrierDismissible + MANTAP; tak ada skip queue 3 popup |
| 4 | Consistency and Standards | 2 | Clone pola achievement tapi diverge seremoni (no crescent vs NaikLevelScreen baru); emoji vs Material icons |
| 5 | Error Prevention | n/a | Celebration only |
| 6 | Recognition over Recall | 3 | Icon+warna per quest membantu; "+15 XP" hardcoded terlepas dari nilai claim aktual |
| 7 | Flexibility and Efficiency | 2 | No reduced-motion (sibling NaikLevelScreen punya), no queue skip |
| 8 | Aesthetic and Minimalist | 3 | Hierarki bersih; 5 level teks bertumpuk di icon 120px agak sibuk |
| 9 | Error Recovery | n/a | Tak ada error path |
| 10 | Help and Documentation | n/a | Self-evident |
| **Total** | | **20/28** | **Good (71%)** |

## Design Specificity Verdict

**Weak / mostly generic.** Popup ini reskin dialog achievement: GlassPanel, confetti, "MANTAP!", barrier 0.55, elasticOut identik. Nol signifier Islami — padahal sibling NaikLevelScreen baru saja dapat crescent badge + copy Masha Allah/Barakallah. Inconsistency itu masalah nyata: side quest fire TIAP HARI tapi terasa MURAH dibanding momen langka level-up. Copy membawa semua identitas produk ("Istiqomah!", "🌙" emoji — melanggar konvensi Material icons app). Fix murah: satu baris copy Islami atau crescent vektor menggantikan emoji.

Deterministic scan: detect.mjs → [] (absence of capability untuk Dart, bukan clean bill). Static audit: 0 Semantics; 0 hardcoded fontSize (semua AppText ✓ — lebih bersih dari achievement_medal yang punya fontSize:10); particleCount 45; barrierDismissible true; 0 disableAnimations/MediaQuery; 0 raw hex (achievement_medal punya 5); mounted guards ada di _drain tapi tak ada context.mounted dalam _show; dua overlay (achievement + side quest) independent — logPrayerAsync isi KEDUA notifier sekaligus → race dialog menumpuk simultan (bug code kandidat).

## Overall Impression

Arsitektur drain-loop disiplin dan konsisten dengan pola achievement — itu kekuatan sejati. Tapi popup ini menyela ibadah di tengah aksi (tap dzikir ke-100, scroll Quran ayat ke-10), dan gamification seharusnya membingkai ibadah, bukan menyergapnya. Biggest opportunity: hormati khushu' — selebrasi lebih ringan/delayed, atau collapse queue jadi satu "Alhamdulillah".

## What's Working

1. Reuse pola disiplin — ValueNotifier + drain loop + mount sekali di DashboardShell; caller tanpa context.
2. Chaining level-up (e.$2 > 0 → push NaikLevelScreen, awaited per entry) benar dan terdokumentasi.
3. Mapping warna+icon per quest bersih; 0 raw hex, 0 hardcoded fontSize — lebih bersih dari medal.

## Priority Issues

- **[P1] Interupsi mid-ibadah.** Modal penuh di tap dzikir ke-100 memecah khushu'. Medali datang di natural endpoint; side quest selesai mid-action. Fix: defer/soften (toast saat layar ibadah aktif) atau collapse queue jadi ringkasan sesi. → /impeccable quieter
- **[P1] No reduced motion.** elasticOut + confetti + scale abaikan MediaQuery.disableAnimations; sibling sudah mendukung. → /impeccable animate
- **[P1] Nol Semantics.** TalkBack baca fragmen urut acak; no liveRegion. → /impeccable harden
- **[P2] Tanpa signifier Islami + emoji.** Inconsistent dengan NaikLevelScreen baru; momen harian lebih murah dari momen langka. → /impeccable delight
- **[P2] Queue >1 tanpa collapse/counter.** 3 quest selesai = 3 popup serial (+ chain NaikLevelScreen) — 4-6 modal bertumpuk. → /impeccable distill
- **[P3] "+15 XP" hardcoded** padahal nilai claim ada di game logic — drift risk. → /impeccable clarify

Plus bug code (di luar skor desain): dua overlay independent dapat race/stack dialog simultan saat logPrayerAsync mengisi kedua notifier dalam satu call — shared busy lock di DashboardShell (~5 baris).

## Persona Red Flags

- **Jordan (first-timer):** "SIDE QUEST" tak diterjemahkan + popup tiba-tiba mid-dzikir = bingung; bisa dismiss via barrier tanpa tahu XP sudah masuk.
- **Casey (mobile):** layout aman di 360dp, tapi chain queue memaksa tap berulang satu tangan.
- **Sam (a11y):** nol Semantics, no reduced-motion, kontras label caps warna tersier di light theme belum terverifikasi AA.

## Minor Observations

- Judul mengulang label ("SIDE QUEST SELESAI!" + "Dzikir 100x Selesai!") — redundan.
- XP sudah di-grant SEBELUM dialog terbuka; popup bilang "+15 XP" seolah memberi saat itu juga — framing keliru.
- _show tanpa context.mounted guard internal; mengandalkan guard caller (aman untuk sekarang, rapuh).
- No dedupe kalau quest sama ter-announce dua kali.

## Questions to Consider

1. Haruskah menyelesaikan ibadah memicu modal sama sekali — atau tick XP di header adalah selebrasi yang lebih hormat?
2. Kalau 3 quest tuntas, mana lebih Islami: 3 popup arcade atau satu kartu "Alhamdulillah, 3 quest harian tuntas"?
3. Apakah popup boleh muncul mid-tap, atau menunggu user berhenti/jeda layar?
