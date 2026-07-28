# Google Sign-In setup — Muslim Leveling v6 (backup online)

Kode app sudah siap. Login Google dipakai **hanya** untuk backup progress ke Supabase.

## Root cause yang sering bikin gagal

Native Google Sign-In mencocokkan **package name + SHA-1 sertifikat penanda tangan APK**
dengan OAuth Android client di Google Cloud. Kalau SHA-1 APK yang terpasang tidak
terdaftar → `ApiException: 10` (DEVELOPER_ERROR) / idToken kosong.

| Keystore | SHA-1 | Status |
|---|---|---|
| Debug lokal (`~/.android/debug.keystore`) | `A4:26:1B:D1:DF:E4:AA:AB:AE:20:C3:D9:70:5F:A1:22:18:21:EE:2C` | ✅ terdaftar |
| Release (`~/muslim-leveling-release.jks`) | `DF:2C:7E:72:5A:29:A7:1B:6F:66:FA:A6:FA:04:78:77:5B:46:F7:23` | ❌ belum |
| Debug runner GitHub | **berubah tiap build** | ❌ tidak mungkin didaftarkan |

**Jangan berasumsi APK sudah di-sign release.** `android/app/build.gradle.kts`
memakai keystore release hanya bila `android/key.properties` ada; kalau tidak, ia
jatuh ke signing config **debug**. Di runner GitHub, `debug.keystore` dibuat ulang
setiap kali sehingga SHA-1-nya acak — APK dari CI tanpa secret keystore **tidak akan
pernah** bisa native sign-in, berapa kali pun SHA didaftarkan.

Selalu baca sidik jari APK yang benar-benar kamu pasang:
```bash
apksigner verify --print-certs app-release.apk | grep -E "certificate DN|SHA-1"
```

Supaya APK CI punya SHA-1 tetap, isi 4 GitHub Secrets berikut di
**Settings → Secrets and variables → Actions**:

| Secret | Isi |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 ~/muslim-leveling-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | password keystore |
| `ANDROID_KEY_ALIAS` | `muslim-leveling` |
| `ANDROID_KEY_PASSWORD` | password key |

Workflow `flutter.yml` akan menyusun `key.properties` sendiri saat build, dan
mencetak SHA-1 hasilnya di log step **Report APK signing certificate**.

App juga **auto-fallback** ke login browser kalau native gagal — jalur itu tidak
butuh SHA-1 sama sekali.

App sekarang **auto-fallback** ke login browser (Supabase OAuth) kalau native gagal.  
Browser path **tidak** butuh Android SHA-1 — tapi butuh Web client + redirect URL di Supabase.

---

## 1) Google Cloud Console (wajib untuk native + Supabase)

Project: `muslim-leveling` (number `691907686915`)

1. **APIs & Services → Credentials**
2. Edit / buat **OAuth client ID → Android**
   - Package: `id.muslimleveling.muslim_leveling`
   - SHA-1 **debug**: `A4:26:1B:D1:DF:E4:AA:AB:AE:20:C3:D9:70:5F:A1:22:18:21:EE:2C`
   - SHA-1 **release**: `DF:2C:7E:72:5A:29:A7:1B:6F:66:FA:A6:FA:04:78:77:5B:46:F7:23`
   - Google Cloud = 1 client per SHA-1 → buat **2 Android clients** (debug + release), atau tambah SHA di Firebase.
3. Pastikan **Web application** client ada:
   - Client ID: `691907686915-2kkvt45674moh5b79uu9udj3s4k6to0s.apps.googleusercontent.com`
   - Copy **Client Secret** (untuk Supabase)
4. **OAuth consent screen** → status Testing OK (tambah test users) atau Publish.

### Cara cek SHA-1 lagi
```bash
# Debug
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android | grep SHA1

# Release (keystore production app ini)
keytool -list -v -keystore ~/muslim-leveling-release.jks \
  -alias muslim-leveling -storepass android | grep SHA1
```

---

## 2) Supabase Dashboard (wajib)

Project: `https://hiywlsqaurqvbwwuutbo.supabase.co`

### Auth → Providers → Google
- Enable
- **Client ID** = Web OAuth client di atas
- **Client Secret** = dari Google Cloud Web client

### Auth → URL Configuration
Tambah **Redirect URLs**:
```
id.muslimleveling.muslim_leveling://login-callback
```
(Site URL boleh biarkan default Supabase.)

### SQL Editor
Jalankan `supabase_rls.sql` (RLS: user hanya akses baris `device_id = auth.uid()`).

---

## 3) App code (sudah di-commit)

| File | Role |
|---|---|
| `lib/services/auth_service.dart` | Native Google → idToken → Supabase; fallback browser OAuth |
| `android/app/src/main/AndroidManifest.xml` | Deep link `id.muslimleveling.muslim_leveling://login-callback` |
| `lib/main.dart` | Supabase PKCE auth flow |
| `lib/services/supabase_sync.dart` | Backup JSON ke `user_data` keyed by auth.uid |
| `android/app/google-services.json` | Android OAuth client (debug SHA only — update setelah tambah release SHA) |

Override Web client ID saat build (opsional):
```bash
flutter build apk --release \
  --dart-define=GOOGLE_WEB_CLIENT_ID="xxxxx.apps.googleusercontent.com"
```

---

## 4) Verifikasi di device

1. Install release APK (signed release keystore).
2. Profil → **Lanjut dengan Google**.
3. Expected:
   - **Native OK** (setelah SHA release terdaftar): picker Google → login langsung.
   - **Native gagal**: browser Google terbuka → setuju → kembali ke app → snackbar backup OK.
4. Snackbar error sekarang human-readable (DEVELOPER_ERROR 10, timeout, dll).

---

## Checklist cepat

- [ ] Android OAuth client + **release SHA-1** di Google Cloud / Firebase
- [ ] Web OAuth client ID + secret di Supabase Google provider
- [ ] Redirect URL `id.muslimleveling.muslim_leveling://login-callback` di Supabase
- [ ] `supabase_rls.sql` sudah di-run
- [ ] OAuth consent: test user / published

Tanpa checklist di atas, progress **tetap aman lokal** (SharedPreferences). Login cuma unlock restore lintas device.
