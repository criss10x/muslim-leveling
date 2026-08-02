# Minimal Splash Design

## Goal

Make the initial splash feel fast and polished in both themes, then navigate
after a 900 ms minimum display time.

## Layout

```
        [ logo mark ]
       MUSLIM LEVELING
 Level Up Iman, Level Up Kehidupanmu
         progress bar
```

The centered layout and existing copy remain unchanged.

## Theme

- Light: flat light canvas, deep emerald logo and bar, no glow or heavy shadow.
- Dark: existing dark canvas, bright jade logo and a restrained jade glow.
- Reuse `AppColors`, `AppText`, and existing logo assets. No new asset or
  dependency is added.

## Animation

- 0–180 ms: logo fades and scales from 96% to 100%.
- 120–450 ms: title and tagline fade in with a small upward movement.
- 300–850 ms: progress fills once.
- At 900 ms: resolve local onboarding state, then fade to the destination over
  200 ms.
- Animations do not loop; the splash remains calm and exits quickly.

## Reliability

Reading SharedPreferences remains asynchronous. If it fails, the user goes to
the onboarding screen instead of remaining on Splash.

## Verification

Add widget tests for the 900 ms navigation timing and the static light/dark
theme treatments. Run the targeted Splash tests and `flutter analyze`.
