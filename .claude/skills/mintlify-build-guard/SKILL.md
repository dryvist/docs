---
name: mintlify-build-guard
description: Single-command validator for the JacobPEvans/docs Mintlify site. Runs frontmatter checks, broken-link scan, image-reference resolution, tiered word-count, Mermaid parse, and snippet-import verification. Emits a single pass/fail report. Triggers on "/mintlify-build-guard", "validate docs", "check docs", "run build guard", "lint docs".
---

# mintlify-build-guard

Run the full set of Mintlify site checks and emit a single pass/fail report with line-level violations. Wraps existing tooling — not a reimplementation.

## When to use

- Before committing new or edited MDX pages.
- As part of a pre-commit or CI gate on PRs.
- Any time you want confidence that the site will build cleanly.

## When NOT to use

- Authoring or restructuring pages — use `mintlify-docs-update` or `mintlify-page-author`.
- Auto-fixing violations — this skill is read-only.
- Checking a single isolated property (e.g., only word count) — run the matching step directly.

## Prerequisites

The dev shell must be active:

```bash
nix develop
```

or via `direnv` (`use flake`). This makes `mint` and `mmdc` available on PATH.

## Checks (run in this order)

### 1 — Frontmatter validation

For every `.mdx` file under the docs root, confirm all three fields are present and valid:

```bash
find . -name "*.mdx" ! -path "./.git/*" | while read f; do
  grep -qE "^title:" "$f"       || echo "MISSING title: $f"
  grep -qE "^description:" "$f" || echo "MISSING description: $f"
  grep -qE "^tier: [12]$" "$f"  || echo "MISSING/INVALID tier: $f"
done
```

**Fail** if any page is missing `title`, `description`, or a valid `tier` (must be `1` or `2`).

### 2 — Broken-link scan

```bash
nix develop --command mint broken-links
```

**Fail** if exit code is non-zero. Capture stdout and list each broken link with source file and target.

### 3 — Image reference resolution

Extract every local image reference and verify the file exists:

```bash
grep -rn '<Frame src="[^h][^"]*"' . --include="*.mdx"
grep -rn '!\[.*\]([^h][^)]*)' . --include="*.mdx"
```

For each extracted path: confirm it exists under the repo root or under `/images/`. Skip `http://` and `https://` references.

**Fail** if any local image path does not resolve to an existing file. Report file, line, and missing path.

### 4 — Tiered word-count cap

For each `.mdx` file, strip the frontmatter block (`---...---`) and count prose words:

```bash
sed '/^---$/,/^---$/d' <file> | wc -w
```

Read `tier:` from the file's frontmatter and apply:

| Tier | Warn threshold | Fail threshold |
|------|---------------|----------------|
| 1    | > 450 w       | (warn only)    |
| 2    | > 900 w       | > 1 200 w      |
| unset / default | > 900 w | > 1 200 w |

Emit a **warning** (non-blocking) for warn-level violations; emit a **failure** for fail-level violations.

### 5 — Mermaid parse check

Find every fenced ` ```mermaid ` block in every `.mdx`, extract the block body, and validate via `mmdc`:

```bash
echo '<mermaid block contents>' | nix develop --command mmdc --input - --output /dev/null
```

**Fail** if `mmdc` exits non-zero for any block. Report file path, line number, and the mmdc error.

### 6 — Snippet import resolution

Find every snippet import:

```bash
grep -rn 'import {' . --include="*.mdx" | grep 'from "/snippets/'
```

For each match:
1. Resolve the path `snippets/<slug>.mdx` (also try `.tsx`, `.jsx`, `.ts`, `.js`).
2. Confirm the file exists.
3. Confirm the imported symbol (the identifier between `{` and `}`) is exported from that file.

**Fail** if the file does not exist or the symbol is not exported.

## Output format

```
mintlify-build-guard — <timestamp>
=====================================

── Check 1: Frontmatter ────────────────────────────
[PASS | FAIL — N violation(s)]
  <file>  missing: <field>

── Check 2: Broken links ───────────────────────────
[PASS | FAIL — N violation(s)]
  <source-file>  →  <broken-target>

── Check 3: Image references ───────────────────────
[PASS | FAIL — N violation(s)]
  <file>:<line>  missing: <path>

── Check 4: Word count ─────────────────────────────
[PASS | WARN — N issue(s)]
  ⚠ <file>  <N>w  (warn: tier 1 > 450)
  ✗ <file>  <N>w  (fail: tier 2 > 1200)

── Check 5: Mermaid blocks ─────────────────────────
[PASS | FAIL — N violation(s)]
  <file>:<line>  mmdc error: <message>

── Check 6: Snippet imports ────────────────────────
[PASS | FAIL — N violation(s)]
  <file>:<line>  missing: <symbol> from <path>

=====================================
Result: PASS (0 failures, N warnings) | FAIL (N failures, N warnings)
```

Overall result is **PASS** only when zero failures exist across all six checks. Warnings do not block PASS.

## Exit behaviour

If the overall result is FAIL, surface each failure section and ask the user which to fix first. Do not attempt auto-fixes.

## Composes with

- **`mintlify-docs-update`** — run build-guard after scaffolding to confirm new pages pass.
- **`mintlify-mermaid-theme`** — diagrams generated by that skill pass Check 5 automatically.
- **`mintlify-nav-sync`** — run build-guard after a nav sync to confirm no broken links were introduced.
