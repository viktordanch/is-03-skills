# Extract canvas / UI boundaries

## Goal

Keep **one direction of dependency**: React UI (components, SCSS) talks to the app through **actions and props**; the **canvas pipeline** (scene, `renderScene`, element packages) does not import React. Mixed files are refactors waiting to happen.

## Allowed layers (mental model)

| Layer | Examples | May import from |
|------|-----------|-----------------|
| React UI | `components/`, toolbars, dialogs | `types`, action creators, small helpers, icons |
| App glue | `App.tsx`, wiring | components + actionManager |
| Scene / render | `scene/`, `renderer/`, frame loops | element/math/common — **not** `react` |
| Elements & math | `packages/element`, `packages/math` | other packages — **not** React |

## Red flags in one file

- **Imports** that combine `react` with `renderScene`, `StaticCanvas`, scene caches, or heavy `@excalidraw/element` layout from inside a file that also renders large JSX trees for chrome.
- **Direct canvas context** use outside the renderer in a file that is mostly UI.
- **Element mutation** helpers interleaved with JSX event handlers when the same logic is needed in non-React code paths (export pure functions).

## Extraction steps

1. **Draw the boundary** — decide whether the split is “UI shell + action dispatch” vs “pure function that returns scene data / hit targets.”
2. **Move pure logic** — functions with no `useState` / JSX go to a colocated `*-helpers.ts` or the appropriate `packages/` module; keep names aligned with existing neighbors.
3. **Keep events thin** — handlers call `actionManager.dispatch()` or pass ids into existing actions; do not reimplement scene updates in React.
4. **Test** — colocated tests for the UI; unit tests for pure helpers if the repo already tests that layer.

## What not to do

- Do not render the scene with React DOM, `react-konva`, or new canvas wrapper libraries.
- Do not add global state libraries to “simplify” the split.
