---
name: imageoptimize
description: Optimize image assets for web delivery by reducing file size while preserving visual quality. Use when the user asks to compress, optimize, convert, or resize PNG/JPEG/WebP/SVG images.
---

# Image Optimize

## When to use this skill

Use when requests include:
- "optimize images"
- "compress PNG/JPEG"
- "convert to WebP"
- "reduce bundle/image size"
- "prepare web assets"

## Optimization workflow

1. Identify target images and baseline sizes first.
2. Choose a safe optimization path:
   - lossless optimization first (preferred default)
   - lossy conversion only when quality/size trade-off is acceptable
3. Optimize by format:
   - PNG: `oxipng -o 4 --strip safe <file.png>` (or `optipng -o2`)
   - JPEG: `jpegoptim --strip-all --max=85 <file.jpg>`
   - WebP conversion: `cwebp -q 82 <input> -o <output.webp>`
   - SVG: `svgo <file.svg> -o <file.svg>`
4. Re-check file sizes and keep only meaningful reductions.
5. Validate visuals for artifacts and text readability.

## Command conventions (Ubuntu/Linux)

- Prefer Linux shell commands and forward-slash paths only.
- If tooling is missing, install with apt when user approves:
  - `sudo apt update`
  - `sudo apt install -y oxipng jpegoptim webp svgo`

## Guardrails

- Keep originals or use git-tracked changes to allow rollback.
- Do not upscale images.
- Do not change aspect ratio unless explicitly requested.
- Prefer deterministic settings for repeatable output.
- Avoid adding new npm dependencies unless user asks.

## Output format

When reporting results, include:
1. files changed
2. before/after sizes
3. total reduction percentage
4. any quality-impact notes

## Documentation and verification

- **With vs without:** See the `imageoptimize` section in `dev-docs/docs/introduction/agent-skills.mdx`.
- **Verify:** from repo root, `bash scripts/verify-agent-skills.sh` reports which optional CLIs are installed (`oxipng`, `jpegoptim`, and so on). Use `bash scripts/verify-agent-skills.sh --full` if you also want the same Yarn checks as the polishing skill.
