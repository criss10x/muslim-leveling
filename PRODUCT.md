# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Muslim Indonesia, sekitar 17–35 tahun. Situasinya: pemakaian harian di HP sendiri, biasanya
sendiri-sendiri, bukan di depan komputer. Pekerjaannya: menjaga sholat 5 waktu + tilawah tetap
jalan setiap hari, dan melihat bahwa usahanya menumpuk (XP, level, streak, medali) — bukan
sekadar mencentang checklist.

## Product Purpose

Mengubah ibadah harian yang mudah kendor menjadi progres yang terlihat dan terasa naik.
Aplikasi ini ada supaya orang yang sudah tahu kewajibannya tapi gampang bolong punya alasan
kembali besok. Sukses = user istiqomah, diukur dari streak dan retensi harian, bukan dari
jumlah fitur.

## Positioning

Islamic habit tracker bergamifikasi: ibadah harian dijadikan progres level/XP, lengkap dengan
medali, tier, dan kosmetik. Aplikasi Muslim lain di Play Store posisinya pengingat (adzan,
jadwal, Quran reader); yang membedakan di sini adalah mekanisme permainannya. Quran reader,
jadwal sholat, dan notif adzan adalah kelengkapan yang wajib ada supaya klaim "habit tracker
ibadah" bisa dipercaya — bukan posisi produknya.

## Operating Context

- HP Android kelas menengah, sering OEM ketat (Xiaomi/Oppo/Vivo) yang mematikan alarm saat app
  ditutup — notif adzan butuh exemption baterai tanpa fallback, jadi onboarding wajib.
- Dipakai sebagai ritual harian: buka saat adzan, murottal waktu luang, dzikir/doa, baca
  artikel Belajar.
- Sebagian besar user pakai tanpa login; login Google hanya untuk backup cloud (opsional).
  Local-first bukan sekadar arsitektur, itu kondisi pemakaian nyata.
- Distribusi lewat Google Play: `id.muslimleveling.muslim_leveling`.

## Capabilities and Constraints

- Offline-first: SharedPreferences adalah source of truth; Firestore hanya backup cloud saat
  signed in, dan merge tidak pernah blind-overwrite lokal.
- Ibadah: 5 waktu + rawatib / tilawah / sedekah, streak Jumat mingguan, mode haid yang
  membekukan streak.
- Quran: mushaf penuh, audio per-ayat multi-qari, tafsir, bookmark, resume bacaan terakhir.
- Jadwal sholat: Equran (proxy Kemenag) primer, MyQuran + Aladhan fallback; default Jakarta.
  Notif dipin ke WIB (`Asia/Jakarta`); WITA/WIT belum dipetakan.
- Adzan notif: 3 mode (fokus / seimbang / intensif) × 3 keluaran (senyap / suara / adzan).
- Bahasa: 4 locale (id, en, tr, ms). Chrome UI lewat ARB; konten (ayat, doa, kata ulama, nama
  bulan Hijriah) tetap Bahasa Indonesia + badge penanda bahasa.
- Monetisasi belum aktif — `EntitlementService` sekarang mengembalikan "semua gratis".
- Terbuka, belum diputuskan: kapan premium diaktifkan dan apa saja isinya (arah yang
  dikonfirmasi: kosmetik dan fitur premium berbayar), struktur harga, kapan sosial/leaderboard
  masuk dan bentuknya. Sosial/leaderboard belum punya skema data atau desain apa pun — jangan
  dibangun diam-diam sebagai efek samping tugas lain.
- Android saja (satu-satunya dir native: `android/`). iOS dan tablet belum diputuskan; jangan
  diasumsikan target.

## Brand Commitments

- Nama: **Muslim Leveling**.
- Label tab tetap `Home / Jadwal / Quran / Belajar / Profil` — jangan rename meski mockup
  memakai label lain.
- Emoji adalah konten, bukan dekorasi yang boleh dihapus saat redesign.
- Brand Electric Jade: light deep `#047857`, dark bright `#34D399`, `onPrimary: #064E3B`.
  Gold = reward, cyan/biru = live/now. Kartu flat — tanpa shadow/glass/neon, kecuali tier glow
  di hero dark mode.
- Token desain dari `lib/theme/app_theme.dart` (`AppColors`, `AppText`, `AppSpacing`,
  `AppRadius`). Warna/font baru masuk lewat token, bukan hex di layar.
- Ikon UI dari `Icons.*` Material; aset PNG hanya untuk launcher icon, `logo.png`, `mosque_bg.jpg`.
- Konten agama tidak diterjemahkan; kalau chrome UI berbahasa lain, kontennya diberi penanda.

## Evidence on Hand

- Sudah tayang di Google Play (`id.muslimleveling.muslim_leveling`).
- Visual regression nyata: golden PNG di `test/` (mis. `test/profil_stats_test.dart`), di-regenerate
  hanya di Ubuntu karena rendering font beda per OS.
- Halaman: `docs/index.html` (landing), `docs/privacy-policy.html`, `docs/delete-account.html`.
- Riwayat desain: `docs/superpowers/plans/` dan `docs/superpowers/specs/`.
- **Yang tidak ada dan tidak boleh dikarang**: testimoni, jumlah download, rating, jumlah user,
  angka retensi, benchmark pesaing, nama partner/investor, lisensi selain yang benar-benar
  dimiliki, dan klaim sertifikasi apa pun.

## Product Principles

1. **Ibadahnya yang utama, permainannya yang bikin bertahan.** Gamifikasi harus membuat ibadah
   lebih mudah dijalani; begitu ia mengaburkan atau menyaingi ibadahnya, itu kegagalan.
2. **Bertahan lebih berharga daripada pintar.** Perilaku di jam kritis (HP dimatikan OEM, tidak
   ada internet, alarm tidak jalan, langganan tidak ada) lebih penting daripada fitur baru.
3. **Local-first tidak bisa ditawar.** Semua fitur inti harus jalan tanpa akun dan tanpa jaringan;
   cloud hanya lapisan tambahan.
4. **Naik level, bukan sekadar tampil baru.** Perubahan UI harus menambah kejelasan progres atau
   kualitas ritual; keramaian visual bukan pencapaian.
5. **Jujur pada yang nyata.** Jangan menambah klaim, angka, atau janji yang tidak dimiliki produk.

## Accessibility & Inclusion

- Teks Arab harus tetap besar dan jelas (bacaan Quran, doa, dzikir) — bukan hiasan.
- 4 bahasa dengan pemilih bahasa yang menampilkan nama bahasa dalam bahasanya sendiri, supaya
  orang yang HP-nya berbahasa lain tetap menemukan bahasanya.
- Mode haid untuk akhwat: streak dibekukan, bukan dihitung gagal.
- Target sentuh 48dp dan skala font sistem belum diaudit; belum ada standar formal (WCAG dsb.)
  yang ditetapkan untuk produk ini.
