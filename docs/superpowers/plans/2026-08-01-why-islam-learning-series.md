# Dari Kebiasaan ke Keyakinan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menambahkan kategori Belajar baru dengan sepuluh artikel WHY Islam dan quiz situasional untuk pengguna yang mengenal ritual tetapi belum memahami alasannya.

**Architecture:** Tambahkan satu `LearningCategory` statis pada `LearningContent.categories`. `BelajarTab`, `LearningService.totalModules`, penguncian modul, SharedPreferences, dan Supabase backup sudah membaca daftar kategori/modul secara dinamis, sehingga tidak diperlukan model atau layanan baru.

**Tech Stack:** Flutter/Dart, `LearningContent`, `flutter_test`.

## Global Constraints

- Gunakan Bahasa Indonesia ringkas, hangat, dan tidak menghakimi.
- Gunakan ID baru `why_4.1` hingga `why_4.10`; jangan mengubah progres modul yang ada.
- Setiap artikel memiliki lima quiz, empat opsi per soal, dan jawaban benar tersebar di indeks 0–3.
- Gunakan rujukan Al-Quran singkat; hindari klaim sains viral sebagai fondasi iman.
- Tidak menambah paket atau sistem penyimpanan baru.

---

### Task 1: Uji kontrak kategori Keyakinan

**Files:**
- Modify: `test/learning_content_test.dart`
- Modify: `lib/services/learning_content.dart`

**Interfaces:**
- Consumes: `LearningContent.categories`, `LearningContent.getArticle`, `LearningContent.getQuiz`, `LearningContent.isModuleUnlocked`.
- Produces: Kontrak teruji untuk kategori `keyakinan` dan modul `why_4.1` sampai `why_4.10`.

- [x] Tulis test yang mencari `keyakinan`, mengharapkan 10 modul, dan memastikan modul pertama `why_4.1` serta quiz terakhir berisi lima soal.
- [x] Jalankan `flutter test test/learning_content_test.dart`; hasil gagal karena kategori belum ada.
- [x] Tambahkan kategori dan sepuluh modul pada registry.
- [x] Jalankan ulang test hingga lulus.

### Task 2: Artikel dan quiz WHY Islam

**Files:**
- Modify: `lib/services/learning_content.dart`
- Modify: `test/learning_content_test.dart`

**Interfaces:**
- Consumes: `ArticleBlock` dan `QuizQuestion`.
- Produces: Sepuluh artikel dan lima puluh soal untuk `why_4.1` sampai `why_4.10`.

- [x] Tulis test yang mengharapkan semua artikel memiliki `Heading`, semua quiz lima soal, dan seluruh posisi jawaban 0–3 dipakai.
- [x] Jalankan test; hasil gagal karena konten belum terdaftar atau indeks jawaban belum tersebar.
- [x] Daftarkan mapping artikel/quiz dan isi kontennya untuk setiap modul.
- [x] Jalankan ulang test hingga lulus.

### Task 3: Verifikasi integrasi

**Files:**
- Modify: `lib/services/learning_content.dart`
- Modify: `test/learning_content_test.dart`

- [x] Jalankan `flutter analyze` dan pastikan tanpa isu.
- [x] Jalankan `flutter test test/learning_content_test.dart`, lalu `flutter test`; golden test Profil lama tetap gagal pada Windows.
- [ ] Commit dan push file aplikasi, test, dan rencana dengan pesan `feat: add why Islam learning category`.
