# Google Sign-In di Hero Card Profil — Plan

**Goal:** Tambah tombol "Lanjut dengan Google" di hero card profil tab. Fresh auth_service, bukan restore yang lama.

**Context:** Branch `codex/remove-google-signin` — auth sudah dihapus. Hero card ada di `_hero()` method, line ~915-1220 di profil_tab.dart. CloudSync masih ada (dead code tanpa auth).

## Tasks

### 1. Re-add deps
- `pubspec.yaml`: add `firebase_auth: ^6.0.0`, `google_sign_in: ^6.2.1`
- `flutter pub get`

### 2. Re-generate firebase_options.dart
- `flutterfire configure --project=muslim-leveling --yes`
- Butuh Firebase project access — cek `firebase apps:list`

### 3. New auth_service.dart (fresh)
- Minimal: `init()`, `signInWithGoogle()`, `signOut()`, `userId`, `isSignedIn`, `lastError`
- Firebase Auth + Google Sign-In native flow
- Sentry captureException on error
- CloudSync.initWithUser on sign-in, CloudSync.clearUser on sign-out
- Error mapping per error-mapping.md

### 4. Hero card button
- Di `_hero()`, setelah mini stats row, tambah `if (!AuthService.isSignedIn)` FilledButton "Lanjut dengan Google"
- Atau kalau sudah sign-in: "Backup aktif" + tombol logout kecil
- `_handleGoogleLogin()` di _ProfilTabState — signInWithGoogle → _completeLogin (merge cloud) → snackbar

### 5. Merge cloud setelah login
- CloudSync.initWithUser(uid) → load remote → merge local/remote (pakai backup_merge.dart yang masih ada) → save merged → push to cloud

### 6. Verify
- `flutter analyze lib/` clean
- Build APK test di device

### 7. Commit & push ke branch baru

## Risks
- `flutterfire configure` butuh auth token — kalau gagal, copy firebase_options.dart dari git history (`git show codex/release-v1.0.0-16:lib/firebase_options.dart`)
- Google Sign-In butuh SHA-1 — sudah ada di Firebase Console dari setup sebelumnya
