# mintlify-docs-update

Project-level Claude Code skill that keeps `docs.jacobpevans.com` in sync with the public repos under `JacobPEvans` and `Drivist`.

## What you get

- Scans both GitHub accounts via `gh repo list`.
- Filters to public, non-archived, non-fork repos.
- Maps each repo to a sidebar group (Infrastructure, Nix, AI Development, Observability, Tools).
- Scaffolds a new MDX page for any repo that doesn't already have one, using `template-repo-page.mdx`.
- Adds the new page to the right sidebar group in `docs.json`, alphabetically.
- Validates the site with `mint broken-links` before handing back.
- Enforces the tiered word-count guard via `tier:` frontmatter.

## What you don't get

- No overwrites of existing pages.
- No deep technical writing — the skill scaffolds a clean shell with placeholders; you fill the prose.
- No private, archived, or forked repos by default.

## Installation

This skill is project-scoped — it ships inside the `JacobPEvans/docs` repo and is loaded automatically by Claude Code when a session opens in this repo.

```bash
git clone https://github.com/JacobPEvans/docs ~/git/docs/main
cd ~/git/docs/main
# Claude Code picks up .claude/skills/mintlify-docs-update/ automatically.
```

Requirements:

- Claude Code 4.x or newer (skill API support).
- `gh` CLI authenticated against an account that can read `JacobPEvans` and `Drivist`.
- `nix` and `direnv` for the `mint dev` / `mint broken-links` validation step (enter the dev shell with `nix develop`).

No global install. No package to publish. The skill is the directory.

## Usage

From a Claude Code session in this repo:

```
/mintlify-docs-update
```

Or describe what you want:

- "Add a docs page for `<repo>`"
- "Sync the docs site with my repos"
- "What repos are missing pages?"

The skill activates on those triggers. You'll be asked to confirm before pages are written.

### How it works in plain English

1. Run `gh repo list JacobPEvans --no-archived` and the same for `Drivist`.
2. For each repo, compute the expected path: `<sidebar-group-prefix><repo-name>.mdx`.
3. If the file exists, skip. Otherwise, copy `template-repo-page.mdx` and replace tokens.
4. Add the path to `docs.json` under the right group.
5. Run `mint broken-links`; fix any new violations.
6. Report what was added, what was skipped, and why.

### Optional flags (interpret manually in chat)

- `--dry-run` — list what would be created without writing files.
- `--include-archived` — include archived repos.
- `--include-forks` — include forks.
- `--org <name>` — restrict to a single org.

## Limitations

- The skill doesn't read repo READMEs — placeholders need to be filled by hand.
- Categorization is name-based; if a repo's name doesn't match any pattern, the skill asks.
- The Drivist org currently has zero public repos. The skill still queries it on every run; this is intentional so new Drivist repos are picked up automatically.

## Roadmap

Five companion skills are tracked as GitHub issues with the `skill` label on `JacobPEvans/docs`:

1. `mintlify-page-author` — author a single page with full prose, not just a scaffold.
2. `mintlify-visual-audit` — grade every page on component variety, theme compliance, dead links.
3. `mintlify-mermaid-theme` — Reef Green Mermaid preset generator with house shape conventions.
4. `mintlify-nav-sync` — keep `docs.json` in sync with the filesystem.
5. `mintlify-build-guard` — pre-commit / CI validator combining `mint dev`, `mint broken-links`, frontmatter and tier checks.

See `tools/automation.mdx` for the live tracking links.

## Files in this directory

- `SKILL.md` — the skill definition (loaded by Claude Code when the skill activates).
- `template-repo-page.mdx` — the canonical per-repo page template.
- `README.md` — this file.
