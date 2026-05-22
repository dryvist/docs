---
name: mintlify-visual-audit
description: Grade every MDX page on visual richness, theme compliance, and link health. Use when reviewing docs quality, checking tier compliance, auditing Mermaid theme usage, or running a site health check before a release. Triggers on "/mintlify-visual-audit", "audit the docs", "check docs quality", "grade every page", "site health check".
---

# mintlify-visual-audit

Read every MDX page on the site and grade it on visual richness, theme compliance, and link health. Output a red/amber/green report with a prioritized fix list, including split-into-sub-page suggestions for over-budget pages.

Idempotent — safe to run on every PR.

## When to use

- Before a release or major content push to spot regressions.
- After a batch of new pages are scaffolded (e.g. by `mintlify-docs-update`).
- When the "docs health" CI check flags warnings.
- Periodic quality review via `/auto-maintain`.

## When NOT to use

- Auto-fixing pages — this skill is read-only. Apply its suggestions manually or via `mintlify-page-author`.
- Running `mint dev` or `mint broken-links` — those belong in `mintlify-build-guard`.
- Syncing `docs.json` — use `mintlify-nav-sync`.

## Workflow

### Step 1 — Enumerate pages

Walk the filesystem for every site-page `.mdx` file. Exclude `snippets/`, `.claude/` (skill templates such as `mintlify-docs-update/template-repo-page.mdx` are not site pages), and any vendored directories:

```bash
find . -type f -name "*.mdx" \
  -not -path "./snippets/*" \
  -not -path "./.claude/*" \
  -not -path "*/node_modules/*" \
  | sort
```

### Step 2 — Per-page checks

For each `.mdx` file, run all checks below. Assign severity per check:
- **red**: must fix (blocks tier compliance or causes broken links)
- **amber**: should fix (visual quality, theme consistency)
- **green**: no issues

#### 2a — Tier-aware word count

Read the `tier:` frontmatter field. Count words in the page body (excluding frontmatter, code blocks, and HTML attributes).

| Tier | Warn (amber) | Fail (red) |
| --- | --- | --- |
| 1 | >450w | >600w |
| 2 | >900w | >1200w |
| (default) | >900w | >1200w |

Tier 1 amber matches the existing guidance in `.claude/skills/mintlify-docs-update/SKILL.md` (warn >450w); the red threshold extends that to a hard fail at 1.33× cap.

Default tier: `tier: 2` unless the path matches `*/overview.mdx` or is `introduction.mdx` (then `tier: 1`).

Severity: fail → **red**, warn → **amber**.

For Tier 1 pages over budget, suggest 2-3 candidate sub-pages to split into, based on heading structure.

#### 2b — Mermaid presence

Flag pages that describe a system, pipeline, or relationship between components without a fenced ` ```mermaid ` block. Heuristic: page body contains the words "flow", "pipeline", "feeds", "deploys", or "provisions", or uses a heading containing "How it fits" or "Architecture" — and has no Mermaid block. (Avoid generic verbs like "calls" that appear in routine prose.)

Severity: **amber**.

#### 2c — Component variety

Count occurrences of `<Card`, `<Steps`, `<Frame`, `<Note>`, `<Tip>`, `<Warning>`, `<Info>`. Pages with zero component usage (100% prose) get flagged.

Severity: **amber**.

#### 2d — Icon usage

Any `<Card>` element missing an `icon=` attribute gets flagged. Use a tag-name-aware match such as `<Card\b` (word boundary) so `<CardGroup>` — which carries no `icon=` and is expected — is not falsely flagged. Extract each `<Card\b` tag and check for `icon=`.

Severity: **amber**.

#### 2e — Callout usage

Search for patterns where a paragraph starts with `**Note:**`, `**Warning:**`, `**Tip:**`, `**Important:**` — these should be `<Note>`, `<Warning>`, `<Tip>`, or `<Info>` callouts instead.

Severity: **amber**.

#### 2f — Mermaid theme compliance

For each fenced ` ```mermaid ` block, check whether the first non-blank line is an `%%{init:` directive that sets `primaryColor` to `#4FB3A9`. Match the value flexibly — existing diagrams in this repo use the quoted JSON-like form `'primaryColor':'#4FB3A9'` inside a `themeVariables` block, so a substring search for `#4FB3A9` near a `primaryColor` key is sufficient. The canonical theme directive (single source of truth) lives in `AGENTS.md`; if `AGENTS.md` updates the canonical primary color, update this check to match. Flag Mermaid blocks that are present but missing this directive or use a different primary color.

Severity: **amber**.

#### 2g — Dead-link risk

Scan all internal `href="..."` attributes and markdown links `[...](...)` that start with `/`. Strip the leading `/` and check the filesystem **as-is first** — this correctly handles static assets such as `/images/foo.png` or `/files/spec.pdf`. Only if the file is missing **and** the path has no extension, retry with `.mdx` appended (for routing links like `/security/overview` → `security/overview.mdx`). Flag links where no matching file exists in either form.

Severity: **red** (broken internal link).

### Step 3 — Aggregate and rank

After all per-page checks:

1. Collect every individual finding (page × check).
2. Rank by: severity (red first), then frequency across the site, then alpha by page path.
3. Pick the top 5 findings for the site-wide prioritized fix list.

### Step 4 — Emit report

Output a Markdown report in this structure:

```
# Mintlify Visual Audit — <date>

## Prioritized Fix List (top 5 site-wide)

1. [red] `<page-path>` — <finding>
...

## Per-page Report

### `<page-path>` — 🔴 / 🟡 / 🟢

| Check | Severity | Detail |
| --- | --- | --- |
| Word count | 🔴 | 512w (Tier 1 cap: 450w). Suggested splits: "X", "Y". |
| Mermaid presence | 🟡 | Page describes a pipeline but has no diagram. |
| ... | | |

Overall: red | amber | green
```

Rules:
- A page is **red** if any check is red.
- A page is **amber** if no red checks and at least one amber check.
- A page is **green** if all checks pass.
- Omit checks that pass — only list findings.
- Green pages can be listed in a collapsed summary at the bottom.

### Step 5 — Post-run summary

After the report, emit a one-line summary:

```
Audit complete: N pages — R red, A amber, G green. Top issue: <top-1-finding>.
```

## Outputs

- Markdown report (printed to the conversation; not written to disk unless the user asks).
- One-line summary.

## Flags (planned)

- `--path <glob>` — restrict audit to a subset of pages.
- `--fix-list-only` — skip per-page detail, emit only the top-5 fix list.
- `--min-severity <red|amber>` — filter report to issues at or above the given severity.

These flags are interpreted manually in the conversation; there is no CLI binary.

## Related

- See `mintlify-build-guard` — runs `mint broken-links` and frontmatter validation (CI-facing).
- See `mintlify-page-author` — authors a single page with full prose.
- See `mintlify-mermaid-theme` — generates Reef Green Mermaid diagrams.
- See `mintlify-nav-sync` — keeps `docs.json` in sync with the filesystem.
- See open issues with label `skill` for planned improvements.

