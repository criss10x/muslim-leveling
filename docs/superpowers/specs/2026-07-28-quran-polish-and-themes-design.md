# Quran polish & empat preset tema — Design

Tanggal: 2026-07-28  
Branch dasar: `main`

## Tujuan

Memperindah tab Quran tanpa mengubah alur baca, dan mengembangkan tema aplikasi dari satu pilihan gelap/terang menjadi empat preset global yang tersimpan lintas sesi.

## Preset tema

| Mode | Preset | Peran |
|---|---|---|
| Dark | Emerald Default | Palet bawaan: kanvas hitam, emerald/jade terang. |
| Dark | Night Mosque | Biru-hijau malam dengan aksen emas redup. |
| Light | Emerald Default | Palet bawaan: kanvas abu dingin, kartu putih, emerald dalam. |
| Light | Mushaf | Kanvas gading hangat, hijau hutan, dan emas kalem. |

Keempat preset adalah pilihan global. Tidak ada pengaturan tema khusus untuk Quran; tab, reader, player, dan layar lain mengikuti preset aktif.

## Arsitektur

`ThemeNotifier` mengganti state biner `ThemeMode` dengan enum preset yang menyediakan `Brightness` dan menjadi satu-satunya identitas tema di `SharedPreferences`.

`AppColors` tetap menjadi API warna tunggal bagi widget. Getter warna memilih palet dari preset aktif, sehingga pemanggil yang ada tidak perlu diubah satu per satu. `isLightTheme` tetap tersedia untuk cabang layout yang hanya perlu mengetahui brightness.

`AppTheme.light()` dan `AppTheme.dark()` tetap dipakai MaterialApp. Keduanya mengambil token warna aktif untuk menghasilkan `ThemeData`; perubahan preset memicu `ThemeNotifier.notifyListeners()` sehingga aplikasi dan System UI direbuild dengan warna serta brightness yang benar.

Preferensi lama `theme_mode = light` dimigrasikan ke `lightEmerald`; nilai lain yang tidak dikenal maupun `dark` dimigrasikan ke `darkEmerald`. Setelah pengguna memilih preset, nilai enum baru disimpan di kunci preferensi yang sama.

## Pemilih tema

Baris pengaturan Profil “Tema Terang” diganti menjadi “Tema aplikasi”. Saat diketuk, bottom sheet menampilkan empat kartu swatch dalam dua bagian: **Gelap** dan **Terang**. Kartu aktif memiliki indikator centang; memilih kartu segera mengganti tema dan menutup sheet. Tidak ada toggle terpisah.

## Quran polish

`QuranTab` mempertahankan loading, error, pencarian, empty state, dan navigasi ke `QuranReader`. Struktur visualnya:

1. Header ringkas “Al-Quran” dengan subteks “114 surat”.
2. Search field berlabel yang kontras dengan kanvas.
3. Label bagian “Pilih surat” dan jumlah hasil pencarian.
4. Baris surat sebagai kartu ringan: nomor pada tile aksen, informasi Latin dan metadata di tengah, nama Arab di kanan, serta chevron sebagai affordance.

Kartu memakai token `AppColors` dan spacing/radius yang sudah ada. Tidak ada gambar baru, data baru, atau fitur bacaan tambahan. Ukuran teks Arab serta semantik tap dipertahankan.

## Penanganan error dan aksesibilitas

Error pemuatan Quran dan hasil pencarian kosong tetap memiliki pesan jelas. Pemilih tema menggunakan label mode/preset dan state terpilih yang dapat dibaca screen reader. Emas hanya menjadi aksen, bukan teks utama berukuran kecil.

## Pengujian

- Unit test `ThemeNotifier`: migrasi `light`, fallback `dark`, penyimpanan dan pemulihan keempat preset, serta brightness setiap preset.
- Widget test pemilih tema: keempat label dirender dan pilihan memanggil preset benar.
- Update widget test Quran: header, jumlah surat, pencarian, hasil kosong, dan navigasi tetap berfungsi.
- Jalankan seluruh `flutter test` dan `flutter analyze` setelah perubahan.

## Di luar scope

- Tema otomatis mengikuti sistem atau jadwal waktu.
- Tema khusus per tab atau per surat.
- Penggantian font, data Quran, atau logika audio.
- Bookmark, progres baca, atau sistem gamifikasi baru.
