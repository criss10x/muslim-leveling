# Home Hero Hybrid Design

## Goal

Membuat hero rank di tab Home terasa seperti kartu status game yang tegas tanpa kehilangan karakter Islamic premium dan tanpa mengganggu keterbacaan rank, level, serta progres XP.

## Direction

Gunakan satu layout informasi yang sama pada semua tema, dengan treatment visual berbeda:

- Light mode: Islamic premium yang tenang. Card tetap putih, flat, dan dominan polos. Pattern bintang delapan hanya menjadi tekstur tonal tipis di sisi kanan.
- Dark mode: rank-game yang lebih tegas. Card memakai teal gelap dengan jade wash lembut, pattern sedikit lebih terlihat, tier glow terbatas, dan emblem rank lebih dominan.

Hero tidak memakai foto masjid, glass effect, neon berlebihan, pedang, shield perang, atau ilustrasi karakter. Identitas rank ditampilkan lewat emblem geometris netral.

## Layout

- Konten utama tetap rata kiri: label `CURRENT RANK`, title rank, nickname dan level, label XP, angka XP, progress bar, serta sisa XP.
- Emblem rank ditempatkan di kanan atas agar tidak mengambil ruang teks.
- Emblem memakai bentuk medali bundar dengan outer ring tier, inner surface, ikon bintang delapan, dan level kecil sebagai metadata.
- Pattern geometris hanya memenuhi sisi kanan card lalu memudar sebelum area teks.
- Tinggi card dan urutan informasi tetap sama agar tidak menggeser section Home lain.

## Light Mode

- Background: `AppColors.surfaceContainerLow` tanpa gradient penuh.
- Accent wash: radial jade sangat tipis dari sudut kanan atas.
- Pattern opacity: 4–6% memakai warna tier ink.
- Border: 1 px deep jade/tier dengan opacity rendah.
- Shadow: tidak ada.
- Emblem: surface putih, ring tier, ikon jade atau tier ink; tidak memakai glow.
- Rank title: `AppColors.onSurface` untuk kontras AA.

## Dark Mode

- Background: `AppColors.surfaceContainerLow` dengan diagonal/radial jade wash yang halus.
- Pattern opacity: 8–10% memakai warna tier.
- Border: 1.5 px tier/jade.
- Shadow: satu tier glow halus hanya pada hero, mengikuti chrome budget yang sudah ada.
- Emblem: dark inset surface dengan tier ring dan glow kecil.
- Rank title: gradient tier yang sudah ada tetap dipakai.

## Components

Perubahan tetap lokal di `lib/screens/home_tab.dart`:

- `_heroRank(LevelInfo info)` menyusun card dan menambahkan decorative stack.
- `_RankMedallion` merender emblem rank dari `TierVisualConfig` dan level.
- `_IslamicHeroPatternPainter` merender lattice bintang delapan yang memudar ke kiri.

Tidak ada asset bitmap, dependency, konfigurasi, service, atau state baru.

## Behavior and Accessibility

- Hero tetap non-interaktif; tidak ada gesture baru.
- Decorative painter dan emblem tidak membawa semantic label agar screen reader hanya membaca informasi rank yang nyata.
- Semua decorative layers memakai `IgnorePointer`.
- Teks dan progress tetap berada di atas decorative layers dan mempertahankan kontras tema yang sudah ada.
- Layout harus aman untuk rank title panjang dengan `maxLines: 1` dan ellipsis.

## Verification

- Widget test memastikan emblem dan painter hadir di light dan dark theme.
- Golden test Home tidak ditambahkan karena repo belum memiliki baseline golden Home; visual diverifikasi melalui widget rendering dan screenshot lokal bila emulator tersedia.
- Jalankan test hero terkait, seluruh `flutter test`, dan `flutter analyze`.
- Empat issue analyzer baseline di file test yang tidak terkait tetap diterima sesuai keputusan pengguna dan tidak diubah dalam branch ini.
