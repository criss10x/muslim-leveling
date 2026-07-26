# Cosmetic Locker Visual Polish

## Goal

Make the Profile tab's Loker Skin feel like a small, understandable collection
surface rather than an unlabelled grid, in both light and dark themes.

## Scope

Modify only the existing `CosmeticLocker` presentation and its focused widget
test. Preserve the catalog, ownership rules, equip behavior, Pro gate, and
paywall navigation.

## Layout

The locker keeps its three slots (Bingkai, Aura, Gelar), but adds clear
collection hierarchy:

1. A compact header row shows the active slot's unlocked free collection count
   and a short collection label.
2. Existing slot controls become a consistently styled segmented row using the
   current theme tokens; no dependency or custom navigation is added.
3. Every visible card has one clear state:
   - equipped: primary outline and `DIPAKAI` label;
   - Pro while not entitled: lock icon and `PRO` label;
   - usable free item: its existing emoji and name.
4. If the selected slot has no earned free cosmetic beyond its default, show a
   compact progression panel below the grid: "Selesaikan quest harian untuk
   membuka skin dari Daily Chest." It is informational only; the user reaches
   quests through the existing Beranda tab.

## Visual treatment

- Reuse `AppColors`, `AppText`, `AppRadius`, and `AppSpacing`.
- Use emerald only for equipped/interactive state, gold for Pro, and subdued
  neutral colors for explanatory copy.
- Keep the current three-column grid and fixed, non-scrollable embedding in
  the Profile `ListView`.
- Use subtle borders and surface contrast; do not add assets, gradients,
  heavy shadows, animation, or new data models.

## Behavior and accessibility

- Tapping an equipped free item unequips that slot, returning it to the
  catalog default; this gives users an obvious way to remove a cosmetic.
- Tapping a different allowed item still equips it immediately.
- Tapping Pro while non-Pro still opens the existing paywall.
- Each item remains a semantic button with a minimum 44dp touch target and a
  label describing its cosmetic name and state.
- Long cosmetic names remain limited to two lines with ellipsis.

## Testing

- Add focused widget coverage for the progression panel in an empty free slot.
- Add focused widget coverage that tapping an equipped item unequips it.
- Keep the existing owned-free equip test.
- Run focused locker tests and the full Flutter suite when the SDK is
  available; this workspace currently has no Flutter SDK, so static diff
  checks remain the available local verification.

