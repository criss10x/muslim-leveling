# Fitur Quran & Murrotal — Design

Tanggal: 2026-07-27
Branch dasar: `feat/profile-avatar-prestige`

## Tujuan

Menambahkan modul Al-Quran ke aplikasi: membaca 114 surat lengkap dengan teks
Arab dan terjemahan Indonesia, memutar murrotal per ayat, serta mengatur cara
pemutaran (range ayat, pengulangan, kecepatan) dan tampilan (ukuran font).

Fitur ini berdiri sendiri. Integrasi dengan sistem EXP/leveling tidak termasuk
dalam scope dan akan dirancang terpisah setelah modul ini selesai.

## Keputusan Utama

| Keputusan | Pilihan | Alasan |
|---|---|---|
| Teks | Bundle offline di assets | Membaca tetap jalan tanpa internet; ukuran hanya ~5MB |
| Audio | Stream per ayat | Bundle audio 114 surat >1GB, tidak layak |
| Qari | Alafasy saja | Satu qari, tanpa selector di UI |
| Cakupan | 114 surat | Quran lengkap |
| Navigasi | Tab ke-5 "Quran" | Fitur utama, akses satu tap |
| Player | `just_audio` playlist | Repeat/next/prev/gapless bawaan library |

## Arsitektur

### Pipeline data (development-time, sekali jalan)

Script `tool/fetch_quran.dart` menarik data dari **api.alquran.cloud**, edisi
`quran-uthmani` (Arab) dan `id.indonesian` (terjemahan Kemenag), lalu menulis:

- `assets/quran/surahs.json` — metadata 114 surat:
  `{number, nameArabic, nameLatin, meaning, ayahCount, revelation}`
  di mana `revelation` bernilai `"Makkiyah"` atau `"Madaniyah"`.
- `assets/quran/ayahs.json` — ~6.236 entri: `{surah, ayah, arabic, translation}`

Output di-commit ke repo. Build CI tidak melakukan network call. Script hanya
dijalankan ulang bila sumber data perlu diperbarui.

### Sumber audio

Pola URL EveryAyah:
`https://everyayah.com/data/Alafasy_128kbps/{surah:03d}{ayah:03d}.mp3`

Contoh: QS 2:12 → `.../002012.mp3`

**Langkah pertama implementasi adalah memverifikasi pola URL ini masih valid**
(fetch beberapa ayat di awal/tengah/akhir mushaf). Bila tidak valid, ganti ke
CDN Quran.com; hanya fungsi pembentuk URL yang berubah, sisanya tetap.

### Komponen baru

| File | Tanggung jawab | Bergantung pada |
|---|---|---|
| `lib/services/quran_data.dart` | Load & cache JSON assets. Query daftar surat dan ayat per surat. Murni data. | assets |
| `lib/services/quran_audio_service.dart` | Bungkus `just_audio`. Bangun playlist dari range+repeat, kontrol transport, speed, loop. Expose stream ayat aktif. | `just_audio` |
| `lib/services/quran_settings.dart` | Persist preferensi tampilan & speed. | `shared_preferences` |
| `lib/screens/quran_tab.dart` | Daftar 114 surat + search. | `quran_data` |
| `lib/screens/quran_reader.dart` | Tampilan ayat + player bar + dua sheet setelan. | ketiga service |
| `lib/widgets/quran_ayah_card.dart` | Kartu satu ayat (Arab, terjemahan, highlight, tombol play). | `quran_settings` |
| `lib/widgets/quran_player_bar.dart` | Transport bar audio. | `quran_audio_service` |
| `lib/widgets/quran_playback_sheet.dart` | Setelan murrotal (range, repeat, speed). | `quran_audio_service` |
| `lib/widgets/quran_display_sheet.dart` | Setelan tampilan (font, toggle terjemahan). | `quran_settings` |

Batasan antar layer: `quran_data` tidak tahu apa-apa soal audio maupun UI.
`quran_audio_service` tidak tahu soal widget — ia menerima angka (surah, range,
repeat) dan mengeluarkan stream posisi. UI mengikat keduanya.

### Dependency baru (`pubspec.yaml`)

- `just_audio` — pemutaran & playlist
- `just_audio_background` — kontrol di notifikasi/lockscreen
- `audio_session` — perilaku audio focus (jeda saat telepon masuk, dsb)

Tambahan asset: `assets/quran/` didaftarkan di `flutter/assets`.

## Perilaku UI

### Tab Quran — daftar surat

List 114 surat. Tiap baris: nomor dalam ornamen, nama Latin + arti, nama Arab
di kanan, dan sub-baris "Makkiyah · 7 ayat". Search bar di atas memfilter
berdasarkan nama Latin, nama Arab, atau nomor surat. Tap membuka reader.

### Reader surat

Daftar ayat yang bisa di-scroll. Tiap kartu ayat berisi badge nomor ayat, teks
Arab rata kanan, terjemahan Indonesia di bawahnya, dan tombol play kecil yang
memulai pemutaran dari ayat tersebut.

Ayat yang sedang berbunyi diberi highlight latar warna aksen, dan daftar
auto-scroll agar ayat itu tetap terlihat saat pemutaran berpindah.

App bar memuat ikon "Aa" yang membuka sheet setelan tampilan.

### Player bar

Menempel di bawah, muncul hanya saat ada sesi audio aktif. Isinya: label
"QS Al-Baqarah : 12", tombol prev / play-pause / next, progress bar ayat
berjalan, dan ikon ⚙ yang membuka sheet setelan murrotal.

Dua sheet sengaja dipisah: setelan murrotal adalah hal yang diatur saat
menghafal, setelan tampilan saat membaca.

## Setelan Murrotal

### Range ayat

Dua dropdown, "Dari ayat" dan "Sampai ayat", dibatasi jumlah ayat surat yang
sedang dibuka. Default: 1 sampai ayat terakhir.

Invarian: range tidak pernah kosong. Bila "dari" diset melewati "sampai", nilai
"sampai" dinaikkan otomatis mengikutinya.

Range selalu berada di dalam satu surat. Pemutaran lintas surat tidak didukung.

### Ulangi per ayat

Stepper: 1× … 10×, ditambah opsi **∞**.

- Nilai 1–10 diimplementasikan dengan memasukkan ayat yang sama ke playlist
  sebanyak N kali, sehingga hitungan berhenti tepat lalu lanjut sendiri ke ayat
  berikutnya.
- Opsi ∞ diimplementasikan dengan `LoopMode.one` pada ayat berjalan; playlist
  tidak maju sampai pengguna menekan next atau stop. Playlist tak-hingga tidak
  mungkin dibangun, karena itu ∞ memakai mekanisme berbeda dari 1–10.

### Ulangi semua

Toggle yang mengulang **range**, bukan seluruh surat. Bila range diset 5–10,
siklusnya 5→10→5→10 dan ayat 1–4 tidak pernah dibunyikan.

ON berarti tanpa batas: siklus berjalan terus sampai dihentikan manual
(`LoopMode.all` atas playlist range). Tidak ada batas jumlah putaran. OFF
berarti berhenti setelah ayat terakhir range selesai.

### Presedensi bila keduanya aktif

Bila "ulangi per ayat" diset ∞ sementara "ulangi semua" ON, **∞ per ayat
menang**: `LoopMode.one` aktif dan pemutaran tidak pernah sampai ke akhir range,
sehingga "ulangi semua" tidak berpengaruh. Toggle "ulangi semua" tetap terlihat
menyala tetapi diberi keterangan bahwa ia baru berlaku setelah ∞ dimatikan.
Alasannya: ∞ per ayat adalah instruksi yang lebih spesifik dan lebih baru dari
niat pengguna saat menghafal satu ayat.

### Kecepatan

Chip: 0.5× / 0.75× / 1× / 1.25× / 1.5× / 2×. Diterapkan langsung lewat
`setSpeed()` tanpa menghentikan audio; pitch tidak berubah.

## Setelan Tampilan

- Ukuran font Arab: slider 20–44 px
- Ukuran font terjemahan: slider 12–24 px
- Toggle tampilkan/sembunyikan terjemahan

Sheet menampilkan pratinjau satu ayat yang ikut berubah saat slider digeser.

## Persistensi

Tersimpan lintas sesi (`shared_preferences`): ukuran font Arab, ukuran font
terjemahan, toggle terjemahan, kecepatan terakhir.

Tidak disimpan: range ayat dan jumlah pengulangan. Keduanya spesifik pada sesi
hafalan satu surat; me-restore range surat lama ke surat baru membingungkan.
Setiap kali surat dibuka, range kembali ke penuh dan repeat kembali ke 1×.

## Penanganan Error

- Gagal memuat audio (koneksi mati/terputus): pemutaran berhenti, muncul
  snackbar "Gagal memuat audio, periksa koneksi" dengan aksi "Coba lagi". Teks
  dan terjemahan tetap terbaca karena tersimpan offline.
- Mengubah setelan saat audio berjalan: perubahan speed dan setelan tampilan
  tidak menghentikan audio. Perubahan range atau repeat count membangun ulang
  playlist dan memulai dari awal range.
- Asset JSON gagal di-parse: tab Quran menampilkan state error dengan pesan,
  bukan crash.

## Testing

Unit test, untuk logika yang tidak butuh device:

- Pembentukan playlist dari (surah, rangeAwal, rangeAkhir, repeat) menghasilkan
  urutan URL yang benar, termasuk kasus repeat 1, repeat N, dan mode ∞
- Validasi range: "dari" > "sampai" terkoreksi otomatis; batas atas mengikuti
  jumlah ayat surat
- Parsing `surahs.json` dan `ayahs.json`: jumlah surat 114, jumlah ayat sesuai
  metadata tiap surat
- Round-trip persistensi setelan

Widget test: daftar surat merender dan memfilter; kartu ayat merespons
perubahan ukuran font dan toggle terjemahan.

Pemutaran audio sungguhan diverifikasi manual di device. Mem-mock `just_audio`
untuk membuktikan audio berbunyi tidak membuktikan apa pun yang berguna.

## Di Luar Scope

- Integrasi EXP / leveling / target harian
- Pilihan qari selain Alafasy
- Cache audio untuk pemakaian offline
- Bookmark, last-read position, tafsir, transliterasi
- Pemutaran lintas surat
