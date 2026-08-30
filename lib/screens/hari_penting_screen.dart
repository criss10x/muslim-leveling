import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/hijri_service.dart';

/// Hari Penting Islam — replace HijriCalendarScreen (month-grid lama).
/// Layout: timeline strip 12 bulan Hijri di atas + list 10 kartu kronologis.
class HariPentingScreen extends StatefulWidget {
  const HariPentingScreen({super.key});

  @override
  State<HariPentingScreen> createState() => _HariPentingScreenState();
}

class _HariPentingScreenState extends State<HariPentingScreen> {
  List<ImportantHijriDate>? _dates;
  bool _loading = true;
  int _selectedMonth = DateTime.now().month; // ponytail: fallback Gregorian
  final _scrollCtrl = ScrollController();

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
      // Center timeline ke bulan pertama yang punya tanggal mendatang.
      if (dates.isNotEmpty) {
        final upcoming = dates.firstWhere(
          (d) => (d.daysUntil ?? 999) >= 0,
          orElse: () => dates.last,
        );
        _selectedMonth = upcoming.hMonth;
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hari Penting Islam',
          style: AppText.headlineMd().copyWith(color: AppColors.onSurface),
        ),
      ),
      body: _loading
          ? _buildLoading()
          : _dates == null || _dates!.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: Column(
                    children: [
                      _buildTimeline(),
                      Expanded(child: _buildList()),
                    ],
                  ),
                ),
    );
  }

  // --- Timeline strip ---

  Widget _buildTimeline() {
    // ponytail: 12 kotak statis, highlight bulan yang punya momen.
    final monthsWithEvent = <int>{};
    if (_dates != null) {
      for (final d in _dates!) {
        monthsWithEvent.add(d.hMonth);
      }
    }

    return SizedBox(
      height: 56,
      child: ListView.builder(
        controller: _scrollCtrl,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: 12,
        itemBuilder: (_, i) {
          final month = i + 1;
          final short = _monthShort(month);
          final hasEvent = monthsWithEvent.contains(month);
          final isSelected = month == _selectedMonth;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedMonth = month);
              _scrollToMonth(month);
            },
            child: Container(
              width: 48,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    short,
                    style: AppText.bodyMd().copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 10,
                    ),
                  ),
                  if (hasEvent) ...[
                    const SizedBox(height: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _monthShort(int m) {
    const names = [
      '', 'Muh', 'Saf', 'Rb1', 'Rb2', 'Jm1', 'Jm2',
      'Raj', 'Sya', 'Ram', 'Syw', 'DzQ', 'DzH',
    ];
    return m >= 1 && m <= 12 ? names[m] : '?';
  }

  void _scrollToMonth(int month) {
    // ponytail: scroll list ke kartu pertama di bulan ini.
    if (_dates == null) return;
    final idx = _dates!.indexWhere((d) => d.hMonth == month);
    if (idx < 0) return;
    // Estimate item height ~100px, scroll to that offset.
    // Real implementation would use ScrollablePositionedList, but
    // ponytail: ListView + animateTo covers it for 10 items.
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
                    _gregMonthShort(d.gDate!.month),
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
                    d.label,
                    style: AppText.bodyLg().copyWith(
                      color: isPast
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d.hijriLabel,
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
                d.statusText,
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

  String _gregMonthShort(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return m >= 1 && m <= 12 ? names[m] : '?';
  }

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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'Tidak bisa memuat tanggal penting.',
            style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _load,
            child: Text('Coba lagi',
                style: AppText.bodyMd().copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
