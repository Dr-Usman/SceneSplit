# Play Store assets

Marketing assets for [SceneSplit on Google Play](https://play.google.com/store/apps/details?id=com.avenzor.scenesplit).

`screenshots/`, `mockups/`, and `feature-graphic.png` are **gitignored** (large binaries). Keep them locally for Play Console uploads. This README is tracked in git.

GitHub README gallery uses compressed copies under [`docs/screenshots/`](../../docs/screenshots/).

## Layout

```
store/play/
  README.md             # This file (in git)
  feature-graphic.png   # 1024 × 500 (gitignored; local / Play Console)
  screenshots/          # Raw device captures (~1080 × 2400, gitignored)
  mockups/              # Framed phone creatives (1024 × 1536, gitignored)
```

## Feature graphic

- Size: **1024 × 500** PNG
- Brand: teal `#00B5B2`, purple `#7856E6`, navy `#0A1334`
- Uses the real `assets/images/logo.png` (accurate mark + wordmark)
- Tagline: “Split bills. Settle fair.”
- Keep lighting subtle — avoid heavy light rays / plastic glow

## Screenshots (raw)

Captured on Android with demo data (emulator or device). Prefer **user-facing overview screens** for the store listing — not create-flow sheets (new scene, add expense, record settlement).

| File | Theme | Screen |
|------|--------|--------|
| `onboarding-light.png` | Light | First-run onboarding |
| `home-light.png` / `home-dark.png` | Both | Scenes tab + bottom nav (AppBar +) |
| `balances-light.png` / `balances-dark.png` | Both | Balances hero + pair cards |
| `balances-filter-light.png` | Light | Who → Whom filter sheet |
| `pair-balance-light.png` | Light | Pair drill-down (per-scene totals) |
| `group-detail-light.png` / `group-detail-dark.png` | Both | Scene detail (breakdown + members) |
| `person-detail-light.png` | Light | Person totals (total debt / total credit) |

Upload phone screenshots from `screenshots/` or the framed `mockups/` set (Play accepts either; framed mockups often convert better).

## Mockups

Framed creatives built from real screenshots (phone UI only — no extra floating logo marks on the frame):

| File | Notes |
|------|--------|
| `mockup-balances.png` | Balances tab — “See who owes whom across scenes” |
| `mockup-home-light.png` | Single light Scenes home + bottom nav |
| `mockup-home-dark.png` | Equal dual — dark + light Scenes home side-by-side (“Looks great in light and dark”) |
| `mockup-pair-balance.png` | Pair drill-down across scenes |
| `mockup-scene-person.png` | Dual — scene detail + person detail |
| `mockup-onboarding.png` | Onboarding (“No accounts. Just split.”) |

### Play Store phone screenshot order

Upload the framed mockups in this order (phone listing, first image is the cover):

1. `mockup-balances.png` — headline: cross-scene who owes whom
2. `mockup-home-light.png` — Scenes home at a glance
3. `mockup-home-dark.png` — light + dark Scenes home
4. `mockup-pair-balance.png` — pair drill-down across scenes
5. `mockup-scene-person.png` — scene detail + person totals
6. `mockup-onboarding.png` — no accounts / first-run

If you upload raw captures instead, use the same story order: Balances → Home (light) → Home (dark) → pair balance → scene detail → person detail → onboarding.

## Re-seed demo data

Debug builds only (or any build with the define):

```bash
# Auto-seed on launch when the DB has no groups
flutter run --dart-define=SEED_DEMO=true

# Or: Profile → Developer → Load demo data (debug builds)
```

Wipe app data first if groups already exist:

```bash
adb shell pm clear com.avenzor.scenesplit
```

Demo story: **Alex** (you) + Sam, Jordan, Casey — scenes Apartment, Tokyo Trip, Movie Night.

## Re-capture screenshots

```bash
adb shell screencap -p /sdcard/ss.png
adb pull /sdcard/ss.png store/play/screenshots/<name>.png
```

Priority shots: Scenes home, Balances (list + filter), pair drill-down, scene detail, person detail — light and dark where useful.

Toggle theme in Profile → Appearance (Light / Dark).
