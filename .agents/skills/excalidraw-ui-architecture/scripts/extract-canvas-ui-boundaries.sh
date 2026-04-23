#!/usr/bin/env bash
# Flag TS/TSX files that mix React with canvas/pipeline modules (split candidates).
# Uses grep only. Usage: extract-canvas-ui-boundaries.sh <file-or-directory>
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <file-or-directory>" >&2
  exit 1
fi

TARGET="$1"

if [[ ! -e "$TARGET" ]]; then
  echo "Path not found: $TARGET" >&2
  exit 1
fi

mapfile -t files < <(find "$TARGET" \( -name "*.ts" -o -name "*.tsx" \) -type f 2>/dev/null | sort)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No .ts/.tsx files under: $TARGET" >&2
  exit 0
fi

has_react() {
  grep -qE "from ['\"]react['\"]" "$1" 2>/dev/null
}

has_pipeline() {
  # Heuristic: scene, renderer, renderScene, element/math packages, canvas entrypoints
  grep -qE "scene/|/renderer/|renderScene|@excalidraw/element|@excalidraw/math|/element/types|StaticCanvas" "$1" 2>/dev/null
}

echo "== Cross-boundary scan: files that import both React and pipeline-style strings =="
echo "    (heuristic; review imports manually) — $TARGET"
echo

found=0
for f in "${files[@]}"; do
  if has_react "$f" && has_pipeline "$f"; then
    echo "$f"
    found=1
  fi
done

if [[ "$found" -eq 0 ]]; then
  echo "(No files matched the heuristic.)"
fi

echo
echo "== Import lines to review (pipeline-like substrings) =="
for f in "${files[@]}"; do
  if has_react "$f" && has_pipeline "$f" && out=$(grep -nE "import .*(scene/|/renderer/|renderScene|@excalidraw/element|@excalidraw/math|StaticCanvas)" "$f" 2>/dev/null); then
    echo "--- $f"
    echo "$out"
  fi
done 2>/dev/null || true

echo
echo "Done. See references/extract-canvas-ui-boundaries.md in this skill for how to split layers."
