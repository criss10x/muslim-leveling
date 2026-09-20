#!/usr/bin/env python3
"""Sisipkan key ARB untuk teks daily quest / naik level / side quest.

Sekali pakai (bukan tool yang dipanggil berulang): sumber teks English ada di
TEXT di bawah, teks Indonesia diambil dari kode lama. Setelah dijalankan,
`flutter gen-l10n` + `tool/gen_quest_arb.py` yang jadi alur normal.

ARB tidak diurutkan ulang — key disisipkan sebelum blok "@@" pertama, jadi
diff-nya kecil dan urutan lama tidak berubah.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# key: (indonesia, english)
TEXT = {
    # ── desc quest (pool + hero streak) ──
    'quest_subuh_tepat_desc': (
        'Sholat Subuh tepat waktu (≤30 menit setelah adzan)',
        'Pray Fajr on time (within 30 minutes of the adhan)'),
    'quest_five_rings_desc': (
        'Lengkapin 5/5 sholat hari ini',
        'Complete all 5/5 prayers today'),
    'quest_timely_prayers_desc': (
        'Sholat tepat waktu (≤10 menit), 3x hari ini',
        'Pray on time (within 10 minutes), 3x today'),
    'quest_dhuha_before_dzuhur_desc': (
        'Sholat Dhuha sebelum Dzuhur',
        'Pray Dhuha before Dhuhr'),
    'quest_rawatib_two_desc': (
        'Rawatib 2x hari ini',
        'Pray 2 rawatib today'),
    'quest_dzuhur_tepat_desc': (
        'Sholat Dzuhur tepat waktu (≤30 menit setelah adzan)',
        'Pray Dhuhr on time (within 30 minutes of the adhan)'),
    'quest_maghrib_tepat_desc': (
        'Sholat Maghrib tepat waktu (≤30 menit setelah adzan)',
        'Pray Maghrib on time (within 30 minutes of the adhan)'),
    'quest_isya_hadir_desc': (
        'Jangan lewatkan sholat Isya malam ini',
        "Don't miss Isha tonight"),
    'quest_any_three_desc': (
        'Kerjakan 3 sholat wajib hari ini (bebas yang mana)',
        'Complete 3 obligatory prayers today (any of them)'),
    'quest_subuh_isya_desc': (
        'Kunci dua ujung hari: Subuh + Isya',
        'Lock both ends of the day: Fajr + Isha'),
    'quest_one_sunnah_desc': (
        'Kerjakan 1 sholat sunnah apa saja hari ini',
        'Pray 1 sunnah prayer today, any kind'),
    'quest_rawatib_one_desc': (
        "Rawatib 1x hari ini (qobliyah/ba'diyah bebas)",
        "Pray 1 rawatib today (qobliyah/ba'diyah, either)"),
    'quest_zikir_33_desc': (
        'Zikir 33x lewat tombol Daily Zikir',
        'Dhikr 33x using the Daily Dhikr button'),
    'quest_zikir_goal_desc': (
        'Tuntaskan Daily Zikir sampai {goal}',
        'Finish Daily Dhikr up to {goal}'),
    'quest_quran_10ayat_desc': (
        'Baca Quran 10 ayat hari ini',
        'Read 10 Quran verses today'),
    'quest_hadis_3_desc': (
        'Baca 3 hadis hari ini (≥5 dtk tiap hadis)',
        'Read 3 hadith today (≥5 sec each)'),
    'quest_dzikir_33_subuh_desc': (
        'Dzikir Subhanallah 33x (tasbih setelah sholat)',
        'Dhikr Subhanallah 33x (tasbih after prayer)'),
    'quest_quran_1halaman_desc': (
        'Baca Quran 20 ayat (≈1 halaman mushaf)',
        'Read 20 Quran verses (≈1 mushaf page)'),
    'quest_hadis_5_desc': (
        'Baca 5 hadis hari ini (≥5 dtk tiap hadis)',
        'Read 5 hadith today (≥5 sec each)'),
    'quest_berjamaah_1_desc': (
        'Sholat berjamaah 1x hari ini (pilih bonus berjamaah saat claim)',
        'Pray in congregation once today (pick the jamaah bonus when claiming)'),
    'quest_hero_streak_7_desc': (
        'Pertahanin Hero Streak 7 hari! 🔥',
        'Keep your 7-day Hero Streak alive! 🔥'),

    # ── copy dorongan per kategori (4 each) ──
    'questCopy_sholat_1': (
        'Kamu mungkin lagi sibuk, tapi tetap nyempetin. Good job.',
        'You were probably busy, but you made time anyway. Good job.'),
    'questCopy_sholat_2': (
        'Adzan selesai, kamu langsung jalan. Mantap.',
        'The adhan ended and you moved right away. Solid.'),
    'questCopy_sholat_3': (
        'Tepat waktu hari ini. Satu hal baik yang kamu jaga.',
        'On time today. One good thing you kept safe.'),
    'questCopy_sholat_4': (
        'Capek tetap capek. Tapi kamu tetap datang. 🤍',
        'Tired is still tired. But you showed up anyway. 🤍'),
    'questCopy_sunnah_1': (
        'Nggak wajib, tapi kamu tetap memilih untuk melakukannya.',
        'Not required, yet you chose to do it anyway.'),
    'questCopy_sunnah_2': (
        'Nggak ada yang maksa. Kamu sendiri yang memilih untuk datang.',
        'Nobody forced you. You chose to come on your own.'),
    'questCopy_sunnah_3': (
        'Dua rakaat hari ini. Kecil, tapi berarti.',
        'Two rakaat today. Small, but it counts.'),
    'questCopy_sunnah_4': (
        'Pelan-pelan, kebiasaan baik seperti ini yang kamu bangun.',
        'Slowly — this is the kind of habit you are building.'),
    'questCopy_zikir_1': (
        'Di tengah ramainya hari, kamu masih menyempatkan ingat Allah.',
        'In the middle of a loud day, you still made room to remember Allah.'),
    'questCopy_zikir_2': (
        'Berhenti sebentar. Tarik napas. Ingat Allah.',
        'Pause for a moment. Breathe. Remember Allah.'),
    'questCopy_zikir_3': (
        'Apa pun yang lagi kamu pikirin, kamu tetap meluangkan waktu untuk zikir.',
        'Whatever is on your mind, you still made time for dhikr.'),
    'questCopy_zikir_4': (
        'Selesai zikir. Semoga hati terasa sedikit lebih ringan. 🤍',
        'Dhikr done. May your heart feel a little lighter. 🤍'),
    'questCopy_quran_1': (
        'Satu ayat hari ini. Pelan-pelan, yang penting terus.',
        'One verse today. Slowly — what matters is that you keep going.'),
    'questCopy_quran_2': (
        'Hari ini kamu kembali membuka Al-Quran. Senang lihatnya.',
        'You opened the Quran again today. Good to see.'),
    'questCopy_quran_3': (
        'Nggak harus banyak. Satu halaman pun tetap sebuah langkah.',
        'It does not have to be much. One page is still a step.'),
    'questCopy_quran_4': (
        'Satu halaman selesai. Besok lanjut lagi, ya.',
        'One page down. Pick it up again tomorrow.'),
    'questCopy_hadis_1': (
        'Hari ini kamu meluangkan waktu untuk belajar dari sabda Nabi.',
        'Today you made time to learn from the words of the Prophet.'),
    'questCopy_hadis_2': (
        'Satu hadis kamu baca hari ini. Semoga ada yang bisa kamu bawa ke harimu.',
        'You read a hadith today. May something from it stay with you.'),
    'questCopy_hadis_3': (
        'Nemu hadis yang ngena? Simpan. Siapa tahu kamu butuh mengingatnya lagi.',
        'Found one that hits home? Save it. You may need the reminder again.'),
    'questCopy_hadis_4': (
        'Sedikit belajar hari ini, semoga jadi bekal untuk besok.',
        'A little learning today, may it carry you into tomorrow.'),
    'questCopy_fiveRings_1': (
        'Subuh, Dzuhur, Ashar, Maghrib, Isya. Kamu hadir di semuanya hari ini.',
        'Fajr, Dhuhr, Asr, Maghrib, Isha. You showed up for every one today.'),
    'questCopy_fiveRings_2': (
        'Lima waktu selesai. Alhamdulillah, hari ini kamu berhasil menjaganya.',
        'All five done. Alhamdulillah, you kept them today.'),
    'questCopy_fiveRings_3': (
        'Satu hari, lima waktu. Lengkap. 🤍',
        'One day, five prayers. Complete. 🤍'),
    'questCopy_fiveRings_4': (
        'Hari ini selesai dengan baik. Besok kita mulai lagi.',
        'Today closed well. Tomorrow we start again.'),
    'questCopy_subuhIsya_1': (
        'Subuh kamu jaga, Isya kamu jaga. Alhamdulillah.',
        'You kept Fajr, you kept Isha. Alhamdulillah.'),
    'questCopy_subuhIsya_2': (
        'Dari awal sampai akhir hari, kamu tetap menyempatkan diri.',
        'From the start of the day to the end, you still made time.'),
    'questCopy_subuhIsya_3': (
        'Dua waktu ini kamu jaga hari ini. Good job.',
        'You kept these two today. Good job.'),
    'questCopy_subuhIsya_4': (
        'Hari ini kamu berhasil menjaga Subuh dan Isya. Besok lanjut lagi.',
        'You kept Fajr and Isha today. Keep it going tomorrow.'),

    # ── mode haid ──
    'questHaid_1': (
        'Hari ini waktunya istirahat. Tetap semangat, ya. 🤍',
        'Today is for resting. Stay strong. 🤍'),
    'questHaid_2': (
        'Nggak apa-apa berhenti sebentar. Kamu tetap bagian dari perjalanan ini.',
        'It is okay to pause. You are still part of this journey.'),
    'questHaid_3': (
        'Hari ini kamu nggak perlu mengejar quest ini. Jaga diri dan tetap dekat dengan Allah.',
        'You do not need to chase this quest today. Take care of yourself and stay close to Allah.'),
    'questHaid_4': (
        'Quest boleh berhenti sebentar. Perjalananmu tetap lanjut.',
        'The quest can wait. Your journey still continues.'),

    # ── klaim quest ──
    'questClaimAlhamdulillah': ('Alhamdulillah', 'Alhamdulillah'),
    'questClaimContinue': ('Lanjut', 'Continue'),

    # ── side quest: kartu selebrasi ──
    'sqCombinedTitle': (
        'Alhamdulillah, {count} Quest Tuntas!',
        'Alhamdulillah, {count} Quests Done!'),
    'sqCombinedDesc': (
        'Semua quest harian selesai hari ini. Semoga istiqomah!',
        'All daily quests finished today. May you stay consistent!'),
    'sqZikirTitle': ('Dzikir 100x Selesai!', 'Dhikr 100x Done!'),
    'sqZikirDesc': (
        'Konsisten berdzikir hari ini. Istiqomah!',
        'Consistent in dhikr today. Keep it up!'),
    'sqTilawahTitle': ('Baca Quran 10 Ayat Selesai!', 'Read 10 Quran Verses — Done!'),
    'sqTilawahDesc': (
        'Tilawah hari ini tuntas. Lanjutkan besok!',
        'Recitation done for today. Continue tomorrow!'),
    'sqHadisTitle': ('Belajar 5 Hadis Selesai!', 'Study 5 Hadith — Done!'),
    'sqHadisDesc': (
        'Lima hadis baru terbaca hari ini. Terus belajar!',
        'Five new hadith read today. Keep learning!'),
    'sqBadgeCombined': ('QUEST HARIAN TUNTAS', 'ALL DAILY QUESTS DONE'),
    'sqBadgeSingle': ('QUEST SELESAI', 'QUEST COMPLETE'),
    'sqButton': ('MANTAP!', 'NICE!'),
    'sqBarrierLabel': ('side quest selesai', 'side quest complete'),
    'sqSemantics': ('{title}. {desc}. Bonus {xp} XP.', '{title}. {desc}. Bonus {xp} XP.'),
    # dipakai sebagai `source` layar Naik Level
    'sqSourceZikir': ('Dzikir 100x', 'Dhikr 100x'),
    'sqSourceTilawah': ('Baca Quran', 'Read Quran'),
    'sqSourceHadis': ('Belajar Hadis', 'Study Hadith'),

    # ── layar naik level ──
    'naikTitle': ('NAIK LEVEL!', 'LEVEL UP!'),
    'naikBadgeSemantics': (
        'Bulan sabit emas, lambang naik level',
        'Golden crescent, the mark of a level up'),
    'naikReached': (
        'Masha Allah, kamu mencapai {rank} — Level {level}',
        'Masha Allah, you reached {rank} — Level {level}'),
    'naikFrom': ('dari {source}', 'from {source}'),
    'naikBack': ('KEMBALI', 'BACK'),
    'naikRewardSemanticsFull': (
        'Hadiah: tambah {xp} XP, level {level}, gelar baru {rank}',
        'Reward: +{xp} XP, level {level}, new title {rank}'),
    'naikRewardSemanticsLevel': (
        'Hadiah: level {level}, gelar baru {rank}',
        'Reward: level {level}, new title {rank}'),
    'naikChipLevelJumps': ('Lonjakan', 'Jump'),
    'naikChipLevel': ('Level', 'Level'),
    'naikChipRank': ('GELAR BARU', 'NEW TITLE'),
    'naikProgressSemantics': (
        'Menuju level {next}: {have} dari {need} XP',
        'Toward level {next}: {have} of {need} XP'),
    'naikClosing': (
        'Barakallah — terus istiqomah, level berikutnya menantimu ✨',
        'Barakallah — stay consistent, the next level is waiting ✨'),
    'naikLevelLabel': ('Level {level}', 'Level {level}'),
}


def insert(path, pairs):
    raw = path.read_text()
    data = json.loads(raw)
    added, skipped = [], []
    for k, v in pairs.items():
        if k in data:
            skipped.append(k)
            continue
        added.append(k)

    # Sisipkan blok JSON baru sebelum penutup map root.
    # Jebakan yang sudah kena, semuanya pada string-manipulation JSON:
    #   1. `rstrip('}')` menghapus SEMUA brace penutup (termasuk blok metadata
    #      terakhir) — buang SATU karakter saja.
    #   2. koma di akhir blok = trailing comma sebelum `}` → JSON invalid.
    #      Jadi blok disusun tanpa koma, baru koma disisipkan antar-baris.
    #   3. json.dumps default meng-escape non-ASCII jadi \u2014, padahal ARB ini
    #      memakai karakter asli (—, ✨). ensure_ascii=False supaya konsisten.
    trimmed = raw.rstrip()
    assert trimmed.endswith('}'), 'ARB tidak berakhir dengan }'
    body = trimmed[:-1].rstrip()
    if not body.endswith(','):
        body += ','
    entries = [f'  {json.dumps(k, ensure_ascii=False)}: '
               f'{json.dumps(pairs[k], ensure_ascii=False)}' for k in added]
    out = body + '\n' + ',\n'.join(entries) + '\n}\n'
    json.loads(out)  # validasi hasil akhir, bukan potongannya
    path.write_text(out)
    return added, skipped


def main():
    for loc, idx in (('id', 0), ('en', 1)):
        pairs = {k: v[idx] for k, v in TEXT.items()}
        added, skipped = insert(ROOT / f'lib/l10n/app_{loc}.arb', pairs)
        print(f'app_{loc}.arb: +{len(added)} key, {len(skipped)} sudah ada')
        if skipped:
            print('   dilewati:', skipped)


if __name__ == '__main__':
    main()
