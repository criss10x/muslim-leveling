#!/usr/bin/env python3
"""Batch 2 l10n: pindahkan literal Indonesia di screens/widgets ke ARB.

Dua jalur, sengaja dipisah supaya mudah diaudit:
  ITEMS   — penggantian eksak: literal utuh ada di file, ganti apa adanya.
  SPECIAL — 8 kasus yang literalnya berbeda di Dart (berplaceholder multi-baris,
            string bersambung). Ditulis eksplisit old → new, tanpa regex pintar.

Nilai ARB ditulis ke keempat locale dulu (id = sumber), lalu `arb_ai` yang
mengisi en/tr/ms — nol tulis Inggris manual.

  python3 tool/apply_batch2.py --dry   # periksa rencana
  python3 tool/apply_batch2.py         # tulis
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

ITEMS: list[tuple[str, str, str]] = [
    ('lib/screens/belajar_result.dart', 'blModulNotFound', 'Modul tidak ditemukan'),
    ('lib/screens/belajar_result.dart', 'blModulDone', 'Modul Selesai!'),
    ('lib/screens/belajar_result.dart', 'blKnowledgeUp', 'Pengetahuanmu semakin bertambah.'),
    ('lib/screens/belajar_result.dart', 'blMinScore70', 'Minimal 70% untuk lulus. Coba lagi ya!'),
    ('lib/screens/belajar_result.dart', 'blReadAgain', 'Baca lagi artikelnya, lalu coba quiz lagi. Kamu pasti bisa!'),
    ('lib/screens/belajar_result.dart', 'blBackToHub', 'Kembali ke Hub'),
    ('lib/widgets/quran_display_sheet.dart', 'qdArabicSize', 'Ukuran teks Arab'),
    ('lib/widgets/quran_display_sheet.dart', 'qdTransSize', 'Ukuran terjemahan'),
    ('lib/widgets/quran_display_sheet.dart', 'qdLatinHint', 'Bacaan latin untuk membantu membaca Arab'),
    ('lib/widgets/quran_display_sheet.dart', 'qdTajwidColors', 'Warna Tajwid'),
    ('lib/widgets/quran_display_sheet.dart', 'qdTafsirMuyassar', 'Tafsir Muyassar (ringkas, mudah dicerna)'),
    ('lib/widgets/quran_display_sheet.dart', 'qdTafsirKemenag', 'Tafsir Kemenag (lengkap)'),
    ('lib/screens/pro_paywall_screen.dart', 'ppUnlockSkins', 'Buka semua skin premium'),
    ('lib/screens/pro_paywall_screen.dart', 'ppActivateDev', 'Aktifkan Pro (dev)'),
    ('lib/screens/dapet_exp_screen.dart', 'deExpTitle', 'DAPET EXP!'),
    ('lib/screens/belajar_quiz.dart', 'bqModulNotFound', 'Modul tidak ditemukan'),
    ('lib/screens/belajar_quiz.dart', 'bqQuizUnavailable', 'Quiz belum tersedia'),
    ('lib/screens/belajar_quiz.dart', 'bqNotYetRight', 'Belum tepat'),
    ('lib/widgets/quran_player_bar.dart', 'qpPrevAyah', 'Ayat sebelumnya'),
    ('lib/widgets/quran_player_bar.dart', 'qpNextAyah', 'Ayat berikutnya'),
    ('lib/widgets/quran_player_bar.dart', 'qpMurrotalSettings', 'Setelan murrotal'),
    ('lib/widgets/quran_playback_sheet.dart', 'qpbRepeatRange', 'Ulangi rentang'),
    ('lib/widgets/quran_playback_sheet.dart', 'qpbSleepTimer', 'Tidur otomatis'),
    ('lib/widgets/quran_playback_sheet.dart', 'qpbEndOfSurah', 'Akhir surat'),
    ('lib/screens/quran_bookmarks_screen.dart', 'qbNoBookmark', 'Belum ada bookmark'),
    ('lib/screens/quran_bookmarks_screen.dart', 'qbDeleteBookmark', 'Hapus bookmark'),
    ('lib/widgets/quran_ayah_card.dart', 'qacDeleteBookmark', 'Hapus bookmark'),
    ('lib/widgets/prayer_heatmap.dart', 'phPrevMonth', 'Bulan sebelumnya'),
    ('lib/widgets/prayer_heatmap.dart', 'phNextMonth', 'Bulan berikutnya'),
    ('lib/widgets/cosmetic_locker.dart', 'clProLocked', 'Pro terkunci'),
    ('lib/widgets/cosmetic_locker.dart', 'clCompleteQuest', 'Selesaikan quest harian untuk membuka skin dari Daily Chest.'),
]

# (file, key, teks id, cuplikan Dart lama, cuplikan Dart baru)
SPECIAL: list[tuple[str, str, str, str, str]] = [
    ('lib/widgets/quran_display_sheet.dart', 'qdTajwidLegend',
     'Merah=Ghunnah, Biru=Qalqalah/Idgham, Hijau=Mad',
     """'Merah=Ghunnah, Biru=Qalqalah/Idgham, '
                        'Hijau=Mad'""",
     'AppL10n.of(context).qdTajwidLegend'),
    ('lib/screens/pro_paywall_screen.dart', 'ppProPitch',
     'Perisai, aura, dan gelar eksklusif. Gaya baru untuk avatarmu — tanpa memengaruhi XP, streak, atau peringkatmu.',
     """'Perisai, aura, dan gelar eksklusif. Gaya baru untuk avatarmu — '
                'tanpa memengaruhi XP, streak, atau peringkatmu.'""",
     'AppL10n.of(context).ppProPitch'),
    ('lib/screens/dapet_exp_screen.dart', 'deQuizDone',
     'Kamu menyelesaikan quiz {moduleTitle}!',
     "'Kamu menyelesaikan quiz \${module.title}!'",
     'AppL10n.of(context).deQuizDone(moduleTitle: module.title)'),
    ('lib/screens/dapet_exp_screen.dart', 'deLevelShort',
     'Lv {level}',
     "'Lv \${info.level}'",
     'AppL10n.of(context).deLevelShort(info.level)'),
    ('lib/screens/dapet_exp_screen.dart', 'deLevel',
     'Level {level}',
     "'Level \${info.level}'",
     'AppL10n.of(context).deLevel(info.level)'),
    ('lib/screens/belajar_quiz.dart', 'bqQuestionOf',
     'PERTANYAAN {current}/{total}',
     "'PERTANYAAN \${_current + 1}/\${_questions.length}'",
     'AppL10n.of(context).bqQuestionOf(_current + 1, _questions.length)'),
    ('lib/screens/quran_bookmarks_screen.dart', 'qbSurahName',
     'Surat {number}',
     "'Surat \${b.surah}'",
     'AppL10n.of(context).qbSurahName(b.surah)'),
    ('lib/widgets/quran_ayah_card.dart', 'qacAyahNumber',
     'Ayat {number}',
     "'Ayat \${ayah.ayah}'",
     'AppL10n.of(context).qacAyahNumber(ayah.ayah)'),
]

INT_PH = {'level', 'number', 'current', 'total'}


def add_keys() -> None:
    """Tulis semua key ke 4 ARB. Nilai = teks id; en/tr/ms diisi `arb_ai`."""
    rows = [(k, t) for _, k, t in ITEMS] + [(k, t) for _, k, t, _, _ in SPECIAL]
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
    for f, key, _text, old, new in SPECIAL:
        per_file.setdefault(f, []).append((old, new))

    for f, pairs in per_file.items():
        p = ROOT / f
        src = p.read_text()
        orig = src
        for old, new in pairs:
            found = old in src
            if not found:
                # SPECIAL menuliskan `\${x}` (escape Dart di dalam literal Python);
                # file sumber memakai `${x}` apa adanya — coba versi tanpa backslash.
                alt = old.replace('\\$', '$')
                if alt in src:
                    old, found = alt, True
            if not found:
                print(f'  !! TIDAK COCOK di {f}: {old[:60]}')
                continue
            src = src.replace(old, new)
            src = re.sub(r'const (Text|Semantics|Tooltip)\(\s*' + re.escape(new), r'\1(' + new, src)
        if src == orig:
            continue
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
        rows = [(k, t) for _, k, t in ITEMS] + [(k, t) for _, k, t, _, _ in SPECIAL]
        print(f'{len(rows)} key → {len({f for f, _, _ in ITEMS} | {f for f, _, _, _, _ in SPECIAL})} file')
        for k, t in rows:
            print(f'  {k:20s} {t[:70]}')
    else:
        add_keys()
        rewrite_dart()
