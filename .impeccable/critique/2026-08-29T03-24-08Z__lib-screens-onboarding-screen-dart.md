---
target: first-run onboarding
total_score: 17
max_score: 36
na_heuristics: 10
p0_count: 1
p1_count: 2
p2_count: 2
p3_count: 3
timestamp: 2026-08-29T03-24-08Z
slug: lib-screens-onboarding-screen-dart
---
# Audit: First-Run Onboarding Flow
Method: dual-agent (A: sa-0-90979b76 · B: sa-1-1f0fd496)

H1 1, H2 3, H3 2, H4 3, H5 1, H6 2, H7 2, H8 2, H9 1, H10 n/a → 17/36 (Acceptable 47%)

Specificity: Generic App Store template with warrior paint. 3 emoji mascots
placeholder-tier; no live preview of XP/level loop. Could belong to any
prayer-time app. 'MEMUAT DATA PEJUANG...' on splash is the most characterful
element and it disappears in 900ms.

## Verified mechanical facts
B: detector exit 0, 0 findings (regex-only, .dart out of scope).
- HeroButton ~56px ≥ 48dp ✓
- GhostButton ~44px ⚠️ borderline
- TextButton 'Lewati' ~36px ❌ below 48dp
- Zero Semantics in onboarding + splash
- Zero text overflow (maxLines/ellipsis) on 6 Text widgets
- Font: 12px GhostButton, 14px body, 20px title, 24px HeroButton
- 3 pages (welcome→location→notification)
- Skip shown on pages 1-2, disabled on page 3 (trapped)
- _skip() calls _finish() → saves onboarding_done=true + nickname='Pejuang'
- Location failure → SnackBar, returns without crash; manual picker fallback
- Notification denied → caught silently, onboarding still completes
- Revisit path: NONE (onboarding_done permanent)
- Post-onboarding: user lands on DashboardShell with quests visible (aha bridge exists)
- Mascot: raw emoji, not brand assets

## Priority Issues
- P0: No escape from page 3 — 'Lewati' disabled on _isLast. Fix: add GhostButton
  'Lewati, nanti saja' on _page3() calling _finish(enableNotif: false). ~4 lines.
- P1: Onboarding never shows the product — no XP preview, no live demo, 43 words
  of copy where 1 animated card would do. Casey bails at page 2. Fix: replace
  _Mascot(emoji:'🛡️') on page 1 with animated mock XP card ('+50 XP Subuh ✓').
  ~20 lines (reusable from existing UnlockMoment).
- P1: 6-8 taps to first XP value — aha moment is at minimum tap 6+ after download.
  Jordan learns concepts but never sees the loop. Not fixable without
  restructuring the flow (defer location/notif to in-context prompts).
- P2: Nickname 'Pejuang' hardcoded — user never inputs it. Gendered (masculine).
  Fix: optional input field on page 1 or post-onboarding Profil prompt.
- P2: Splash 900ms no tap-to-skip — fast devices yank user mid-read. Fix:
  GestureDetector onTap: _navigate() as early-out, keep 900ms as max.
- P3: Emoji mascot (🛡️📍🔔) renders inconsistent per manufacturer, not branded.
  Fix: swap to app icon/gradient container, or SVG assets if available.
- P3: 6 Text widgets without maxLines/overflow — long city names overflow at
  text scale 1.3+. Fix: maxLines: 1 + TextOverflow.ellipsis on city + title.
- P3: Zero Semantics — TalkBack users get no labels. Fix: wrap each _PageBody
  in Semantics(container: true, label: 'Langkah 1 dari 3: Selamat Datang').

## Persona
Casey: 3 pages before dashboard → hits Lewati → arrives blind → 15-20s before
first possible XP. Patience ~10s. No 'Log Sholat' CTA visible = gone.
Jordan: reads 'quest sholat, XP, level' → has no mental model → page 2 asks
location → might think this is a GPS app. Teaches concepts, never demonstrates.

## Questions
1. What if onboarding was one screen? 'Log Subuh sekarang' with 1 tap, show XP
   popup, THEN ask location/notif in-context. Aha moment = onboarding.
2. Why does app need location before user needs the app? Location feeds jadwal
   + qiblat — neither needed to log first prayer. Defer to first tap on
   'Jadwal' tab with clear 'this is why we need it now'.
