# Profile skin and prayer schedule design

## Scope

- Retire selectable avatar frames from the profile skin locker.
- Use the circular avatar treatment for the profile hero, including users who
  have an old saved frame selection.
- Remove the editable location row from the profile hero card. Prayer-location
  management remains available from the schedule tab.
- Make the next-prayer hero text readable in both light and dark themes.

## Approach

The cosmetic catalogue will retain only the default circular frame as a
compatibility fallback, while non-default frame items (including
`shield_classic`) are removed. The locker exposes only Aura and Title slots.
The profile hero supplies the default circular frame directly, so a persisted
legacy `equipped['frame']` value cannot alter its shape.

The profile hero no longer renders or edits the saved prayer location. No
location data is deleted, and the schedule tab remains responsible for reading
and changing it.

The next-prayer hero replaces its fixed white foreground with the active
theme's semantic foreground colour for its hero surface. This preserves
contrast in the light and dark palettes without introducing per-theme literals.

## Layout

```text
Profile hero             Skin locker
------------------       -----------------
 circular avatar          [Aura] [Title]
 profile details          no Frame tab
 no location row

Schedule hero
------------------
 next-prayer text uses the active theme foreground
```

## Compatibility and errors

- Old saved frame ids remain harmless: the profile hero ignores them and uses
  the circular default.
- Removing a frame catalogue entry must not make cosmetic resolution throw; an
  unknown cosmetic id falls back to its slot default.
- Location preferences stay intact because only their profile-card control is
  removed.

## Verification

- Widget tests verify the locker has no Frame tab and the profile hero has no
  location control while retaining a circular default avatar.
- A widget test pumps the schedule hero with the light theme and asserts that
  its next-prayer label uses the theme semantic foreground rather than white.
- Run the focused profile, cosmetic, and schedule tests, then `flutter
  analyze`.
