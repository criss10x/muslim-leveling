# Compact profile layout design

## Goal

Make the profile page denser on phones without reducing touch targets or
changing its content, colours, or behavior.

## Changes

- Reduce the gaps from hero to skin locker and from skin locker to statistics
  from `AppSpacing.lg` (24) to `AppSpacing.md` (16).
- Keep the 44dp skin-slot controls, but reduce the locker card padding from 16
  to 12 and make collection tiles shorter by changing their grid aspect ratio
  from 0.65 to 0.80.
- Make the statistics bento cards lower by changing their grid aspect ratio
  from 1.5 to 1.8. Their card padding and label-to-value gap use the existing
  small spacing token.
- Reduce the gap following the statistics grid from 12 to 8.

## Layout

```text
Hero
  16px
Loker Skin (compact collection tiles)
  16px
Statistik (compact bento cards)
   8px
Konten profil berikutnya
```

## Constraints and verification

- Do not change skin selection behavior, statistics data, colors, or type
  hierarchy outside the smaller card spacing.
- Keep interactive skin controls at least 44dp high.
- Update the profile golden and run the profile, cosmetic locker, and full
  Flutter test suites plus `flutter analyze`.
