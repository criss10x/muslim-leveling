---
target: lib/widgets/quran_share_sheet.dart
total_score: 24
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 2
timestamp: 2026-08-17T18-02-11Z
slug: lib-widgets-quran-share-sheet-dart
---
# Critique — Bagikan Ayat (Quran Share Sheet)

Method: dual-agent (A: sa-0-566c4ec4 TIMED OUT → inline · B: sa-1-8bdaf6f9)
Target: lib/widgets/quran_share_sheet.dart

## Design Health Score (Nielsen, /40)

| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 2 | No post-share confirmation; only spinner during capture |
| 2 | Match System / Real World | 3 | Bahasa natural (Bagikan, Gradasi, Estetik); but "Solid" is English amid ID labels |
| 3 | User Control and Freedom | 3 | Back escapes; background change is instant & reversible |
| 4 | Consistency and Standards | 3 | Uses AppTokens; copy drift "Level Up Iman" vs "Level Up Iman, Level Up Kehidupanmu" in achievement card |
| 5 | Error Prevention | 2 | Fixed 340×604 card, no auto-scale — long ayat overflow |
| 6 | Recognition Rather Than Recall | 3 | Chips icon+label; swatch = color itself |
| 7 | Flexibility and Efficiency | 2 | Single rigid flow; smart default but no accelerators |
| 8 | Aesthetic and Minimalist Design | 3 | Focused; ≤4 visible options per decision point |
| 9 | Error Recovery | 1 | `catch (_) { // silent }` swallows share failure |
| 10 | Help and Documentation | 2 | Self-evident flow; entry tooltip "Bagikan ayat" only |
| **Total** | | **24/40** | **Acceptable** |

## Design Specificity Verdict
Authored for a Qur'an app — Amiri Quran (RTL) for Arabic, surah name/arti header, "QS X · Ayat N" detail chip, gold accent for the sacred text, mosque_bg for estetik. Not category-interchangeable. The specific flaw is *breadth over depth*: 4+3+1 background presets exist, but the core text (the verse) has no fit-to-card guard — the app spends design budget on backdrop chrome while the content that matters can break.

Deterministic scan: empty (`[]`, exit 0) — `detect.mjs` has no `.dart` support (SCANNABLE_EXTENSIONS excludes it). Not evidence of quality; coverage gap. No browser visualization (native mobile, no URL). No false positives.

## Cognitive Load
Pass: single focus, chunking, grouping, visual hierarchy, one-decision-in-view, working memory, progressive disclosure. Partial: minimal choices (3 mode chips + 4 swatches = at ceiling, OK). **1 marginal item → Low load.**

## Emotional Journey
Peak: instant live preview — pick a background, card repaints. Strong front-load. End: tap share → OS sheet, OR nothing at all on silent failure. Peak-end rule broken: delighted entry, dead tail.

## What's Working
1. Instant live preview + swatch picker — zero-latency delight, correct Operate feel.
2. Consistent token use (AppColors/AppText/AppRadius) + reuse of existing share MethodChannel + ShareUtil.
3. Correct RTL Arabic + Amiri Quran + translated hierarchy.

## Priority Issues
- **[P1] Long ayat overflow the fixed 9:16 card.** Ayat like Al-Baqarah 282 (or any ≥5-line Arabic at font 30) exceed 604px; Spacers collapse, RenderFlex overflow. Fix: auto-scale Arabic via FittedBox or make height content-driven. `/impeccable adapt`
- **[P1] Share failure is silent.** `catch (_) { // silent }` resets button to idle with no message; user can't tell if the image went out. Fix: SnackBar "Gagal membagikan — coba lagi" on error, success confirm on channel reply. `/impeccable harden`
- **[P2] Translation truncated at 5 lines** inside a share artifact — the recipient gets a cut-off verse meaning. Fix: drop maxLines for a fixed-height card OR auto-fit font so full translation renders. `/impeccable clarify`
- **[P2] Color swatches are 40×40px** (5px gap) — below 44×44pt touch target. Fix: 48×48 targets. `/impeccable adapt`
- **[P3] Inline "GET IT ON Google Play" badge** isn't the official asset (brand guidelines) and "Estetik" mode ships only 1 image against richer solid/gradient sets. Fix: real play badge PNG; estetik +1-2 assets or gallery via `image_picker` (already a dep). `/impeccable polish`

## Persona Red Flags
**Riley (stress-tester)**: Al-Baqarah 282 → Arabic wraps past card bottom, clipped in capture. Failed share (channel error) → silent reset, no retry cue. RTL text with long Arabic strings not stress-tested.
**Casey (distracted mobile)**: 40px swatches under thumb; share button at bottom (good), but swatch row is mid-screen, reachable but cramped; one-handed mode requires precision.
**Jordan (first-timer)**: mixed "Solid" (EN) beside "Gradasi/Estetik" (ID); the mode-chip → swatch relationship isn't labeled ("pilih warna"), so the 3→N reveal may read as two random controls.

## Minor Observations
- Footer copy "Level Up Iman" diverges from achievement card "Level Up Iman, Level Up Kehidupanmu".
- Detail chip is black-on-dark (alpha .25) — near-invisible on the darkest solid presets.
- Gold surah name (secondaryFixed) can wash on the light estetik scrim.

## Questions to Consider
- What if the card auto-fit to the verse instead of forcing 9:16?
- Does sacred text need the Google Play badge at all, or is that chrome noise?
- What if estetik mode let users pick their own mosque photo (image_picker already installed)?
