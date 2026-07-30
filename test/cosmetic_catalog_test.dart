import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/services/cosmetic_catalog.dart';

void main() {
  test('all cosmetic ids are unique', () {
    final ids = CosmeticCatalog.all.map((c) => c.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every slot has a default that requires no ownership', () {
    for (final slot in CosmeticSlot.values) {
      final defId = CosmeticCatalog.defaults[slot];
      expect(defId, isNotNull, reason: 'missing default for $slot');
      final c = CosmeticCatalog.byId(defId!);
      expect(c, isNotNull);
      expect(c!.access, CosmeticAccess.free);
      expect(CosmeticCatalog.isDefault(defId), isTrue);
    }
  });

  test('every legacyRewardName maps to a real free cosmetic', () {
    final withLegacy = CosmeticCatalog.all.where(
      (c) => c.legacyRewardName != null,
    );
    expect(withLegacy, isNotEmpty);
    for (final c in withLegacy) {
      expect(
        c.access,
        CosmeticAccess.free,
        reason: 'earned (legacy) cosmetics must be free',
      );
    }
  });

  test('frame cosmetics carry a frameShape; others do not', () {
    for (final c in CosmeticCatalog.bySlot(CosmeticSlot.frame)) {
      expect(c.frameShape, isNotNull, reason: '${c.id} missing frameShape');
    }
  });

  test('frame slot keeps only the circular default', () {
    final frames = CosmeticCatalog.bySlot(CosmeticSlot.frame);

    expect(frames.map((c) => c.id), ['frame_default']);
    expect(frames.single.frameShape, FrameShape.circle);
    expect(CosmeticCatalog.byId('shield_classic'), isNull);
  });

  test('auras have distinct effects and rarity labels', () {
    final auras = CosmeticCatalog.bySlot(
      CosmeticSlot.aura,
    ).where((c) => !CosmeticCatalog.isDefault(c.id)).toList();

    expect(auras.map((c) => c.auraSpec!.effect).toSet().length, auras.length);
    expect(auras.map((c) => c.rarity), contains(CosmeticRarity.proSignature));
  });
}
