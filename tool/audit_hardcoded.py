#!/usr/bin/env python3
"""Audit string UI yang masih hardcoded (belum lewat ARB).

Hanya melaporkan literal yang benar-benar tampil ke pengguna: argumen pertama
Text(...), label/hint/title pada widget Material, dan pesan SnackBar. Bukan
setiap literal Dart — nama key, route, json field, pesan debug bukan target.

Pakai:  python3 tool/audit_hardcoded.py            # ringkasan per file
        python3 tool/audit_hardcoded.py --file lib/screens/jadwal_tab.dart
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / 'lib'

# Argumen yang PASTI tampil ke pengguna.
UI_ARGS = [
    r'Text\(\s*', r'Text\.rich\(', r'SelectableText\(\s*', r'Tooltip\(message:\s*',
    r'SnackBar\(content:\s*Text\(\s*', r'label:\s*Text\(\s*', r'title:\s*',
    r'labelText:\s*', r'hintText:\s*', r'helperText:\s*', r'errorText:\s*',
    r'labelLarge:\s*', r'semanticsLabel:\s*', r'tooltip:\s*',
    r'AppBar\(title:\s*Text\(\s*', r'content:\s*Text\(\s*',
]

# Lokasi yang BLOCKING kalau dinamis: label: 'xxx' pada BottomNavigationBarItem,
# NavigationDestination, Tab, PopupMenuItem, dsb.
NAMED = [
    r"label:\s*'", r"title:\s*'", r"Text\(\s*'", r'Text\(\s*"',
    r"hintText:\s*'", r"labelText:\s*'", r"tooltip:\s*'",
    r"semanticsLabel:\s*'",
]

PAT = re.compile('|'.join(f'(?:{p})' for p in NAMED))
STR = re.compile(r"'((?:[^'\\\n]|\\.){2,})'|\"((?:[^\"\\\n]|\\.){2,})\"")

SKIP_DIRS = {'l10n', 'generated'}
SKIP_SUFFIX = ('.g.dart', '.freezed.dart', '.gr.dart')


def is_user_facing(text: str) -> bool:
    """Saring literal yang jelas bukan teks UI."""
    t = text.strip()
    if not t or len(t) < 2:
        return False
    # tanpa huruf sama sekali → key/id/format
    if not re.search(r'[A-Za-zÀ-ÿ]', t):
        return False
    # identifier / snake_case / kebab / route / nama paket
    if re.fullmatch(r'[a-z0-9_\-./:]+', t):
        return False
    # warna, format tanggal, satuan
    if re.fullmatch(r'[#%0-9a-zA-Z:.\-+\s/]*', t):
        return False
    # kode murni
    if re.fullmatch(r'[A-Z_]{2,}', t):
        return False
    # sumber daya / path
    if t.startswith(('assets/', 'http', 'package:', 'lib/')):
        return False
    # json/route/konstanta kunci
    if t.startswith(('$', '{{')) or t.endswith('.json'):
        return False
    if re.fullmatch(r'[a-z]+([A-Z][a-zA-Z]*)+', t):  # camelCase
        return False
    # kalimat asli: ada spasi ATAU ada huruf besar di awal & 2+ huruf
    return bool(re.search(r'\s', t)) or bool(re.fullmatch(r'[A-ZÀ-Ý][\w\'\-]{2,}', t))


def scan(path: Path):
    src = path.read_text(encoding='utf-8')
    out = []
    for m in PAT.finditer(src):
        seg = src[m.end() - 1:m.end() + 400]
        sm = STR.match(src[m.end() - 1:]) if False else STR.match(src[m.end() - 1:])
        if not sm:
            continue
        lit = sm.group(1) or sm.group(2)
        if not is_user_facing(lit):
            continue
        line = src[:m.start()].count('\n') + 1
        out.append((line, lit))
    # dedupe per (line, text)
    seen, uniq = set(), []
    for ln, t in out:
        if (ln, t) in seen:
            continue
        seen.add((ln, t))
        uniq.append((ln, t))
    return uniq


def main():
    only = None
    if '--file' in sys.argv:
        only = sys.argv[sys.argv.index('--file') + 1]

    files = []
    for p in sorted(LIB.rglob('*.dart')):
        if any(d in p.parts for d in SKIP_DIRS):
            continue
        if p.name.endswith(SKIP_SUFFIX):
            continue
        files.append(p)

    total = 0
    rows = []
    for p in files:
        if only and not str(p.relative_to(ROOT)).endswith(only):
            continue
        hits = scan(p)
        if hits:
            rel = str(p.relative_to(ROOT))
            rows.append((len(hits), rel, hits))
            total += len(hits)

    rows.sort(reverse=True)
    print(f'{"file":58s} {"jml":>4s}')
    for n, rel, _ in rows:
        print(f'{rel:58s} {n:>4d}')
    print(f'\nTOTAL: {total} string di {len(rows)} file')

    if only:
        for n, rel, hits in rows:
            print(f'\n=== {rel} ===')
            for ln, t in hits:
                print(f'  {ln:>5d}  {t[:90]}')


if __name__ == '__main__':
    main()
