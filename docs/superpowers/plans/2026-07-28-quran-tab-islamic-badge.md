# Nomor Surat Rub el Hizb & Polish Daftar Surat — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mengganti pill nomor surat di tab Quran dengan ornamen Rub el Hizb dan merapikan hierarki baris daftar surat, tanpa menyentuh layar reader.

**Architecture:** Satu widget baru `RubElHizbBadge` menggambar oktagram lewat `CustomPainter` (vector, tanpa aset, warna dari `AppColors` sehingga otomatis benar di keempat preset tema). `QuranTab` berubah dari `Column` + `ListView` menjadi `CustomScrollView` supaya search field bisa dipin sebagai `SliverPersistentHeader`. Baris surat memecah subtitle padat menjadi arti + baris meta berisi chip tempat turun.

**Tech Stack:** Flutter (Material 3), `google_fonts` (sudah terpasang), `flutter_test`. Tidak ada dependensi baru.

## Global Constraints

- Spec acuan: `docs/superpowers/specs/2026-07-28-quran-tab-islamic-badge-design.md`. Baca sebelum mulai.
- Branch kerja: `codex/quran-polish-themes`. Jangan pindah branch.
- **Tidak ada Flutter SDK di mesin lokal.** Semua verifikasi test dilakukan di GitHub Actions (`.github/workflows/flutter.yml`) dengan cara push lalu membaca hasil run. Perintah verifikasi di tiap task sudah ditulis dalam bentuk itu. Jika ternyata `flutter` tersedia (`command -v flutter`), jalankan `flutter test <file>` secara lokal lebih dulu — jauh lebih cepat — dan tetap push di akhir task.
- Warna WAJIB lewat token `AppColors`. Dilarang menulis literal `Color(0x...)` di file yang disentuh plan ini. Aplikasi punya 4 preset tema (Dark Emerald, Night Mosque, Light Emerald, Mushaf) dan hex mati akan salah di sebagian preset.
- Spacing dan radius WAJIB lewat `AppSpacing` / `AppRadius`. Nilai: `AppSpacing.base = 4`, `xs = 8`, `sm = 12`, `md = 16`, `lg = 24`, `xl = 32`, `xxl = 40`. `AppRadius.xxl = 16`, `AppRadius.pill = 999`.
- Gaya teks WAJIB lewat `AppText`: `headlineMd()` (Sora 24/700), `titleLg()` (Plus Jakarta 20/600), `bodyMd()` (Plus Jakarta 14/400), `labelCapsSm()` (JetBrains Mono 10/700, letterSpacing 1.0).
- **Nama Arab surat tidak boleh diubah gayanya.** Tetap `AppText.titleLg()` + `AppColors.primary`. Yang berubah hanya posisi dan pengaturan lebarnya. Ini keputusan eksplisit pemilik produk.
- Tidak menambah aset, tidak menambah paket, tidak mengubah `assets/quran/*`, tidak menyentuh `lib/screens/quran_reader.dart` atau `lib/widgets/quran_ayah_card.dart`.
- Pakai `withValues(alpha: x)`, bukan `withOpacity(x)` — repo memakai API Flutter terbaru.
- Komentar kode ditulis dalam Bahasa Indonesia dan hanya menjelaskan **kenapa**, bukan **apa**, mengikuti gaya komentar yang sudah ada di repo.

## File Structure

| File | Status | Tanggung jawab |
|---|---|---|
| `lib/services/game_service.dart` | Modify | Hanya 4 perbaikan kurung kurawal agar `flutter analyze` lolos. Tidak ada perubahan logika. |
| `lib/widgets/rub_el_hizb_badge.dart` | Create | Widget + painter oktagram berisi nomor. Satu tanggung jawab, dipakai `QuranTab`. |
| `lib/screens/quran_tab.dart` | Modify | Header, sticky search, dan tata letak baris surat. |
| `test/rub_el_hizb_badge_test.dart` | Create | Test unit widget badge. |
| `test/quran_tab_test.dart` | Modify | Menyesuaikan assertion lama + menambah test chip, chevron, dan sticky search. |

---

### Task 0: Buka blokade CI

CI di branch ini **gagal di step Analyze**, bukan di test. `flutter analyze` keluar dengan exit code 1 karena 4 pelanggaran `curly_braces_in_flow_control_structures` di `lib/services/game_service.dart`. Selama ini belum diperbaiki, step `Test` tidak pernah dijalankan sama sekali, sehingga tidak ada satu pun sinyal test untuk task-task berikutnya.

Ini di luar cakupan fitur Quran, tapi wajib dikerjakan lebih dulu karena semua verifikasi task berikutnya bergantung padanya. Jangan menyentuh logika apa pun di file ini — hanya menambahkan kurung kurawal.

**Files:**
- Modify: `lib/services/game_service.dart:458-459`, `:896-897`, `:903-904`, `:1602-1603`

**Interfaces:**
- Consumes: —
- Produces: CI yang lolos step Analyze, sehingga step Test berjalan dan menghasilkan output.

- [ ] **Step 1: Catat baseline test yang sudah merah**

Sebelum mengubah apa pun, tidak ada yang bisa dicatat karena Test belum pernah jalan. Lanjut ke Step 2; baseline diambil di Step 4.

- [ ] **Step 2: Bungkus keempat `if` dengan blok**

Di `lib/services/game_service.dart` baris 458-459, ubah:

```dart
    if (level <= 39)
      return 'Muslim Grandmaster ${roman(5 - ((level - 30) ~/ 2))}';
```

menjadi:

```dart
    if (level <= 39) {
      return 'Muslim Grandmaster ${roman(5 - ((level - 30) ~/ 2))}';
    }
```

Di baris 896-897, ubah:

```dart
    if (state.prayerLog.any((l) => l.date == today && l.prayer == prayer))
      return null;
```

menjadi:

```dart
    if (state.prayerLog.any((l) => l.date == today && l.prayer == prayer)) {
      return null;
    }
```

Di baris 903-904, ubah:

```dart
    if (type == 'wajib' &&
        !_testSkipTimeWindow &&
        !isPrayerWindowOpen(prayer, state.timings))
      return null;
```

menjadi:

```dart
    if (type == 'wajib' &&
        !_testSkipTimeWindow &&
        !isPrayerWindowOpen(prayer, state.timings)) {
      return null;
    }
```

Di baris 1602-1603, ubah:

```dart
    if (_cache.questDate == todayStr() && _cache.quests.isNotEmpty)
      return _cache;
```

menjadi:

```dart
    if (_cache.questDate == todayStr() && _cache.quests.isNotEmpty) {
      return _cache;
    }
```

Nomor baris bergeser setiap kali satu blok ditambahkan — kerjakan dari baris terbesar ke terkecil (1602 → 903 → 896 → 458) agar nomor baris di atasnya tetap valid.

- [ ] **Step 3: Commit dan push**

```bash
git add lib/services/game_service.dart
git commit -m "fix: bungkus if satu baris dengan blok agar analyze lolos"
git push origin codex/quran-polish-themes
```

- [ ] **Step 4: Baca hasil CI dan catat baseline test merah**

```bash
gh run list --branch codex/quran-polish-themes --limit 1
```

Tunggu sampai kolom status menjadi `completed`, lalu:

```bash
gh run view --log-failed
```

Harapan: step **Analyze** lolos (`No issues found!`). Step **Test** kini berjalan. Kemungkinan besar Test tetap merah — ada 5 test lama yang sudah merah sejak sebelum pekerjaan ini dan **bukan** berasal dari tab Quran.

Salin daftar nama test yang gagal ke catatan. Daftar inilah baseline. Aturan untuk semua task berikutnya: **test yang gagal tidak boleh bertambah dari daftar ini**, dan tidak boleh ada nama test dari `quran_tab_test.dart` atau `rub_el_hizb_badge_test.dart` di dalamnya.

- [ ] **Step 5: Hentikan dan lapor jika Analyze masih merah**

Jika Analyze masih gagal setelah perbaikan ini, jangan lanjut ke Task 1. Baca pesan errornya, laporkan ke pemilik repo, dan tunggu instruksi. Task berikutnya tidak punya cara verifikasi tanpa CI yang menjalankan test.

---

### Task 1: Widget `RubElHizbBadge`

Rub el Hizb (۞) adalah oktagram — dua persegi identik yang saling diputar 45°. Di mushaf ia menandai pembagian juz. Digambar sebagai vector agar tetap tajam di segala kerapatan layar dan ikut berganti warna mengikuti preset tema.

**Files:**
- Create: `lib/widgets/rub_el_hizb_badge.dart`
- Test: `test/rub_el_hizb_badge_test.dart`

**Interfaces:**
- Consumes: `AppColors.primary`, `AppSpacing.xxl`, `AppText.labelCapsSm()` dari `lib/theme/app_theme.dart`.
- Produces: `class RubElHizbBadge extends StatelessWidget` dengan konstruktor `const RubElHizbBadge({super.key, required int number, double size = AppSpacing.xxl})`. Task 2 memakainya sebagai `RubElHizbBadge(number: surah.number)`.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/rub_el_hizb_badge_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_leveling/widgets/rub_el_hizb_badge.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('menampilkan nomor surat di tengah badge', (tester) async {
    await tester.pumpWidget(wrap(const RubElHizbBadge(number: 18)));

    expect(find.text('18'), findsOneWidget);
  });

  testWidgets('badge berukuran persegi sesuai parameter size', (tester) async {
    await tester.pumpWidget(wrap(const RubElHizbBadge(number: 1, size: 40)));

    final size = tester.getSize(find.byType(RubElHizbBadge));
    expect(size.width, 40);
    expect(size.height, 40);
  });

  testWidgets('menggambar ornamen lewat CustomPaint', (tester) async {
    await tester.pumpWidget(wrap(const RubElHizbBadge(number: 114)));

    expect(
      find.descendant(
        of: find.byType(RubElHizbBadge),
        matching: find.byType(CustomPaint),
      ),
      findsWidgets,
    );
  });
}
```

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

Jika `flutter` tersedia secara lokal:

```bash
flutter test test/rub_el_hizb_badge_test.dart
```

Harapan: GAGAL saat kompilasi dengan `Error: Couldn't resolve the package 'muslim_leveling/widgets/rub_el_hizb_badge.dart'` atau `Undefined name 'RubElHizbBadge'`.

Jika `flutter` tidak tersedia, lewati langkah ini — file implementasinya memang belum ada, jadi kegagalannya pasti. Jangan commit test tanpa implementasi ke CI; keduanya di-commit bersama di Step 5.

- [ ] **Step 3: Tulis implementasi minimal**

Buat `lib/widgets/rub_el_hizb_badge.dart`:

```dart
import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Nomor surat di dalam ornamen Rub el Hizb (۞) — dua persegi yang saling
/// diputar 45°, penanda pembagian juz di mushaf. Digambar CustomPainter,
/// bukan aset: vector tetap tajam di semua kerapatan layar, dan warnanya
/// bisa mengikuti token tema aktif tanpa menyiapkan empat file gambar.
class RubElHizbBadge extends StatelessWidget {
  final int number;
  final double size;

  const RubElHizbBadge({
    super.key,
    required this.number,
    this.size = AppSpacing.xxl,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RubElHizbPainter(color: color),
        child: Center(
          child: Text(
            '$number',
            style: AppText.labelCapsSm().copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

class _RubElHizbPainter extends CustomPainter {
  final Color color;

  const _RubElHizbPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Sisakan 1.5px dari tepi supaya stroke tidak terpotong SizedBox induk.
    final radius = size.shortestSide / 2 - 1.5;

    canvas.drawCircle(
      center,
      radius * 0.58,
      Paint()..color = color.withValues(alpha: 0.14),
    );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: 0.75);

    // Dua persegi dengan circumradius sama, beda fase 45° — itulah oktagram.
    for (final phase in const [pi / 4, 0.0]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final angle = phase + i * pi / 2;
        final point = Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _RubElHizbPainter oldDelegate) =>
      oldDelegate.color != color;
}
```

- [ ] **Step 4: Jalankan test untuk memastikan lulus**

Jika `flutter` tersedia:

```bash
flutter test test/rub_el_hizb_badge_test.dart
```

Harapan: `All tests passed!` (3 test).

- [ ] **Step 5: Commit dan push**

```bash
git add lib/widgets/rub_el_hizb_badge.dart test/rub_el_hizb_badge_test.dart
git commit -m "feat: badge nomor surat bergaya Rub el Hizb"
git push origin codex/quran-polish-themes
```

- [ ] **Step 6: Verifikasi lewat CI**

```bash
gh run list --branch codex/quran-polish-themes --limit 1
```

Tunggu `completed`, lalu bandingkan dengan baseline dari Task 0 Step 4:

```bash
gh run view --log-failed
```

Harapan: step Analyze lolos, dan daftar test yang gagal **persis sama** dengan baseline — tidak ada nama test dari `rub_el_hizb_badge_test.dart` di dalamnya. Kalau ada, perbaiki sebelum lanjut ke Task 2.

---

### Task 2: Baris surat — badge, chip, dan nama Arab di kanan

Subtitle `arti · tempat turun · jumlah ayat` sekarang menumpuk jadi satu baris yang kepotong di layar sempit. Dipecah menjadi arti pada barisnya sendiri, lalu baris meta berisi chip tempat turun dan jumlah ayat. Chevron dibuang karena baris kartu yang bisa ditap sudah jelas dengan sendirinya, dan ruang itu diberikan ke nama Arab.

**Files:**
- Modify: `lib/screens/quran_tab.dart:156-235` (seluruh `class _SurahRow`)
- Test: `test/quran_tab_test.dart`

**Interfaces:**
- Consumes: `RubElHizbBadge(number: int)` dari Task 1. `QuranSurah` dari `lib/services/quran_data.dart` dengan field `int number`, `String nameArabic`, `String nameLatin`, `String meaning`, `String revelation`, `int ayahCount`. Nilai `revelation` di `assets/quran/surahs.json` hanya `Makkiyah` atau `Madaniyah`.
- Produces: `_SurahRow` yang sudah dipoles; Task 3 hanya memakainya di dalam sliver, tidak mengubah isinya.

- [ ] **Step 1: Tulis test yang gagal**

Tambahkan tiga test ini ke `test/quran_tab_test.dart`, di dalam `main()`, setelah test `'menampilkan daftar surat'` yang sudah ada:

```dart
  testWidgets('menampilkan chip tempat turun, bukan subtitle gabungan', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    // Al-Fatihah Makkiyah, Al-Baqarah Madaniyah — keduanya di layar pertama.
    expect(find.text('Makkiyah'), findsWidgets);
    expect(find.text('Madaniyah'), findsWidgets);
    expect(find.text('7 ayat'), findsOneWidget);
    // Subtitle gabungan lama tidak boleh ada lagi.
    expect(find.textContaining('Pembukaan · '), findsNothing);
  });

  testWidgets('baris surat tidak lagi memakai chevron', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('setiap baris surat memakai badge Rub el Hizb', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    expect(find.byType(RubElHizbBadge), findsWidgets);
  });
```

Tambahkan import ini di bagian atas `test/quran_tab_test.dart`:

```dart
import 'package:muslim_leveling/widgets/rub_el_hizb_badge.dart';
```

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

Jika `flutter` tersedia:

```bash
flutter test test/quran_tab_test.dart
```

Harapan: GAGAL. `menampilkan chip tempat turun` gagal karena `find.text('Makkiyah')` tidak ketemu (teksnya masih menyatu dalam satu string), `baris surat tidak lagi memakai chevron` gagal karena chevron masih ada, dan `setiap baris surat memakai badge Rub el Hizb` gagal karena badge belum dipasang.

- [ ] **Step 3: Tulis implementasi**

Di `lib/screens/quran_tab.dart`, tambahkan import berikut di bawah import yang sudah ada:

```dart
import '../widgets/rub_el_hizb_badge.dart';
```

Ganti seluruh `class _SurahRow` (baris 156 sampai akhir file) dengan:

```dart
class _SurahRow extends StatelessWidget {
  final QuranSurah surah;
  const _SurahRow({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Semantics(
        button: true,
        label: 'Buka surat ${surah.nameLatin}',
        child: Material(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => QuranReader(surah: surah)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  RubElHizbBadge(number: surah.number),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.nameLatin,
                          style: AppText.titleLg().copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          surah.meaning,
                          style: AppText.bodyMd().copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            _RevelationChip(label: surah.revelation),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${surah.ayahCount} ayat',
                              style: AppText.labelCapsSm().copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Lebar dikunci lalu diciutkan bila perlu: nama Arab terpanjang
                  // (mis. المنافقون) sebelumnya kena ellipsis karena berebut
                  // ruang dengan chevron.
                  SizedBox(
                    width: 108,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          surah.nameArabic,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          style: AppText.titleLg().copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip tempat turun surat. Madaniyah memakai pasangan warna sekunder (emas)
/// supaya asal turunnya bisa dipindai tanpa membaca teks. Pasangan
/// container/on-container dipakai, bukan goldInk, karena di preset Dark
/// goldInk di atas secondaryContainer praktis tidak terbaca.
class _RevelationChip extends StatelessWidget {
  final String label;
  const _RevelationChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final madaniyah = label.toLowerCase() == 'madaniyah';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: madaniyah
            ? AppColors.secondaryContainer
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppText.labelCapsSm().copyWith(
          color: madaniyah
              ? AppColors.onSecondaryContainer
              : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
```

Nilai `revelation` selain `Madaniyah` jatuh ke gaya netral, bukan error — itu perilaku yang diinginkan.

- [ ] **Step 4: Jalankan test untuk memastikan lulus**

Jika `flutter` tersedia:

```bash
flutter test test/quran_tab_test.dart
```

Harapan: semua test di file itu lulus, termasuk empat test lama. Test `'shows Quran hierarchy and opens the selected reader'` masih memeriksa `find.text('Pilih surat')` dan `find.text('114 surat')` — keduanya masih ada di Task 2 dan baru berubah di Task 3. Jangan sentuh dulu.

- [ ] **Step 5: Commit dan push**

```bash
git add lib/screens/quran_tab.dart test/quran_tab_test.dart
git commit -m "feat: baris surat pakai badge Rub el Hizb dan chip tempat turun"
git push origin codex/quran-polish-themes
```

- [ ] **Step 6: Verifikasi lewat CI**

```bash
gh run list --branch codex/quran-polish-themes --limit 1
gh run view --log-failed
```

Harapan: Analyze lolos, daftar test gagal masih sama persis dengan baseline Task 0.

---

### Task 3: Header dan search yang menempel

`Column` + `ListView` tidak bisa memin satu bagian saja. Diganti `CustomScrollView`: judul ikut ter-scroll di sliver biasa, search field dipin lewat `SliverPersistentHeader`. Label "Pilih surat" dan angka jumlah hasil dihapus karena redundan.

**Files:**
- Modify: `lib/screens/quran_tab.dart:13-154` (`_QuranTabState`, termasuk `build`)
- Test: `test/quran_tab_test.dart:11-25` (test pertama) dan penambahan test baru

**Interfaces:**
- Consumes: `_SurahRow({required QuranSurah surah})` dari Task 2 — dipakai apa adanya, tidak diubah.
- Produces: —

- [ ] **Step 1: Perbarui test lama dan tulis test baru yang gagal**

Di `test/quran_tab_test.dart`, ganti test pertama `'shows Quran hierarchy and opens the selected reader'` menjadi:

```dart
  testWidgets('shows Quran hierarchy and opens the selected reader', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    expect(find.text('Al-Quran'), findsOneWidget);
    expect(find.text('114 surat · 30 juz'), findsOneWidget);
    // Label "Pilih surat" dihapus: daftar di bawah search sudah jelas
    // isinya, dan angka jumlah hasil tersirat dari isi daftar.
    expect(find.text('Pilih surat'), findsNothing);

    await tester.tap(find.text('Al-Fatihah'));
    await tester.pumpAndSettle();

    expect(find.byType(QuranReader), findsOneWidget);
  });
```

Lalu tambahkan test baru ini setelahnya:

```dart
  testWidgets('search tetap terlihat setelah daftar di-scroll', (tester) async {
    await tester.pumpWidget(wrap(QuranTab()));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    // Judul ikut ter-scroll hilang, search field-nya yang dipin.
    expect(find.text('Al-Quran'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });
```

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

Jika `flutter` tersedia:

```bash
flutter test test/quran_tab_test.dart
```

Harapan: GAGAL. Test pertama gagal karena `'114 surat · 30 juz'` belum ada dan `'Pilih surat'` masih ada. Test sticky gagal karena `CustomScrollView` belum dipakai (`findsNothing` untuk `find.byType(CustomScrollView)` membuat `drag` melempar error).

- [ ] **Step 3: Tulis implementasi**

Di `lib/screens/quran_tab.dart`, tambahkan controller ke `_QuranTabState`. Sisipkan setelah deklarasi `bool _failed = false;`:

```dart
  // Controller eksplisit: SliverPersistentHeader membangun ulang child-nya
  // saat scroll, dan TextField tanpa controller berisiko kehilangan isinya.
  final TextEditingController _searchController = TextEditingController();
```

Tambahkan `dispose` tepat setelah `initState`:

```dart
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
```

Ganti isi `return SafeArea(...)` di dalam `build` — yaitu dari baris `return SafeArea(` sampai penutup sebelum `}` milik `build` — dengan:

```dart
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Al-Quran',
                        style: AppText.headlineMd().copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      // Kaligrafi sebagai aksen, bukan informasi — karena itu
                      // diredupkan dan tidak diberi semantik.
                      ExcludeSemantics(
                        child: Text(
                          'القرآن',
                          textDirection: TextDirection.rtl,
                          style: AppText.headlineMd().copyWith(
                            color: AppColors.goldInk.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '114 surat · 30 juz',
                    style: AppText.bodyMd().copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchHeader(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: AppText.bodyMd().copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Cari surat, arti, atau nomor',
                  hintStyle: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Surat tidak ditemukan',
                  style: AppText.bodyMd().copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.xs,
                bottom: AppSpacing.xxl * 2,
              ),
              sliver: SliverList.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => _SurahRow(surah: list[i]),
              ),
            ),
        ],
      ),
    );
```

Tambahkan delegate ini di akhir file, setelah `_RevelationChip`:

```dart
/// Search field yang menempel di atas saat daftar di-scroll. minExtent sama
/// dengan maxExtent karena tingginya tetap; garis bawah hanya muncul ketika
/// ada konten yang lewat di belakangnya, supaya header tidak terlihat
/// mengambang saat daftar masih di puncak.
class _SearchHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _SearchHeader({required this.child});

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent
                ? AppColors.outlineVariant
                : Colors.transparent,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SearchHeader oldDelegate) => true;
}
```

- [ ] **Step 4: Jalankan test untuk memastikan lulus**

Jika `flutter` tersedia:

```bash
flutter test test/quran_tab_test.dart
```

Harapan: `All tests passed!` — tujuh test (empat lama yang sudah disesuaikan, tiga tambahan dari Task 2, satu tambahan sticky search dari task ini).

Jika test sticky gagal dengan `find.text('Al-Quran')` masih ketemu, jarak drag kurang jauh; naikkan offset drag, jangan mengubah implementasi.

- [ ] **Step 5: Commit dan push**

```bash
git add lib/screens/quran_tab.dart test/quran_tab_test.dart
git commit -m "feat: header kaligrafi dan search yang menempel di tab Quran"
git push origin codex/quran-polish-themes
```

- [ ] **Step 6: Verifikasi lewat CI**

```bash
gh run list --branch codex/quran-polish-themes --limit 1
gh run view --log-failed
```

Harapan: Analyze lolos, daftar test gagal masih sama persis dengan baseline Task 0, dan build APK sukses.

- [ ] **Step 7: Ambil APK untuk cek mata di HP**

Test widget tidak bisa menilai kontras warna. Empat preset tema harus dilihat langsung, terutama chip Madaniyah di preset **Mushaf** (kanvas gading) dan **Light Emerald**.

```bash
gh run download --name app-release-apk --dir build/ci-apk
```

Pasang APK-nya, lalu periksa di keempat preset (Profil → Tema aplikasi):

1. Badge Rub el Hizb terbaca jelas, garisnya tidak hilang di latar terang.
2. Chip Madaniyah kontras dengan latarnya di keempat preset.
3. Nama Arab tidak terpotong pada surat bernama panjang — cek surat 63 (المنافقون) dan 77 (المرسلات).
4. Search benar-benar menempel saat daftar di-scroll, dan garis bawahnya muncul.

Laporkan temuan ke pemilik repo. Perbaikan kontras adalah iterasi terpisah, bukan bagian plan ini.

---

## Definition of Done

- [ ] `flutter analyze` lolos di CI (Task 0).
- [ ] Daftar test yang gagal di CI tidak bertambah dari baseline Task 0.
- [ ] Tidak ada test dari `quran_tab_test.dart` maupun `rub_el_hizb_badge_test.dart` yang gagal.
- [ ] Build APK di CI sukses.
- [ ] `lib/screens/quran_reader.dart` dan `lib/widgets/quran_ayah_card.dart` tidak berubah — pastikan dengan `git diff main --stat`.
- [ ] Tidak ada literal `Color(0x...)` baru di file yang disentuh — pastikan dengan `git diff main -- lib/ | grep 'Color(0x'`.
- [ ] APK sudah dilihat langsung di keempat preset tema.
