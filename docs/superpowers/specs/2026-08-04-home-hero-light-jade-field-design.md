# Home Hero Light Jade Field Design

## Goal

Make the Home rank hero feel native to the light Home canvas while preserving the existing dark hero unchanged.

## Scope

- Change only the light-theme presentation of the existing Home rank hero.
- Preserve layout, copy, dimensions, XP behavior, animation, state, semantics, and dark-theme styling.
- Support both Light Emerald and Light Mushaf through semantic `AppColors` tokens.
- Add no assets, dependencies, state, or reusable abstractions.

## Visual Direction

The light hero uses the approved **Jade Field** direction: a flat white-to-soft-jade surface that connects the cool canvas, white cards, and brand emerald.

### Card shell

- Keep the existing `AppRadius.xl` shape and no-shadow light treatment.
- Replace the tier-colored light wash with a restrained wash derived from `AppColors.primaryContainer`, concentrated at the top-right.
- Use a low-opacity `AppColors.primary` border so the edge reads as brand structure rather than tier decoration.
- Keep the dark card wash, border, and glow exactly as they are.

### Islamic lattice

- Keep the current right-side eight-point lattice geometry and fade.
- In light mode, draw it with `AppColors.primary` at restrained opacity so it belongs to the app palette.
- Preserve the current tier-colored dark lattice and its opacity.

### Rank medallion

- In light mode, render the medallion as a soft-jade seal using `AppColors.primary`, `AppColors.primaryContainer`, and semantic foreground colors.
- Do not let tier colors dominate the light medallion.
- Preserve the existing tier-gradient ring, dark inset surface, and glow in dark mode.
- Keep the current 68 dp footprint, star geometry, level label, non-interactive behavior, and excluded semantics.

### Typography and progress

- Keep the light rank title in `AppColors.onSurface` for strong contrast.
- Preserve all labels, nickname/level metadata, spacing, XP values, XP track, and fill behavior.
- Do not rename Home tab content or alter Bahasa/English labels.

## Implementation Boundaries

The change stays in `lib/screens/home_tab.dart`. Existing theme branching in `_heroRank` and `_RankMedallion` is sufficient; no new component or theme token is needed.

The smallest implementation is:

1. Select semantic light wash, border, and pattern colors inside `_heroRank`.
2. Select semantic light ring, inner surface, and star colors inside `_RankMedallion`.
3. Leave the dark branches unchanged.

## Testing

Update `test/home_hero_hybrid_test.dart` to verify:

- Light hero still has no shadow.
- Light background uses a semantic primary-container wash and primary border.
- Light lattice uses brand primary at the intended restrained opacity.
- Light medallion uses the approved semantic jade treatment.
- Dark hero still has one restrained glow, tier-based decoration, and the existing lattice opacity.
- No widget exceptions occur in either theme.

Run the focused hero test, `flutter analyze`, and the full Flutter test suite. Any unrelated pre-existing failure must be reported without weakening the focused checks.

## Acceptance Criteria

- Light hero visually matches the approved Jade Field mockup.
- Light Emerald and Light Mushaf both derive their appearance from `AppColors`.
- Dark hero is visually and behaviorally unchanged.
- No new asset, dependency, state, interaction, or abstraction is introduced.
