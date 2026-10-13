import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/quran_api.dart' show quranUseEnglish;
import '../services/quran_data.dart';
import '../services/quran_situasi.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'quran_reader.dart';

/// Label situasi dari ARB. 54 id situasi tidak bisa dipetakan lewat
/// `Map<String, String Function(AppL10n)>` tanpa menulis 54 entri yang sama
/// panjangnya dengan ARB-nya sendiri, jadi label diambil dengan nama getter
/// yang sudah di-generate. Kalau ada id yang lupa ditambahkan, `describe`
/// mengembalikan null dan tes `ayat_situasi_screen_test.dart` gagal.
String situationLabel(AppL10n l10n, String id) => _describe(l10n, id) ?? '';

/// Deskripsi satu baris di bawah judul situasi (dipakai layar ayat).
String situationDesc(AppL10n l10n, String id) => _describe(l10n, id) ?? '';

/// Label tingkat 1 — alasan besar orang membuka Quran.
///
/// Ditulis sebagai kalimat yang dirasakan user ("Sedih dan kacau"), bukan
/// istilah ("Syifa"): tingkat ini yang pertama dibaca orang yang sedang tidak
/// bisa menjelaskan masalahnya sendiri.
String umbrellaLabel(AppL10n l10n, String id) => switch (id) {
  'shifa' => l10n.situasiAlasanShifa,
  'dikuatkan' => l10n.situasiAlasanDikuatkan,
  'huda' => l10n.situasiAlasanHuda,
  'diingatkan' => l10n.situasiAlasanDiingatkan,
  _ => '',
};

/// Kalimat bantu di bawah label alasan.
String umbrellaHint(AppL10n l10n, String id) => switch (id) {
  'shifa' => l10n.situasiAlasanShifaHint,
  'dikuatkan' => l10n.situasiAlasanDikuatkanHint,
  'huda' => l10n.situasiAlasanHudaHint,
  'diingatkan' => l10n.situasiAlasanDiingatkanHint,
  _ => '',
};

/// Ikon tiap alasan, dari set ikon app (bukan emoji: emoji tidak punya sistem
/// ikon dan ukurannya ikut font sehingga tidak sejajar dengan teks).
IconData umbrellaIcon(String id) => switch (id) {
  'shifa' => AppIcons.favorite,
  'dikuatkan' => AppIcons.bolt,
  'huda' => AppIcons.explore,
  'diingatkan' => AppIcons.wbSunny,
  _ => AppIcons.circleOutlined,
};

/// Urutan tingkat 1 = urutan tampil. Bukan urutan abjad: alurnya mengikuti
/// gerak hati, dari yang paling berat ke yang paling lega.
const kUmbrellas = ['shifa', 'dikuatkan', 'huda', 'diingatkan'];

String groupLabel(AppL10n l10n, String id) => switch (id) {
  'kacau' => l10n.situasiGroupKacau,
  'ujian' => l10n.situasiGroupUjian,
  'hubungan' => l10n.situasiGroupHubungan,
  'iman' => l10n.situasiGroupIman,
  'keputusan' => l10n.situasiGroupKeputusan,
  'ampunan' => l10n.situasiGroupAmpunan,
  'motivasi' => l10n.situasiGroupMotivasi,
  'syukur' => l10n.situasiGroupSyukur,
  'dunia' => l10n.situasiGroupDunia,
  _ => '',
};

/// Label sub-tahap di dalam satu grup.
///
/// Tahap dipakai supaya grup besar tidak jadi daftar yang harus dibaca satu per
/// satu (mis. "Kena ujian hidup" 7 pilihan -> menimpa sekarang / sudah
/// berlarut). Id-nya dikunci tes supaya tidak ada tahap tanpa label.
String stageLabel(AppL10n l10n, String id) => switch (id) {
  'rasa' => l10n.situasiStageRasa,
  'beban-pikiran' => l10n.situasiStageBebanPikiran,
  'kebiasaan' => l10n.situasiStageKebiasaan,
  'menimpa' => l10n.situasiStageMenimpa,
  'berlarut' => l10n.situasiStageBerlarut,
  'terdekat' => l10n.situasiStageTerdekat,
  'kecewa' => l10n.situasiStageKecewa,
  'jarak' => l10n.situasiStageJarak,
  'arah' => l10n.situasiStageArah,
  'pilihan-besar' => l10n.situasiStagePilihanBesar,
  'cari-yakin' => l10n.situasiStageCariYakin,
  'salah' => l10n.situasiStageSalah,
  'kembali' => l10n.situasiStageKembali,
  'mulai' => l10n.situasiStageMulai,
  'bertahan' => l10n.situasiStageBertahan,
  'rezeki-baik' => l10n.situasiStageRezekiBaik,
  'tenang' => l10n.situasiStageTenang,
  _ => '',
};

String? _describe(AppL10n l10n, String id) => switch (id) {
  'sedih' => l10n.situasiSitSedih,
  'cemas' => l10n.situasiSitCemas,
  'marah' => l10n.situasiSitMarah,
  'kesepian' => l10n.situasiSitKesepian,
  'insecure' => l10n.situasiSitInsecure,
  'iri' => l10n.situasiSitIri,
  'putus-asa' => l10n.situasiSitPutusAsa,
  'burnout' => l10n.situasiSitBurnout,
  'fomo' => l10n.situasiSitFomo,
  'rezeki-sempit' => l10n.situasiSitRezekiSempit,
  'sakit' => l10n.situasiSitSakit,
  'kehilangan' => l10n.situasiSitKehilangan,
  'gagal' => l10n.situasiSitGagal,
  'dizalimi' => l10n.situasiSitDizalimi,
  'keluarga-besar' => l10n.situasiSitKeluargaBesar,
  'rumah-tangga' => l10n.situasiSitRumahTangga,
  'konflik-ortu' => l10n.situasiSitKonflikOrtu,
  'pasangan' => l10n.situasiSitPasangan,
  'putus-cinta' => l10n.situasiSitPutusCinta,
  'teman-toxic' => l10n.situasiSitTemanToxic,
  'parenting' => l10n.situasiSitParenting,
  'dikucilkan' => l10n.situasiSitDikucilkan,
  'memaafkan' => l10n.situasiSitMemaafkan,
  'futur' => l10n.situasiSitFutur,
  'jauh-dari-allah' => l10n.situasiSitJauhDariAllah,
  'tujuan-hidup' => l10n.situasiSitTujuanHidup,
  'munafik' => l10n.situasiSitMunafik,
  'was-was' => l10n.situasiSitWasWas,
  'baru-hijrah' => l10n.situasiSitBaruHijrah,
  'pilih-jodoh' => l10n.situasiSitPilihJodoh,
  'pilih-karier' => l10n.situasiSitPilihKarier,
  'merantau' => l10n.situasiSitMerantau,
  'kuliah-bisnis' => l10n.situasiSitKuliahBisnis,
  'istikharah' => l10n.situasiSitIstikharah,
  'quarter-life' => l10n.situasiSitQuarterLife,
  'setelah-maksiat' => l10n.situasiSitSetelahMaksiat,
  'merasa-kotor' => l10n.situasiSitMerasaKotor,
  'mulai-taubat' => l10n.situasiSitMulaiTaubat,
  'takut-azab' => l10n.situasiSitTakutAzab,
  'berani-bicara' => l10n.situasiSitBeraniBicara,
  'istiqomah' => l10n.situasiSitIstiqomah,
  'lawan-malas' => l10n.situasiSitLawanMalas,
  'jadi-pemimpin' => l10n.situasiSitJadiPemimpin,
  'versi-lebih-baik' => l10n.situasiSitVersiLebihBaik,
  'dapat-rezeki' => l10n.situasiSitDapatRezeki,
  'sembuh-lulus' => l10n.situasiSitSembuhLulus,
  'dapat-jodoh' => l10n.situasiSitDapatJodoh,
  'hati-tenang' => l10n.situasiSitHatiTenang,
  'lihat-alam' => l10n.situasiSitLihatAlam,
  'pagi-malam' => l10n.situasiSitPagiMalam,
  'ketidakadilan' => l10n.situasiSitKetidakadilan,
  'berlomba-dunia' => l10n.situasiSitBerlombaDunia,
  'doomscrolling' => l10n.situasiSitDoomscrolling,
  'dunia-makin-rusak' => l10n.situasiSitDuniaMakinRusak,
  _ => null,
};

/// Halaman "Ayat rekomendasi" — SATU route untuk empat tingkat:
///
/// 1. tanpa parameter     -> 4 alasan besar ("Kamu lagi ngerasain apa?")
/// 2. [umbrella] diisi    -> grup di bawah alasan itu (maksimal 3)
/// 3. [groupId] diisi     -> situasi grup itu, dibelah sub-tahap
/// 4. [situationId] diisi -> SATU ayat + "ayat lain" + "buka di Quran"
///
/// ponytail: tetap satu widget (bukan empat layar) karena tiap tingkat hanya
/// menambah satu parameter dan tidak punya state sendiri di luar pilihan ayat;
/// memisahkannya berarti empat route + plumbing tanpa manfaat.
///
/// Kenapa bertingkat: sebelumnya 54 situasi tampil sekaligus dalam satu daftar
/// bergulir, dan itu terbaca seperti daftar yang harus dibaca habis sebelum
/// boleh memilih. Orang yang butuh ayat tidak selalu tahu nama masalahnya; yang
/// dia tahu cuma rasanya.
class AyatSituasiScreen extends StatefulWidget {
  /// Dipilih di tingkat 1.
  final String? umbrella;

  /// Dipilih di tingkat 2.
  final String? groupId;

  /// Dipilih di tingkat 3.
  final String? situationId;

  const AyatSituasiScreen({
    super.key,
    this.umbrella,
    this.groupId,
    this.situationId,
  });

  @override
  State<AyatSituasiScreen> createState() => _AyatSituasiScreenState();
}

class _AyatSituasiScreenState extends State<AyatSituasiScreen> {
  List<SituationGroup> _groups = const [];
  List<Situation> _situations = const [];
  bool _loading = true;

  // ── mode ayat ──
  QuranSurah? _surah;
  QuranAyah? _ayah;
  int? _refSurah;
  int? _refAyah;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = await quranSituasi.groups();
    final situations = await quranSituasi.all();
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _situations = situations;
      _loading = false;
    });
    if (widget.situationId != null) await _nextAyat();
  }

  /// Ambil ayat berikutnya lalu resolve teksnya. Urutannya penting: kalau
  /// resolve gagal, ayat yang SUDAH tampil tidak diganti — layar jangan kosong
  /// hanya karena satu kegagalan I/O.
  Future<void> _nextAyat() async {
    final id = widget.situationId;
    if (id == null) return;
    final ref = quranSituasi.nextAyat(id);
    if (ref == null) return;
    // Locale dibaca SEBELUM await: memakai context setelah await adalah
    // pelanggaran use_build_context_synchronously, dan guard `mounted` di
    // bawah tidak menutup kasus itu di mata analyzer.
    final english = quranUseEnglish(Localizations.localeOf(context));
    try {
      final surahs = await quranData.surahs();
      final surah = surahs[ref.surah - 1];
      final ayahs = await quranData.ayahs(ref.surah, english: english);
      if (!mounted) return;
      setState(() {
        _surah = surah;
        _ayah = ayahs[ref.ayah - 1];
        _refSurah = ref.surah;
        _refAyah = ref.ayah;
      });
    } catch (_) {
      // Diamkan: teks lama tetap tampil, tombol tetap bisa ditekan lagi.
    }
  }

  void _openInQuran() {
    final surah = _surah;
    if (surah == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranReader(surah: surah, initialAyah: _refAyah),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _title(l10n),
              style: AppText.titleLg().copyWith(color: AppColors.onSurface),
              maxLines: 2,
            ),
            // Jejak tingkat di atas: tanpa ini, user yang sudah dua tingkat di
            // dalam tidak tahu alasan mana yang tadi dia pilih.
            if (widget.umbrella != null && widget.situationId == null)
              Text(
                umbrellaLabel(l10n, widget.umbrella!),
                style: AppText.labelCapsSm().copyWith(color: AppColors.primary),
                maxLines: 1,
              ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _body(l10n),
    );
  }

  String _title(AppL10n l10n) {
    if (widget.situationId != null) {
      return situationLabel(l10n, widget.situationId!);
    }
    if (widget.groupId != null) return groupLabel(l10n, widget.groupId!);
    if (widget.umbrella != null) return umbrellaLabel(l10n, widget.umbrella!);
    return l10n.situasiTitle;
  }

  Widget _body(AppL10n l10n) {
    if (widget.situationId != null) return _ayatMode(l10n);
    if (widget.groupId != null) return _situationList(l10n);
    if (widget.umbrella != null) return _groupList(l10n);
    return _reasonList(l10n);
  }

  // ── tingkat 1: 4 alasan ──

  Widget _reasonList(AppL10n l10n) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      children: [
        for (final u in kUmbrellas) ...[
          FlatCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: PressableScale(
              pressedScale: 0.98,
              onTap: () => _push(AyatSituasiScreen(umbrella: u)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Icon(
                      umbrellaIcon(u),
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          umbrellaLabel(l10n, u),
                          style: AppText.bodyLg().copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          umbrellaHint(l10n, u),
                          style: AppText.bodyMd().copyWith(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.chevronRight,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }

  // ── tingkat 2: grup di bawah satu alasan ──

  Widget _groupList(AppL10n l10n) {
    final groups = _groups
        .where((g) => g.umbrella == widget.umbrella)
        .toList(growable: false);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      children: [
        _prompt(l10n.situasiPickGroup),
        for (final g in groups) ...[
          _row(
            label: groupLabel(l10n, g.id),
            trailing: _count(
              _situations.where((s) => s.group == g.id).length,
              l10n,
            ),
            onTap: () => _push(
              AyatSituasiScreen(umbrella: widget.umbrella, groupId: g.id),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }

  // ── tingkat 3: situasi, dibelah sub-tahap ──

  Widget _situationList(AppL10n l10n) {
    final group = _groups.where((g) => g.id == widget.groupId).firstOrNull;
    final items = _situations
        .where((s) => s.group == widget.groupId)
        .toList(growable: false);
    final children = <Widget>[_prompt(l10n.situasiPickStage)];

    if (group != null && group.hasStages) {
      for (final stage in group.stages) {
        final inStage = items
            .where((s) => s.stage == stage)
            .toList(growable: false);
        if (inStage.isEmpty) continue;
        children.add(HudHeader(stageLabel(l10n, stage)));
        for (final s in inStage) {
          children.add(_situationRow(l10n, s));
        }
      }
    } else {
      // Grup datar: membelahnya tidak menolong karena situasinya memang sedikit.
      for (final s in items) {
        children.add(_situationRow(l10n, s));
      }
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      children: children,
    );
  }

  Widget _situationRow(AppL10n l10n, Situation s) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: _row(
      label: situationLabel(l10n, s.id),
      onTap: () => _push(
        AyatSituasiScreen(
          umbrella: widget.umbrella,
          groupId: widget.groupId,
          situationId: s.id,
        ),
      ),
    ),
  );

  /// Kalimat bantu di bawah judul ("Yang mana lebih dekat?").
  Widget _prompt(String text) => Padding(
    padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
    child: Text(
      text,
      style: AppText.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
    ),
  );

  /// Baris pilihan: kartu datar + label + chevron. Satu bentuk untuk tingkat 2
  /// dan 3 supaya berpindah tingkat tidak terasa seperti pindah aplikasi.
  Widget _row({
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) => FlatCard(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: PressableScale(
      pressedScale: 0.98,
      onTap: onTap,
      // Tinggi minimum 48dp: ambang sentuh Android. Terukur, baris ini cuma
      // 44dp dengan padding vertikal biasa — bisa ditekan, tapi di bawah
      // ambang yang nyaman untuk jari.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
            ),
          ),
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: AppSpacing.xs),
          ],
          Icon(
            AppIcons.chevronRight,
            size: 18,
            color: AppColors.onSurfaceVariant,
          ),
        ],
        ),
      ),
    ),
  );

  /// Jumlah pilihan di grup: menyiapkan user sebelum masuk, bukan setelah.
  Widget _count(int n, AppL10n l10n) => Text(
    l10n.situasiChooseCount('$n'),
    style: AppText.labelCapsSm().copyWith(color: AppColors.onSurfaceVariant),
  );

  // ── tingkat 4: satu ayat ──

  Widget _ayatMode(AppL10n l10n) {
    final ayah = _ayah;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ayah == null)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              // Terpusat, bukan menempel atas: terukur, konten ayat cuma setinggi
              // 68..330px sementara ruang sampai tombol 871px di layar 915 →
              // sebelumnya ada ruang mati 541px di bawah ayat, terbaca seperti
              // layar yang belum selesai memuat. Center + SingleChildScrollView:
              // ayat pendek terpusat, ayat panjang tetap bisa digulir.
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'QS. ${_surah?.nameLatin ?? ''} ${_refSurah ?? ''}:${_refAyah ?? ''}',
                          style: AppText.labelCapsSm().copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          ayah.arabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: AppText.arabic(28).copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          ayah.translation,
                          style: AppText.bodyLg().copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _nextAyat,
                    icon: Icon(AppIcons.refresh, size: 18),
                    label: Text(l10n.situasiOtherAyah),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: ayah == null ? null : _openInQuran,
                    icon: Icon(AppIcons.menuBookOutlined, size: 18),
                    label: Text(l10n.situasiOpenInQuran),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
