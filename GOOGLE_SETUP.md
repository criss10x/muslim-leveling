# Google Sign-In setup — Firebase

Alur login app:

```text
Google native popup → Firebase Auth → Firestore user_data/{firebaseUid}
```

## Firebase project

- Project: `muslim-leveling`
- Package: `id.muslimleveling.muslim_leveling`
- Console: https://console.firebase.google.com/project/muslim-leveling/settings/general/android

Aktifkan **Authentication → Sign-in method → Google**.

`android/app/google-services.json` dan `lib/services/auth_service.dart` harus memakai Web OAuth client yang sama:

```text
691907686915-ljhu8cc4uvjuggd093fv5bl7dvk6joil.apps.googleusercontent.com
```

## SHA-1 Android

Daftarkan kedua SHA-1 pada Firebase Console → Project Settings → Your apps → Android app:

| Keystore | SHA-1 |
|---|---|
| Debug lokal | `A4:26:1B:D1:DF:E4:AA:AB:AE:20:C3:D9:70:5F:A1:22:18:21:EE:2C` |
| Release | `DF:2C:7E:72:5A:29:A7:1B:6F:66:FA:A6:FA:04:78:77:5B:46:F7:23` |
| Play App Signing | `71:43:87:B5:51:78:B5:63:64:10:1C:A4:A1:E1:54:50:E2:CD:17:E8` |
| Play Post-Quantum (hybrid aktif) | `37:28:4F:19:CD:C3:85:A0:38:A8:08:52:4F:B0:EE:52:30:F2:F8:D5` |

APK yang ditandatangani dengan SHA-1 yang belum terdaftar akan gagal dengan `DEVELOPER_ERROR` (Code 10).

Untuk APK dari Play Store, tambahkan juga SHA-1 dari **Play App Signing certificate**.

## Build

Debug:

```bash
flutter build apk --debug
```

Release membutuhkan `android/key.properties` dan keystore `muslim-leveling-release.jks`:

```bash
flutter build apk --release --split-per-abi
```

Release build sengaja gagal jika keystore tidak tersedia; debug build tetap boleh tanpa release keystore.

## Firestore

Deploy rules dari `firestore.rules`:

```bash
firebase deploy --only firestore:rules
```

Rule hanya mengizinkan user membaca/menulis dokumen dengan ID yang sama dengan Firebase Auth UID.
