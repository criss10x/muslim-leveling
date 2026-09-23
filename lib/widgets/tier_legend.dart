import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'tier_avatar.dart';

/// Pintasan gaya "baris" di tab Profil: HudHeader + kartu PressableScale
/// ber-surfaceContainer dengan chevron. Dipakai tiga baris yang duduk
/// berdampingan (Kalender, Loker Skin, Sistem Rank) supaya vokabulernya satu.
class ProfilRowTile extends StatelessWidget {
  final String header;
  final String body;
  final String semantics;
  final IconData icon;
  final VoidCallback onTap;

  const ProfilRowTile({
    super.key,
    required this.header,
    required this.body,
    required this.semantics,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      label: semantics,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HudHeader(header),
          PressableScale(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      body,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMd().copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Icon(
                    AppIcons.arrowForwardIos,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Legend sistem rank: satu baris per tier, warna chip diambil dari
/// [getTierVisualConfig] — sumber yang sama dengan avatar di kartu hero, jadi
/// penjelasan ini tidak bisa berbeda dari warna yang benar-benar dipakai.
/// Warnanya sengaja bukan teks: sebagian warna tier gelap (Mythic Immortal
/// nyaris hitam) dan tidak lolos kontras sebagai teks di kartu terang. Nama
/// tier memakai onSurface (aman di 4 tema), warna tier dipakai sebagai chip.
class TierLegend extends StatelessWidget {
  final int currentLevel;

  const TierLegend({super.key, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final currentTier = getTierName(currentLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, start) in tierLadder)
          _row(l10n, name, start, name == currentTier),
      ],
    );
  }

  Widget _row(AppL10n l10n, String name, int start, bool isCurrent) {
    final config = getTierVisualConfig(name);
    // Divisi I–V hanya untuk tier yang punya gelar bernomor; Mythic ke atas
    // memakai gelar tetap (lihat GameService.getRankTitle).
    final hasDivision = start < 80;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [config.primaryColor, config.secondaryColor],
              ),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyMd().copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (isCurrent) ...[
            _nowBadge(l10n),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            hasDivision ? l10n.profilRankDivision : l10n.profilRankNoDivision,
            style: AppText.labelCaps().copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 58,
            child: Text(
              l10n.profilRankFromLevel(start),
              textAlign: TextAlign.right,
              style: AppText.labelCaps().copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nowBadge(AppL10n l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Text(
        l10n.profilRankNow,
        style: AppText.labelCaps().copyWith(
          color: AppColors.primary,
          fontSize: 9,
        ),
      ),
    );
  }
}
