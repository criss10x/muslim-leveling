# Profile Order and Prayer GPS Area Design

## Scope

Make two focused adjustments without changing theme tokens, labels, game data,
prayer API providers, or manual location selection.

## Approved Profile order

The `ProfilTab` `ListView` order becomes:

1. Hero
2. Streak per Sholat
3. Statistik
4. Loker Skin
5. Achievements
6. Mode Haid

The existing spacing between adjacent sections stays `AppSpacing.md`. Account
backup and Settings remain after Mode Haid in their current order. The compact
Loker Skin button and its bottom-sheet interaction are unchanged.

## Approved GPS area resolution

`PrayerService.getCurrentLocation()` must resolve a kabupaten/kota, not a
kecamatan, before it searches the existing prayer-location API.

`prayerAreaFromAddress()` reads only the reverse-geocoder fields that can
represent a prayer area: `county`, `city`, `municipality`, then `town`. It
skips any candidate explicitly named `Kecamatan ...` or `Kec. ...`; it no
longer uses `village`, which is a lower administrative area.

The first acceptable kabupaten/kota candidate continues through the existing
`searchCities()` API lookup and location persistence flow. If no acceptable
candidate exists, `getCurrentLocation()` returns the existing lookup failure
state so the user can choose a location manually rather than storing a
kecamatan.

## Tests

Add unit coverage showing a kecamatan-valued `county` is skipped in favour of
a kabupaten/kota-valued `city`, and that village-only reverse-geocoder data
returns no prayer area. Update the Profil widget layout test to enforce the
approved section order. Run `flutter analyze` and focused Profil/Jadwal tests.
