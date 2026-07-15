#!/usr/bin/env bash
# Create (or replace locally) an annotated git tag whose message is the
# CHANGELOG.md section for that version.
#
# Usage:
#   ./tool/tag_release.sh 1.2.0
#   ./tool/tag_release.sh v1.2.0
#   ./tool/tag_release.sh 1.1.0 --force   # rewrite an existing local tag
#
# Push afterward:
#   git push origin "v1.2.0"
#   git push --force origin "v1.1.0"   # only when rewriting a published tag
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ "${1:-}" = "" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

RAW="${1#v}"
TAG="v${RAW}"
FORCE=false
if [ "${2:-}" = "--force" ] || [ "${2:-}" = "-f" ]; then
  FORCE=true
fi

if [ ! -f CHANGELOG.md ]; then
  echo "CHANGELOG.md not found" >&2
  exit 1
fi

PUBSPEC_VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)"
if [ "$PUBSPEC_VERSION" != "$RAW" ] && [ "$FORCE" != true ]; then
  echo "pubspec version ($PUBSPEC_VERSION) does not match tag version ($RAW)" >&2
  echo "Bump pubspec first, or pass --force when rewriting an older tag." >&2
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

{
  echo "SceneSplit ${RAW}"
  echo
  # Rewrite "### Added" → "Added" so git tag cleanup does not strip "#" comment lines.
  awk -v ver="$RAW" '
    $0 ~ "^## \\[" ver "\\]" {found=1; next}
    found && /^## / {exit}
    found {
      if (!started) {
        if ($0 ~ /^[[:space:]]*$/) next
        started=1
      }
      if ($0 ~ /^### /) {
        sub(/^### /, "")
        print
        next
      }
      print
    }
  ' CHANGELOG.md
} > "$TMP"

if ! grep -q '^- ' "$TMP"; then
  echo "No CHANGELOG.md section found for ## [${RAW}]" >&2
  echo "Add Added/Changed/Fixed notes before tagging." >&2
  exit 1
fi

# Trim trailing blank lines
while [ -s "$TMP" ] && [ -z "$(tail -n 1 "$TMP")" ]; do
  sed -i.bak '$ d' "$TMP"
  rm -f "${TMP}.bak"
done

# --cleanup=verbatim keeps the message exactly as written.
if git rev-parse "$TAG" >/dev/null 2>&1; then
  if [ "$FORCE" != true ]; then
    echo "Tag ${TAG} already exists. Re-run with --force to replace the local tag." >&2
    exit 1
  fi
  TARGET="$(git rev-list -n 1 "$TAG")"
  git tag -d "$TAG" >/dev/null
  git tag -a --cleanup=verbatim "$TAG" -F "$TMP" "$TARGET"
  echo "Replaced annotated tag ${TAG} -> ${TARGET}"
else
  git tag -a --cleanup=verbatim "$TAG" -F "$TMP"
  echo "Created annotated tag ${TAG} -> $(git rev-list -n 1 "$TAG")"
fi

echo
echo "Tag message:"
echo "------------"
git tag -l --format='%(contents)' "$TAG"
echo "------------"
echo
echo "Next:"
echo "  git push origin ${TAG}"
if [ "$FORCE" = true ]; then
  echo "  (rewriting a remote tag: git push --force origin ${TAG})"
fi
