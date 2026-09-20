import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/hijri_service.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';

/// Hari Penting Islam — replace HijriCalendarScreen (month-grid lama).
/// Layout: list kronologis 10 momen penting + badge status.
class HariPentingScreen extends StatefulWidget {
  const HariPentingScreen({super.key});

  @override
  State<HariPentingScreen> createState() => _HariPentingScreenState();
}

class _HariPentingScreenState extends State<HariPentingScreen> {
  List<ImportantHijriDate>? _dates;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = await hijriService.importantDatesGregorian();
    if (!mounted) return;
    setState(() {
      _dates = dates;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(AppIcons.arrowBack, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.hjHariPentingTitle,
          style: AppText.headlineMd().copyWith(color: AppColors.onSurface),
        ),
      ),
      body: _loading
          ? _buildLoading()
          : _dates == null || _dates!.isEmpty
              ? _buildEmpty(l10n)
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: _buildList(),
                ),
    );
  }

  // --- List kartu ---

  Widget _buildList() {
    final dates = _dates!;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: dates.length,
      itemBuilder: (_, i) => _buildCard(dates[i]),
    );
  }

  Widget _buildCard(ImportantHijriDate d) {
    final l10n = AppL10n.of(context);
    final daysUntil = d.daysUntil;
    final isPast = daysUntil != null && daysUntil < 0;
    final isToday = daysUntil == 0;
    final isUpcoming = daysUntil != null && daysUntil > 0;

    // Warna badge.
    Color badgeColor;
    Color badgeBg;
    if (isToday) {
      badgeColor = AppColors.secondaryFixed; // gold ink
      badgeBg = AppColors.secondaryFixedDim.withValues(alpha: 0.15);
    } else if (isUpcoming) {
      badgeColor = AppColors.primary;
      badgeBg = AppColors.primary.withValues(alpha: 0.12);
    } else {
      badgeColor = AppColors.onSurfaceVariant;
      badgeBg = AppColors.surfaceContainer;
    }

    return Opacity(
      opacity: isPast ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.secondaryFixedDim.withValues(alpha: 0.06)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday
                ? AppColors.secondaryFixed.withValues(alpha: 0.4)
                : AppColors.outlineVariant.withValues(alpha: 0.2),
            width: isToday ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Kiri: tanggal Gregorian.
            if (d.gDate != null) ...[
              Column(
                children: [
                  Text(
                    '${d.gDate!.day}',
                    style: AppText.displayHero(24).copyWith(
                      color: isPast
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', Localizations.localeOf(context).toString())
                        .format(d.gDate!),
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
            ],
            // Tengah: nama momen + tanggal Hijri.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.labelFor(l10n),
                    style: AppText.bodyLg().copyWith(
                      color: isPast
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d.hijriLabel(l10n),
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Kanan: badge status.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                d.statusText(l10n),
                style: AppText.bodyMd().copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ponytail: _gregMonthShort dihapus — pakai intl supaya "Agu" jadi "Aug"
  // di locale en, tanpa daftar nama bulan kedua yang bisa basi.

  // --- States ---

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildEmpty(AppL10n l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.calendarMonthOutlined,
              size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            l10n.hjHariPentingEmpty,
            style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _load,
            child: Text(l10n.onbLocationRetry,
                style: AppText.bodyMd().copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
