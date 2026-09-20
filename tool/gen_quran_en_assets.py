#!/usr/bin/env python3
"""Generate aset terjemahan Inggris dari alquran.cloud (sekali jalan).

Menulis `assets/quran/en/surah/<n>.json` = [{"ayah":N,"translation":"..."}].

Arab TIDAK disimpan: teks Arab sudah ada di `assets/quran/surah/<n>.json`
(edisi Uthmani yang sama). Menggandakannya hanya menambah ~2MB aset.

Jalankan: python3 tool/gen_quran_en_assets.py
"""
import json
import pathlib
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / 'assets' / 'quran' / 'en' / 'surah'
SRC = 'https://api.alquran.cloud/v1/quran/en.sahih'


def main() -> None:
    with urllib.request.urlopen(SRC, timeout=120) as r:
        data = json.load(r)
    surahs = data['data']['surahs']
    assert len(surahs) == 114, f'surah count {len(surahs)}'

    OUT.mkdir(parents=True, exist_ok=True)
    total = 0
    for s in surahs:
        n = s['number']
        rows = [
            {'ayah': a['numberInSurah'], 'translation': a['text']}
            for a in s['ayahs']
        ]
        # Nomor ayat harus 1..n berurutan — kalau tidak, aset lokal dan Inggris
        # akan bergeser satu sama lain saat di-zip.
        assert [r['ayah'] for r in rows] == list(range(1, len(rows) + 1)), n
        total += len(rows)
        (OUT / f'{n}.json').write_text(
            json.dumps(rows, ensure_ascii=False), encoding='utf-8'
        )

    assert total == 6236, f'total ayat {total}'

    # Jumlah ayat tiap surat harus sama dengan aset Arab lokal.
    for n in range(1, 115):
        local = json.loads((ROOT / 'assets/quran/surah' / f'{n}.json').read_text())
        en = json.loads((OUT / f'{n}.json').read_text())
        assert len(local) == len(en), f'surat {n}: lokal {len(local)} vs en {len(en)}'

    print(f'OK: 114 berkas, {total} ayat, cocok dengan aset lokal')


if __name__ == '__main__':
    main()
