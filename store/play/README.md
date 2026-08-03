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
  mockups/              # Framed phone creatives (9:16, gitignored)
```

## Feature graphic

- Size: **1024 × 500** PNG
- Brand: teal `#00B5B2`, purple `#7856E6`, navy `#0A1334`
- Uses the real `assets/images/logo.png` (accurate mark + wordmark)
- Tagline: “Split bills. Settle fair.”
- Keep lighting subtle — avoid heavy light rays / plastic glow

## Screenshots (raw)

Captured on a physical Android device with demo data:

| File | Theme | Screen |
|------|--------|--------|
| `onboarding-light.png` | Light | First-run onboarding (**USD**) |
| `home-light.png` / `home-dark.png` | Both | Home balances + groups |
| `group-detail-light.png` / `group-detail-dark.png` | Both | Tokyo Trip — balances + **donut** |
| `group-settlements-light.png` | Light | Apartment — debts + **settlement** + expenses |
| `group-debts-dark.png` | Dark | Who owes whom |
| `settle-up-light.png` | Light | Record settlement sheet |
| `add-expense-light.png` | Light | Add expense — **Paid by** + **Split** in focus |
| `pending-summary-*.png` | Both | “You get by group” sheet |

Upload phone screenshots from `screenshots/` or the framed `mockups/` set (Play accepts either; framed mockups often convert better).

## Mockups

Framed creatives built from the real screenshots (phone UI only — no extra floating logo marks on the frame):

| File | Notes |
|------|--------|
| `mockup-onboarding.png` | Onboarding + title “No accounts. Just split.” (USD) |
| `mockup-home-light.png` | Single light home phone |
| `mockup-home-dark.png` | **Dual phones** — light + dark home (“Looks great in light and dark”) |
| `mockup-group-detail.png` | Dual — Tokyo donut + Apartment settlements (real screenshots) |
| `mockup-settle-up.png` | Settle up |
| `mockup-add-expense.png` | Paid by + Split (“Split any way you like”) |
| `mockup-pending-summary.png` | Pending summary chart (caption only, no logo badge) |

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

Demo story: **Alex** (you) + Sam, Jordan, Casey — groups Apartment, Tokyo Trip, Movie Night. Screenshots used **USD** (`--dart-define=SEED_CURRENCY=USD`); default seed currency may differ.

## Re-capture screenshots

```bash
adb shell screencap -p /sdcard/ss.png
adb pull /sdcard/ss.png store/play/screenshots/<name>.png
```

For `add-expense-light.png`, scroll so **Paid by** starts near the top and **Split** (Equal / Exact / %) is visible.

Toggle theme in Profile → Appearance (Light / Dark).
