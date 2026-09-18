#!/usr/bin/env python3
"""Sisipkan key ke app_id.arb / app_en.arb tanpa menulis ulang seluruh file.

Re-dump penuh (json.dumps sort_keys atas seluruh dict) akan mengacak urutan
placeholder di semua @-blok lama → diff ratusan baris tanpa perubahan makna.
Sisip baris di posisi alfabetis = diff sebesar yang benar-benar ditambah.

Pakai sebagai modul:
    from arb_insert import insert
    insert('lib/l10n/app_id.arb', {'onbFoo': 'bar'})
Nilai boleh str (satu baris) atau dict (blok @-meta, ditulis multi-baris).
"""
import json
import re

TOP = re.compile(r'^  "((?:@?)[^"]+)":')


def _render(key, value):
    name = json.dumps(key, ensure_ascii=False)
    if isinstance(value, dict):
        body = json.dumps(value, ensure_ascii=False, indent=2)
        body = '\n'.join('  ' + line for line in body.split('\n'))
        return f'  {name}: {body.lstrip()},'
    return f'  {name}: {json.dumps(value, ensure_ascii=False)},'


def insert(path, adds):
    lines = open(path, encoding='utf-8').read().split('\n')
    existing = {m.group(1) for l in lines if (m := TOP.match(l))}
    for key in sorted(adds):
        # Menyisipkan key yang sudah ada menghasilkan JSON valid dengan
        # key ganda — nilai terakhir menang tanpa error, jadi bug ini
        # diam-diam sampai ada yang membaca diff-nya.
        if key in existing:
            raise SystemExit(f'{path}: key "{key}" sudah ada — dibatalkan')
        text = _render(key, adds[key])
        at = None
        for i, line in enumerate(lines):
            m = TOP.match(line)
            if m and m.group(1) > key:
                at = i
                break
        if at is None:
            # Simpan di akhir: baris key terakhir perlu koma dulu.
            last = max(i for i, l in enumerate(lines) if TOP.match(l))
            if not lines[last].rstrip().endswith(','):
                lines[last] = lines[last].rstrip() + ','
            at = last + 1
        lines.insert(at, text)
    open(path, 'w', encoding='utf-8').write('\n'.join(lines))
