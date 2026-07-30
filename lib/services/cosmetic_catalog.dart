/// Slots an avatar can equip. One equipped cosmetic per slot.
enum CosmeticSlot { frame, aura, title }

/// How a cosmetic is unlocked. `oneTime` is intentionally deferred (v2).
enum CosmeticAccess { free, pro }

enum CosmeticRarity { normal, rare, epic, legendary, proSignature }

extension CosmeticRarityLabel on CosmeticRarity {
  String get label => switch (this) {
    CosmeticRarity.normal => 'NORMAL',
    CosmeticRarity.rare => 'RARE',
    CosmeticRarity.epic => 'EPIC',
    CosmeticRarity.legendary => 'LEGENDARY',
    CosmeticRarity.proSignature => 'PRO SIGNATURE',
  };
}

/// Silhouette of the avatar's default frame.
enum FrameShape { circle, squareRounded, shieldClassic }

enum AuraEffect { halo, crescent, drift, orbit, goldOrbit }

/// Visual parameters for an aura layer around the avatar.
class AuraSpec {
  final AuraEffect effect;
  final int particleCount;
  final bool goldTint;
  const AuraSpec({
    required this.effect,
    this.particleCount = 6,
    this.goldTint = false,
  });
}

/// One cosmetic definition. Static data only — no behaviour.
class Cosmetic {
  final String id;
  final CosmeticSlot slot;
  final String name;
  final String emoji;
  final CosmeticAccess access;
  final CosmeticRarity rarity;
  final String? legacyRewardName; // maps an old chest reward name → this id
  final FrameShape? frameShape; // slot == frame
  final AuraSpec? auraSpec; // slot == aura
  final String? titleText; // slot == title

  const Cosmetic({
    required this.id,
    required this.slot,
    required this.name,
    required this.emoji,
    required this.access,
    this.rarity = CosmeticRarity.normal,
    this.legacyRewardName,
    this.frameShape,
    this.auraSpec,
    this.titleText,
  });
}

/// The single source of truth for all cosmetics.
class CosmeticCatalog {
  static const Map<CosmeticSlot, String> defaults = {
    CosmeticSlot.frame: 'frame_default',
    CosmeticSlot.aura: 'aura_none',
    CosmeticSlot.title: 'title_none',
  };

  static const List<Cosmetic> all = [
    // ── Frames ──
    Cosmetic(
      id: 'frame_default',
      slot: CosmeticSlot.frame,
      name: 'Lingkaran Klasik',
      emoji: '⚪',
      access: CosmeticAccess.free,
      frameShape: FrameShape.circle,
    ),
    // ── Auras ──
    Cosmetic(
      id: 'aura_none',
      slot: CosmeticSlot.aura,
      name: 'Tanpa Aura',
      emoji: '∅',
      access: CosmeticAccess.free,
      auraSpec: null,
    ),
    Cosmetic(
      id: 'aura_sultan',
      slot: CosmeticSlot.aura,
      name: 'Nur Fajr',
      emoji: '✦',
      access: CosmeticAccess.free,
      rarity: CosmeticRarity.rare,
      auraSpec: AuraSpec(effect: AuraEffect.halo, particleCount: 3),
      legacyRewardName: 'Efek Aura Sultan',
    ),
    Cosmetic(
      id: 'aura_istiqomah',
      slot: CosmeticSlot.aura,
      name: 'Hilal Senja',
      emoji: '🌙',
      access: CosmeticAccess.free,
      rarity: CosmeticRarity.epic,
      auraSpec: AuraSpec(effect: AuraEffect.crescent, particleCount: 1),
      legacyRewardName: 'Jejak Api Istiqomah',
    ),
    Cosmetic(
      id: 'aura_wings',
      slot: CosmeticSlot.aura,
      name: 'Sakinah',
      emoji: '◌',
      access: CosmeticAccess.free,
      rarity: CosmeticRarity.legendary,
      auraSpec: AuraSpec(effect: AuraEffect.drift, particleCount: 5),
      legacyRewardName: 'Sayap Malaikat Istiqomah',
    ),
    Cosmetic(
      id: 'aura_tahajjud',
      slot: CosmeticSlot.aura,
      name: 'Falak',
      emoji: '✧',
      access: CosmeticAccess.pro,
      rarity: CosmeticRarity.proSignature,
      auraSpec: AuraSpec(effect: AuraEffect.orbit, particleCount: 3),
    ),
    Cosmetic(
      id: 'aura_nur_emas',
      slot: CosmeticSlot.aura,
      name: 'Siraj Emas',
      emoji: '✨',
      access: CosmeticAccess.pro,
      rarity: CosmeticRarity.proSignature,
      auraSpec: AuraSpec(
        effect: AuraEffect.goldOrbit,
        particleCount: 4,
        goldTint: true,
      ),
    ),

    // ── Titles ──
    Cosmetic(
      id: 'title_none',
      slot: CosmeticSlot.title,
      name: 'Tanpa Title',
      emoji: '∅',
      access: CosmeticAccess.free,
      titleText: '',
    ),
    Cosmetic(
      id: 'title_crescent',
      slot: CosmeticSlot.title,
      name: 'Bulan Sabit Menyala',
      emoji: '🌙',
      access: CosmeticAccess.free,
      rarity: CosmeticRarity.rare,
      titleText: 'Bulan Sabit Menyala',
      legacyRewardName: 'Lencana Bulan Sabit Menyala',
    ),
    Cosmetic(
      id: 'title_tahajjud_slayer',
      slot: CosmeticSlot.title,
      name: 'Pembasmi Sunyi Tahajjud',
      emoji: '⚔️',
      access: CosmeticAccess.free,
      rarity: CosmeticRarity.epic,
      titleText: 'Pembasmi Sunyi Tahajjud',
      legacyRewardName: 'Gelar Pembasmi Sunyi Tahajjud',
    ),
    Cosmetic(
      id: 'title_dzikir',
      slot: CosmeticSlot.title,
      name: 'Ramuan Mana Dzikir',
      emoji: '🧪',
      access: CosmeticAccess.free,
      rarity: CosmeticRarity.rare,
      titleText: 'Ramuan Mana Dzikir',
      legacyRewardName: 'Ikon Ramuan Mana Dzikir',
    ),
    Cosmetic(
      id: 'title_maghrib_guard',
      slot: CosmeticSlot.title,
      name: 'Penjaga Maghrib',
      emoji: '🌆',
      access: CosmeticAccess.free,
      rarity: CosmeticRarity.epic,
      titleText: 'Penjaga Maghrib',
      legacyRewardName: 'Segel Penjaga Maghrib',
    ),
    Cosmetic(
      id: 'title_quran_sage',
      slot: CosmeticSlot.title,
      name: "Bijak Al-Qur'an",
      emoji: '🥋',
      access: CosmeticAccess.free,
      rarity: CosmeticRarity.legendary,
      titleText: "Bijak Al-Qur'an",
      legacyRewardName: "Jubah Bijak Al-Qur'an",
    ),
    Cosmetic(
      id: 'title_mythic_sword',
      slot: CosmeticSlot.title,
      name: 'Pedang Sholat Mitik',
      emoji: '🗡️',
      access: CosmeticAccess.free,
      rarity: CosmeticRarity.legendary,
      titleText: 'Pedang Sholat Mitik',
      legacyRewardName: 'Pedang Sholat Mitik',
    ),
    Cosmetic(
      id: 'title_pro_muhsin',
      slot: CosmeticSlot.title,
      name: 'Al-Muhsin',
      emoji: '👑',
      access: CosmeticAccess.pro,
      rarity: CosmeticRarity.proSignature,
      titleText: 'Al-Muhsin',
    ),
  ];

  static Cosmetic? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<Cosmetic> bySlot(CosmeticSlot slot) =>
      all.where((c) => c.slot == slot).toList();

  static bool isDefault(String id) => defaults.values.contains(id);
}
