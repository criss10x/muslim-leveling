#!/usr/bin/env python3
"""Inventaris string UI yang BELUM dilokalisasi (hardcoded di Dart).

Bukan sekadar grep: string literal Dart dipisahkan jadi
  UI      -> kandidat untuk ARB (ada spasi/huruf besar/akhiran kalimat)
  CODE    -> identifier, key prefs, nama paket, path, format, regex (JANGAN disentuh)

Pemakaian:
    python3 tool/scan_hardcoded.py              # ringkasan per file
    python3 tool/scan_hardcoded.py --detail lib/screens/doa_screen.dart
    python3 tool/scan_hardcoded.py --json       # untuk diproses script lain
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# File yang memang sudah dilokalisasi / bukan UI.
SKIP = {
    'lib/l10n/', 'lib/theme/', 'test/', 'tool/', 'lib/main.dart',
}

# Pola yang menandakan literal itu KODE, bukan copy untuk user.
CODE_PATTERNS = [
    re.compile(r'^[a-z0-9_]+$'),                 # snake_case: 'subuh', 'quest_zikir_33'
    re.compile(r'^[a-z][a-zA-Z0-9]*$'),          # camelCase: 'male', 'hadis5'
    re.compile(r'^[A-Za-z_][A-Za-z0-9_]*\.[a-z]+$'),  # 'app_en.arb', 'lib/main.dart'
    re.compile(r'^[\w./-]+\.(dart|arb|png|json|wav|mp3|ttf|svg)$'),
    re.compile(r'^https?://'),
    re.compile(r'^(package:|dart:)'),
    re.compile(r'^[#%]?[0-9A-Fa-f]{6,8}$'),      # warna hex
    re.compile(r'^[A-Za-z]+/[A-Za-z0-9/*._-]+$'),  # 'application/json'
    re.compile(r'^[A-Z]{2,}$'),                   # KONSTANTA
    re.compile(r'^[a-z]+[A-Z][A-Za-z]*$'),        # camelCase multi
    re.compile(r'^[\d:.,/\s%+-]+$'),              # angka/format
    re.compile(r'^(assets|images|fonts)/'),
    re.compile(r'^\{.*\}$'),                      # '{n}/{target}'
    re.compile(r'^[A-Za-z0-9_-]+@[A-Za-z]'),      # email/domain
    re.compile(r'^[a-z0-9_]+(,[a-z0-9_]+)+$'),    # daftar key
]

# Kata Indonesia yang kuat → hampir pasti copy untuk user.
ID_HINT = re.compile(
    r'\b(sholat|subuh|dzuhur|ashar|maghrib|isya|zikir|dzikir|quran|hadis|ayat|'
    r'halaman|hari|baca|klaim|selesai|tuntas|lanjut|kembali|naik|level|gelar|'
    r'bonus|rawatib|dhuha|jamaah|malam|waktu|semua|semoga|terus|bisa|tidak|'
    r'nggak|kamu|aku|kita|dan|atau|untuk|dengan|dari|yang|akan|sudah|belum|'
    r'sedang|lagi|sini|itu|ini|buka|tutup|simpan|hapus|ubah|pilih|cari|lihat|'
    r'aturan|tentang|tujuan|bantuan|kesalahan|berhasil|gagal|mohon|silakan|'
    r'wajib|sunnah|puasa|sedekah|doa|surat|juz|tafsir|terjemah|arti)\b',
    re.I)


def is_code(lit: str) -> bool:
    return any(p.match(lit) for p in CODE_PATTERNS)


def is_ui(lit: str) -> bool:
    if len(lit) < 2:
        return False
    if is_code(lit):
        return False
    if ID_HINT.search(lit):
        return True
    # kalimat: ada spasi + huruf kecil, atau ada tanda baca akhir
    return (' ' in lit and re.search(r'[a-z]', lit) is not None)


def scan(path: Path):
    src = path.read_text()
    out = []
    # buang komentar dulu supaya // dan /// tidak ikut terbaca
    cleaned = re.sub(r'//[^\n]*', '', src)
    for m in re.finditer(r"r?'((?:[^'\\\n]|\\.)*)'", cleaned):
        lit = m.group(1).replace("\\'", "'")
        if is_ui(lit):
            line = cleaned[:m.start()].count('\n') + 1
            out.append((line, lit))
    return out


def targets():
    files = []
    for d in ('lib/screens', 'lib/widgets', 'lib/services'):
        for p in sorted((ROOT / d).glob('*.dart')):
            rel = str(p.relative_to(ROOT))
            if any(rel.startswith(s) for s in SKIP):
                continue
            files.append(p)
    return files


def main():
    detail = sys.argv[2] if len(sys.argv) > 2 and sys.argv[1] == '--detail' else None
    as_json = '--json' in sys.argv

    files = [ROOT / detail] if detail else targets()
    rows = []
    for p in files:
        hits = scan(p)
        rel = str(p.relative_to(ROOT))
        l10n_uses = len(re.findall(r'\bAppL10n\b|\bl10n\.', p.read_text()))
        rows.append({'file': rel, 'strings': len(hits), 'l10n_uses': l10n_uses,
                     'items': [{'line': l, 'text': t} for l, t in hits]})

    if as_json:
        print(json.dumps(rows, indent=1, ensure_ascii=False))
        return

    if detail:
        r = rows[0]
        print(f"{r['file']}  ({r['strings']} string UI, {r['l10n_uses']} pemakaian l10n)")
        for it in r['items']:
            s = it['text'] if len(it['text']) <= 92 else it['text'][:89] + '...'
            print(f"  {it['line']:5d}  {s}")
        return

    tot = sum(r['strings'] for r in rows)
    zero = [r for r in rows if r['l10n_uses'] == 0 and r['strings'] > 0]
    print(f"{'file':46s} {'UI':>4}  l10n")
    for r in sorted(rows, key=lambda x: -x['strings']):
        if r['strings'] == 0:
            continue
        flag = ' <-- 0 l10n' if r['l10n_uses'] == 0 else ''
        print(f"{r['file']:46s} {r['strings']:4d}  {r['l10n_uses']:4d}{flag}")
    print(f"\nTOTAL string UI: {tot}")
    print(f"file tanpa l10n sama sekali: {len(zero)} "
          f"({sum(r['strings'] for r in zero)} string)")


if __name__ == '__main__':
    main()
