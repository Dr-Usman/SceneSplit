# Contributing

Thanks for helping improve SceneSplit. This guide covers local checks, CI, and how releases are published.

## Development checks

Before opening a PR, run the same checks CI runs:

```bash
dart format .
flutter analyze --fatal-infos
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code lib/database/app_database.g.dart
flutter test
```

One-liner (except the codegen diff check):

```bash
dart format . && flutter analyze --fatal-infos && flutter test
```

Re-run `build_runner` only after changes to `lib/database/tables.dart` or `@DriftDatabase` annotations. See [`AGENTS.md`](AGENTS.md) for architecture and coding conventions.

## CI/CD

GitHub Actions workflows live in [`.github/workflows/`](.github/workflows/).

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | PR to `main` | Format check, analyze, Drift codegen check, tests |
| `release-android.yml` | Tag `v*` | Signed split APKs attached to GitHub Release |
| `release-ios.yml` | Tag `v*` (disabled) | Signed IPA — enable after iOS secrets are configured |
| `release-macos.yml` | Tag `v*` | macOS `.app` zip |
| `release-web.yml` | Tag `v*` | Web bundle zip |
| `release-linux.yml` | Tag `v*` | Linux x64 tar.gz |
| `release-windows.yml` | Tag `v*` | Windows x64 zip |

## Releasing

### Pre-release checklist

Run the [development checks](#development-checks) above and fix any failures before bumping the version.

### Release steps

1. Complete the pre-release checklist.
2. Bump `version` in `pubspec.yaml` (e.g. `1.0.1+2` — increment the build number after `+`).
3. Update [`CHANGELOG.md`](CHANGELOG.md) (move items from `[Unreleased]` into the new version section). This file is the source of truth for both the **Git annotated tag message** and the **GitHub Release** description — write clear Added / Changed / Fixed bullets users can understand.
4. Commit, create an annotated tag from the changelog, and push:

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: release v1.0.1"

# Annotated tag (-a) with the CHANGELOG section as the tag message.
# Do not use plain `git tag v1.0.1` — lightweight tags have no description.
./tool/tag_release.sh 1.0.1

git push origin main
git push origin v1.0.1
```

The tag must match the semver portion of `pubspec.yaml` (`v1.0.1` → `1.0.1+2`). Release workflows extract that version’s section from `CHANGELOG.md` and publish it as the GitHub Release description (not auto-generated commit lists), then upload platform artifacts. Build the Play Store AAB locally when needed:

```bash
flutter build appbundle --release
```

## Required GitHub Secrets

**Android** (split APK releases):

| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded upload keystore (`.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias |

**iOS** (IPA releases):

| Secret | Description |
|--------|-------------|
| `IOS_CERTIFICATE_BASE64` | Distribution `.p12` (base64) |
| `IOS_CERTIFICATE_PASSWORD` | P12 password |
| `IOS_PROVISIONING_PROFILE_BASE64` | App Store provisioning profile (base64) |
| `KEYCHAIN_PASSWORD` | Temporary keychain password for CI |

Local Android signing: create `android/key.properties` and place `upload-keystore.jks` in `android/` (both gitignored).

## Branch protection

On GitHub, go to **Settings → Branches → Add branch protection rule** for `main`:

1. Enable **Require a pull request before merging** (recommended).
2. Enable **Require status checks to pass before merging**.
3. Search for and select the **CI** / `analyze-and-test` check from `ci.yml`.
4. Enable **Require branches to be up to date before merging** (recommended).

This blocks merges until `flutter analyze`, formatting, codegen, and tests pass.
