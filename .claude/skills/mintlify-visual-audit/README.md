# mintlify-visual-audit

Project-level Claude Code skill that grades every MDX page on the site for visual richness, theme compliance, and link health.

## What you get

- Per-page red/amber/green severity rating.
- Tier-aware word-count compliance check (Tier 1 ≤450w, Tier 2 ≤1200w cap).
- Mermaid presence detection — flags pages that describe flows without a diagram.
- Component variety check — flags 100%-prose pages with no Cards, Steps, Frames, or callouts.
- Card icon audit — flags `<Card>` elements missing an `icon=` attribute.
- Callout prose audit — flags bold `**Note:**` / `**Warning:**` patterns that should be `<Note>` / `<Warning>`.
- Reef Green theme compliance — flags Mermaid blocks missing the `%%{init:...}%%` directive.
- Dead-link risk — flags internal links that do not resolve to a file on disk.
- Site-wide prioritized fix list: top 5 issues, ranked by severity then frequency.
- Split suggestions for over-budget Tier 1 pages.

## What you don't get

- No auto-fixing — this skill is read-only.
- No `mint dev` or `mint broken-links` execution — use `mintlify-build-guard` for that.

## Installation

This skill is project-scoped — it ships inside the `JacobPEvans/docs` repo and is loaded automatically by Claude Code when a session opens in this repo.

```bash
git clone https://github.com/JacobPEvans/docs ~/git/docs/main
cd ~/git/docs/main
# Claude Code picks up .claude/skills/mintlify-visual-audit/ automatically.
```

No global install. No package to publish.

## Usage

From a Claude Code session in this repo:

```
/mintlify-visual-audit
```

Or describe what you want:

- "Audit the docs site"
- "Grade every page"
- "Check docs quality before the release"
- "Site health check"

### How it works in plain English

1. Walks every `.mdx` file under the docs root (excluding `snippets/`).
2. For each page, runs 7 checks: word count, Mermaid presence, component variety, card icons, callout prose, Mermaid theme, and dead links.
3. Assigns red/amber/green severity per check.
4. Emits a Markdown report — one section per page — plus a site-wide top-5 fix list.
5. For over-budget Tier 1 pages, suggests candidate sub-pages based on heading structure.

### Optional flags (interpret manually in chat)

- `--path <glob>` — restrict audit to a subset of pages.
- `--fix-list-only` — emit only the top-5 fix list, skip per-page detail.
- `--min-severity <red|amber>` — filter to issues at or above the given severity.

## Limitations

- Dead-link detection is filesystem-based — it cannot follow redirects or validate external URLs.
- Mermaid presence detection uses a keyword heuristic and may have false positives on narrative pages.
- Word count excludes frontmatter, code blocks, and HTML attributes; actual rendered word count may differ slightly.

## Files in this directory

- `SKILL.md` — the skill definition (loaded by Claude Code when the skill activates).
- `README.md` — this file.

