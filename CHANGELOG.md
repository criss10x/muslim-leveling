# Changelog

All notable user-facing changes. Newest first.

## [Unreleased]

### Added
- Turkish (Türkçe) and Malay (Bahasa Melayu) — the app now ships 4 languages
  (id, en, tr, ms). Both are picked the same way as English: Profile > App
  language, or onboarding page 1. Language names are shown in their own
  language, so someone whose phone is in the wrong language can still find
  theirs.
- Automatic ARB translation (`arb_ai.yaml`, run with `arb_ai`). Adding a
  language is now: add the code to `targets`, run the tool, run
  `flutter gen-l10n`. Only new/changed keys are sent to the API — re-running
  after a one-line copy change costs a few seconds, not a full re-translation.
  The parity test guards every language, not just en.
- Quotes from the scholars (32) and Hijri month / important-date names are now
  translated too, so "Kata Ulama" and the Hijri dates stop being Indonesian in
  the other languages. Scholar names stay as-is (they are proper names).

### Fixed
- Malay and Indonesian share ~80% of their vocabulary, so the old
  "is this Indonesian prose?" guard flagged correct Malay as untranslated
  (149 false positives). Replaced with a measured ratio check that catches the
  real failure — a locale that is still a copy of the template.

## [1.1.3] - 2026-09-19

### Fixed
- Onboarding asks for the battery exemption again (the "no restrictions"
  dialog). It was dropped in 01a15fc along with the exact-alarm prompt, but
  the two are not equivalent: exact-alarm falls back to `inexactAllowWhileIdle`
  while the battery exemption has no fallback, so Xiaomi/Oppo/Vivo killed the
  adhan alarm whenever the app was closed.

### Added
- Onboarding page 3 spells out what the Arabic terms mean ("Ikhwan is Arabic
  for male, akhwat for female") instead of asking the question bare — the old
  copy was only answerable by people who already knew the words, and the
  English build was worse off than the Indonesian one. The gender sheet in
  Profile carries the same gloss.
- Onboarding resumes where you left off (page + gender + city) instead of
  starting over when Android kills the app mid-flow.

### Removed
- Achievement share button (unlock popup + medal detail dialog) and the
  `share_card.dart` achievement card behind it. Sharing an achievement pushed
  the user's streak/level in other people's faces — medals are a private
  milestone now. Verse sharing (`quran_share_sheet.dart`) is unchanged.

### Fixed
- Quran share sheet and Daily Highlight were hardcoded Indonesian: English
  users saw "Bagikan Ayat", "Gradasi", "Terjemahan". All strings now come
  from ARB.
- Onboarding page 5 could dead-end when the city list failed to load; offline
  was reported as "city not found" instead of a retry.

## [1.9.1] - 2026-07-23

### Fixed
- Adzan reminders no longer fire ~7 hours late (timezone pinned to Asia/Jakarta).
- Prayer schedule Aladhan fallback works again when Kemenag is down (cityName passed).
- Idle animation tickers no longer burn CPU in light mode / non-effect tiers.
- Home load I/O parallelized; avatar photos downsampled to screen size.
- JSON parse failures in game/achievement state reported to Sentry.

### Security / ops
- Local signing secrets stay gitignored (`key.properties`, `*.jks`).
- Removed tracked Supabase key screenshot from the tree.

## [1.9.0] - 2026-07-22

### Added
- Strava-like light theme + Electric Jade brand pair.
- Pure black dark canvas.

### Fixed
- Google login release SHA-1 path + OAuth callback.
- Cloud backup merge on signed-in only.
