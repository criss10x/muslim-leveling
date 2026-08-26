---
target: saat unlock achievements
total_score: 20
max_score: 32
na_heuristics: 7,10
p0_count: 2
p1_count: 2
timestamp: 2026-08-26T15-24-29Z
slug: lib-widgets-achievement-medal-dart
---
# Critique (Re-run): Saat Unlock Achievement
Method: dual-agent (A: sa-0-e8fa8c2f · B: sa-1-b4e08dfd)

## Scores
H1 3, H2 2, H3 2, H4 3, H5 3, H6 3, H7 n/a, H8 2, H9 2, H10 n/a → 20/32 (Acceptable, 62%)

Key: Visibility 3 (no journey breadcrumb) · Match 2 (EN header di UI IDN) · Control 2 (antrean tanpa skip) · Consistency 3 · ErrorPrevention 3 (no grace period) · Recognition 3 (glyph angka tanpa caption) · Aesthetic 2 (tier 3x) · ErrorRecovery 2 (dismiss tanpa undo)

## Specificity
~70% authored: tier palette, glyph streak, MANTAP!. Generik: struktur kembar side-quest/NaikLevel, nol kosakata Islami di momen unlock.
Detector: exit 0, 0 findings (HTML-oriented, valid no-op di Dart).

## Priority Issues
- [P0] Nol sinyal sensorik (haptic/suara) saat unlock — HapticFeedback.heavyImpact() satu baris; keputusan produk (popup bisa muncul pasca-ibadah)
- [P0] Nol debounce di _drain (achievement_medal.dart ~L256) — popup hijack saat user beraksi; fix delay 600ms
- [P1] Antrean unbounded tanpa skip — N unlock = N popup serial; tambah Lewati semua/coalesce
- [P1] Chrome redundan: tier label teks (L373) duplikat Semantics (L309); header EN L317 → IDN/hapus
- [P2] Reduced-motion gap: dialog transition L290 + confetti controller 3200ms tidak dihormati
- Minor: black core L165 light theme, shouldRepaint tanpa legendary L214, textScaler tanpa clamp, confetti flat 45 partikel

## Persona
Casey: dismiss tak sengaja tanpa grace, tanpa haptic. Jordan: header EN + ROOKIE mengecilkan, glyph tanpa caption.

## Questions
- Tanpa confetti/elastic, masih terasa earned?
- Popup achievement vs side-quest: mana yang harusnya lebih ramai?
