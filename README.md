# Muslim Leveling

Flutter Android app: prayer quests, XP, streaks, adzan reminders, Quran reader + murottal, Belajar articles/quiz. Local-first; Google login = optional cloud backup.

**Version:** `1.0.0+2` · **Package:** `id.muslimleveling.muslim_leveling` · **Branch:** `main`

## Stack

- Flutter (Dart 3.12+)
- SharedPreferences (source of truth)
- Supabase Auth + row sync (signed-in only)
- Google Sign-In → Supabase
- `flutter_local_notifications` + timezone (Asia/Jakarta)
- `just_audio` (murottal playback)
- Sentry (client DSN)

## Features

- 5 daily prayers + rawatib / tilawah / sedekah quests; Jumat weekly streak
- XP, level, hero streak, achievements, cosmetics (skins, avatar tiers)
- Quran: full mushaf reader, per-ayah audio multi-qari, tafsir, rub' el hizb badge, resume bacaan terakhir
- Belajar: artikel + kuis + hasil
- Jadwal shalat: Equran (Kemenag proxy) primary, MyQuran + Aladhan fallback; default Jakarta
- City picker (Jadwal, Profil); onboarding = cek lokasi + notif toggle, tanpa form nama
- Adzan notif: fokus / seimbang / intensif · senyap / suara / adzan
- Qibla compass
- Theme presets: Emerald (dark) / Mushaf (light) · Electric Jade brand
- Haid mode freezes streaks

## Setup

```bash
flutter pub get
flutter run
```

Release APK (needs local keystore):

```bash
# repo root key.properties (gitignored)
# storeFile=/absolute/path/to/muslim-leveling-release.jks
# storePassword=…
# keyAlias=muslim-leveling
# keyPassword=…

flutter build apk --release --split-per-abi
```

Google login release: register SHA-1 of the release keystore in Google Cloud + Supabase OAuth redirect
`id.muslimleveling.muslim_leveling://login-callback`.

## Architecture (short)

| Layer | Role |
|---|---|
| `GameService` | Local game state; fire-and-forget `SupabaseSync.saveGame` |
| `PrayerService` | City + jadwal cache (Equran → MyQuran → Aladhan); `locationVersion` notifies tabs |
| `QuranApi` / `QuranAudioService` | Mushaf data, tafsir, per-ayah murottal (`just_audio`) |
| `NotificationService` | Exact/inexact schedule; 3 Android channels |
| `ThemeService` | Emerald/Mushaf preset, persisted |
| `AuthService` | Google → Supabase session |
| `SupabaseSync` | No network until signed in |

Tabs live in `IndexedStack` (`DashboardShell`): Home / Jadwal / Quran / Belajar / Profil. Location change bumps `locationVersion` → Home reschedules adzan, Jadwal refetches.

## Git / release

- Trunk-based on `main`; CI: analyze + split-per-abi release APK artifact
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)
- Never commit: `key.properties`, `*.jks`, `.env*`, `test/failures/`, secret screenshots

## Notes

- Notif timezone pinned WIB (`Asia/Jakarta`). WITA/WIT needs city→TZ map later.
- Golden tests: `test/profil_stats_test.dart` pins a fixed "now" — regenerate goldens on Ubuntu only (font rendering differs per OS).
- Hardcoded Supabase anon key / Sentry DSN / OAuth client ID are public client credentials; RLS owns data isolation.
