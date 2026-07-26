import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/cosmetic_catalog.dart';
import 'package:muslim_leveling/widgets/tier_avatar.dart';

void main() {
  test('tier presentation keeps free palettes and accents distinct', () {
    final master = getTierVisualConfig('Master');
    final epic = getTierVisualConfig('Epic');
    final legend = getTierVisualConfig('Legend');
    final mythic = getTierVisualConfig('Mythic');
    final immortal = getTierVisualConfig('Mythic Immortal');

    expect(master.primaryColor, isNot(mythic.primaryColor));
    expect(epic.primaryColor, isNot(getTierVisualConfig('Mythic Glory').primaryColor));
    expect(legend.primaryColor, isNot(immortal.primaryColor));
    expect(getTierVisualConfig('Grandmaster').accent, TierFrameAccent.sapphire);
    expect(getTierVisualConfig('Legend').accent, TierFrameAccent.lavender);
    expect(getTierVisualConfig('Mythic').accent, TierFrameAccent.cyan);
    expect(getTierVisualConfig('Mythic Honor').accent, TierFrameAccent.ultraviolet);
    expect(getTierVisualConfig('Mythic Glory').accent, TierFrameAccent.magenta);
    expect(immortal.accent, TierFrameAccent.obsidianOpal);
    expect(getTierVisualConfig('Elite').hasPartialOuterArcs, isTrue);
    expect(getTierVisualConfig('Mythic Honor').hasPartialOuterArcs, isTrue);
    expect(getTierVisualConfig('Warrior').hasPartialOuterArcs, isFalse);
    expect(immortal.hasFullOuterRing, isTrue);
  });

  test('Warrior and Master define distinct earned frame cues', () {
    expect(getTierVisualConfig('Warrior').frameCue, TierFrameCue.thinFullRing);
    expect(getTierVisualConfig('Master').frameCue, TierFrameCue.jadeDiamond);
  });

  test('tier thresholds retain all ten existing ranks', () {
    expect(getTierName(1), 'Warrior');
    expect(getTierName(10), 'Elite');
    expect(getTierName(20), 'Master');
    expect(getTierName(30), 'Grandmaster');
    expect(getTierName(40), 'Epic');
    expect(getTierName(50), 'Epic');
    expect(getTierName(60), 'Legend');
    expect(getTierName(70), 'Legend');
    expect(getTierName(80), 'Mythic');
    expect(getTierName(85), 'Mythic Honor');
    expect(getTierName(90), 'Mythic Glory');
    expect(getTierName(95), 'Mythic Immortal');
  });

  test('circle path fills the box and is round', () {
    final path = buildFramePath(FrameShape.circle, const Size(100, 100), 16);
    final b = path.getBounds();
    expect(b.width, closeTo(100, 0.5));
    expect(b.height, closeTo(100, 0.5));
    expect(path.contains(const Offset(50, 50)), isTrue);
    // Corner of the bounding box is outside the inscribed circle.
    expect(path.contains(const Offset(2, 2)), isFalse);
  });

  test('squareRounded path stays within bounds', () {
    final path = buildFramePath(FrameShape.squareRounded, const Size(100, 100), 16);
    expect(path.getBounds().width, closeTo(100, 0.5));
    expect(path.getBounds().height, closeTo(100, 0.5));
  });

  test('shield path is non-empty and bounded by the box', () {
    final path = buildFramePath(FrameShape.shieldClassic, const Size(100, 100), 16);
    final b = path.getBounds();
    expect(b.width, greaterThan(0));
    expect(b.height, lessThanOrEqualTo(100.5));
    // Shield tapers: the very bottom-center point exists near y ~ 100.
    expect(path.contains(const Offset(50, 96)), isTrue);
  });

  testWidgets('avatar renders with a shield frame without throwing', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: TierProfileAvatar(
        tierName: 'Warrior',
        equippedFrameId: 'shield_classic',
        sizeDp: 80,
      ),
    ));
    expect(find.byType(TierProfileAvatar), findsOneWidget);
  });

  testWidgets('full avatar uses an outer accent without MediaQuery', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: TierProfileAvatar(tierName: 'Master', sizeDp: 80),
    ));

    final fullAccent = find.byKey(const ValueKey('tier-avatar-accent-full-outer'));
    expect(fullAccent, findsOneWidget);
    expect(tester.getSize(fullAccent), const Size(104, 104));
  });

  testWidgets('Epic avatar renders its earned frame with initials fallback',
      (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: TierProfileAvatar(
        tierName: 'Epic', displayName: 'Ahmad Fikri', sizeDp: 88,
      ),
    ));
    expect(find.text('AF'), findsOneWidget);
  });

  testWidgets('Epic Pro avatar keeps the Epic frame and renders Pro finish',
      (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: TierProfileAvatar(
        tierName: 'Epic', displayName: 'Ahmad Fikri', isPro: true, sizeDp: 88,
      ),
    ));
    expect(find.bySemanticsLabel('Epic achievement frame'), findsOneWidget);
    expect(find.bySemanticsLabel('Pro signature finish'), findsOneWidget);
  });

  testWidgets('compact avatar stays static for Mythic Immortal', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: SmallTierAvatar(
        tierName: 'Mythic Immortal', displayName: 'Ahmad Fikri',
      ),
    ));
    expect(find.byType(SmallTierAvatar), findsOneWidget);
  });

  testWidgets('compact avatar keeps its tier cue peripheral', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: SmallTierAvatar(
        tierName: 'Master', displayName: 'Ahmad Fikri',
      ),
    ));

    expect(find.byKey(const ValueKey('small-tier-accent-peripheral')), findsOneWidget);
    expect(find.byKey(const ValueKey('tier-avatar-accent-full-outer')), findsNothing);
    expect(find.byType(AnimatedBuilder), findsNothing);
  });
}
