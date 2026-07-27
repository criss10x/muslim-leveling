import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/cosmetic_catalog.dart';
import '../services/cosmetic_service.dart';
import '../services/game_service.dart';
import '../services/entitlement_service.dart';
import '../screens/pro_paywall_screen.dart';

const _slotLabels = {
  CosmeticSlot.frame: 'Bingkai',
  CosmeticSlot.aura: 'Aura',
  CosmeticSlot.title: 'Title',
};

const _slotIcons = {
  CosmeticSlot.frame: Icons.crop_square_rounded,
  CosmeticSlot.aura: Icons.auto_awesome,
  CosmeticSlot.title: Icons.workspace_premium_outlined,
};

class CosmeticLocker extends StatefulWidget {
  const CosmeticLocker({super.key});

  @override
  State<CosmeticLocker> createState() => _CosmeticLockerState();
}

class _CosmeticLockerState extends State<CosmeticLocker> {
  CosmeticSlot _slot = CosmeticSlot.frame;

  @override
  void initState() {
    super.initState();
    GameService.stateVersion.addListener(_rebuild);
    EntitlementService.proStatus.addListener(_rebuild);
  }

  @override
  void dispose() {
    GameService.stateVersion.removeListener(_rebuild);
    EntitlementService.proStatus.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _onTap(Cosmetic c) async {
    final isPro = EntitlementService.isPro;
    if (c.access == CosmeticAccess.pro && !isPro) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProPaywallScreen()));
      return;
    }

    final equippedId = CosmeticService.resolveSlot(
      GameService.current,
      c.slot,
      isPro: isPro,
    );
    if (c.id == equippedId &&
        CosmeticService.isAllowed(GameService.current, c.id, isPro: isPro)) {
      await GameService.unequipCosmetic(c.slot);
      return;
    }
    await GameService.equipCosmetic(c.slot, c.id, isPro: isPro);
  }

  Color _rarityColor(CosmeticRarity rarity) => switch (rarity) {
    CosmeticRarity.normal => AppColors.onSurfaceVariant,
    CosmeticRarity.rare => AppColors.tertiary,
    CosmeticRarity.epic => const Color(0xFF7C3AED),
    CosmeticRarity.legendary => AppColors.goldInk,
    CosmeticRarity.proSignature => AppColors.primary,
  };

  Widget _previewGlyph(Cosmetic cosmetic, Color color) {
    if (cosmetic.slot != CosmeticSlot.aura) {
      return Text(cosmetic.emoji, style: const TextStyle(fontSize: 26));
    }
    final icon = switch (cosmetic.auraSpec?.effect) {
      AuraEffect.halo => Icons.brightness_1_outlined,
      AuraEffect.crescent => Icons.dark_mode_outlined,
      AuraEffect.drift => Icons.blur_on_outlined,
      AuraEffect.orbit => Icons.all_inclusive,
      AuraEffect.goldOrbit => Icons.auto_awesome,
      null => Icons.do_not_disturb_alt_outlined,
    };
    return Icon(icon, color: color, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    final isPro = EntitlementService.isPro;
    final state = GameService.current;
    final equippedId = CosmeticService.resolveSlot(state, _slot, isPro: isPro);
    final unlockedFree = CosmeticCatalog.bySlot(_slot)
        .where(
          (c) =>
              c.access == CosmeticAccess.free &&
              CosmeticService.isAllowed(state, c.id, isPro: isPro),
        )
        .toList();
    final hasEarnedFree = unlockedFree.any(
      (c) => !CosmeticCatalog.isDefault(c.id),
    );
    final items = CosmeticCatalog.bySlot(_slot)
        .where(
          (c) =>
              c.access == CosmeticAccess.pro ||
              CosmeticService.isAllowed(state, c.id, isPro: isPro),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: CosmeticSlot.values.map((s) {
            final selected = s == _slot;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: s == CosmeticSlot.values.last ? 0 : AppSpacing.sm,
                ),
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: _slotLabels[s]!,
                  child: InkWell(
                    onTap: () => setState(() => _slot = s),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.surfaceContainerHigh
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _slotIcons[s],
                            size: 14,
                            color: selected
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _slotLabels[s]!,
                            style: AppText.labelCapsSm().copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'KOLEKSI',
              style: AppText.labelCapsSm().copyWith(color: AppColors.onSurface),
            ),
            Text(
              '${unlockedFree.length} TERBUKA',
              style: AppText.labelCapsSm().copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.65,
          children: items.map((c) {
            final allowed = CosmeticService.isAllowed(
              state,
              c.id,
              isPro: isPro,
            );
            final locked = c.access == CosmeticAccess.pro && !isPro;
            final owned = allowed || CosmeticCatalog.isDefault(c.id);
            final selected = c.id == equippedId;
            final stateLabel = selected
                ? 'DIPAKAI'
                : locked
                ? 'PRO SIGNATURE'
                : null;
            final rarityColor = _rarityColor(c.rarity);

            return Semantics(
              button: true,
              selected: selected,
              label:
                  '${c.name}, ${selected
                      ? 'dipakai'
                      : locked
                      ? 'Pro terkunci'
                      : 'tersedia'}',
              child: InkWell(
                onTap: () => _onTap(c),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 112),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: locked
                        ? AppColors.goldInk.withValues(alpha: 0.08)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : locked
                          ? AppColors.goldInk
                          : AppColors.outlineVariant,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _previewGlyph(
                        c,
                        locked ? AppColors.goldInk : rarityColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.name,
                        style: AppText.bodyMd().copyWith(
                          fontSize: 10,
                          color: owned
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        c.rarity.label,
                        style: AppText.labelCapsSm().copyWith(
                          color: rarityColor,
                          fontSize: 8,
                          letterSpacing: 0.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (stateLabel != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          stateLabel,
                          style: AppText.labelCapsSm().copyWith(
                            color: locked
                                ? AppColors.goldInk
                                : AppColors.primary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (!hasEarnedFree) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Selesaikan quest harian untuk membuka skin dari Daily Chest.',
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
