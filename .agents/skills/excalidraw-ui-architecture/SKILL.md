---
name: excalidraw-ui-architecture
description: >-
  Refactors Excalidraw components by narrowing AppState-shaped props and by
  separating React UI from the canvas (Scene, renderScene, element math). Use
  when the user wants to reduce prop drilling, split mixed canvas/UI files, or
  mentions appstate-prop-minimizer or extract-canvas-ui-boundaries.
---

# Excalidraw UI architecture

## When to use this skill

- A component or panel receives `AppState` (or many `appState` fields) and the API is hard to test or reuse.
- A file mixes React DOM (toolbar, panel, dialog) with canvas concerns (`renderScene`, scene math, direct element mutation helpers).
- The user names **appstate prop minimization** or **canvas vs UI boundaries**.

## Workflows (pick one)

### A — AppState prop minimization

1. Read [references/appstate-prop-minimizer.md](references/appstate-prop-minimizer.md) for patterns and checklists.
2. Run the discovery script (from repo root; uses `grep`, no extra packages):

   ```bash
   bash .agents/skills/excalidraw-ui-architecture/scripts/appstate-prop-minimizer.sh
   ```

   Pass a subpath to focus, e.g. `packages/excalidraw/components/`.

3. Refactor: introduce smaller prop types, lift derived values at the boundary, keep state updates in `actionManager.dispatch()` only.

### B — Extract canvas / UI boundaries

1. Read [references/extract-canvas-ui-boundaries.md](references/extract-canvas-ui-boundaries.md) for the allowed layers and red flags.
2. Run the boundary report on a file or directory:

   ```bash
   bash .agents/skills/excalidraw-ui-architecture/scripts/extract-canvas-ui-boundaries.sh path/to/Component.tsx
   ```

3. Split: move pure canvas/scene logic next to the rendering pipeline; keep React components as thin controllers that dispatch actions and read props.

## Project constraints (non-negotiable)

- State updates only through `actionManager.dispatch()` — do not add Redux, Zustand, or similar.
- Canvas drawing stays in the existing Scene → `renderScene()` → canvas pipeline; do not move drawing to React DOM or third-party canvas libraries.

## Supporting files

- AppState narrowing — [references/appstate-prop-minimizer.md](references/appstate-prop-minimizer.md)
- Layer split — [references/extract-canvas-ui-boundaries.md](references/extract-canvas-ui-boundaries.md)

## Documentation and verification

- **With vs without:** See the `excalidraw-ui-architecture` section in `dev-docs/docs/introduction/agent-skills.mdx`. It compares using this skill to ad hoc refactors that ignore layer boundaries.
- **Verify:** from repo root, `bash scripts/verify-agent-skills.sh` runs both helper scripts and checks their output; no Yarn required for that part. Use `bash scripts/verify-agent-skills.sh --full` to include the same Yarn checks as the polishing skill.
