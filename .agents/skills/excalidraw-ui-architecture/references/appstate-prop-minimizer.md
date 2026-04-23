# AppState prop minimization

## Goal

Replace wide `AppState` (or dozens of ad hoc fields) in leaf components with **minimal, task-specific types** at the call boundary, without changing how global state is stored.

## Rules

- **Do not** introduce external stores. Parents still read `AppState` from the existing tree; you **narrow what children receive**.
- **Do** pass derived flags and IDs (`selectedElementIds`, `zoom`, a single `strokeColor`) instead of the whole `AppState` when a child only needs a slice.
- **Do** add small `type` aliases for props: `type ToolbarButtonProps = { isActive: boolean; onSelect: () => void }` rather than `appState: AppState`.

## Refactor checklist

1. **List real reads** — grep the component for `appState.`, `props.appState.`, and `AppState` field access. Those names are the candidate props.
2. **Group by concern** — selection vs tool vs view vs theme. If two groups do not both render in the same branch, consider splitting the component.
3. **Push derivation up** — compute booleans, filtered lists, and labels in the parent; pass results as plain props.
4. **Stabilize callbacks** — pass `() => actionManager.dispatch(...)` from the parent or a thin hook-free wrapper; avoid inline object literals in hot lists when it causes avoidable re-renders (match existing file style).
5. **Verify** — `yarn test:typecheck` and tests for the touched component directory.

## Anti-patterns

- Passing `AppState` to a presentational child “for future use.”
- Spreading `...appState` into props.
- Duplicating `AppState` fields in local React state (duplicates of truth).

## When to keep `AppState`

Containers that are already the natural boundary (e.g. a top-level panel that needs many unrelated `AppState` fields) may still take `appState: AppState`. Prefer narrowing at the **next** layer down.
