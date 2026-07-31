# Profile Layout Density Design

## Scope

Polish layout tab Profil on phone without changing labels, colors, typography,
theme presets, cosmetic behaviour, or profile data.

## Approved layout

The top portion of `ProfilTab` becomes:

1. Existing hero card.
2. Existing Statistik section immediately below the hero.
3. Loker Skin as a compact outlined action row below Statistik.
4. Existing haid toggle and all following sections in their current order.

## Component changes

`_stats()` retains the current 2-by-2 grid and its data. It is moved ahead of
`_cosmeticLocker()` in the `ListView` only.

`_cosmeticLocker()` loses its full `FlatCard` container and large embedded
locker presentation. It becomes one compact, full-width outlined row with a
Material icon, the existing `LOKER SKIN` label, a brief supporting label, and
a trailing chevron. Tapping the row opens the existing cosmetic locker flow;
it presents the existing `CosmeticLocker` widget in a scrollable modal bottom
sheet. Cosmetic data, choices, and persistence do not change.

## Layout rules

- Keep horizontal page padding at `AppSpacing.md`.
- Use `AppSpacing.md` between hero, Statistik, and the compact locker row.
- Use `AppSpacing.sm` within the compact row.
- Preserve all colors through `AppColors` so every existing light and dark
  preset remains legible.
- Keep the 2-by-2 statistics grid intact; it has no empty cells and is more
  glanceable than a vertical list on phones.

## Error handling and data flow

No service or async path changes. The bottom sheet reuses `CosmeticLocker`
rather than duplicating cosmetics state.

## Tests

Update the Profil widget/layout test to assert Statistik follows the hero and
that a compact Loker Skin action remains reachable. Run `flutter analyze` and
the focused Profil tests after the implementation.
