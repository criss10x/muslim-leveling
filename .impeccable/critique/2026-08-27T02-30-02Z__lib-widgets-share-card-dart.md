---
target: tombol bagikan + kartu share achievement
total_score: 18
max_score: 32
na_heuristics: 7,10
p0_count: 2
p1_count: 2
timestamp: 2026-08-27T02-30-02Z
slug: lib-widgets-share-card-dart
---
# Critique: Tombol Bagikan + Kartu Share Achievement
Method: dual-agent (A: sa-0-25499a0d · B: sa-1-de599626)

H1 2, H2 3, H3 2, H4 3, H5 2, H6 3, H7 n/a, H8 1, H9 2, H10 n/a → 18/32 (Needs attention, 56%)

Specificity: half-authored (wordmark, default username, tier gradient); ML-template sisanya, nol konten Islami.
Koreksi verifikasi: kartu SUDAH 9:16 (320x569); bukan 16:9 seperti dilaporkan A/B. Export 960x1707 < ideal IG 1080x1920.

## Priority
- [P0] Kartu illegible di IG thumb — 10 text blocks, tagline 8pt; buang tagline, fokus cerita/angka
- [P0] Nol konten Islami — footer iklan app ganti Alhamdulillah/doa + tanggal unlock
- [P1] glyphText+statLine duplikat angka; _saved=true sebelum invokeMethod (label 'Bagikan Lagi' padahal batal)
- [P1] Hierarki tombol nol — Bagikan solid primary, Tutup ghost; ikon check vs label Tutup mismatch
- [P2] Label 'ke Story' misleading di Android; spinner tanpa min 200ms; mounted guard setelah toImage; phase partikel nondeterministik; temp PNG tanpa cleanup

## Risks (B)
R1 _saved race (verified), R2 catch type-erased, R3 temp leak, R4 text color ikut tema vs frame locked, R5 flash, R6 mounted, R8 partikel, R9 tanpa fallback copy, R10 ikon mismatch.

## Persona
Casey: spinner 1-3s tanpa step, dialog masih block di belakang share sheet, tanpa toast sukses. Jordan (audience): 'Hero Streak' tidak dimengerti; framing benar 'Sholat 5 waktu beruntun'; @username lokal; 'Muslim Warrior' tonal clash.

## Questions
- Kartu share = badge atau progress story (tanggal hijriah + 1 stat + 1 ayat)?
- Wordmark English Latin vs satu baris Arab + subtitle Indonesia?
