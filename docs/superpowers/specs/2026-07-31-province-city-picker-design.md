# Province-First City Picker Design

## Goal

Make the Jadwal manual location picker guide users through a province before a kabupaten/kota, while retaining typed filtering at both stages.

## Flow

1. The existing “Cari Kota” button opens one dialog in its province stage.
2. All 34 existing Equran province names are shown in a locally filterable list.
3. Selecting a province loads that province’s kabupaten/kota list from the existing Equran `kabkota` endpoint.
4. The city stage displays the selected province, a back control to change it, and a locally filterable kabupaten/kota list.
5. Selecting a kabupaten/kota closes the dialog and returns the existing `{id, name}` value, so existing save, refresh, notification, and cache flows remain unchanged.

## Data and Errors

- The service exposes the existing province list and a single method that loads a province’s kabupaten/kota names from Equran.
- The selected city uses a stable local ID based on its province and city name; schedule fetching already uses the city name, while the ID scopes cache entries.
- Province and city typed filtering is entirely local after the relevant list is available.
- Loading, empty-result, and network-failure states keep the dialog open and offer the back control; no fallback to ambiguous global city search.

## Scope

- Modify only `PrayerService`, the shared `CityPicker`, and focused service/widget tests.
- Keep GPS “Lokasi Saat Ini”, app labels outside the picker, themes, permissions, dependencies, and schedule calculations unchanged.
- Reuse existing `AppColors`, `AppText`, `AppSpacing`, and Material icons.

## Verification

- Test province list exposure, city list parsing/filtering, and stable selected location value.
- Widget test verifies province stage appears first and city stage appears only after a province selection.
- Run focused tests, `flutter analyze`, then the full Flutter test suite.
