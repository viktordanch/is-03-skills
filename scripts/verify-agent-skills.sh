#!/usr/bin/env bash
# Verification for agent skills: polishing, imageoptimize, excalidraw-ui-architecture.
# Run from the repository root: bash scripts/verify-agent-skills.sh [--full]
#
#   (default) Fast: excalidraw helper scripts, optional image CLIs, no Yarn.
#   --full     Also run yarn test:code and yarn test:typecheck (polishing skill).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

FULL=0
if [[ "${1:-}" == "--full" ]]; then
  FULL=1
fi

has_cmd() { command -v "$1" &>/dev/null; }

if [[ "$FULL" -eq 1 ]]; then
  echo "=== 1. polishing (full: yarn test:code + test:typecheck) ==="
  if has_cmd yarn; then
    yarn test:code
    yarn test:typecheck
    echo "OK: yarn test:code and yarn test:typecheck passed."
  else
    echo "FAIL: yarn not in PATH" >&2
    exit 1
  fi
else
  echo "=== 1. polishing (skipped in fast mode) ==="
  echo "  Run with --full to execute: yarn test:code && yarn test:typecheck"
fi

echo
echo "=== 2. imageoptimize (optional CLIs) ==="
for t in oxipng jpegoptim cwebp svgo; do
  if has_cmd "$t"; then
    echo "  OK: $t is available"
  else
    echo "  WARN: $t not found (on Ubuntu: sudo apt install -y $t, or see imageoptimize/SKILL.md)"
  fi
done

echo
echo "=== 3. excalidraw-ui-architecture (helper scripts) ==="
APPSTATE_SCRIPT=".agents/skills/excalidraw-ui-architecture/scripts/appstate-prop-minimizer.sh"
BOUNDARY_SCRIPT=".agents/skills/excalidraw-ui-architecture/scripts/extract-canvas-ui-boundaries.sh"
for s in "$APPSTATE_SCRIPT" "$BOUNDARY_SCRIPT"; do
  if [[ ! -f "$s" ]]; then
    echo "FAIL: missing $s" >&2
    exit 1
  fi
done

OUT_APPSTATE=$(bash "$APPSTATE_SCRIPT" packages/excalidraw/components 2>&1) || {
  echo "FAIL: appstate-prop-minimizer.sh failed" >&2
  exit 1
}
if ! grep -q "TSX files mentioning AppState" <<<"$OUT_APPSTATE"; then
  echo "FAIL: unexpected output from appstate-prop-minimizer.sh" >&2
  echo "$OUT_APPSTATE" | head -5
  exit 1
fi
echo "OK: appstate-prop-minimizer.sh (first lines of output):"
echo "$OUT_APPSTATE" | head -8

OUT_BOUNDARY=$(bash "$BOUNDARY_SCRIPT" packages/excalidraw/components/App.tsx 2>&1) || {
  echo "FAIL: extract-canvas-ui-boundaries.sh failed" >&2
  exit 1
}
if ! grep -q "Cross-boundary" <<<"$OUT_BOUNDARY"; then
  echo "FAIL: unexpected output from extract-canvas-ui-boundaries.sh" >&2
  echo "$OUT_BOUNDARY" | head -5
  exit 1
fi
echo "OK: extract-canvas-ui-boundaries.sh (first lines of output):"
echo "$OUT_BOUNDARY" | head -12

echo
echo "=== verify-agent-skills: passed ==="
echo "Docs: dev-docs/docs/introduction/agent-skills.mdx"
echo "Polishing: use --full to run Yarn checks."
