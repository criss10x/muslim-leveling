#!/usr/bin/env python3
"""Klasifikasi sisa string hardcoded: mana yang boleh diekstrak, mana yang tidak.

Kenapa perlu: hitungan mentah "literal berbentuk prosa" mencampur 4 hal yang
sangat berbeda perlakuan:
  CHROME  — label/tombol/pesan UI        → ekstrak ke ARB (kerja mekanis)
  SACRED  — terjemahan ayat/hadis/doa    → JANGAN mesin; butuh sumber otoritatif
  DEBUG   — log, 'DEBUG: $x', stacktrace → biarkan (tak tampil ke user)
  NAME    — nama tokoh/kota/qari/tier    → biarkan (keputusan produk, bukan UI)

Dipakai sebagai burndown: `python3 tool/classify_hardcoded.py --summary`.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ARB = json.load(open(ROOT / 'lib/l10n/app_id.arb'))
LOCALIZED = {v for k, v in ARB.items() if not k.startswith('@') and isinstance(v, str)}

STR = re.compile(r"'((?:[^'\\\n]|\\.){2,})'|\"((?:[^\"\\\n]|\\.){2,})\"")
SKIP = re.compile(r'^[a-z0-9_.\-/:@#\s]+\$?$|^[a-z_]+$|^[\d\s.,:%°\-]+$|^\$\{|^\{|\}|^#|^http|^data:|^package:|^assets/|^[A-Za-z]+\(|^[A-Z_]+$')
ID_FUNC = re.compile(r'\b(dan|yang|atau|untuk|dengan|dari|tidak|sudah|akan|ini|itu|kamu|anda|bisa|adalah|pada)\b', re.I)

# teks suci: penanda khas ayat/hadis/doa (bukan daftar lengkap — deteksi isyarat)
SACRED = re.compile(
    r'\b(Allah|Tuhan|Nabi|Rasul|beriman|shalat|solat|rakaat|neraka|surga|pahala|dosa|'
    r'bertakwa|Maha|Sesungguhnya|Barangsiapa|alaihi|shallallahu|hadis|ayat|QS\.?)\b')
DEBUG = re.compile(r'DEBUG|\$e\b|\$st\b|\$error|Exception|stackTrace|trace\b|\bprint\b|\\n\s*\$')
NAMEISH = re.compile(r'^[A-Z][a-zA-Z]*( [A-Z][a-zA-Z]*){0,2}$')  # Title Case pendek = nama


def _in_comment(text: str, pos: int) -> bool:
    """True kalau posisi `pos` berada setelah `//` di barisnya.

    Tanpa ini, prosa di dalam komentar (mis. `// flash "Tidak ditemukan"`)
    terhitung sebagai teks UI — angka burndown jadi menggelembung.
    """
    start = text.rfind('\n', 0, pos) + 1
    line = text[start:pos]
    c = line.find('//')
    if c < 0:
        return False
    # kutip tak-ter-escape berjumlah genap sebelum '//' → benar komentar
    return len(re.findall(r"(?<!\\)['\"]", line[:c])) % 2 == 0


def classify(f: Path, text: str) -> list[tuple[str, int, str]]:
    out = []
    sacred_file = any(k in f.name for k in ('quran', 'hadis', 'doa', 'dzikir', 'belajar'))
    for m in STR.finditer(text):
        t = m.group(1) or m.group(2)
        if not t or not any(c.isalpha() for c in t):
            continue
        if t in LOCALIZED or SKIP.match(t.strip()) or t.startswith(('package:', 'assets/', 'http', '/')):
            continue
        if not (ID_FUNC.search(t) or (len(t.split()) >= 2 and t[0].isupper())):
            continue
        if _in_comment(text, m.start()):
            continue
        line = text[:m.start()].count('\n') + 1
        if DEBUG.search(t) or '\n' in t:
            cat = 'DEBUG'
        elif SACRED.search(t) and (sacred_file or len(t.split()) >= 6
                                   or re.search(r'\b(Allah|Sesungguhnya|Barangsiapa|Maha)\b', t)):
            cat = 'SACRED'
        elif NAMEISH.match(t.strip()):
            cat = 'NAME'
        else:
            cat = 'CHROME'
        out.append((cat, line, t))
    return out


def main() -> None:
    summary = '--summary' in sys.argv
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    files = [ROOT / only[0].removeprefix('lib/').join(('lib/', ''))] if only else sorted((ROOT / 'lib').rglob('*.dart'))
    files = [f for f in files if f.exists() and 'l10n/app_localizations' not in str(f)]
    tally: dict[str, int] = {}
    per_file: list[tuple[int, str]] = []
    chrome_dump: dict[str, list] = {}
    for f in files:
        hits = classify(f, f.read_text())
        rel = str(f.relative_to(ROOT))
        for cat, line, t in hits:
            tally[cat] = tally.get(cat, 0) + 1
            if cat == 'CHROME':
                chrome_dump.setdefault(rel, []).append((line, t))
        n = sum(1 for c, _, _ in hits if c == 'CHROME')
        if n:
            per_file.append((n, rel))
    print('=== kategori sisa ===')
    for k in ('CHROME', 'SACRED', 'NAME', 'DEBUG'):
        print(f'  {k:7s} {tally.get(k, 0)}')
    print(f'  TOTAL   {sum(tally.values())}')
    print()
    per_file.sort(reverse=True)
    if summary:
        print('=== CHROME per file (burndown) ===')
        for n, rel in per_file:
            print(f'  {n:4d}  {rel}')
        total = sum(n for n, _ in per_file)
        print(f'\n{len(per_file)} file, {total} chrome')
    else:
        for n, rel in per_file:
            print(f'##### {rel}  ({n})')
            for line, t in chrome_dump[rel]:
                print(f'  {line:5d}  {t[:100]}')
            print()


if __name__ == '__main__':
    main()
