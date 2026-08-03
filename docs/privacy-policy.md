# Privacy Policy — Muslim Leveling

**Effective date:** 4 August 2026
**App:** Muslim Leveling (`id.muslimleveling.muslim_leveling`)

Muslim Leveling ("the app") helps you track prayer times, quests, and Islamic learning progress. This policy explains what data is collected, why, and where it goes.

## 1. Data We Collect

**Location (optional, on-device only)**
Used solely to calculate prayer times for your position. Coordinates are sent over HTTPS to the public prayer-time APIs (`equran.id`, `api.myquran.com`) to fetch the schedule. Location is never stored on our servers and never shared with third parties beyond the API call itself. You can instead pick a city manually and never grant location permission.

**Google Account (optional)**
If you sign in with Google, we receive your email, name, and profile photo from Google Sign-In. This is used only to back up and sync your game/learning progress to your account. Sign-in is optional — the app works fully offline without it.

**App Progress Data**
Quest progress, XP, achievements, and learning records. Stored locally on your device. If signed in, a copy is synced to our Supabase (PostgreSQL) backend tied to your account.

**Notifications & Alarms**
Prayer reminders use local notifications and exact alarms. No data leaves the device.

**Crash Reports**
Sentry collects anonymized crash logs (device model, OS version, stack trace) to fix bugs. No personal content is included.

## 2. What We Never Do

- No ads, no ad trackers, no analytics-for-marketing.
- No selling or sharing of personal data with third parties.
- No location history or background location tracking.

## 3. Third-Party Services

- **Supabase** — account & progress sync (supabase.com/privacy)
- **Sentry** — crash reporting (sentry.io/privacy)
- **Google Sign-In** — authentication (policies.google.com/privacy)
- **eQuran.id / MyQuran.com** — prayer time calculation

## 4. Data Retention & Deletion

Progress stays on your device until you uninstall. Server-side backup exists only while your account is active. To delete your account and all server data, email us at the address below — we delete within 7 days.

## 5. Children

The app is suitable for all ages and collects no data from children beyond what is described above. Account sign-in requires the user's own Google account.

## 6. Changes

Changes to this policy are posted on this page with an updated effective date.

## 7. Contact

Email: **muslim.leveling@gmail.com**
GitHub: github.com/madekotprint/muslim-leveling-v6
