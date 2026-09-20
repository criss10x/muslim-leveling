#!/usr/bin/env python3
"""Batch 4 l10n: pesan dari services (tanpa BuildContext).

Pola repo (lihat GameService.sunnahHint): service menerima `AppL10n l10n`
sebagai parameter, bukan mencari context sendiri. Ikut itu.

Pemakaian: python3 tool/apply_batch4.py
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

ITEMS = [
    # ── prayer_service: pesan kegagalan lokasi (ditampilkan di layar) ──
    ('lib/services/prayer_service.dart', 'locFailureDisabled',
     'Aktifkan layanan lokasi perangkat, lalu coba lagi.'),
    ('lib/services/prayer_service.dart', 'locFailureDenied',
     'Izinkan akses lokasi untuk menggunakan lokasi saat ini.'),
    ('lib/services/prayer_service.dart', 'locFailureDeniedForever',
     'Izin lokasi diblokir. Buka Pengaturan untuk mengizinkannya.'),
    ('lib/services/prayer_service.dart', 'locFailureTimeout',
     'Lokasi terlalu lama ditemukan. Coba lagi di area terbuka.'),
    ('lib/services/prayer_service.dart', 'locFailureLookup',
     'Kota tidak dapat ditemukan. Periksa koneksi atau pilih kota manual.'),
    # ── auth_service: pesan galat login ──
    ('lib/services/auth_service.dart', 'authNoIdToken',
     'Google tidak kirim idToken. Cek SHA-1 di Firebase Console.'),
    ('lib/services/auth_service.dart', 'authEmptyUser', 'Firebase Auth gagal — user kosong.'),
    ('lib/services/auth_service.dart', 'authDevError10',
     'Google DEVELOPER_ERROR (10): SHA-1 belum terdaftar di Firebase Console.'),
    ('lib/services/auth_service.dart', 'authMisconfigured',
     'Google Sign-In misconfigured. Cek OAuth consent + SHA-1.'),
    ('lib/services/auth_service.dart', 'authNetworkError', 'Jaringan error saat login Google.'),
    ('lib/services/auth_service.dart', 'authCredInvalid',
     'Firebase Auth gagal validasi credential.'),
    ('lib/services/auth_service.dart', 'authNotEnabled',
     'Google Sign-In belum diaktifkan di Firebase Console.'),
    ('lib/services/auth_service.dart', 'authEmailInUse',
     'Email sudah terdaftar dengan metode lain.'),
    # ── cloud_sync ──
    ('lib/services/cloud_sync.dart', 'csSyncFailed', 'Sinkronisasi gagal.'),
    ('lib/services/cloud_sync.dart', 'csOffline', 'Tidak ada koneksi. Data tersimpan lokal.'),
]

# (file, key, teks id, cuplikan lama, cuplikan baru)
SPECIAL = [
    ('lib/services/notification_service.dart', 'notifModeFokus',
     'Mode Fokus aktif! Pengingat hanya saat masuk waktu adzan.',
     "'fokus' => 'Mode Fokus aktif! Pengingat hanya saat masuk waktu adzan.',",
     "'fokus' => l10n.notifModeFokus,"),
    ('lib/services/notification_service.dart', 'notifModeSeimbang',
     'Mode Seimbang aktif! Pengingat semua sholat wajib 15 menit sebelum adzan.',
     "'seimbang' => 'Mode Seimbang aktif! Pengingat semua sholat wajib 15 menit sebelum adzan.',",
     "'seimbang' => l10n.notifModeSeimbang,"),
    ('lib/services/notification_service.dart', 'notifModeIntensif',
     'Mode Intensif aktif! Diingetin 30 menit & 5 menit sebelum sholat. Pertahanin streak! 🔥',
     "'intensif' => 'Mode Intensif aktif! Diingetin 30 menit & 5 menit sebelum sholat. Pertahanin streak! 🔥',",
     "'intensif' => l10n.notifModeIntensif,"),
    ('lib/services/notification_service.dart', 'notifReady',
     'Notifikasi Muslim Leveling siap! 🔔',
     "_ => 'Notifikasi Muslim Leveling siap! 🔔',",
     '_ => l10n.notifReady,'),
    ('lib/services/notification_service.dart', 'notifTestBody',
     'Kalau adzan terdengar, notifikasi kamu siap! Kalau tidak, cek volume alarm HP.',
     "'Kalau adzan terdengar, notifikasi kamu siap! Kalau tidak, cek volume alarm HP.',",
     'l10n.notifTestBody,'),
    ('lib/services/notification_service.dart', 'notifTestTitle',
     '🕌 Tes Suara Adzan',
     "'🕌 Tes Suara Adzan',", 'l10n.notifTestTitle,'),
    ('lib/services/notification_service.dart', 'notifChannelReminder',
     'Notifikasi pengingat waktu sholat',
     "static const _channelDesc = 'Notifikasi pengingat waktu sholat';",
     "// ponytail: nama channel Android dibekukan saat dibuat; dilokalkan di UI, bukan di sini.\n  static const _channelDesc = 'Notifikasi pengingat waktu sholat';"),
]

INT_PH = {'level', 'number', 'days'}


def add_keys():
    rows = [(k, t) for _, k, t in ITEMS] + [(k, t) for _, k, t, _, _ in SPECIAL]
    for loc in ('id', 'en', 'tr', 'ms'):
        p = ROOT / f'lib/l10n/app_{loc}.arb'
        d = json.loads(p.read_text())
        n = 0
        for key, text in rows:
            if key in d:
                continue
            d[key] = text
            ph = re.findall(r'\{(\w+)\}', text)
            if ph:
                d[f'@{key}'] = {'placeholders': {
                    x: ({'type': 'int'} if x in INT_PH else {'type': 'String'}) for x in ph}}
            n += 1
        p.write_text(json.dumps(d, indent=2, ensure_ascii=False) + '\n')
        print(f'ARB {loc}: +{n}')


if __name__ == '__main__':
    add_keys()
