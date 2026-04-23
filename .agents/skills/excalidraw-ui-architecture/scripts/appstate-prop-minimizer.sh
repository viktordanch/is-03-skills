#!/usr/bin/env bash
# Surface TSX files that thread AppState / appState heavily — candidates to narrow props.
# Uses grep only (no ripgrep required). Optional: install ripgrep for faster use elsewhere.
# Usage: appstate-prop-minimizer.sh [path]
#   path defaults to packages/excalidraw (relative to cwd).
set -euo pipefail

ROOT="${1:-packages/excalidraw}"

if [[ ! -e "$ROOT" ]]; then
  echo "Path not found: $ROOT (run from repo root or pass a valid path)" >&2
  exit 1
fi

echo "== TSX files mentioning AppState — sorted by 'appState' substring hit count =="
echo "    (low count can mean the type is imported but props are already narrow) — $ROOT"
echo

find "$ROOT" -name "*.tsx" -type f | while IFS= read -r f; do
  if grep -q "AppState" "$f" 2>/dev/null; then
    c=$(grep -c "appState" "$f" 2>/dev/null || echo 0)
    printf "%5s  %s\n" "$c" "$f"
  fi
done | sort -k1,1nr

echo
echo "== Top files by total AppState|appState line matches =="
find "$ROOT" -name "*.tsx" -type f | while IFS= read -r f; do
  if grep -qE "AppState|appState" "$f" 2>/dev/null; then
    t=$(grep -cE "AppState|appState" "$f" 2>/dev/null || echo 0)
    printf "%5s  %s\n" "$t" "$f"
  fi
done | sort -k1,1nr | head -25

echo
echo "Done. See references/appstate-prop-minimizer.md in this skill for refactor steps."
