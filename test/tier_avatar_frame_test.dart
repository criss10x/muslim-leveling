import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/cosmetic_catalog.dart';
import 'package:muslim_leveling/widgets/tier_avatar.dart';

void main() {
  test('tier presentation keeps free palettes distinct', () {
    final master = getTierVisualConfig('Master');
    final epic = getTierVisualConfig('Epic');
    final legend = getTierVisualConfig('Legend');
    final mythic = getTierVisualConfig('Mythic');
    final immortal = getTierVisualConfig('Mythic Immortal');

    expect(master.primaryColor, isNot(mythic.primaryColor));
    expect(epic.primaryColor, isNot(getTierVisualConfig('Mythic Glory').primaryColor));
    expect(legend.primaryColor, isNot(immortal.primaryColor));
  });

  test('all ten tiers use the approved motif and outer treatment', () {
    const expected = <String, (TierFrameAccent, TierOuterTreatment)>{
      'Warrior': (TierFrameAccent.fullThinRing, TierOuterTreatment.none),
      'Elite': (TierFrameAccent.doubleArc, TierOuterTreatment.partialArcs),
      'Master': (TierFrameAccent.diamond, TierOuterTreatment.none),
      'Grandmaster': (TierFrameAccent.facetedHex, TierOuterTreatment.none),
      'Epic': (TierFrameAccent.rubySeal, TierOuterTreatment.none),
      'Legend': (TierFrameAccent.crescent, TierOuterTreatment.none),
      'Mythic': (TierFrameAccent.constellation, TierOuterTreatment.none),
      'Mythic Honor': (
        TierFrameAccent.orbitalArcs,
        TierOuterTreatment.partialArcs,
      ),
      'Mythic Glory': (TierFrameAccent.sparkTrio, TierOuterTreatment.none),
      'Mythic Immortal': (
        TierFrameAccent.immortalCrest,
        TierOuterTreatment.fullRing,
      ),
    };

    for (final entry in expected.entries) {
      final config = getTierVisualConfig(entry.key);
      expect(config.accent, entry.value.$1, reason: entry.key);
      expect(config.outerTreatment, entry.value.$2, reason: entry.key);
    }
    expect(expected.values.map((value) => value.$1).toSet(), hasLength(10));
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

  testWidgets('initials preserve non-BMP Unicode runes', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: TierProfileAvatar(
        tierName: 'Epic',
        displayName: '😀 Ahmad',
        sizeDp: 88,
      ),
    ));

    expect(find.text('😀A'), findsOneWidget);
  });

  testWidgets('Epic Pro avatar keeps the frame clear of its Pro finish',
      (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: TierProfileAvatar(
        tierName: 'Epic',
        displayName: 'Ahmad Fikri',
        equippedFrameId: 'frame_subuh',
        isPro: true,
        sizeDp: 88,
      ),
    ));
    expect(find.bySemanticsLabel('Epic achievement frame'), findsOneWidget);
    expect(find.bySemanticsLabel('Pro signature finish'), findsOneWidget);

    final framePhoto = find.byKey(const ValueKey('tier-avatar-frame-photo'));
    final proCrest = find.byKey(const ValueKey('tier-avatar-pro-crest'));
    expect(framePhoto, findsOneWidget);
    expect(proCrest, findsOneWidget);

    final frameRect = tester.getRect(framePhoto);
    final crestRect = tester.getRect(proCrest);
    expect(crestRect.overlaps(frameRect), isFalse);
    expect(crestRect.left, greaterThan(frameRect.right));
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

  testWidgets('compact avatars retain every tier-specific peripheral cue',
      (tester) async {
    const tiers = <String>[
      'Warrior',
      'Elite',
      'Master',
      'Grandmaster',
      'Epic',
      'Legend',
      'Mythic',
      'Mythic Honor',
      'Mythic Glory',
      'Mythic Immortal',
    ];

    for (final tier in tiers) {
      final accent = getTierVisualConfig(tier).accent;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmallTierAvatar(
          tierName: tier,
          displayName: 'Ahmad Fikri',
        ),
      ));

      expect(
        find.byKey(ValueKey('small-tier-accent-${accent.name}')),
        findsOneWidget,
        reason: tier,
      );
      expect(find.byKey(const ValueKey('tier-avatar-accent-full-outer')), findsNothing);
      expect(find.byType(AnimatedBuilder), findsNothing);
    }
  });
}
