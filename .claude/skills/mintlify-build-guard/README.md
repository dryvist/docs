# mintlify-build-guard

Project-level Claude Code skill that validates the JacobPEvans/docs Mintlify site in a single pass and emits a structured pass/fail report.

## What you get

- **Frontmatter** — every `.mdx` page has `title`, `description`, and `tier` (1 or 2).
- **Broken links** — `mint broken-links` gate; every internal link resolves.
- **Image references** — every local `<Frame src="...">` and `![](...)` points to an existing file.
- **Tiered word-count** — Tier 1 pages ≤ 450 w (warn only), Tier 2 ≤ 900 w (warn) / ≤ 1 200 w (fail).
- **Mermaid blocks** — every fenced `mermaid` block parses via `mmdc`.
- **Snippet imports** — every `import { X } from "/snippets/..."` resolves and the symbol is exported.

## What you do NOT get

- No auto-fixing — read-only validator.
- No authoring or page restructuring — use `mintlify-docs-update` or `mintlify-page-author`.

## Installation

This skill is project-scoped — it ships inside the `JacobPEvans/docs` repo and is loaded automatically by Claude Code when a session opens in this repo.

```bash
git clone https://github.com/JacobPEvans/docs ~/git/docs/main
cd ~/git/docs/main
# Claude Code picks up .claude/skills/mintlify-build-guard/ automatically.
```

Requirements:

- Claude Code 4.x or newer.
- `nix` and `direnv` for `mint` and `mmdc` (available via `nix develop`).

## Usage

```
/mintlify-build-guard
```

Or ask naturally: "validate the docs", "check the docs build", "run the build guard", "lint docs".

The skill runs all six checks sequentially and prints a single report.

## Files in this directory

- `SKILL.md` — the skill definition (loaded by Claude Code when the skill activates).
- `README.md` — this file.

## Composes with

- **`mintlify-docs-update`** — scaffold new pages; run build-guard after to confirm they pass.
- **`mintlify-mermaid-theme`** — Mermaid blocks from that skill pass Check 5 automatically.
- **`mintlify-nav-sync`** — run build-guard after a nav sync to confirm no broken links were introduced.
