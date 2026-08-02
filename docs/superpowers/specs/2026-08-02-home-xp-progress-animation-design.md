# Home XP Progress Animation

## Goal

Make the XP progress bar in the Home hero move smoothly when the displayed XP
progress changes, while preserving the same visual styling as the Profil bar.

## Design

`_heroRank` in `lib/screens/home_tab.dart` will wrap the existing bar fill in a
`TweenAnimationBuilder<double>`.

- The first render animates from `0` to `info.progress`.
- Later XP updates animate from the rendered value to the new target.
- Duration: 500 ms with `Curves.easeOutCubic`.
- Progress remains clamped to `0.0..1.0`.
- The existing tier gradient, dark-mode glow, 10 px height, and pill radius do
  not change.

## Scope

Only the Home hero XP bar changes. Profil's XP bar and game-state logic remain
unchanged. No animation controller, additional state, or dependency is added.

## Verification

Add a widget test that pumps Home with changing XP and confirms the progress
bar's fill width advances over time and reaches the requested value. Run the
new test, `flutter analyze`, and the relevant Home test suite.
