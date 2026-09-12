/// Kutipan kata-kata ulama / hikmah islami — aset lokal, offline & deterministik.
///
/// ponytail: tidak ada API quotes islami yang layak dipakai (dicek: myquran v3
/// tidak punya endpoint quotes, equran.id tidak punya, tidak ada API publik
/// Indonesia yang stabil) → pool statis seperti `_quotes` di quest_claim_screen.
/// Teks Indonesia + nama tokoh saja; tanpa teks Arab supaya tidak ada tulisan
/// Arab yang diragukan. Atribusi = versi yang beredar luas di kitab adab/Diwan
/// (bukan verifikasi sanad) — hapus/ganti entri yang tidak dipercaya.
class UlamaQuote {
  final String tokoh;
  final String idn;
  const UlamaQuote(this.tokoh, this.idn);
}

const ulamaQuotes = <UlamaQuote>[
  // ── Ali bin Abi Thalib ──────────────────────────────────────────────
  UlamaQuote(
    'Ali bin Abi Thalib',
    'Ilmu itu lebih baik daripada harta. Ilmu menjaga kamu, sedangkan harta justru kamu yang menjaganya.',
  ),
  UlamaQuote(
    'Ali bin Abi Thalib',
    'Orang berilmu itu hidup walau sudah wafat, sedangkan orang bodoh itu mati walau masih hidup.',
  ),
  UlamaQuote(
    'Ali bin Abi Thalib',
    'Jangan melihat siapa yang berbicara, tapi lihatlah apa yang dia katakan.',
  ),
  UlamaQuote(
    'Ali bin Abi Thalib',
    'Nilai seseorang diukur dari apa yang dia tekuni dengan sungguh-sungguh.',
  ),
  // ── Umar bin Khattab ────────────────────────────────────────────────
  UlamaQuote(
    'Umar bin Khattab',
    'Hisablah dirimu sendiri sebelum kamu dihisab, dan timbanglah amalmu sebelum ditimbang.',
  ),
  UlamaQuote(
    'Umar bin Khattab',
    'Aku tidak pernah menyesal karena diam, tapi aku sering menyesal karena berbicara.',
  ),
  UlamaQuote(
    'Umar bin Khattab',
    'Kehormatanmu adalah agamamu, dan harga dirimu adalah akhlakmu.',
  ),
  // ── Imam Syafi\'i ───────────────────────────────────────────────────
  UlamaQuote(
    'Imam Syafi\'i',
    'Waktu itu seperti pedang — kalau kamu tidak memotongnya, dia yang memotongmu.',
  ),
  UlamaQuote(
    'Imam Syafi\'i',
    'Ilmu bukanlah yang dihafal, tetapi ilmu adalah yang memberi manfaat.',
  ),
  UlamaQuote(
    'Imam Syafi\'i',
    'Ilmu itu cahaya, dan cahaya Allah tidak akan masuk ke dalam hati orang yang bermaksiat.',
  ),
  UlamaQuote(
    'Imam Syafi\'i',
    'Barangsiapa tidak tahan lelahnya belajar, dia harus tahan perihnya kebodohan.',
  ),
  // ── Imam Malik ──────────────────────────────────────────────────────
  UlamaQuote(
    'Imam Malik',
    'Aku tidak berhenti belajar sejak aku menyadari bahwa aku masih bodoh.',
  ),
  UlamaQuote(
    'Imam Malik',
    'Aku tidak memberi fatwa sampai aku bertanya kepada orang yang lebih berilmu dariku.',
  ),
  // ── Imam Ahmad bin Hanbal ───────────────────────────────────────────
  UlamaQuote(
    'Imam Ahmad bin Hanbal',
    'Manusia lebih membutuhkan ilmu daripada makanan dan minuman.',
  ),
  UlamaQuote(
    'Imam Ahmad bin Hanbal',
    'Aku tidak menulis satu hadis pun melainkan aku amalkan dulu isinya.',
  ),
  // ── Imam Abu Hanifah ────────────────────────────────────────────────
  UlamaQuote('Imam Abu Hanifah', 'Ilmu tanpa amal seperti pohon tanpa buah.'),
  // ── Hasan al-Bashri ─────────────────────────────────────────────────
  UlamaQuote(
    'Hasan al-Bashri',
    'Anak Adam hanyalah kumpulan hari-hari. Setiap satu hari berlalu, sebagian dari dirinya ikut pergi.',
  ),
  UlamaQuote(
    'Hasan al-Bashri',
    'Barangsiapa mengenal Allah, dia akan mencintai-Nya; dan yang mencintai-Nya akan sibuk dengan-Nya.',
  ),
  UlamaQuote(
    'Hasan al-Bashri',
    'Sesungguhnya dunia ini hanya sebentar, jangan sampai kita bekerja untuknya seolah selamanya.',
  ),
  // ── Umar bin Abdul Aziz ─────────────────────────────────────────────
  UlamaQuote(
    'Umar bin Abdul Aziz',
    'Jadikan dunia ini cukup berada di tanganmu, jangan sampai masuk ke dalam hatimu.',
  ),
  UlamaQuote(
    'Umar bin Abdul Aziz',
    'Perbanyaklah mengingat mati, karena itu menghapus cinta kepada dunia.',
  ),
  // ── Sufyan ats-Tsauri ───────────────────────────────────────────────
  UlamaQuote(
    'Sufyan ats-Tsauri',
    'Aku tidak mengobati sesuatu yang lebih berat daripada niatku sendiri.',
  ),
  UlamaQuote(
    'Sufyan ats-Tsauri',
    'Ilmu itu untuk diamalkan; kalau tidak diamalkan, dia akan pergi.',
  ),
  // ── Abdullah bin Mas\'ud ────────────────────────────────────────────
  UlamaQuote(
    'Abdullah bin Mas\'ud',
    'Diam adalah hikmah, tapi sedikit orang yang mau mengamalkannya.',
  ),
  UlamaQuote(
    'Abdullah bin Mas\'ud',
    'Sebaik-baik hati adalah yang dipenuhi rasa takut dan harap kepada Allah.',
  ),
  // ── Ibnu Qayyim al-Jauziyyah ────────────────────────────────────────
  UlamaQuote(
    'Ibnu Qayyim al-Jauziyyah',
    'Tidak ada yang lebih bermanfaat bagi hati daripada membaca Al-Qur\'an dengan tadabbur.',
  ),
  UlamaQuote(
    'Ibnu Qayyim al-Jauziyyah',
    'Hati bisa sakit seperti badan sakit, dan obatnya adalah istigfar.',
  ),
  UlamaQuote(
    'Ibnu Qayyim al-Jauziyyah',
    'Kesabaran itu cahaya — dengannya jalan yang sempit terasa lapang.',
  ),
  // ── Al-Ghazali ──────────────────────────────────────────────────────
  UlamaQuote(
    'Al-Ghazali',
    'Ilmu tanpa amal adalah sia-sia, dan amal tanpa ilmu tidak akan sempurna.',
  ),
  UlamaQuote(
    'Al-Ghazali',
    'Kebahagiaan bukan pada banyaknya harta, tetapi pada lapangnya hati.',
  ),
  UlamaQuote(
    'Al-Ghazali',
    'Siapa yang menuntut ilmu semata untuk membanggakan diri, ilmunya akan menjadi hujjah atas dirinya.',
  ),
  // ── Ibrahim bin Adham ───────────────────────────────────────────────
  UlamaQuote(
    'Ibrahim bin Adham',
    'Jaga hatimu, karena Allah melihat bukan hanya amalmu, tapi juga apa yang ada di dalamnya.',
  ),
];
