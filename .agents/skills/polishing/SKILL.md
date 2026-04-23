---
name: polishing
description: Improve and finalize code changes before handoff by running a focused quality pass. Use when the user asks to polish, clean up, refine, or make work production-ready in this Excalidraw monorepo.
---

# Polishing

## When to use this skill

Use when the request is about finishing quality, not introducing new features:
- "polish this"
- "clean this up"
- "make this merge-ready"
- "refine implementation"

## Polishing workflow

1. Re-read changed files and confirm behavior still matches the request.
2. Remove obvious rough edges:
   - confusing naming
   - duplicated logic
   - dead code or stale comments
   - overly complex conditionals that can be simplified safely
3. Preserve project architecture constraints:
   - keep Excalidraw state updates through `actionManager.dispatch()`
   - do not introduce external state libraries
   - keep rendering in the existing Scene -> `renderScene()` -> canvas pipeline
4. Improve readability with minimal changes:
   - prefer small pure helpers for repeated logic
   - keep functions focused
   - add short comments only where intent is non-obvious
5. Validate with project checks relevant to the scope:
   - `yarn test:code` (linter check)
   - `yarn test:typecheck`
   - `yarn test:app` or targeted tests for touched areas
   - broader checks only when risk is high or requested
6. Report what was polished and what remains as optional follow-up.

## Output style for polish requests

Respond with:
1. What was improved (behavior, readability, safety)
2. What was verified (tests/checks run)
3. Any residual risk or optional next improvements

## Guardrails

- Do not add new dependencies without explicit approval.
- Do not perform broad refactors unless requested.
- Do not change public behavior during a polish pass unless fixing a bug.
