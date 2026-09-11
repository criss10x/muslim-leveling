import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../services/game_service.dart';
import '../theme/app_icons.dart';

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
  /// Pool quest 19: 'subuh_tepat','dzuhur_tepat','maghrib_tepat',
  /// 'isya_hadir','timely_prayers','five_rings',
  /// 'dhuha_before_dzuhur','rawatib_one','rawatib_two','one_sunnah',
  /// 'subuh_isya','any_three','zikir_33','zikir_goal','dzikir_33_subuh',
  /// 'quran_10ayat','quran_1halaman','hadis_3','hadis_5'.
  _QuestCategory get _category {
    final id = widget.quest.id;
    if (id.contains('hadis')) return _QuestCategory.hadis;
    if (id.contains('quran')) return _QuestCategory.quran;
    if (id.contains('zikir') || id.contains('dzikir')) {
      return _QuestCategory.zikir;
    }
    if (id == 'quest_five_rings') return _QuestCategory.fiveRings;
    if (id == 'quest_subuh_isya') return _QuestCategory.subuhIsya;
    if (id.contains('rawatib') || id.contains('dhuha') ||
        id == 'quest_one_sunnah') {
      return _QuestCategory.sunnah;
    }
    // Sisa: subuh_tepat, dzuhur_tepat, maghrib_tepat, isya_hadir,
    // timely_prayers, any_three — semua tentang disiplin wajib.
    return _QuestCategory.sholat;
  }

  /// Quote islami pendek — round-robin per quest.id (deterministic).
  _Quote _pickQuote() {
    final q = _quotes[_category]!;
    final i = widget.quest.id.hashCode.abs() % q.length;
    return q[i];
  }

  /// Copy dorongan — spesifik untuk daily quest rotasi, bukan generik.
  /// Pilih berdasarkan kategori quest (A-G), fallback ke H, dengan
  /// round-robin per quest.id (deterministic, terasa 'tercatat').
  String _encouragement() {
    if (widget.isHaidMode) {
      final i = widget.quest.id.hashCode.abs() % _haidPool.length;
      return _haidPool[i];
    }
    final lines = _copyPool[_category] ?? _copyPool[_QuestCategory.sholat]!;
    final i = widget.quest.id.hashCode.abs() % lines.length;
    return lines[i];
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
                      trailingIcon: AppIcons.arrowForward,
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

enum _QuestCategory { sholat, sunnah, zikir, quran, hadis, fiveRings, subuhIsya }

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
  _QuestCategory.quran: [
    _Quote(
      'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
      'Bacalah dengan menyebut nama Tuhanmu yang menciptakan.',
    ),
    _Quote(
      'إِنَّ الَّذِينَ يَتْلُونَ كِتَابَ اللَّهِ وَأَقَامُوا الصَّلَاةَ...',
      'Sesungguhnya orang-orang yang membaca kitab Allah dan mendirikan shalat... akan mendapat pahala yang berlipat.',
    ),
    _Quote(
      'شَهِدَ اللَّهُ أَنَّهُ لَا إِلَٰهَ إِلَّا هُوَ',
      'Allah menyatakan bahwa tidak ada tuhan selain Dia.',
    ),
  ],
  _QuestCategory.subuhIsya: [
    _Quote(
      'وَاعْبُدْ رَبَّكَ حَتَّىٰ يَأْتِيَكَ الْيَقِينُ',
      'Sembahlah Tuhanmu sampai datang kepadamu keyakinan.',
    ),
    _Quote(
      'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      'Barangsiapa bertakwa kepada Allah, niscaya Dia membukakan jalan keluar.',
    ),
    _Quote(
      'لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا',
      'Janganlah bersedih, sesungguhnya Allah bersama kita.',
    ),
  ],
  _QuestCategory.zikir: [
    _Quote(
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'Maha Suci Allah dan dengan puji-Nya, Maha Suci Allah yang Maha Agung.',
    ),
    _Quote(
      'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      'Tidak ada tuhan selain Allah, Maha Esa, tidak ada sekutu bagi-Nya.',
    ),
    _Quote(
      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'Segala puji bagi Allah, Tuhan semesta alam.',
    ),
  ],
  _QuestCategory.hadis: [
    _Quote(
      'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
      'Sesungguhnya setiap amal tergantung pada niatnya.',
    ),
    _Quote(
      'مَنْ غَشَّنَا فَلَيْسَ مِنَّا',
      'Barangsiapa menipu kami, dia bukan dari golongan kami.',
    ),
    _Quote(
      'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
      'Muslim adalah yang menjaga kaum muslimin dari gangguan lisan dan tangannya.',
    ),
  ],
  _QuestCategory.fiveRings: [
    _Quote(
      'الْعَبْدُ يُؤْجَرُ عَلَى كُلِّ شَيْءٍ حَتَّى فِتَاتِ التُّفَاحَةِ',
      'Hamba diberi pahala atas setiap hal, bahkan potongan kecilnya.',
    ),
    _Quote(
      'أَحَبُّ الْأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
      'Amal yang paling dicintai Allah adalah yang paling konsisten, walau sedikit.',
    ),
    _Quote(
      'مَنْ رَضِيَ بِقَسْمِ اللَّهِ كَانَ لَهُ أَجْرٌ عَظِيمٌ',
      'Barangsiapa ridha dengan ketentuan Allah, dia mendapat pahala yang besar.',
    ),
  ],
};

/// Copy dorongan per kategori quest — round-robin per quest.id (deterministic).
/// Spesifik untuk daily quest rotasi, bukan generik. Tone: 'hangat, pendek,
/// humble, supportive' — bukan 'memberi penilaian dari atas'. Emoji sangat
/// sedikit (🤍 🌙 ✨), hindari klaim teologis spesifik yang belum ada dasar.
const _copyPool = <_QuestCategory, List<String>>{
  _QuestCategory.sholat: [
    'Kamu mungkin lagi sibuk, tapi tetap nyempetin. Good job.',
    'Adzan selesai, kamu langsung jalan. Mantap.',
    'Tepat waktu hari ini. Satu hal baik yang kamu jaga.',
    'Capek tetap capek. Tapi kamu tetap datang. 🤍',
  ],
  _QuestCategory.sunnah: [
    'Nggak wajib, tapi kamu tetap memilih untuk melakukannya.',
    'Nggak ada yang maksa. Kamu sendiri yang memilih untuk datang.',
    'Dua rakaat hari ini. Kecil, tapi berarti.',
    'Pelan-pelan, kebiasaan baik seperti ini yang kamu bangun.',
  ],
  _QuestCategory.zikir: [
    'Di tengah ramainya hari, kamu masih menyempatkan ingat Allah.',
    'Berhenti sebentar. Tarik napas. Ingat Allah.',
    'Apa pun yang lagi kamu pikirin, kamu tetap meluangkan waktu untuk zikir.',
    'Selesai zikir. Semoga hati terasa sedikit lebih ringan. 🤍',
  ],
  _QuestCategory.quran: [
    'Satu ayat hari ini. Pelan-pelan, yang penting terus.',
    'Hari ini kamu kembali membuka Al-Quran. Senang lihatnya.',
    'Nggak harus banyak. Satu halaman pun tetap sebuah langkah.',
    'Satu halaman selesai. Besok lanjut lagi, ya.',
  ],
  _QuestCategory.hadis: [
    'Hari ini kamu meluangkan waktu untuk belajar dari sabda Nabi.',
    'Satu hadis kamu baca hari ini. Semoga ada yang bisa kamu bawa ke harimu.',
    'Nemu hadis yang ngena? Simpan. Siapa tahu kamu butuh mengingatnya lagi.',
    'Sedikit belajar hari ini, semoga jadi bekal untuk besok.',
  ],
  _QuestCategory.fiveRings: [
    'Subuh, Dzuhur, Ashar, Maghrib, Isya. Kamu hadir di semuanya hari ini.',
    'Lima waktu selesai. Alhamdulillah, hari ini kamu berhasil menjaganya.',
    'Satu hari, lima waktu. Lengkap. 🤍',
    'Hari ini selesai dengan baik. Besok kita mulai lagi.',
  ],
  _QuestCategory.subuhIsya: [
    'Subuh kamu jaga, Isya kamu jaga. Alhamdulillah.',
    'Dari awal sampai akhir hari, kamu tetap menyempatkan diri.',
    'Dua waktu ini kamu jaga hari ini. Good job.',
    'Hari ini kamu berhasil menjaga Subuh dan Isya. Besok lanjut lagi.',
  ],
};

/// haidMode — round-robin 4 baris. Hindari klaim teologis ('niatmu dihitung'),
/// fokus pada dukungan personal ('kamu tetap bagian dari perjalanan ini').
const _haidPool = [
  'Hari ini waktunya istirahat. Tetap semangat, ya. 🤍',
  'Nggak apa-apa berhenti sebentar. Kamu tetap bagian dari perjalanan ini.',
  'Hari ini kamu nggak perlu mengejar quest ini. Jaga diri dan tetap dekat dengan Allah.',
  'Quest boleh berhenti sebentar. Perjalananmu tetap lanjut.',
];

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
      _QuestCategory.sholat => AppIcons.mosqueOutlined,
      _QuestCategory.sunnah => AppIcons.autoAwesomeOutlined,
      _QuestCategory.zikir => AppIcons.spaOutlined,
      _QuestCategory.quran => AppIcons.menuBookOutlined,
      _QuestCategory.hadis => AppIcons.formatQuoteOutlined,
      _QuestCategory.fiveRings => AppIcons.workspacePremiumOutlined,
      _QuestCategory.subuhIsya => AppIcons.brightness2Outlined,
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
      child: Icon(haid ? AppIcons.acUnit : _icon, color: color, size: 32),
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
