# National GPS Prayer Area Resolution Design

## Problem

Nominatim may describe an Indonesian GPS coordinate with a lower-level area in
`town` and its regency name in another field. In South Kuta, for example, the
response can contain `town: Kuta Selatan`, `region: Badung`, and `state: Bali`.
The current flow accepts `town`, fails to find it in the prayer-location API,
then saves the raw district name. Schedule requests subsequently fail because
the prayer API expects `Kab. Badung`.

## Approved behavior

GPS location resolution must work against the prayer API's province and
kabupaten/kota catalog for all Indonesian provinces supported by the app. A
reverse-geocoder label is never trusted as the final prayer area by itself.

`PrayerService.getCurrentLocation()` will:

1. Resolve the reverse-geocoder `state` to one of the app's existing Equran
   province names.
2. Fetch the existing Equran kabupaten/kota list for that province.
3. Compare administrative address candidates (`county`, `region`,
   `state_district`, `city`, `municipality`, then `town`) against that list.
4. Normalize only naming syntax for comparison: case, punctuation, whitespace,
   and the prefixes `Kabupaten`, `Kab.`, `Kab`, and `Kota`.
5. Return the exact kabupaten/kota spelling supplied by Equran. Thus `Badung`
   resolves to `Kab. Badung`, while `Kuta Selatan` is rejected.

The GPS path will use the matched Equran location directly. The existing
MyQuran search remains available for manual typed search and is not part of
GPS validation.

## Failure behavior

If the province cannot be resolved, the province catalog cannot be loaded, or
none of the address candidates matches a valid kabupaten/kota, the operation
returns the existing `lookupFailed` result. It must not save a district,
village, or other raw geocoder value as fallback. The existing snackbar then
directs the user to select a location manually.

## Code shape

Keep the change inside `PrayerService` and reuse `citiesForProvince()` plus the
existing province aliases. Add one small pure matcher that accepts an address
and a valid kabupaten/kota list; this keeps network behavior out of unit tests
and avoids new dependencies or hardcoded district-to-regency tables.

## Tests

Unit tests cover:

- `region: Badung` matching `Kab. Badung` even when `town: Kuta Selatan` is
  present.
- `city: Denpasar` matching `Kota Denpasar`.
- case and prefix normalization.
- rejection when only a kecamatan or unmatched lower-level area is available.

Run the focused prayer-service tests, `flutter analyze`, and the full Flutter
test suite before the implementation is considered complete.
