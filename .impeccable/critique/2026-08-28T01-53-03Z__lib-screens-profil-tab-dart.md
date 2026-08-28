---
target: streak per-sholat (tab profil)
total_score: 15
max_score: 24
na_heuristics: 5,7,10
p0_count: 2
p1_count: 1
timestamp: 2026-08-28T01-53-03Z
slug: lib-screens-profil-tab-dart
---
# Audit: Streak Per-Sholat (Tab Profil)
Method: dual-agent (A: sa-0-3b385f44, B: sa-1-2376f6a2)

H1 1, H2 2, H3 1, H4 2, H5 n/a, H6 1, H7 n/a, H8 2, H9 0, H10 n/a → 11/24 (Acceptable 46%, but H1/H3/H6/H9 rendah)

Specificity: half-authored. Label IDN, Friday/Jumat row lokal. Grammar visual = Duolingo-clone (Icons.fire+N).

## Verified mechanical risks
R1 Streak ambiguity: current saja dirender, best/lastDate/freezeAvailable di StreakState L80 tapi tidak dipakai → current=7 broken 3 hari lalu = current=7 hidup
R2 _evalStreakMissed L1950 recovery branch menulis current×0.75 tapi TIDAK menulis lastDate (verified) → chain stale sampai user re-log
R3 DateTime.parse unguarded di runDailyCheck L1868 (verified) — corrupted save → daily refresh gagal total
R4 0 Semantics di streak block (TalkBack baca 'Subuh 7' tanpa konteks)
R5 0 text overflow safety net pada 5 Text widget
R6 Font 10pt (label) & 12pt (minggu) di bawah baseline 12sp
R7 Hardcoded prayer list diduplikasi 3× (profil_tab, game_service logPrayer, wajibList)
R8 Tidak ada cross-link ke achievement (subuh_solo_carry/legend)
R9 unlogPrayer revert naive (current-1 ignoring date continuity)
R10 Cutoff 03:00 tidak disosialisasikan ke UI

## Priority
- P0: status 'today' per-sholat (dot jika lastDate==today, warning jika yesterday, hide jika older)
- P0: surface 'best' + 'freezeAvailable' dari StreakState
- P1: sort row by weakness + at-risk cell bold + chevron
- P1: Semantics wrapper pada streak row
- P2: tambah suffix 'hari' pada count daily
- P2: Friday row selalu render (best/4 minggu) untuk discoverability
- P2: deduplicate wajibList import dari game_service
- P3: text overflow safety net pada 5 Text
- P3: fix _evalStreakMissed tulis lastDate setelah recovery
- P3: try/catch di DateTime.parse L1868

## Persona
Casey: '12 0 0 0 0' dibaca sebagai kegagalan, bukan 'belum mulai'. Tanpa CTA Casey close app tanpa buka prayer logger.
Jordan: hari pertama lihat header + 5 gray zero, tanpa onboarding atau preview — fitur terasa kosmetik.

## Questions
1. Per-prayer streak grain yang tepat? 5 counter paralel bersaing untuk perhatian. 1 hero-streak + 'fajr weak link' callout = actionable, on-brand.
2. Saat haidMode, kenapa card identik dengan hari biasa? Either snowflake badge di cell atau suppress warning state.
