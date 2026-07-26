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
    expect(getTierVisualConfig('Elite').hasPartialOuterArcs, isTrue);
    expect(getTierVisualConfig('Mythic Honor').hasPartialOuterArcs, isTrue);
    expect(getTierVisualConfig('Warrior').hasPartialOuterArcs, isFalse);
    expect(immortal.hasFullOuterRing, isTrue);
  });

  test('tier thresholds retain all ten existing ranks', () {
    expect(getTierName(1), 'Warrior');
    expect(getTierName(10), 'Elite');
    expect(getTierName(30), 'Grandmaster');
    expect(getTierName(60), 'Legend');
    expect(getTierName(80), 'Mythic');
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
}
