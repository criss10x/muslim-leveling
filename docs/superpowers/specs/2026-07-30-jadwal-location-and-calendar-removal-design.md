# Jadwal Location and Calendar Removal Design

## Goal

Make **Lokasi Saat Ini** work on Android when device location is enabled, make location failures actionable, and temporarily remove the unfinished calendar feature from the Jadwal tab.

## Scope

- Add Android coarse and fine location permissions required by `geolocator`.
- Check location-service state and permission state before reading a position.
- Return a small, typed location-lookup result so the UI can distinguish unavailable GPS, denied permission, timeout, and city-resolution failure.
- Replace the text location button with an icon-only, minimum-44dp control.
- Keep **Cari Kota** as the expanded companion control.
- Remove the Calendar button, calendar screen, and the now-unused `hijri` dependency.

## Non-goals

- No change to saved-city selection, schedule fetching, Qibla, or prayer calculations.
- No new location, map, or calendar dependency.
- No iOS configuration work; this project currently has no `ios/` target.

## Layout

```text
Waktu Sholat
Tanggal

[ location icon ] [ Cari Kota                     ]
Kota aktif
```

The location button remains at least 44 by 44 dp. Both controls use existing semantic theme colors, so light and dark presets retain their established contrast.

## Location Flow

1. Confirm the device location service is enabled.
2. Read or request app location permission.
3. Stop with a specific reason for denied, permanently denied, or unavailable permission.
4. Read the position with the current 20-second timeout.
5. Reverse-geocode and resolve the city using the existing APIs.
6. Return a success city or a typed failure; `JadwalTab` maps that result to a concise Snackbar.

The generic “Pastikan GPS aktif” message is removed because it conflates permission, device-service, timeout, and network failures.

## Verification

- Add service-level tests for location-result-to-message behavior where plugin calls are mockable.
- Add widget assertions that the Jadwal header has the icon-only location button, the expanded city-search button, and no calendar affordance.
- Run `flutter test` and `flutter analyze`.
