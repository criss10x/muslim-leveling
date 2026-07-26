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
  CosmeticSlot.title: 'Gelar',
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
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProPaywallScreen()),
      );
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
                      child: Text(
                        _slotLabels[s]!,
                        style: AppText.labelCapsSm(),
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
            Text('KOLEKSI', style: AppText.labelCapsSm()),
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
          children: items.map((c) {
            final allowed = CosmeticService.isAllowed(state, c.id, isPro: isPro);
            final locked = c.access == CosmeticAccess.pro && !isPro;
            final owned = allowed || CosmeticCatalog.isDefault(c.id);
            final selected = c.id == equippedId;
            final stateLabel = selected
                ? 'DIPAKAI'
                : locked
                    ? 'PRO'
                    : null;

            return Semantics(
              button: true,
              selected: selected,
              label:
                  '${c.name}, ${selected ? 'dipakai' : locked ? 'Pro terkunci' : 'tersedia'}',
              child: InkWell(
                onTap: () => _onTap(c),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 88),
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
                      Text(
                        locked ? '🔒' : c.emoji,
                        style: const TextStyle(fontSize: 26),
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
                      if (stateLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          stateLabel,
                          style: AppText.labelCapsSm().copyWith(
                            color: locked ? AppColors.goldInk : AppColors.primary,
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
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
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
