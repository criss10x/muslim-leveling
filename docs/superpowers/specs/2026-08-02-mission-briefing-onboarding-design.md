# Mission Briefing Onboarding Design

## Goal

Make first-time onboarding feel like a clear first mission: gamified, quick to
scan, and without implying the user has already earned a rank.

## Layout

```
          [ neutral logo mark ]
           SELAMAT DATANG
   Mulai perjalanan baikmu hari ini.

 Quest Sholat   Catat sholat, raih XP, jaga streak.
 Belajar Islam  Artikel dan quiz yang mudah dipahami.
 Raih Badge     Konsisten tiap hari, kumpulkan badge.

              MULAI MISI PERTAMA
```

The three benefits stay stacked so each description is one readable line and
the CTA stays visible without excessive scrolling.

## Theme

- Light: a flat white logo card, deep emerald primary, and clean card borders.
- Dark: the same neutral logo card with a soft jade brand halo, not a rank or
  prestige glow.
- Reuse AppColors, AppText, and the existing logo. Add no bitmap asset or
  dependency.

## Motion

- Logo and header enter together over 280 ms with a small upward movement.
- The three benefit rows fade upward in a 70 ms stagger.
- The CTA follows after the rows over 220 ms.
- No looping, carousel, rank effect, or additional onboarding step.

## Behavior and verification

- The CTA keeps the existing route to CharacterCreationScreen.
- Add widget tests for the new CTA label and concise benefit copy.
- Run the targeted onboarding tests and `flutter analyze`.
