# Play Store Security Documentation
**App:** Muslim Leveling  v1.0.0+1  
**Bundle ID:** id.muslimleveling.muslim_leveling

---

## Data Collection & Privacy

### What we collect
- **Error reports:** Sentry (anonymous) — device model, OS version, Flutter version, stack trace *only*. No user data.
- **Usage analytics:** None. App tidak mengirim telemetry ke server.

### What we DON'T collect
- Personal identifiable information (nama, email, phone number, etc.)
- Location data di-upload ke server
- User behavior tracking

### Storage
- All data (profil pengguna, quest log, statistik) disimpan lokal saja (SQLite `SharedPreferences`).
- Online backup via Google Sign-In → Supabase (opsional): user login = sync profil ke cloud, tapi tidak wajib.

---

## Permissions Explained

| Permission | Purpose | Required? | User Impact |
|------------|---------|-----------|-------------|
| `INTERNET` | Download Quran mp3 streaming, auth to Supabase (jika online backup aktif), error reporting (Sentry) | ✅ Wajib | Normal app behavior |
| `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | Auto-deteksi kota user untuk jadwal sholat — query Equran API berdasarkan koordinat GPS | ❌ Opsional | User bisa pilih kota manual via dropdown tanpa GPS |
| `POST_NOTIFICATIONS` | Notifikasi jadwal sholat & reminder mutawatil | ✅ Wajib (Android 13+) | Notifikasi sistem standar |
| `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM` | Memastikan notifikasi sholat tepat waktu meski app background/die | ✅ Wajib (Android 12+) | Exact alarm sejak Android 12 perlu runtime permission request (handled oleh library) |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Pengecualian baterai optimization di Xiaomi/Oppo/Vivo agar notifikasi tetap jalan saat app ditutup | ❌ Opsional | Permintaan polite; user bisa deny tanpa break app |
| `RECEIVE_BOOT_COMPLETED` | Auto-start alarm service setelah device reboot | ✅ Wajib | Background service minimal |
| `WAKE_LOCK` | Prevent layar mati saat memutar mutawatil audio | ✅ Context-bound | Hanya aktif saat playback |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Audio player foreground service (layar bisa off tapi audio tetap play) | ✅ Wajib | Status bar icon kecil "music" saat playback |
| `VIBRATE` | Haptic feedback pada quest completion / streak bonus | ❌ Minimal | Non-intrusive |

### Cleartext Traffic (`usesCleartextTraffic="true"`)
- **Status:** Saat ini aktif karena URL Quran mp3 HTTP fallback.
- **Roadmap:** Semua endpoint sudah support HTTPS (`https://cdn.quran.chat/audio/` dan `json.quran.com`). Update akan hapus flag ini dalam release berikutnya.
- **Play Store note:** Flag ini sementara; aplikasi utama tidak bergantung pada HTTP connection.

---

## Safety & Privacy Summary

- **No third-party ads.**
- **No in-app purchases** (semua fitur gratis).
- **Data portability:** User export profil manual via Share Sheet (file JSON).
- **Deletion:** Reset app data via Settings → Clear data menghapus semua. Tidak ada backdoor deletion API.

---

## Submit Checklist

- [x] Target SDK 36 (per kebijakan Play Store 31 Agustus 2026)
- [x] Release signing (keystore `CN=Muslim Leveling`)
- [ ] Screenshots: 2 screenshot (Home & Jadwal tab) + app icon
- [ ] Description: Bahasa Indonesia & Inggris (copy-paste dari README)
- [ ] Content rating: Family → Children (no violence, no sexual content, education only)
- [ ] Age restriction: None (all ages welcome)

---

## Contact

For privacy questions: https://github.com/criss10x/muslim-leveling-v6/issues/new
