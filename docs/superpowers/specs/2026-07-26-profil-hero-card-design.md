# Profil Hero Card — Visual Polish

## Context

The `ProfilTab` hero card currently presents the user's avatar, nickname, rank,
level, XP progress, location, and four summary stats. The card already follows
the app's emerald/gold/cyan visual language, but the hierarchy is flat: the
identity block, progress block, location row, and stats row compete for
attention. The current layout also relies on small inline controls and tightly
packed labels.

## Goal

Make the hero card feel more intentional and premium in both dark and light
themes while preserving all existing information and behavior.

## Non-goals

- No new profile data or persistence changes.
- No navigation or interaction-flow changes.
- No new assets or dependencies.
- No redesign of the sections below the hero card.

## Design

Use the existing card shell, palette, typography, avatar widget, and spacing
tokens. Recompose the card into four readable layers:

1. **Identity header** — Give the avatar clear visual priority. Group nickname,
   rank, equipped title, and level badges into a predictable vertical stack.
   Keep the edit action discoverable and give it a touch target appropriate for
   mobile.
2. **XP progress** — Keep the XP label and numeric progress aligned, but make
   the progress bar feel like the card's primary progression signal. Preserve
   the existing gradient and clamp behavior.
3. **Location** — Retain the editable location row, with clearer separation
   from progress and a stable chevron affordance. Long city names must ellipsize
   instead of causing overflow.
4. **Summary stats** — Keep Level, XP, Streak, and Rank, but use a consistent
   compact stat treatment with stronger value/label contrast. Rank text must
   remain safe for long titles on narrow screens.

### Theme behavior

- **Dark:** retain the emerald accent and subtle depth, using the existing dark
  surfaces rather than adding a new decorative background or asset.
- **Light:** use the existing white raised-card surface and deep emerald text/
  borders for contrast; avoid dark-theme glow values that become muddy in light.
- Both themes must use existing `AppColors`, `AppText`, `AppRadius`, and
  `AppSpacing` tokens wherever possible.

## Responsive and accessibility requirements

- The card must remain usable at the existing 412×915 golden-test viewport and
  narrower phone widths.
- Nicknames, equipped titles, rank titles, city names, and stat values must not
  overflow horizontally.
- The edit control must remain keyboard/semantics discoverable and have a
  minimum mobile touch target.
- Preserve existing tap behavior for edit profile and edit location.

## Implementation boundary

Modify only `lib/screens/profil_tab.dart` unless a focused test needs a small
addition. Reuse existing widgets and theme tokens. Add or update a focused
widget assertion only if it can verify a meaningful layout contract without
depending on fragile pixel details.

## Verification

- Run the focused profile widget/golden tests if the Flutter SDK is available.
- Run the broader test suite if practical.
- Inspect the final diff for scope, responsive overflow risks, and accidental
  credential or generated-file changes.

