# Muslim Leveling

Aplikasi Android gamifikasi ibadah harian: quest sholat 5 waktu + sunnah, XP, level, streak, achievement, jadwal sholat, Al-Quran dengan audio. Local-first; login Google opsional untuk backup cloud.

**Version:** `1.9.2+22` · **Package:** `id.muslimleveling.muslim_leveling` · **Privacy Policy:** https://criss10x.github.io/muslim-leveling/

## Stack

- Flutter (Dart 3.12+), targetSdk 36
- SharedPreferences (source of truth, save-immediately)
- Supabase Auth + row sync (hanya setelah login Google)
- `flutter_local_notifications` + timezone (Asia/Jakarta)
- Sentry (crash reporting anonim)

## Fitur

- **Quest wajib** — 5 sholat, window: adzan → 03:00 (Subuh lebih ketat: adzan +3 jam). Hari dimulai jam 03:00.
- **Quest sunnah** — dhuha, tahajjud, rawatib, tilawah, zikir, sedekah; tiap quest punya window waktu sendiri.
- **Streak** — per-sholat, hero (5/5), jumat (mingguan), tilawah. Freeze mingguan + recovery ×0.75. Mode haid: tanpa penalti.
- **XP & level** — bonus tepat waktu ≤30 menit, bonus 5/5 harian.
- **Achievement & kosmetik** — medali tier, frame/aura avatar.
- **Jadwal sholat** — eQuran.id (Kemenag) + fallback MyQuran; city picker / GPS.
- **Notifikasi adzan** — mode fokus/seimbang/intensif, per-prayer sound.
- **Al-Quran** — teks + terjemahan + tajwid, audio multi-qari, resume posisi baca.
- **Backup** — 3 blob Supabase (game/learning/achievements), merge max-XP/union saat login.
- Light (Strava neutrals) + dark · Electric Jade brand.

## Setup

```bash
flutter pub get
# android/key.properties → release signing (wajib untuk build release; fail-fast tanpa fallback debug)
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

## Test

```bash
flutter test   # golden tests: regenerate di Ubuntu saja (font render beda per OS)
```

## Branch

- `main` — stabil, mirror release
- `app-release` — cabang kerja release
