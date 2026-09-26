---
name: Muslim Leveling
description: HUD malam untuk ibadah harian — gelap dulu, jade sebagai sinyal, progres sebagai bukti.
colors:
  canvas-night: "#000000"
  card-night: "#121816"
  panel-night: "#161c19"
  inset-night: "#1e2522"
  track-night: "#2a312e"
  ink-night: "#dce4de"
  ink-muted-night: "#bacac1"
  outline-night: "#85948c"
  hairline-night: "#3c4a43"
  emerald-night: "#34d399"
  emerald-bright-night: "#6ee7b7"
  emerald-deep-night: "#047857"
  on-emerald-night: "#064e3b"
  gold-night: "#ffdb3c"
  gold-bright-night: "#ffe16d"
  cyan-night: "#00e1ef"
  canvas-mosque: "#071923"
  card-mosque: "#102934"
  ink-mosque: "#d9e9e9"
  ink-muted-mosque: "#b7cccc"
  hairline-mosque: "#3a5158"
  emerald-mosque: "#5cd5c4"
  gold-mosque: "#ffe08a"
  cyan-mosque: "#76d5f5"
  canvas-day: "#e8eaed"
  card-day: "#ffffff"
  inset-day: "#e5e7eb"
  track-day: "#d1d5db"
  ink-day: "#1a1a1a"
  ink-muted-day: "#5c6370"
  outline-day: "#8b929e"
  hairline-day: "#c5cad3"
  emerald-day: "#047857"
  emerald-fill-day: "#34d399"
  gold-ink-day: "#9a6700"
  gold-fill-day: "#e8b923"
  cyan-day: "#0b6e99"
  canvas-mushaf: "#f7f0e2"
  card-mushaf: "#fffbf3"
  ink-mushaf: "#242018"
  ink-muted-mushaf: "#625b4c"
  hairline-mushaf: "#d1c5ae"
  emerald-mushaf: "#276749"
  gold-ink-mushaf: "#846000"
  cyan-mushaf: "#176b74"
  error-night: "#ffb4ab"
  error-day: "#ba1a1a"
typography:
  display:
    fontFamily: "Sora"
    fontSize: "40sp"
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "-0.5px"
  headline:
    fontFamily: "Sora"
    fontSize: "24sp"
    fontWeight: 700
    lineHeight: 1.333
  title:
    fontFamily: "Plus Jakarta Sans"
    fontSize: "20sp"
    fontWeight: 600
    lineHeight: 1.4
  body:
    fontFamily: "Plus Jakarta Sans"
    fontSize: "14sp"
    fontWeight: 400
    lineHeight: 1.428
  label:
    fontFamily: "JetBrains Mono"
    fontSize: "12sp"
    fontWeight: 700
    lineHeight: 1.333
    letterSpacing: "1.2px"
  script:
    fontFamily: "Amiri Quran"
    fontSize: "28sp"
    fontWeight: 400
    lineHeight: 2
rounded:
  xs: "2px"
  sm: "4px"
  md: "6px"
  lg: "8px"
  xl: "12px"
  xxl: "16px"
  pill: "999px"
spacing:
  base: "4px"
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  xxl: "40px"
components:
  card:
    backgroundColor: "{colors.card-night}"
    typography: "body"
    rounded: "{rounded.xxl}"
    padding: "16px"
  pill:
    backgroundColor: "{colors.card-night}"
    textColor: "{colors.ink-muted-night}"
    typography: "label"
    rounded: "{rounded.pill}"
    padding: "6px 12px"
  display-number:
    textColor: "{colors.emerald-night}"
    typography: "display"
    size: "40sp"
  hud-header:
    textColor: "{colors.ink-muted-night}"
    typography: "label"
    padding: "0 0 12px"
  bar-track:
    backgroundColor: "{colors.track-night}"
    rounded: "{rounded.pill}"
    height: "16px"
  bar-fill:
    backgroundColor: "{colors.emerald-night}"
    rounded: "{rounded.pill}"
    height: "16px"
  hero-button:
    backgroundColor: "{colors.emerald-night}"
    textColor: "{colors.on-emerald-night}"
    typography: "headline"
    rounded: "{rounded.xl}"
    padding: "16px 32px"
  ghost-button:
    backgroundColor: "{colors.canvas-night}"
    textColor: "{colors.cyan-night}"
    typography: "label"
    rounded: "{rounded.xl}"
    padding: "16px 16px"
---

# Design System: Muslim Leveling

## Overview

**Creative North Star: "Night Watch"**

Ini HUD penjaga malam, bukan aplikasi ibadah yang ramah dan lembut. Lapangannya gelap total —
hitam murni, bukan "dark mode" abu-abu — dan di atasnya ada beberapa sinyal: jade yang menandai
apa yang sudah dikerjakan, emas yang menandai nikmat yang didapat, sian yang menandai waktu
yang sedang berjalan. Seperti panel instrumen yang menyala dalam gelap, tidak ada elemen
dekoratif: yang tampak di layar selalu berarti sesuatu. Kunang-kunang jade dan sian yang naik
perlahan di latar adalah satu-satunya kehidupan yang tidak membawa informasi — dan itu memang
sengaja, itu suasana malamnya.

Kepadatan sedang dan tenang. Kartu-kartu membesar seperlunya lalu berhenti; angka jadi bintang
utamanya, dibesarkan dengan huruf Sora yang tegas dan diwarnai emerald. Label kecil berhuruf
mono huruf kapital berfungsi sebagai serif mesin pada panel — bukan hiasan, tapi penanda bagian.
Setiap nilai di file ini masuk akal dalam dua langkah: gelap malam adalah default dan identitas
produk, sementara tema terang (Emerald siang dan kertas Mushaf) adalah versi yang menanggalkan
neon dan kunang-kunang: struktur, kontras, dan fungsi tetap sama persis.

Gerak adalah bahasa hadiah. Kurva memantul hanya dipakai di momen pemberian — kerang XP naik,
medali terbuka, level naik, quest selesai. Sisanya tenang dan cepat. Prinsipnya: efek yang
melenting tanpa sesuatu yang baru didapat akan terasa palsu, dan itu satu-satunya kebohongan
visual yang produk ini tidak boleh lakukan. Satu produk agama tidak boleh terasa seperti sedang
bermain trik dengan perasaan penggunanya.

**Key Characteristics:**
- Lapangan hitam murni; kartu terpisah dari kanvas lewat nada dan rambut 1px, bukan bayangan.
- Tiga sinyal saja: Emerald Istiqomah (aksi/progres), Emas Pahala (hadiah), Sian Waktu (sekarang).
- Angka sebagai pahlawan: Sora tebal, emerald, sering memakai angka bergulir.
- Warna dilarang tanpa arti: kalau sebuah warna tidak menandai aksi, hadiah, atau waktu, itu hiasan dan tidak masuk.
- Neon dan kunang-kunang mati di tema terang; mode siang adalah warga kelas satu, bukan tiruan pucat.
- Gerak memantul hanya saat ada yang didapat.

## Colors

Dua belas nada netral dan tiga sinyal; seluruh sistem hidup dari disiplin "tidak ada warna tanpa arti".

### Primary
- **Emerald Istiqomah (malam)** (#34d399): aksi, progres, dan keadaan hidup. Tombol utama, segmen
  bar terisi, angka besar, ikon aktif di nav.
- **Emerald Istiqomah Terang** (#6ee7b7): ujung terang dari gradien jade (tombol utama, bilah isi).
- **Emerald Dalam** (#047857): emerald versi hari; dipakai sebagai warna aksi utama di tema terang
  dan sebagai isian kontainer di tema malam.
- **Tinta di Atas Emerald** (#064e3b): teks/ikon di atas isian emerald terang. Bukan putih —
  putih di atas #34d399 hanya mencapai ~1,9:1 dan tidak terbaca.

### Secondary
- **Emas Pahala (malam)** (#ffdb3c): hadiah dan pencapaian. Hanya untuk streak, medali, XP yang
  diraih, dan sorotan tier.
- **Emas Pahala Terang** (#ffe16d): isian emas (badge, percikan confetti).
- **Emas Pahala Tinta** (#9a6700): emas versi hari. Emas terang di atas putih gagal kontras, jadi
  tema terang memakai versi dalam untuk tinta dan #e8b923 hanya untuk isian.

### Tertiary
- **Sian Waktu (malam)** (#00e1ef): waktu yang sedang berjalan — sholat berikutnya, hitung mundur,
  HUD "sekarang". Tidak pernah untuk hadiah.
- **Sian Waktu (siang)** (#0b6e99): sian versi hari, peran sama.

### Neutral
- **Kanvas Sebelum Subuh** (#000000): latar tema malam. Hitam murni, sengaja (panel menyala di atasnya).
- **Kartu Jaga Malam** (#121816): permukaan kartu — sediki hijau di dalamnya supaya nol-terang pun tetap terpisah dari kanvas tanpa bayangan.
- **Panel Jaga Malam** (#161c19): panel dan bar nav. Versi 60% alpha-nya adalah panel kaca tema malam.
- **Lekuk Malam** (#1e2522) / **Rel Kosong Malam** (#2a312e): permukaan inset (chip, jalur bar kosong).
- **Tinta Malam** (#dce4de) / **Tinta Samar Malam** (#bacac1): teks utama dan label sekunder. Tidak ada teks abu-abu murni.
- **Rambut Malam** (#3c4a43): rambut 1px, pemisah bagian. **Garis Batas Malam** (#85948c): garis yang harus terlihat sebagai batas kontrol.
- **Kanvas Masjid Malam** (#071923) dan keluarga **Masjid** (kartu #102934, emerald #5cd5c4, emas #ffe08a, sian #76d5f5): preset malam kedua — jade yang lebih tenang dan biru, nuansa masjid setelah isya.
- **Kanvas Siang** (#e8eaed) / **Kartu Siang** (#ffffff): tema terang Emerald. Kartu putih di atas kanvas abu sejuk, pemisahan tipis (kontras terukur 1,25:1) yang ditanggung oleh terang kartu — bukan oleh rambut, karena kartu tidak bergaris tepi.
- **Lekuk Siang** (#e5e7eb) / **Rel Kosong Siang** (#d1d5db): inset tema terang. Perhatikan pembalikan nama Material 3 yang disengaja di kode: `High` = inset yang lebih gelap, `Low` = kartu putih yang terangkat.
- **Kanvas Mushaf** (#f7f0e2) dan keluarga **Mushaf** (kartu #fffbf3, emerald #276749, emas #846000, sian #176b74): tema kertas hangat untuk membaca Quran — kontras diturunkan, saturasi ditahan.

### Named Rules
**The Tiga Sinyal Rule.** Hanya tiga warna yang boleh membawa arti: Emerald Istiqomah = yang kamu kerjakan dan capaianmu. Emas Pahala = yang kamu dapat. Sian Waktu = apa yang sedang berjalan. Warna keempat adalah kebohongan.

**The No Gray Rule.** Tidak ada abu-abu dan tidak ada hitam murni di luar kanvas. Setiap permukaan dan setiap tinta membawa sedikit warna hijau/emas/sian milik mereka.

**The Emas Bukan untuk Aksi Rule.** Emas tidak pernah menjadi warna tombol, tautan, atau navigasi. Kalau emas menandai sesuatu yang bisa ditekan, itu pahala palsu.

**The Alpha Sebelum Kontras Rule.** Kontras diperiksa pada warna setelah alpha dicampur ke latar belakangnya, bukan pada warna token mentah. `emerald` dengan alpha 0,4 di atas hitam adalah warna yang berbeda.

## Typography

**Display Font:** Sora (fallback sans-serif sistem)
**Body Font:** Plus Jakarta Sans (fallback sans-serif sistem)
**Label/Mono Font:** JetBrains Mono (fallback monospace sistem)
**Script Font:** Amiri Quran (khusus teks Arab)

**Karakter:** Sora memberi angka dan judul bobot arsitektural — tegas, sedikit teknik, tidak ramah-berlebihan. Plus Jakarta Sans membuat teks panjang (ayat, tafsir, artikel Belajar) tetap tenang dibaca. JetBrains Mono huruf kapital berjarak lebar menjadi serif mesin dari HUD: label bagian dan readout angka. Amiri Quran berdiri sendiri: teks Arab tidak pernah dicampur dengan font latin, baik di mushaf, doa, maupun hadis.

### Hierarchy
- **Display** (w800, 40sp / 32sp, tinggi 1,2 / 1,19): angka level, hero harga, judul layar perayaan. Di 40sp memakai `letterSpacing: -0.5px`.
- **Headline** (w700, 32sp & 24sp, tinggi 1,25 / 1,33): judul bagian dan label tombol utama.
- **Title** (w600, 20sp, tinggi 1,4): judul kartu dan app bar.
- **Body** (w400, 16sp & 14sp, tinggi 1,5 / 1,43): isi. 14sp adalah ukuran kerja sehari-hari.
- **Label** (w700, 12sp / 10sp, tinggi 1,33 / 1,4, `letterSpacing` 1,2px / 1,0px, KAPITAL): label HUD, nav, dan readout. `labelCapsSm` (10sp) untuk sel HUD yang lebih kecil.
- **Script** (w400, Amiri Quran, tinggi 2,0): teks Arab. Ukuran mengikuti konteks (ayat mushaf jauh lebih besar dari doa dalam daftar), tapi tingginya selalu 2,0 — teks Arab butuh napas vertikal.

### Named Rules
**The Readout Rule.** Label HUD selalu mono, kapital, berjarak lebar, dan lebih kecil dari isi yang dijelaskannya. Mono = mesin yang berbicara; proporsional = manusia yang membaca.

**The Arabic Never Shrinks Rule.** Teks Arab tidak pernah memakai font latin dan tidak pernah diperkecil untuk menghemat ruang; yang menyesuaikan adalah tata letaknya.

**The Token Type Rule.** Ukuran teks selalu diambil dari `AppText`, tidak ditulis langsung di layar. Ada 28 penulisan `fontSize:` langsung di `home_tab.dart` dan 22 di `profil_tab.dart`; itu utang yang tidak boleh bertambah.

## Layout

Model spasialnya sederhana dan disiplin: satu kolom, skala 4/8, dan satu lapis latar (AmbientBackground) yang tetap di belakang semua tab. Tab hidup dalam `IndexedStack` di `DashboardShell`, jadi keadaan tiap tab bertahan saat berpindah — itu juga alasan tab tidak boleh memikul biaya render di luar layar.

Skala jarak: 4 (base), 8 (xs), 12 (sm), 16 (md, default), 24 (lg), 32 (xl), 40 (xxl). Jarak antar bagian memakai `md`/`lg`; jarak di dalam kartu memakai `md`, kecuali daftar padat yang boleh turun ke `sm`. Margin layar mengikuti `lg` di kiri-kanan. Konten memusat dengan lebar maksimum yang nyaman dibaca pada layar lebar; tidak ada tata letak multi-kolom di layar sempit.

Nav bawah: bar solid 5 tab (Home / Jadwal / Quran / Belajar / Profil), tinggi tetap, di atas `SafeArea`, dengan rambut 1px di tepi atasnya. `extendBody: false` adalah keputusan sadar: bar-nya opaque, jadi menaruh isi di belakangnya hanya memotong konten (dulu tab Quran kehilangan item terakhir). Tiap tab menyediakan `AppSpacing.xxl` ruang napas di bawah, bukan angka sihir untuk menambal bar.

Nav hanya ikon + label kecil. Label diambil dari ARB, tidak pernah ditulis di tempat; jangan pernah mengganti nama tab walau mockup memakai istilah lain.

## Elevation & Depth

Sistem ini **tanpa bayangan** — dan itu keputusan, bukan kekurangan: `AppShadow.card()` sengaja mengembalikan daftar kosong di `app_theme.dart`. Kedalaman dibawa oleh tangga permukaan: kanvas yang paling dalam → lekuk inset → panel → kartu yang paling terangkat, dipisahkan nada ditambah satu rambut 1px. Kartu tidak boleh terlihat "melayang"; ia harus terlihat sebagai bidang yang lebih jelas.

Dua pengecualian yang sah, keduanya hanya di tema malam: (1) glow pada permukaan berwarna — tombol utama memancarkan emerald dengan blur 30 dan offset vertikal 8, ujung bilah progres memancarkan halo, dan segmen bar terisi menyala dengan blur 6; (2) tabir `BackdropFilter` pada GlassPanel, dipakai hemat dan tidak pernah lebih dari satu lapis. Di tema terang, glow putih di atas kertas terlihat kotor dan tidak dipakai — pemisahan di sana mutlak berasal dari terang/gelap.

### Named Rules
**The Flat By Default Rule.** Permukaan datar saat diam. Glow adalah jawaban atas keadaan (aktif, tersedia, sedang dibuka), bukan gaya awal.

**The Never Double Count Rule.** Elevasi diungkapkan satu kali saja — lewat nada permukaan ATAU lewat glow, tidak pernah keduanya pada elemen yang sama.

**The Glow Is Reaktif Rule.** Pancaran hangat hanya untuk emerald dan emas, dan hanya saat ada hadiah atau aksi hidup di dekatnya.

## Shapes

Bahasa bentuknya tegas dan sedikit tegas sudut, bukan bulat ramah. Enam langkah radius: 2 (xs) → 4 (sm) → 6 (md) → 8 (lg) → 12 (xl) → 16 (xxl), plus pil untuk elemen sepenuhnya membulat (chip, bar).

- Kartu: 16 (xxl), tanpa bayangan, tanpa garis tepi.
- Tombol (utama dan ghost): 12 (xl) — sudut tegas yang ditahan, konsisten di semua CTA.
- Bar progres: pil (setengah tinggi bar), termasuk di dalam trek berambut.
- Chip dan badge yang menempel di tepi: pil, dengan rambut 1px dari `outlineVariant` (alpha 0,5–0,7).
- Lingkaran dan medali tidak memakai radius sama sekali; bentuknya organik dan hanya diperbolehkan untuk lencana pencapaian.

Garis tepi selalu 1px fisik, dan selalu berasal dari keluarga rambut/outline — tidak ada garis 2px, tidak ada gradien sebagai pengganti garis.

## Components

### Buttons
- **Bentuk:** sudut 12 (xl).
- **Utama (HeroButton):** di tema malam memakai gradien emerald `#34d399 → #6ee7b7` dengan pancaran emerald 30px; di tema terang memakai emerald dalam `#047857` solid tanpa pancaran. Teks memakai headline (Sora 24) berwarna Tinta di Atas Emerald. Label dibungkus `FittedBox(scaleDown)` supaya label panjang menyusut, bukan jebol keluar.
- **Tekan:** `PressableScale` mengecilkan elemen ke 0,96 dalam 110ms dengan `easeOut`, lalu kembali. Ini getaran tombol game, dan berlaku untuk semua elemen yang bisa ditekan, bukan hanya tombol.
- **Menonjol:** `InkWell` untuk riak sentuh; tidak ada bayangan, tidak ada skala pada kartu biasa.
- **GhostButton (sekunder):** latar transparan, rambut 1px sian (alpha 0,4), label mono kapital sian. Dipakai untuk jalan keluar non-utama (lewati, nanti saja). Tidak pernah memakai emerald — kalau bisa ditekan tanpa menambah progres, warnanya bukan emerald.

### Chips
- **Gaya:** pil dengan latar kartu/lekuk, teks label mono 10–12sp warna tinta samar, rambut 1px.
- **Keadaan terpilih:** latar emerald/emas penuh dengan tinta di atasnya; tidak ada gradien, tidak ada bayangan.
- **Chip penanda bahasa konten** (mis. "teks sumber berbahasa Indonesia") memakai ikon translate 14px dan muncul hanya saat bahasa aktif berbeda dari bahasa konten.

### Cards / Containers
- **Sudut:** 16 (xxl).
- **Latar:** `Kartu Jaga Malam` (#121816) di tema malam, putih di tema terang, kertas hangat di Mushaf.
- **Pancaran:** tidak ada — lihat Elevation & Depth.
- **Garis tepi:** tidak ada pada kartu utama; rambut hanya pada panel kaca dan chip.
- **Isi:** padding 16, jarak antar elemen 8–12.

### Inputs / Fields
- **Gaya:** bidang permukaan dengan sudut 12 (xl) dan rambut 1px; tanpa bayangan.
- **Fokus:** rambut berganti ke emerald penuh; tidak ada glow cincin fokus.
- **Galat:** memakai `error-night` (#ffb4ab) / `error-day` (#ba1a1a) pada garis tepi dan teks bantu dengan ikon, bukan latar merah besar.

### Navigation
- **Gaya:** bar solid di bawah, 5 tab, ikon outlined saat tidak aktif dan ikon terisi saat aktif.
- **Teks:** label mono kapital 10sp di bawah ikon, dari ARB.
- **Keadaan:** aktif = emerald; tidak aktif = tinta samar. Tidak ada pil pemilih geser; tab yang aktif cukup berubah warna dan ikon.
- **Layar lebar:** tetap bar bawah; rail lebar belum ada dan tidak boleh diciptakan tanpa keputusan produk.

### HudHeader (komponen khas)
Ini komponen yang paling mengenali sistem ini: satu baris berisi label mono kapital, satu rambut 1px yang memenuhi sisa lebar, dan opsional satu readout angka di ujung kanan. Fungsinya memisahkan bagian tanpa perlu blok atau kotak. Dipakai di seluruh aplikasi untuk memisahkan seksi.

### Bar Progres (komponen khas)
Trek berambut berbentuk pil dengan isian bergradien: emerald untuk XP/level, emas untuk hadiah/streak, sian untuk waktu yang berjalan. Mode bersegmen (5 bagian) dipakai untuk ibadah harian dengan pengisi-per-segmen dan glow hanya di tema malam. Isian selalu bergerak dari kiri dan dianimasikan dalam 800ms dengan `easeOutCubic`.

### Moment Kartu
Panel gelap penuh layar dengan jade atau emas sebagai cahaya utama, memuat satu pesan dan satu tombol. Ini satu-satunya tempat gerakan memantul, kunang-kunang, dan percikan confetti bertemu. Contohnya layar naik level, kerang XP, dan pembukaan medali.

## Do's and Don'ts

### Do:
- **Do** ambil semua warna dari `AppColors`; kalau butuh warna baru, tambahkan token di `app_theme.dart` untuk keempat preset, bukan hex di layar.
- **Do** jaga tiga peran warna tetap utuh: emerald = aksi/progres, emas = hadiah, sian = waktu yang berjalan.
- **Do** ungkapkan kedalaman lewat nada permukaan dan rambut 1px; biarkan `AppShadow.card()` tetap kosong.
- **Do** pakai `labelCapsSm`/`labelCaps` untuk readout HUD; mono, kapital, berjarak lebar.
- **Do** bungkus label tombol panjang dengan `FittedBox(scaleDown)`.
- **Do** beri teks Arab ukuran layak dengan tinggi baris 2,0 dan font Amiri Quran.
- **Do** periksa kontras setelah alpha dicampurkan ke latar (mis. emerald 0,4 di atas kanvas gelap).
- **Do** sediakan `AppSpacing.xxl` ruang napas di bawah tiap tab; nav sudah punya ruangnya sendiri.
- **Do** pertahankan gerak memantul hanya untuk momen hadiah; efek ini tanda tangan sistem, jangan dipakai untuk transisi biasa.

### Don't:
- **Don't** memakai emas untuk tombol, tautan, atau navigasi.
- **Don't** memakai sian untuk hadiah.
- **Don't** menambahkan abu-abu atau hitam murni di luar kanvas; setiap nada membawa sedikit warna.
- **Don't** memakai putih di atas isian emerald terang.
- **Don't** menghidupkan glow atau tabir blur di tema terang.
- **Don't** menambahkan warna keempat tanpa mengubah aturan ini lebih dulu.
- **Don't** menulis `fontSize:` atau hex langsung di layar; pakai token.
- **Don't** memasukkan emoji ke dalam sistem token — emoji adalah konten yang ditulis pengguna, bukan bahasa visual aplikasi.
- **Don't** menghapus tanda bahasa pada konten yang tidak diterjemahkan.
- **Don't** menuliskan angka ajaib `bottom: 100` untuk menambal nav; nav sudah tidak menutupi isi.
