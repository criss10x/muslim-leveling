#!/usr/bin/env python3
"""Lokalisasi kutipan ulama + nama bulan/tanggal Hijriah.

Menjalankan sekali: mengisi ARB dengan teks id + en, lalu menulis jembatan Dart
`lib/l10n/hijri_texts.g.dart` (index/key → getter) yang dipakai kode.

Idempoten: setelah run pertama, ARB jadi SUMBER KEBENARAN — nilai yang sudah ada
di ARB dipakai apa adanya (jadi hasil edit manual tidak ditimpa), tabel di bawah
cuma dipakai untuk key yang belum ada. Tidak ada parsing kode Dart yang rapuh.

Yang SENGAJA tidak diterjemahkan (keputusan user):
  * nama provinsi / kota
  * nama tokoh ulama — transliterasi Latin sudah jadi nama diri
  * teks ayat/hadis Al-Qur'an di `_quotes` quest

Output:
  lib/l10n/app_id.arb, app_en.arb   (uq_ulama_*, uq_month_*, uq_ev_*, hj*)
  lib/l10n/hijri_texts.g.dart

Setelah dijalankan: flutter gen-l10n && flutter analyze
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# ── Nama bulan Hijriah (12) — (Indonesia, English) ─────────────────────────
MONTHS = [
    ('Muharam', 'Muharram'),
    ('Safar', 'Safar'),
    ('Rabiulawal', 'Rabi al-Awwal'),
    ('Rabiulakhir', 'Rabi al-Thani'),
    ('Jumadilawal', 'Jumada al-Awwal'),
    ('Jumadilakhir', 'Jumada al-Thani'),
    ('Rajab', 'Rajab'),
    ('Syaban', 'Shaban'),
    ('Ramadan', 'Ramadan'),
    ('Syawal', 'Shawwal'),
    ('Zulkaidah', 'Dhu al-Qadah'),
    ('Zulhijah', 'Dhu al-Hijjah'),
]

# ── 10 tanggal penting Islam — (bulan, hari) → (Indonesia, English) ────────
EVENTS = {
    (1, 1): ('Tahun Baru Hijriah', 'Hijri New Year'),
    (1, 10): ('Hari Asyura', 'Day of Ashura'),
    (3, 12): ('Maulid Nabi', 'Mawlid al-Nabi'),
    (7, 27): ('Isra Mikraj', 'Isra and Mi\u2019raj'),
    (8, 15): ('Nisfu Syaban', 'Mid-Shaban'),
    (9, 1): ('Awal Ramadan', 'Start of Ramadan'),
    (9, 17): ('Nuzulul Quran', 'Nuzul al-Quran'),
    (10, 1): ('Idulfitri', 'Eid al-Fitr'),
    (12, 9): ('Hari Arafah', 'Day of Arafah'),
    (12, 10): ('Iduladha', 'Eid al-Adha'),
}

# ── Label chrome yang muncul bersama batch ini ────────────────────────────
UI = {
    'hjHariPentingTitle': ('Hari Penting Islam', 'Important Islamic Dates'),
    'hjHariPentingEmpty': (
        'Tidak bisa memuat tanggal penting.',
        'Could not load the important dates.'),
    'hjHariPentingSemantics': (
        'Tanggal Hijriah, buka Hari Penting Islam',
        'Hijri date, opens Important Islamic Dates'),
    'hjToday': ('Hari ini!', 'Today!'),
    'hjPassed': ('Sudah lewat', 'Passed'),
    'hjDaysLeft': ('{days} hari lagi', '{days} days left'),
    'hjHijriSuffix': ('H', 'AH'),
}

# ── 32 kutipan ulama — (tokoh, Indonesia, English) ────────────────────────
# Urutan = urutan `ulamaQuoteTokens` di ulama_quotes.dart (menentukan pasangan
# tokoh ↔ kutipan). Atribusi = versi yang beredar luas di kitab adab/Diwan,
# bukan verifikasi sanad; isi hikmahnya yang diterjemahkan, bukan namanya.
ULAMA = [
    ('Ali bin Abi Thalib',
     'Ilmu itu lebih baik daripada harta. Ilmu menjaga kamu, sedangkan harta justru kamu yang menjaganya.',
     'Knowledge is better than wealth. Knowledge guards you, while you are the one guarding wealth.'),
    ('Ali bin Abi Thalib',
     'Orang berilmu itu hidup walau sudah wafat, sedangkan orang bodoh itu mati walau masih hidup.',
     'The learned live on even after death, while the ignorant are dead even while alive.'),
    ('Ali bin Abi Thalib',
     'Jangan melihat siapa yang berbicara, tapi lihatlah apa yang dia katakan.',
     'Do not look at who is speaking, but look at what he says.'),
    ('Ali bin Abi Thalib',
     'Nilai seseorang diukur dari apa yang dia tekuni dengan sungguh-sungguh.',
     'A person\u2019s worth is measured by what he pursues with sincerity.'),
    ('Umar bin Khattab',
     'Hisablah dirimu sendiri sebelum kamu dihisab, dan timbanglah amalmu sebelum ditimbang.',
     'Hold yourself to account before you are held to account, and weigh your deeds before they are weighed.'),
    ('Umar bin Khattab',
     'Aku tidak pernah menyesal karena diam, tapi aku sering menyesal karena berbicara.',
     'I never regretted silence, but I often regretted speaking.'),
    ('Umar bin Khattab',
     'Kehormatanmu adalah agamamu, dan harga dirimu adalah akhlakmu.',
     'Your honour is your religion, and your dignity is your character.'),
    ("Imam Syafi'i",
     'Waktu itu seperti pedang \u2014 kalau kamu tidak memotongnya, dia yang memotongmu.',
     'Time is like a sword \u2014 if you do not cut it, it cuts you.'),
    ("Imam Syafi'i",
     'Ilmu bukanlah yang dihafal, tetapi ilmu adalah yang memberi manfaat.',
     'Knowledge is not what is memorised, but what brings benefit.'),
    ("Imam Syafi'i",
     'Ilmu itu cahaya, dan cahaya Allah tidak akan masuk ke dalam hati orang yang bermaksiat.',
     'Knowledge is light, and the light of Allah does not enter the heart of a disobedient person.'),
    ("Imam Syafi'i",
     'Barangsiapa tidak tahan lelahnya belajar, dia harus tahan perihnya kebodohan.',
     'Whoever cannot endure the fatigue of learning must endure the pain of ignorance.'),
    ('Imam Malik',
     'Aku tidak berhenti belajar sejak aku menyadari bahwa aku masih bodoh.',
     'I have never stopped learning since I realised how ignorant I still am.'),
    ('Imam Malik',
     'Aku tidak memberi fatwa sampai aku bertanya kepada orang yang lebih berilmu dariku.',
     'I do not give a fatwa until I have asked someone more knowledgeable than me.'),
    ('Imam Ahmad bin Hanbal',
     'Manusia lebih membutuhkan ilmu daripada makanan dan minuman.',
     'People need knowledge more than they need food and drink.'),
    ('Imam Ahmad bin Hanbal',
     'Aku tidak menulis satu hadis pun melainkan aku amalkan dulu isinya.',
     'I did not write down a single hadith without first practising what it says.'),
    ('Imam Abu Hanifah',
     'Ilmu tanpa amal seperti pohon tanpa buah.',
     'Knowledge without practice is like a tree without fruit.'),
    ('Hasan al-Bashri',
     'Anak Adam hanyalah kumpulan hari-hari. Setiap satu hari berlalu, sebagian dari dirinya ikut pergi.',
     'The son of Adam is nothing but a bundle of days. Each day that passes takes part of him with it.'),
    ('Hasan al-Bashri',
     'Barangsiapa mengenal Allah, dia akan mencintai-Nya; dan yang mencintai-Nya akan sibuk dengan-Nya.',
     'Whoever knows Allah will love Him; and whoever loves Him will keep busy with Him.'),
    ('Hasan al-Bashri',
     'Sesungguhnya dunia ini hanya sebentar, jangan sampai kita bekerja untuknya seolah selamanya.',
     'This world is only brief, so let us not work for it as though it lasts forever.'),
    ('Umar bin Abdul Aziz',
     'Jadikan dunia ini cukup berada di tanganmu, jangan sampai masuk ke dalam hatimu.',
     'Let this world rest in your hand, and never let it enter your heart.'),
    ('Umar bin Abdul Aziz',
     'Perbanyaklah mengingat mati, karena itu menghapus cinta kepada dunia.',
     'Remember death often, for it erases the love of this world.'),
    ('Sufyan ats-Tsauri',
     'Aku tidak mengobati sesuatu yang lebih berat daripada niatku sendiri.',
     'I have never had to remedy anything heavier than my own intention.'),
    ('Sufyan ats-Tsauri',
     'Ilmu itu untuk diamalkan; kalau tidak diamalkan, dia akan pergi.',
     'Knowledge is meant to be practised; if it is not, it leaves.'),
    ("Abdullah bin Mas'ud",
     'Diam adalah hikmah, tapi sedikit orang yang mau mengamalkannya.',
     'Silence is wisdom, but few are willing to practise it.'),
    ("Abdullah bin Mas'ud",
     'Sebaik-baik hati adalah yang dipenuhi rasa takut dan harap kepada Allah.',
     'The best heart is the one filled with fear and hope of Allah.'),
    ('Ibnu Qayyim al-Jauziyyah',
     'Tidak ada yang lebih bermanfaat bagi hati daripada membaca Al-Qur\u2019an dengan tadabbur.',
     'Nothing benefits the heart more than reading the Quran with reflection.'),
    ('Ibnu Qayyim al-Jauziyyah',
     'Hati bisa sakit seperti badan sakit, dan obatnya adalah istigfar.',
     'The heart can fall ill as the body does, and its cure is seeking forgiveness.'),
    ('Ibnu Qayyim al-Jauziyyah',
     'Kesabaran itu cahaya \u2014 dengannya jalan yang sempit terasa lapang.',
     'Patience is light \u2014 with it a narrow road feels wide.'),
    ('Al-Ghazali',
     'Ilmu tanpa amal adalah sia-sia, dan amal tanpa ilmu tidak akan sempurna.',
     'Knowledge without practice is wasted, and practice without knowledge is incomplete.'),
    ('Al-Ghazali',
     'Kebahagiaan bukan pada banyaknya harta, tetapi pada lapangnya hati.',
     'Happiness is not in having much, but in having a spacious heart.'),
    ('Al-Ghazali',
     'Siapa yang menuntut ilmu semata untuk membanggakan diri, ilmunya akan menjadi hujjah atas dirinya.',
     'Whoever seeks knowledge only to boast, his knowledge will become a case against him.'),
    ('Ibrahim bin Adham',
     'Jaga hatimu, karena Allah melihat bukan hanya amalmu, tapi juga apa yang ada di dalamnya.',
     'Guard your heart, for Allah sees not only your deeds but what lies within them.'),
]

# Em dash / apostrof tipografis yang mungkin ditulis beda di tabel ini.
DASHES = ('\u2014', '\u2013', '-')


def key_for_ulama(text):
    return 'uq_ulama_' + re.sub(r'[^a-z0-9]+', '_', text.lower())[:40].strip('_')


def existing_arb():
    return {loc: json.loads((ROOT / f'lib/l10n/app_{loc}.arb').read_text())
            for loc in ('id', 'en')}


def insert_arb(path, pairs):
    """Sisipkan key tanpa mengurutkan ulang file (diff kecil).

    Jebakan yang sudah kena di add_quest_arb_keys.py: jangan rstrip('}') (koma),
    jaga koma antar-baris, dan ensure_ascii=False supaya \u2014 tetap karakter asli.
    """
    raw = path.read_text()
    data = json.loads(raw)
    fresh = {k: v for k, v in pairs.items() if k not in data}
    if not fresh:
        return 0
    trimmed = raw.rstrip()
    assert trimmed.endswith('}'), 'ARB tidak berakhir dengan }'
    body = trimmed[:-1].rstrip()
    if not body.endswith(','):
        body += ','
    entries = [f'  {json.dumps(k, ensure_ascii=False)}: '
               f'{json.dumps(v, ensure_ascii=False)}' for k, v in fresh.items()]
    out = body + '\n' + ',\n'.join(entries) + '\n}\n'
    json.loads(out)
    path.write_text(out)
    return len(fresh)


def check_dart_event_list(ref):
    """Dart menyimpan daftar (bulan, hari) untuk tanggal penting; kalau urutannya
    beda dari jembatan, label bisa nyangkut ke tanggal yang salah — jadi dicek."""
    src = (ROOT / 'lib/services/hijri_service.dart').read_text()
    block = src.split('hijriImportantDates = <(int, int)>[')[1].split('];')[0]
    got = [(int(m), int(d))
           for m, d in re.findall(r'\((\d+), (\d+)\)', block)]
    want = sorted(EVENTS)
    if got != want:
        ref.setdefault('problems', []).append(
            f'hijriImportantDates.dart={got} != tabel={want}')


def main():
    arb = existing_arb()
    ref = {}
    idn_pairs, en_pairs = {}, {}
    ulama_ids = []

    for tokoh, idn, en in ULAMA:
        key = key_for_ulama(idn)
        assert key not in idn_pairs, f'key tabrakan: {key}'
        # ARB = sumber kebenaran; tabel cuma dipakai kalau key belum ada.
        idn_pairs[key] = arb['id'].get(key, idn)
        en_pairs[key] = arb['en'].get(key, en)
        ulama_ids.append((key, tokoh))

    month_ids = []
    for i, (idn, en) in enumerate(MONTHS):
        key = f'uq_month_{i + 1}'
        idn_pairs[key] = arb['id'].get(key, idn)
        en_pairs[key] = arb['en'].get(key, en)
        month_ids.append(key)

    event_ids = []
    for (hm, hd), (idn, en) in sorted(EVENTS.items()):
        key = f'uq_ev_{hm}_{hd}'
        idn_pairs[key] = arb['id'].get(key, idn)
        en_pairs[key] = arb['en'].get(key, en)
        event_ids.append(key)

    for k, (idn, en) in UI.items():
        idn_pairs[k] = arb['id'].get(k, idn)
        en_pairs[k] = arb['en'].get(k, en)

    check_dart_event_list(ref)

    n_id = insert_arb(ROOT / 'lib/l10n/app_id.arb', idn_pairs)
    n_en = insert_arb(ROOT / 'lib/l10n/app_en.arb', en_pairs)
    print(f'app_id.arb: +{n_id} key   app_en.arb: +{n_en} key')

    # paritas: id & en harus punya nilai untuk key yang sama
    for k in idn_pairs:
        assert k in en_pairs, f'{k} tidak punya pasangan en'

    # ── Jembatan Dart ───────────────────────────────────────────────────────
    def dart_str(s):
        """Literal Dart: escape backslash + apostrof (nama tokoh ada apostrof)."""
        return "'" + s.replace('\\', '\\\\').replace("'", "\\'") + "'"

    month_cases = '\n'.join(
        f'      {i + 1} => l10n.{k},' for i, k in enumerate(month_ids))
    ev_cases = '\n'.join(
        f'      ({hm}, {hd}) => l10n.{k},'
        for (hm, hd), k in zip(sorted(EVENTS), event_ids))
    entries = ',\n'.join(
        f'  (token: {dart_str(t)}, text: l10n.{k})' for k, t in ulama_ids)
    token_list = '\n'.join(f'  {dart_str(t)},' for _, t in ulama_ids)

    dart = f'''// GENERATED by tool/gen_ulama_hijri_arb.py — JANGAN edit manual.
// Teks hidup di lib/l10n/app_<locale>.arb; ini cuma jembatan index → getter.

import 'app_localizations.dart';

/// Semua kutipan ulama untuk bahasa aktif, urutan sama dengan
/// [ulamaQuoteTokens] di services/ulama_quotes.dart. Pemanggil memilih index
/// dengan [highlightIndex] supaya pilihan tetap deterministik per tanggal.
List<({{String token, String text}})> ulamaQuoteTexts(AppL10n l10n) => [
{entries},
];

/// Semua token (nama tokoh) — dipakai guard supaya tidak ada yang terlewat.
const List<String> ulamaAllTokens = [
{token_list}
];

/// Nama bulan Hijriah index 1..12 (index 0 kosong, mengikuti sumber lama).
String hijriMonthName(AppL10n l10n, int month) => switch (month) {{
{month_cases}
      _ => '',
    }};

/// Label tanggal penting Hijriah; null kalau (bulan, hari) tidak terdaftar.
String? hijriEventLabel(AppL10n l10n, int month, int day) =>
    switch ((month, day)) {{
{ev_cases}
      _ => null,
    }};

/// Tanggal Hijriah lengkap: "17 Safar 1448 H" (id) / "17 Safar 1448 AH" (en).
String hijriDateLabel(AppL10n l10n, int day, int month, int year) =>
    '$day ${{hijriMonthName(l10n, month)}} $year ${{l10n.hjHijriSuffix}}';
'''
    out = ROOT / 'lib/l10n/hijri_texts.g.dart'
    out.write_text(dart)
    print(f'{out.relative_to(ROOT)}: {len(ulama_ids)} kutipan, '
          f'{len(month_ids)} bulan, {len(event_ids)} event')
    if ref.get('problems'):
        for p in ref['problems']:
            print('MASALAH:', p)
        raise SystemExit(1)


if __name__ == '__main__':
    main()
