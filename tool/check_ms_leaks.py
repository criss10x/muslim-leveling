#!/usr/bin/env python3
"""Klasifikasi: nilai Melayu (ms) yang identik dengan Indonesia — sah atau bocor?

Melayu & Indonesia berbagi banyak kosakata, jadi "identik dengan id" BUKAN
otomatis bocor. Skrip ini minta model menilai per-key (bukan menerjemah):
  ok  = kalimat itu memang Melayu yang benar
  id  = masih Indonesia, perlu diperbaiki

Dipakai sekali untuk memisahkan 2 kelas itu sebelum guard ARB ditulis.
Bukan bagian dari build.
"""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONFIG = Path.home() / '.hermes/config.yaml'


def api_key():
    import yaml
    cfg = yaml.safe_load(CONFIG.read_text())
    for p in cfg.get('custom_providers') or []:
        if p.get('name') == 'Sumopod Mimo':
            return p['api_key']
    raise SystemExit('provider Sumopod Mimo tidak ada di config')


def ask(keys, values, model='gemini/gemini-3.5-flash'):
    payload = {
        'model': model,
        'messages': [
            {'role': 'system', 'content':
             'You are a Malay (Bahasa Melayu, Malaysia) proofreader. For each '
             'string, decide whether it is CORRECT natural Malay as written, or '
             'whether it is Indonesian that a Malaysian would find foreign and '
             'would normally be written differently.\n'
             'Malay and Indonesian share much vocabulary, so identical text is '
             'often FINE (e.g. "Lihat semua", "hari", "Tidak perlu", English '
             'loanwords like "ELITE"). Judge by Malaysian usage, not by whether '
             'it differs from Indonesian.\n'
             'Reply ONLY with JSON: {"<key>": "ok" | "id"} where "id" means the '
             'text is Indonesian-only wording that needs a Malay rewrite.'},
            {'role': 'user', 'content': json.dumps(dict(zip(keys, values)),
                                                   ensure_ascii=False)},
        ],
        'temperature': 0,
    }
    r = subprocess.run(
        ['curl', '-s', '-m', '120', 'https://ai.sumopod.com/v1/chat/completions',
         '-H', f'Authorization: Bearer {api_key()}',
         '-H', 'Content-Type: application/json',
         '-d', json.dumps(payload)], capture_output=True, text=True)
    out = json.loads(r.stdout)
    txt = out['choices'][0]['message']['content']
    m = re.search(r'\{.*\}', txt, re.S)
    return json.loads(m.group(0)) if m else {}


def main():
    src = json.loads((ROOT / 'lib/l10n/app_id.arb').read_text())
    ms = json.loads((ROOT / 'lib/l10n/app_ms.arb').read_text())
    tr = json.loads((ROOT / 'lib/l10n/app_tr.arb').read_text())

    # Hanya yang identik dengan id TAPI beda di tr = kandidat (kalau tr pun
    # identik, teksnya memang tak bisa diterjemahkan: nama diri/gelar).
    suspects = [k for k, v in src.items()
                if not k.startswith('@') and isinstance(v, str)
                and ms.get(k) == v and tr.get(k) != v]
    print(f'kandidat diperiksa: {len(suspects)}', file=sys.stderr)

    leaks = {}
    for i in range(0, len(suspects), 40):
        chunk = suspects[i:i + 40]
        res = ask(chunk, [src[k] for k in chunk])
        for k in chunk:
            if res.get(k) == 'id':
                leaks[k] = src[k]
        print(f'  {min(i + 40, len(suspects))}/{len(suspects)} — '
              f'bocor sejauh ini: {len(leaks)}', file=sys.stderr)

    (ROOT / 'tool/.ms_leaks.json').write_text(
        json.dumps(leaks, ensure_ascii=False, indent=1))
    print(f'\nBOCOR: {len(leaks)} dari {len(suspects)} kandidat')
    for k, v in list(leaks.items())[:40]:
        print(f'  {k:46s} {v[:60]!r}')


if __name__ == '__main__':
    main()
