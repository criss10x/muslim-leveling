// Generator aset Quran. Jalankan manual saat data perlu diperbarui:
//   node tool/fetch_quran.mjs
// Outputnya di-commit ke repo agar build tidak butuh jaringan.
import { writeFile, mkdir, readFile } from 'node:fs/promises';

const META_URL = 'https://equran.id/api/v2/surat';
const ayahUrl = (n) =>
  `https://api.alquran.cloud/v1/surah/${n}/editions/quran-uthmani,id.indonesian`;

// Teks Arab dari alquran.cloud kadang diawali BOM (U+FEFF). Kalau lolos, ia
// tampil sebagai glyph liar di awal ayat.
const clean = (s) => s.replace(/﻿/g, '').trim();

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// alquran.cloud membatasi laju permintaan dan menjawab 429 bila terlalu cepat.
// Mundur bertahap lalu coba lagi, karena unduhan 114 surat tidak layak diulang
// dari awal hanya karena satu penolakan sementara.
async function getJson(url, attempt = 1) {
  const res = await fetch(url);
  if (res.status === 429 || res.status >= 500) {
    if (attempt > 6) throw new Error(`HTTP ${res.status} menetap untuk ${url}`);
    const wait = 2000 * attempt;
    console.log(`  HTTP ${res.status}, tunggu ${wait / 1000}s lalu ulangi...`);
    await sleep(wait);
    return getJson(url, attempt + 1);
  }
  if (!res.ok) throw new Error(`HTTP ${res.status} untuk ${url}`);
  return res.json();
}

// Melanjutkan unduhan yang terputus tanpa mengulang surat yang sudah utuh.
async function alreadyComplete(path, expectedCount) {
  try {
    const list = JSON.parse(await readFile(path, 'utf8'));
    return Array.isArray(list) && list.length === expectedCount;
  } catch {
    return false;
  }
}

const write = (path, data) =>
  writeFile(path, JSON.stringify(data, null, 2), 'utf8');

async function main() {
  await mkdir('assets/quran/surah', { recursive: true });

  // ── Metadata (satu permintaan untuk 114 surat) ──
  console.log('Mengambil metadata surat...');
  const meta = await getJson(META_URL);
  if (meta.data.length !== 114) {
    throw new Error(`Metadata tidak lengkap: ${meta.data.length} surat`);
  }

  const surahs = meta.data.map((s) => ({
    number: s.nomor,
    nameArabic: s.nama,
    nameLatin: s.namaLatin,
    meaning: s.arti,
    ayahCount: s.jumlahAyat,
    // equran.id memakai "Mekah"/"Madinah"; UI memakai istilah klasik.
    revelation: s.tempatTurun === 'Mekah' ? 'Makkiyah' : 'Madaniyah',
  }));

  await write('assets/quran/surahs.json', surahs);

  // ── Ayat, satu berkas per surat ──
  for (let n = 1; n <= 114; n++) {
    const path = `assets/quran/surah/${n}.json`;
    if (await alreadyComplete(path, surahs[n - 1].ayahCount)) {
      console.log(`Surat ${n} sudah ada, dilewati`);
      continue;
    }

    const data = await getJson(ayahUrl(n));
    const [arabicEd, indoEd] = data.data;
    const arabic = arabicEd.ayahs;
    const indo = indoEd.ayahs;

    if (arabic.length !== indo.length) {
      throw new Error(`Surat ${n}: jumlah ayat Arab dan terjemahan tidak sama`);
    }

    const ayahs = arabic.map((a, i) => ({
      ayah: a.numberInSurah,
      arabic: clean(a.text),
      translation: clean(indo[i].text),
    }));

    await write(path, ayahs);
    console.log(`Surat ${n} selesai (${ayahs.length} ayat)`);
    // Jeda kecil antar permintaan agar tidak memicu 429 sejak awal.
    await sleep(400);
  }

  console.log('Selesai. 114 surat tertulis ke assets/quran/');
}

main().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
