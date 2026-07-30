# Prayer Location Area Resolution

## Goal

Make the Jadwal “Lokasi Saat Ini” flow use the administrative kabupaten/kota returned by reverse geocoding before a kecamatan or village name.

## Data Flow

1. GPS still supplies latitude and longitude through `Geolocator`.
2. Nominatim reverse geocoding returns its `address` map.
3. The schedule-area candidate is selected in this order: `county`, `city`, `town`, then `village`.
4. The existing MyQuran city search resolves the candidate to its existing city ID and display name; existing fallbacks and error messages remain unchanged.

For Bali, an address containing a kecamatan in `village` and `Kabupaten Badung` in `county` therefore searches for Badung, rather than the kecamatan.

## Scope

- Change only the shared location resolution in `PrayerService`.
- Add a focused regression test proving a county wins over village/kecamatan and fallback order remains available.
- No new dependency, API, UI, permission, cache, or schedule-calculation change.

## Verification

- New focused regression test fails before the change and passes after it.
- Run the Jadwal test file, then `flutter analyze`.
