/// Daftar tokoh kutipan — teks hikmahnya TIDAK disimpan di sini lagi.
///
/// Isi kutipan hidup di `lib/l10n/app_<locale>.arb` dan dibaca lewat jembatan
/// `ulamaQuoteTexts(l10n)` di lib/l10n/hijri_texts.g.dart (di-generate oleh
/// tool/gen_ulama_hijri_arb.py). Urutan daftar ini yang menentukan pasangan
/// tokoh <-> kutipan, jadi JANGAN mengurutkan ulang tanpa regenerate jembatan.
///
/// ponytail: tidak ada API quotes islami yang layak dipakai (dicek: myquran v3
/// tidak punya endpoint quotes, equran.id tidak punya, tidak ada API publik
/// Indonesia yang stabil) -> pool statis seperti `_quotes` di quest_claim_screen.
/// Atribusi = versi yang beredar luas di kitab adab/Diwan (bukan verifikasi
/// sanad) — hapus/ganti entri yang tidak dipercaya. Nama tokoh tidak
/// diterjemahkan (nama diri); isinya punya versi id + en.
const ulamaQuoteTokens = <String>[
  // ── Ali bin Abi Thalib ──────────────────────────────────────────────
  'Ali bin Abi Thalib',
  'Ali bin Abi Thalib',
  'Ali bin Abi Thalib',
  'Ali bin Abi Thalib',
  // ── Umar bin Khattab ────────────────────────────────────────────────
  'Umar bin Khattab',
  'Umar bin Khattab',
  'Umar bin Khattab',
  // ── Imam Syafi'i ────────────────────────────────────────────────────
  "Imam Syafi'i",
  "Imam Syafi'i",
  "Imam Syafi'i",
  "Imam Syafi'i",
  // ── Imam Malik ──────────────────────────────────────────────────────
  'Imam Malik',
  'Imam Malik',
  // ── Imam Ahmad bin Hanbal ───────────────────────────────────────────
  'Imam Ahmad bin Hanbal',
  'Imam Ahmad bin Hanbal',
  // ── Imam Abu Hanifah ────────────────────────────────────────────────
  'Imam Abu Hanifah',
  // ── Hasan al-Bashri ─────────────────────────────────────────────────
  'Hasan al-Bashri',
  'Hasan al-Bashri',
  'Hasan al-Bashri',
  // ── Umar bin Abdul Aziz ─────────────────────────────────────────────
  'Umar bin Abdul Aziz',
  'Umar bin Abdul Aziz',
  // ── Sufyan ats-Tsauri ───────────────────────────────────────────────
  'Sufyan ats-Tsauri',
  'Sufyan ats-Tsauri',
  // ── Abdullah bin Mas'ud ─────────────────────────────────────────────
  "Abdullah bin Mas'ud",
  "Abdullah bin Mas'ud",
  // ── Ibnu Qayyim al-Jauziyyah ────────────────────────────────────────
  'Ibnu Qayyim al-Jauziyyah',
  'Ibnu Qayyim al-Jauziyyah',
  'Ibnu Qayyim al-Jauziyyah',
  // ── Al-Ghazali ──────────────────────────────────────────────────────
  'Al-Ghazali',
  'Al-Ghazali',
  'Al-Ghazali',
  // ── Ibrahim bin Adham ───────────────────────────────────────────────
  'Ibrahim bin Adham',
];
