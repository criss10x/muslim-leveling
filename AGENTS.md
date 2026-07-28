# Muslim Leveling v6 — Agent Guidelines

## Project

Flutter Android app — Islamic gamified habit tracker (sholat, Quran, tilawah, belajar).  
Repo: `criss10x/muslim-leveling-v6`  
Active branch: `codex/quran-polish-themes`  
Project dir: `~/muslim-leveling-v6`

## Code Style

### General
- **Efficient over elaborate.** Shortest working diff wins. No interface/abstract for one impl. No config for a value that never changes. No boilerplate "for later".
- **Ponytail comments** (`ponytail:`): mark deliberate simplifications with a brief comment naming what was skipped and when to add it. Pattern: `ponytail: skipped X, add when Y.`
- **No self-reference in responses.** No "I will now", "Let me", "Sure!". State the thing, the action, the reason.
- **Tersely informative.** Drop filler, hedging, pleasantries. Keep exact code/file paths/errors/URLs.

### Dart
- **StatefulWidget preferred** — no riverpod/bloc unless user requests.
- **Try/catch everything async** with `ponytail:` noting swallowed errors.
- **`ponytail:` in initState** for deferred loading (load in background, never block first paint).
- No custom build runner / code generation.
- SharedPreferences for local state, Supabase for cloud backup. Game state lives in Prefs first.
- Colors/theme from `app_theme.dart` (`AppColors`, `AppText`, `AppSpacing`, `AppRadius`).
- Material icons via `Icons.*` — no custom PNG icons for UI elements (only launcher icon).

### Theme system
- Light theme: canvas `#E8EAED`, white cards, ink `#1A1A1A`.
- Brand Electric Jade: light deep `#047857`, dark bright `#34D399` (`onPrimary: #064E3B`).
- Gold = reward, blue/cyan = live/now (`tertiary`).
- Flat cards (no shadows/glass/neon except tier glow on dark mode hero).
- HudHeader and FlatCard from `common.dart`. NeonProgressBar for XP.

### Naming
- Files: snake_case (e.g., `home_tab.dart`, `game_service.dart`).
- Classes: PascalCase (`GameService`, `HomeTab`).
- Methods/vars: camelCase (`_load`, `isPrayerCheckedToday`).
- Private with leading underscore.

### Architecture
```
lib/
├── screens/        # Full-page widgets (tabs, modals)
├── widgets/        # Reusable widgets
├── services/       # Business logic (GameService, AuthService, etc.)
├── theme/          # AppColors, AppText, AppSpacing, AppRadius
├── models/         # Data classes (game_state.dart, etc.)
assets/
├── images/         # logo.png, mosque_bg.jpg only
docs/               # specs, plans
test/               # unit tests
tool/               # flutter scripts
```

## Key Services
| Service | Role |
|---|---|
| `GameService` | All game state: XP, level, prayer log, quests, streak. Singleton + `stateVersion` ChangeNotifier. |
| `AuthService` | Google login (native popup default → browser OAuth fallback). |
| `SupabaseSync` | Cloud backup/merge. Never blind-overwrite local. |
| `PrayerService` | Jadwal sholat API (fetchSchedule, loadLocation). |
| `AchievementService` | Medals, tier titles (WARRIOR..MYTHIC). |
| `NotificationService` | Adzan reminders, scheduled. |
| `ThemeService` | ThemeNotifier: light/dark toggle + system. |

## Login & Auth Setup

**Native Google Sign-In (popup) — preferred.**  
Requires Android OAuth client registered in Google Cloud Console:

```xml
Package name: id.muslimleveling.muslim_leveling
SHA-1:        DF:2C:7E:72:5A:29:A7:1B:6F:66:FA:A6:FA:04:78:77:5B:46:F7:23
```

URL: https://console.cloud.google.com/apis/credentials → Android OAuth client

**If SHA-1 not registered** (first build) → falls back to browser OAuth.  
For browser OAuth to work, Supabase needs this redirect URL:

```
id.muslimleveling.muslim_leveling://login-callback
```

Supabase → Auth → External OAuth Providers → Google → Authorized redirect URLs

**Keystore**: `~/muslim-leveling-release.jks` (alias: muslim-leveling, pass: android)  
**Build**: `flutter build apk --release --split-per-abi`  
**Upload**: gofile.io, then `rm -rf build/`

## Git

- **Branch names**: `feat/<name>` or `codex/<name>`.
- **Commit style**: `type: what changed` (feat/fix/refactor/ci/docs).
- **Force-push** to `main` when replacing iteration (no backup branch — reflog covers 90d).
- No merge commits between unrelated projects (`--allow-unrelated-histories` only on explicit ok).
- Push often; squash via `git pull --rebase`.

## Testing

- Run `flutter analyze` before build.
- CI (`flutter.yml`) runs: pub get → analyze → test → build APK.
- Test file: `test/widget_test.dart` (smoke test only — extensive tests not enforced).

## Build Pipeline

1. `flutter pub get`
2. `flutter analyze` — must pass (4 info-level curly-brace warnings tolerated)
3. `flutter build apk --release --split-per-abi`
4. Upload arm64-v8a to gofile.io
5. `rm -rf build/`

## CLI Agents (Codex, Claude Code)

When running these agents in this project:

- **Run `flutter analyze`** after any edit — it's the first gate.
- **Don't over-architect.** FlatStatefulWidget + services is enough.
- **Ponytail first.** If something is deferred, intentional, or a shortcut — tag it `ponytail:`.
- **Utama: Bahasa campuran Indonesia-Inggris OK.** Labels/titles tetap Bahasa. Emoji adalah konten, jangan dihapus.
- **Design-only tasks:** design token berubah (warna/font/shape), konten (label/teks/emoji/Bahasa) tetap.
- **Tab labels:** Home/Jadwal/Belajar/Profil — jangan rename meski mockup pakai label beda.

## Google Login

Native popup (bottom sheet pilih akun). Jika belum daftar SHA-1, fallback ke browser.  
Pembahasan auth bisa ditemukan di `lib/services/auth_service.dart`.

Untuk menambahkan SHA-1:
1. Buka Google Cloud Console → APIs & Services → Credentials
2. Edit Android OAuth client untuk `id.muslimleveling.muslim_leveling`
3. Tambah SHA-1: `DF:2C:7E:72:5A:29:A7:1B:6F:66:FA:A6:FA:04:78:77:5B:46:F7:23`
4. Simpan, rebuild APK