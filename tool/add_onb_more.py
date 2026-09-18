"""Tambah key ARB untuk halaman bahasa / nama / Ikhwan-Akhwat / cara main."""
import sys

sys.path.insert(0, 'tool')
from arb_insert import insert  # noqa: E402

ID = {
    # Halaman 1: bahasa
    'onbLangTitle': 'Mau pakai bahasa apa?',
    'onbLangBody': 'Kamu bisa ubah kapan saja di Profil.',
    # Halaman 2: nama
    'onbNameTitle': 'Siapa nama pejuangmu?',
    'onbNameBody': 'Nama ini muncul di Beranda dan kartu medali. Boleh dikosongkan.',
    # Halaman 3: Ikhwan / Akhwat
    'onbGenderIkhwan': 'IKHWAN',
    'onbGenderAkhwat': 'AKHWAT',
    'onbGenderSkip': 'Lewati',
    'onbGenderTitle': 'Kamu Ikhwan atau Akhwat?',
    # ponytail: satu-satunya alasan gender ditanya = menyembunyikan baris
    # Periode Haid. Jangan tambah alasan karangan di sini.
    'onbGenderWhy': 'Akhwat punya fitur Periode Haid: saat datang bulan, '
                    'streak sholat otomatis di-freeze supaya tidak ada '
                    'penalti. Fitur itu kami sembunyikan dari tampilan Ikhwan '
                    'supaya menunya bersih.',
    'onbGenderPrivacy': 'Jawabanmu cuma dipakai untuk menyembunyikan menu. '
                        'Kamu bisa ubah kapan saja di Profil.',
    # Halaman 4: cara main
    'onbHowTitle': 'Cara Main',
    'onbHowBody': 'Tiga hal ini yang bikin ibadah harianmu terasa seperti naik level.',
    'onbHowQuestTitle': 'Quest Harian',
    'onbHowQuestBody': 'Tandai sholat wajib & sunnah tiap hari.',
    'onbHowXpTitle': 'XP & Level',
    'onbHowXpBody': 'Tiap quest selesai dapat XP. Naik level, naik pangkat.',
    'onbHowAchTitle': 'Achievement',
    'onbHowAchBody': 'Buka medali dari streak, tilawah, dan dzikir.',
    'onbHowDemoHint': 'Coba ketuk kartunya',
}
EN = {
    'onbLangTitle': 'Which language do you want?',
    'onbLangBody': 'You can change this anytime in Profile.',
    'onbNameTitle': "What's your warrior name?",
    'onbNameBody': 'This name shows on Home and your medal cards. You can leave it blank.',
    'onbGenderIkhwan': 'IKHWAN',
    'onbGenderAkhwat': 'AKHWAT',
    'onbGenderSkip': 'Skip',
    'onbGenderTitle': 'Are you Ikhwan or Akhwat?',
    'onbGenderWhy': 'Akhwat get the Menstrual Period feature: during your period '
                    'your prayer streak is frozen automatically, so there is no '
                    'penalty. We hide it from the Ikhwan view to keep the menu clean.',
    'onbGenderPrivacy': 'Your answer is only used to hide that menu. '
                        'You can change it anytime in Profile.',
    'onbHowTitle': 'How to Play',
    'onbHowBody': 'Three things that make your daily worship feel like leveling up.',
    'onbHowQuestTitle': 'Daily Quests',
    'onbHowQuestBody': 'Mark obligatory & sunnah prayers every day.',
    'onbHowXpTitle': 'XP & Levels',
    'onbHowXpBody': 'Every quest gives XP. Level up, rank up.',
    'onbHowAchTitle': 'Achievements',
    'onbHowAchBody': 'Unlock medals from streaks, recitation, and dhikr.',
    'onbHowDemoHint': 'Try tapping the card',
}

insert('lib/l10n/app_id.arb', ID)
insert('lib/l10n/app_en.arb', EN)

import json  # noqa: E402

for loc in ('id', 'en'):
    d = json.load(open(f'lib/l10n/app_{loc}.arb', encoding='utf-8'))
    print(loc, len([k for k in d if not k.startswith('@')]))
