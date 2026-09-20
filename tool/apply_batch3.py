#!/usr/bin/env python3
"""Batch 3 l10n: sisa literal chrome di screens/widgets.

Pola sama seperti apply_batch2.py; jalur SPECIAL dipakai untuk string yang di
Dart tampil berbeda (bersambung / berinterpolasi).

  python3 tool/apply_batch3.py           # tulis
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

ITEMS: list[tuple[str, str, str]] = [
    ('lib/screens/jadwal_tab.dart', 'jdLoadFailed', 'Gagal memuat jadwal. Periksa koneksi.'),
    ('lib/screens/jadwal_tab.dart', 'jdAlreadyLogged', '✓ SUDAH DILOG'),
    ('lib/screens/jadwal_tab.dart', 'jdTesSuara', 'Tes suara'),
    ('lib/screens/jadwal_tab.dart', 'jdAdzanDownloadFailed', 'Gagal mengunduh suara adzan. Periksa koneksi lalu coba lagi.'),
    ('lib/screens/quran_tab.dart', 'qtLoadFailed', 'Gagal memuat data Quran'),
    ('lib/screens/quran_tab.dart', 'qtSurahNotFound', 'Surat tidak ditemukan'),
    ('lib/screens/quran_tab.dart', 'qtContinueReading', 'Lanjutkan membaca'),
    ('lib/screens/splash_screen.dart', 'spTagline', 'Level Up iman, Level Up Kehidupanmu'),
    ('lib/screens/splash_screen.dart', 'spLoading', 'MEMUAT DATA PEJUANG...'),
    ('lib/screens/belajar_tab.dart', 'btSubtitle', 'Tingkatkan ilmu, raih lebih banyak XP.'),
    ('lib/screens/doa_screen.dart', 'doaLoadFailed', 'Gagal memuat doa.'),
    ('lib/widgets/tier_avatar.dart', 'taProSignature', 'Pro signature finish'),
    ('lib/widgets/theme_preset_picker.dart', 'tpSelected', 'Tema dipilih'),
    ('lib/screens/quran_reader.dart', 'qrDisplaySettings', 'Setelan tampilan'),
]

# (file, key, teks id, cuplikan Dart lama, cuplikan Dart baru)
SPECIAL: list[tuple[str, str, str, str, str]] = [
    ('lib/screens/jadwal_tab.dart', 'jdSoundFollowGlobal', 'Mengikuti global',
     "'Mengikuti global'", 'AppL10n.of(context).jdSoundFollowGlobal'),
    ('lib/screens/jadwal_tab.dart', 'jdNotifFor', 'Notifikasi {prayer}',
     "'Notifikasi $prayerId'", 'AppL10n.of(context).jdNotifFor(prayerId)'),
    ('lib/screens/jadwal_tab.dart', 'jdSoundSilent', 'Senyap — tanpa suara',
     "'Senyap — tanpa suara'", 'AppL10n.of(context).jdSoundSilent'),
    ('lib/screens/jadwal_tab.dart', 'jdSoundNormal', 'Suara — notifikasi standar HP',
     "'Suara — notifikasi standar HP'", 'AppL10n.of(context).jdSoundNormal'),
    ('lib/screens/jadwal_tab.dart', 'jdSoundAdzan', 'Adzan — suara adzan penuh',
     "'Adzan — suara adzan penuh'", 'AppL10n.of(context).jdSoundAdzan'),
    ('lib/screens/jadwal_tab.dart', 'jdSoundGlobalOption', 'Ikuti pengaturan global',
     "'Ikuti pengaturan global'", 'AppL10n.of(context).jdSoundGlobalOption'),
    ('lib/screens/jadwal_tab.dart', 'jdFootnote',
     'Jadwal dari data KEMENAG RI via api.myquran.com untuk {city}. Ter-update otomatis saat tab dibuka; tap nama kota di atas untuk ganti lokasi.',
     "'Jadwal dari data KEMENAG RI via api.myquran.com untuk $_cityName. '\n      'Ter-update otomatis saat tab dibuka; tap nama kota di atas untuk ganti lokasi.'",
     'AppL10n.of(context).jdFootnote(_cityName)'),
    ('lib/screens/quran_tab.dart', 'qtSearchEmpty',
     'Tidak ditemukan. Coba kata lain di terjemahan, atau tulis nama surat + nomor ayat — mis. {example}.',
     """'Tidak ditemukan. Coba kata lain di terjemahan, '
                            'atau tulis nama surat + nomor ayat — mis. '
                            '\${QuranData.exampleAyahRef}'""",
     'AppL10n.of(context).qtSearchEmpty(QuranData.exampleAyahRef)'),
    ('lib/screens/quran_tab.dart', 'qtOpenSurah', 'Buka surat {surah}',
     "'Buka surat \${surah.nameLatin}'", 'AppL10n.of(context).qtOpenSurah(surah.nameLatin)'),
    ('lib/screens/quran_tab.dart', 'qtAyahOf', 'Ayat {ayah} dari {total}',
     "'Ayat \${r.ayah} dari \${r.surah.ayahCount}'",
     'AppL10n.of(context).qtAyahOf(r.ayah, r.surah.ayahCount)'),
    ('lib/screens/quran_tab.dart', 'qtSurahAyah',
     'Surat {surah} · Ayat {ayah}',
     "'Surat \${hit.surahNumber} · Ayat \${hit.ayahNumber}'",
     'AppL10n.of(context).qtSurahAyah(hit.surahNumber, hit.ayahNumber)'),
    ('lib/screens/belajar_tab.dart', 'btQuizScore', 'Quiz: {score}%',
     "'Quiz: \$quizScore%'", 'AppL10n.of(context).btQuizScore(quizScore)'),
    ('lib/screens/naik_level_screen.dart', 'nlLevelShort', 'Lv {level}',
     r"'Lv $level'", 'AppL10n.of(context).nlLevelShort(level)'),
    ('lib/screens/home_tab.dart', 'homeLevelShort', 'LV {level}',
     r"'LV $level'", 'AppL10n.of(context).homeLevelShort(level)'),
    ('lib/widgets/quran_tafsir_sheet.dart', 'qtsTafsirAyah', 'Tafsir Ayat {ayah}',
     "'Tafsir Ayat \${tafsir.ayah}'", 'AppL10n.of(context).qtsTafsirAyah(tafsir.ayah)'),
]

INT_PH = {'level', 'number', 'ayah', 'current', 'total', 'score', 'surah'}


def add_keys() -> None:
    rows = [(k, t) for _, k, t in ITEMS] + [(k, t) for _, k, t, _, _ in SPECIAL if t]
    for loc in ('id', 'en', 'tr', 'ms'):
        p = ROOT / f'lib/l10n/app_{loc}.arb'
        d = json.loads(p.read_text())
        added = 0
        for key, text in rows:
            if key in d:
                continue
            d[key] = text
            ph = re.findall(r'\{(\w+)\}', text)
            if ph:
                d[f'@{key}'] = {'placeholders': {
                    n: ({'type': 'int'} if n in INT_PH else {'type': 'String'}) for n in ph}}
            added += 1
        p.write_text(json.dumps(d, indent=2, ensure_ascii=False) + '\n')
        print(f'ARB {loc}: +{added}')


def rewrite_dart() -> None:
    per_file: dict[str, list[tuple[str, str]]] = {}
    for f, key, text in ITEMS:
        per_file.setdefault(f, []).append((f"'{text}'", f'AppL10n.of(context).{key}'))
    for f, key, _t, old, new in SPECIAL:
        if old is None:
            continue
        per_file.setdefault(f, []).append((old, new))

    for f, pairs in per_file.items():
        p = ROOT / f
        src = p.read_text()
        orig = src
        for old, new in pairs:
            found = old in src
            if not found and old.replace('\\$', '$') in src:
                old, found = old.replace('\\$', '$'), True
            if not found:
                print(f'  !! TIDAK COCOK {f}: {old[:70]}')
                continue
            src = src.replace(old, new)
            src = re.sub(r'const (Text|Semantics|Tooltip)\(\s*' + re.escape(new), r'\1(' + new, src)
        if src != orig:
            p.write_text(src)
            print(f'  {f}: {len(pairs)}')

    for f in per_file:
        p = ROOT / f
        src = p.read_text()
        if 'app_localizations.dart' in src:
            continue
        depth = len(p.relative_to(ROOT / 'lib').parts) - 1
        lines = src.split('\n')
        last = max(i for i, l in enumerate(lines) if l.startswith('import '))
        lines.insert(last + 1, f"import '{'../' * depth}l10n/app_localizations.dart';")
        p.write_text('\n'.join(lines))
        print(f'  import + {f}')


if __name__ == '__main__':
    if '--dry' in sys.argv:
        print('(kering)')
    else:
        add_keys()
        rewrite_dart()
