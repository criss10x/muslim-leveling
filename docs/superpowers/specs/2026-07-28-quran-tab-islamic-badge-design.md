# Nomor surat bergaya Rub el Hizb & polish daftar surat — Design

Tanggal: 2026-07-28  
Branch dasar: `codex/quran-polish-themes`

## Tujuan

Membuat nomor surat di tab Quran terbaca islami dan merapikan hierarki baris daftar surat, tanpa mengubah alur baca, data, maupun layar reader.

## Ruang lingkup

Hanya `QuranTab` (daftar surat). `QuranReader`, `QuranAyahCard`, player bar, dan sheet setelan tidak disentuh. Tidak ada aset gambar baru, tidak ada perubahan data, tidak ada dependensi baru.

## Badge nomor: Rub el Hizb

Nomor surat berpindah dari pill polos ke ornamen Rub el Hizb (۞) — oktagram yang di mushaf menandai pembagian juz. Dipilih karena autentik terhadap konteks, dan cukup sederhana untuk tetap terbaca pada 40px di 114 baris.

Widget baru `lib/widgets/rub_el_hizb_badge.dart`:

- `CustomPainter` menggambar dua persegi berukuran sama, satu diputar 45°, sebagai outline. Tidak ada aset, tidak ada gambar raster.
- Kanvas 40×40 (`AppSpacing.xxl`), sama dengan tile nomor sekarang, sehingga tinggi baris tidak berubah karena badge.
- Outline memakai `AppColors.primary` dengan alpha 0.75, stroke 1.5. Lingkaran isian di tengah memakai `AppColors.primary` alpha 0.14.
- Angka di tengah memakai `AppText.labelCapsSm()` berwarna `AppColors.primary`.
- Warna diambil saat `paint`, bukan di-cache, sehingga badge otomatis benar di keempat preset tema.
- `shouldRepaint` hanya true ketika nomor atau warna berubah.

Badge murni dekoratif; label semantik tetap berada di baris (`Buka surat <nama>`), tidak ditambah di badge.

## Baris surat

Subtitle `arti · tempat turun · jumlah ayat` yang sekarang menumpuk dalam satu baris dipecah:

1. Nama Latin — `AppText.titleLg()`, `AppColors.onSurface`.
2. Arti surat — `AppText.bodyMd()`, `AppColors.onSurfaceVariant`, satu baris sendiri.
3. Baris meta: chip tempat turun + jumlah ayat sebagai teks kecil.

Chip tempat turun:

- Makkiyah — latar `AppColors.surfaceContainerHigh`, teks `AppColors.onSurfaceVariant`.
- Madaniyah — latar `AppColors.secondaryContainer`, teks `AppColors.goldInk`.

Perbedaan warna ini membuat asal turunnya surat bisa dipindai tanpa membaca teks. Nilai `revelation` di `assets/quran/surahs.json` hanya berisi dua nilai tersebut; nilai lain di luar keduanya jatuh ke gaya netral Makkiyah, bukan error.

**Nama Arab tidak diubah gayanya.** Tetap `AppText.titleLg()` dengan `AppColors.primary` seperti sekarang — tidak ganti font, tidak ganti warna, agar tidak perlu diverifikasi ulang di empat tema. Yang berubah hanya posisinya: `chevron_right` dibuang, dan nama Arab menempati tepi kanan baris dengan lebar tetap sehingga tidak lagi ellipsis akibat berebut ruang dengan chevron.

Tinggi baris naik dari ±72px ke ±82px karena baris meta. Konsekuensinya satu layar memuat kira-kira satu baris lebih sedikit.

## Header dan pencarian

- Judul "Al-Quran" didampingi kaligrafi `القرآن` di kanan, memakai `AppColors.goldInk` dengan opacity redup sebagai aksen, bukan sebagai informasi.
- Subteks menjadi `114 surat · 30 juz`.
- Label bagian "Pilih surat" dan angka jumlah hasil di sebelahnya dihapus; keduanya redundan karena daftarnya sudah jelas dan jumlah hasil sudah tersirat dari isi daftar.
- `Column` + `ListView` diganti `CustomScrollView`. Judul dan subteks ikut ter-scroll di sliver biasa; search field berada di `SliverPersistentHeader` yang pinned, dengan latar `AppColors.background` dan garis bawah `AppColors.outlineVariant` agar tidak menyatu dengan kartu saat menempel.

Loading, error state, empty state pencarian, dan navigasi ke `QuranReader` dipertahankan apa adanya.

## Dampak pada test

`test/quran_tab_test.dart` memeriksa teks yang dihapus atau berubah:

- `find.text('Pilih surat')` — label dihapus, assertion ini harus dibuang.
- `find.text('114 surat')` — subteks berubah menjadi `114 surat · 30 juz`, assertion diubah ke `findsOneWidget` atas teks baru.
- `find.textContaining('Pembukaan')` tetap lolos karena arti kini berdiri sendiri.

Tambahan test yang perlu ada:

- Chip tempat turun tampil untuk surat Makkiyah dan Madaniyah.
- `Icons.chevron_right` tidak lagi ada di baris surat.
- Search field tetap ter-render setelah daftar di-scroll (bukti pinned header).

Test pencarian dan empty state tidak berubah.

## Non-goals

- Tidak menambah fitur bacaan, bookmark, atau "terakhir dibaca".
- Tidak mengubah `QuranAyahCard`; badge nomor ayat di reader tetap seperti sekarang. Konsistensi visual reader menjadi iterasi terpisah bila diinginkan.
- Tidak mengganti font Arab di mana pun.
- Tidak menambah preset tema atau mengubah token warna yang sudah ada.
