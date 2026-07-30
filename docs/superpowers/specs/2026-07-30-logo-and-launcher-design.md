# Logo and Launcher Design

## Goal

Replace every Muslim Leveling logo mark with the supplied mosque-M artwork while keeping Flutter-rendered marks aligned to the active theme primary color.

## Asset Roles

- **Launcher and native Android startup:** the supplied jade-on-black mark. These are static Android resources because the OS renders them before Flutter can load application theme state.
- **Flutter marks (splash, onboarding, and Home header):** the supplied black mark on a transparent background. `ColorFiltered` applies `AppColors.primary`, so every existing light and dark preset renders its correct primary color.

## Implementation

1. Preserve the jade launcher artwork's square composition and generate Android density-specific `mipmap-*` launcher PNGs.
2. Add the jade asset to the native launch `layer-list` on a black background.
3. Create a transparent in-app mosque-M asset from the black-on-white reference without text, border, or extra imagery.
4. Replace every existing Flutter `logo.png` use with the transparent mark and wrap each in `ColorFiltered(mode: AppColors.primary, BlendMode.srcIn)`.

## Constraints

- Do not change labels, navigation, theme tokens, or splash timing.
- Do not add a runtime package.
- Keep the native startup logo static jade; Android cannot access Flutter's selected preset at that point.
- Keep the in-app logo free of a baked color so it remains theme-driven.

## Verification

- Add a splash widget test confirming the logo asset uses a primary-color filter.
- Inspect generated launcher densities and native launch resources.
- Run `flutter analyze` and the full Flutter test suite.
