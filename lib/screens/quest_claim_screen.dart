import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';

/// Quest Harian Claim — layar singkat hangat setelah klaim quest harian.
/// Berbeda dari NaikLevelScreen (event langka, confetti): ini event harian
/// 3-5×/hari, register tenang, paper-feel. Naiknya semangat, bukan tarafnya.
///
/// Trigger: _claimQuest di home_tab.dart setelah claimQuest()
/// kalau tidak push NaikLevelScreen (bukan level-up event).
class QuestClaimScreen extends StatefulWidget {
  final Quest quest;
  final int xpGained;
  final int claimedTodayCount; // 1=pertama, 2=kedua, dst — copy variant
  final bool isHaidMode;

  const QuestClaimScreen({
    super.key,
    required this.quest,
    required this.xpGained,
    required this.isHaidMode,
    this.claimedTodayCount = 1,
  });

  @override
  State<QuestClaimScreen> createState() => _QuestClaimScreenState();
}

class _QuestClaimScreenState extends State<QuestClaimScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 250))
    ..forward();

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  /// Kategori dari quest.id — cepat, deterministic.
  /// Pool quest 15: 'subuh', 'dzuhur', 'maghrib', 'isya', 'tilawah',
  /// 'dhuha', 'rawatib', 'sunnah', 'five_rings', 'timely', 'one_sunnah',
  /// 'any_three', 'subuh_isya'. Tidak ada Quran/Hadis quest id sekarang.
  _QuestCategory get _category {
    final id = widget.quest.id;
    if (id.contains('tilawah') || id.contains('dzikir')) return _QuestCategory.tilawah;
    if (id.contains('rawatib') || id.contains('dhuha') ||
        id.contains('sunnah')) {
      return _QuestCategory.sunnah;
    }
    if (id.contains('five_rings') || id.contains('subuh_isya') ||
        id.contains('any_three') || id.contains('timely')) {
      return _QuestCategory.streak;
    }
    return _QuestCategory.sholat;
  }

  /// Quote islami pendek — round-robin per quest.id (deterministic).
  _Quote _pickQuote() {
    final q = _quotes[_category]!;
    final i = widget.quest.id.hashCode.abs() % q.length;
    return q[i];
  }

  /// Copy dorongan — varies by claim count + haid + at-risk.
  String _encouragement() {
    if (widget.isHaidMode) {
      return 'Tetap dekat dengan-Nya. Setiap niat tercatat.';
    }
    final n = widget.claimedTodayCount;
    if (n == 1) return 'Catatan kebaikan pertamamu hari ini.';
    if (n == 2) return 'Istiqomah — satu lagi tercatat.';
    return 'Terus lanjutkan, malaikat mencatat.';
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final quote = _pickQuote();
    final cat = _category;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entry,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: _entry, curve: Curves.easeOutCubic)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical -
                      AppSpacing.md * 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Top: Amal Tercatat ──
                    Semantics(
                      header: true,
                      child: _PaperCard(
                        child: Column(
                          children: [
                            _CategoryIcon(
                              category: cat,
                              haid: widget.isHaidMode,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Alhamdulillah',
                              style: AppText.headlineLg().copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.quest.desc,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppText.bodyLg().copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                '+${widget.xpGained} XP',
                                style: AppText.labelCaps().copyWith(
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // ── Middle: Pesan Hangat ──
                    _QuoteBlock(quote: quote),
                    const SizedBox(height: AppSpacing.xl),
                    // ── Bottom: Dorongan ──
                    Semantics(
                      label: _encouragement(),
                      child: Text(
                        _encouragement(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppText.bodyMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    HeroButton(
                      label: 'Lanjut',
                      trailingIcon: Icons.arrow_forward,
                      onPressed: reduceMotion
                          ? () => Navigator.of(context).pop()
                          : () async {
                              await _entry.reverse();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _QuestCategory { sholat, sunnah, tilawah, streak }

class _Quote {
  final String arabic;
  final String idn;
  const _Quote(this.arabic, this.idn);
}

/// Pool statis — 4-6 quote per kategori. Pilih round-robin per quest.id.
const _quotes = <_QuestCategory, List<_Quote>>{
  _QuestCategory.sholat: [
    _Quote(
      'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
      'Sesungguhnya shalat itu adalah kewajiban yang ditentukan waktunya atas orang-orang beriman.',
    ),
    _Quote(
      'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ',
      'Peliharalah semua shalat dan shalat wusthaa. Berdirilah karena Allah dengan khusyuk.',
    ),
    _Quote(
      'أَقِمِ الصَّلَاةَ لِذِكْرِي',
      'Laksanakanlah shalat untuk mengingat-Ku.',
    ),
  ],
  _QuestCategory.sunnah: [
    _Quote(
      'مَنْ حَافَظَ عَلَى أَرْبَعِ رَكَعَاتٍ قَبْلَ الظُّهْرِ...',
      'Barangsiapa menjaga empat rakaat sebelum Dzuhur, Allah mengharamkan jasadnya dari api neraka.',
    ),
    _Quote(
      'صَلاَةُ الرَّجُلِ فِي جَمَاعَةٍ تَزِيدُ عَلَى صَلاَتِهِ فِي بَيْتِهِ',
      'Shalat berjamaah melebihi shalat sendirian di rumah 27 derajat.',
    ),
    _Quote(
      'رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا',
      'Dua rakaat shalat fajar lebih baik daripada dunia dan seisinya.',
    ),
  ],
  _QuestCategory.tilawah: [
    _Quote(
      'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
      'Bacalah dengan menyebut nama Tuhanmu yang menciptakan.',
    ),
    _Quote(
      'إِنَّ الَّذِينَ يَتْلُونَ كِتَابَ اللَّهِ وَأَقَامُوا الصَّلَاةَ...',
      'Sesungguhnya orang-orang yang membaca kitab Allah dan mendirikan shalat... akan mendapat pahala yang berlipat.',
    ),
    _Quote(
      'وَقَالَ الرَّسُولُ يَا رَبِّ إِنَّ قَوْمِي اتَّخَذُوا هَٰذَا الْقُرْآنَ مَهْجُورًا',
      'Kami tidak akan meninggalkan Al-Qur\'an; ia penjaga kami di dunia dan syafaat di akhirat.',
    ),
  ],
  _QuestCategory.streak: [
    _Quote(
      'وَاعْبُدْ رَبَّكَ حَتَّىٰ يَأْتِيَكَ الْيَقِينُ',
      'Sembahlah Tuhanmu sampai datang kepadamu keyakinan (ajal).',
    ),
    _Quote(
      'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      'Barangsiapa bertakwa kepada Allah, niscaya Dia akan membukakan jalan keluar.',
    ),
    _Quote(
      'لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا',
      'Janganlah kamu bersedih, sesungguhnya Allah bersama kita.',
    ),
  ],
};

/// Kartu kertas ala Mushaf — light surface di tengah canvas dark,
/// supaya mata istirahat dari hitam pekat + identitas islami kuat.
/// ponytail: ini bukan real parchment asset — reuse surfaceContainerHigh
/// (yang di light theme ~#E5E7EB, di dark ~#1E2522) + hairline border.
class _PaperCard extends StatelessWidget {
  final Widget child;
  const _PaperCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final light = isLightTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: light
            ? AppColors.surfaceContainerLowest // white
            : AppColors.surfaceContainerHigh, // #1E2522 dark emerald-tinted
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: light
              ? AppColors.outlineVariant
              : AppColors.primary.withValues(alpha: 0.18),
        ),
        boxShadow: light
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: child,
    );
  }
}

/// Ikon kategori — paper-feel (background halus, bukan glow).
class _CategoryIcon extends StatelessWidget {
  final _QuestCategory category;
  final bool haid;
  const _CategoryIcon({required this.category, required this.haid});

  IconData get _icon {
    return switch (category) {
      _QuestCategory.sholat => Icons.mosque_outlined,
      _QuestCategory.sunnah => Icons.auto_awesome_outlined,
      _QuestCategory.tilawah => Icons.menu_book_outlined,
      _QuestCategory.streak => Icons.flag_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = haid ? AppColors.tertiary : AppColors.primary;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Icon(haid ? Icons.ac_unit : _icon, color: color, size: 32),
    );
  }
}

/// Quote block — arabic (RTL, larger) + terjemah Indonesia.
class _QuoteBlock extends StatelessWidget {
  final _Quote quote;
  const _QuoteBlock({required this.quote});

  @override
  Widget build(BuildContext context) {
    final light = isLightTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Text(
            quote.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.amiri(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
              height: 1.8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '"${quote.idn}"',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyMd().copyWith(
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: light ? 1.5 : 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
