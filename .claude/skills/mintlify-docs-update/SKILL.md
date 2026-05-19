---
name: mintlify-docs-update
description: Keep the Mintlify docs site in sync with the JacobPEvans (and Drivist) GitHub repos. Use when adding new repos, when a repo is renamed or archived, or when refreshing the site's coverage. Triggers on "/mintlify-docs-update", "add docs for <repo>", "scaffold docs page", "sync docs site with repos", "update mintlify docs".
---

# mintlify-docs-update

Discover public repos under `JacobPEvans` and `Drivist`, diff against pages on this site, and scaffold the missing pages. Never overwrite existing pages; never touch private, archived, or forked repos by default.

## When to use

- A new repo was created and needs a docs page.
- A repo was renamed; the existing page slug is stale.
- A repo was archived and its page should be marked as such.
- Periodic catch-up via `/auto-maintain`.

## When NOT to use

- Authoring deep technical content for a single page. Use the future `mintlify-page-author` skill (issue tracked).
- Visual polish across the site. Use the future `mintlify-visual-audit` skill (issue tracked).
- Rewriting `docs.json` from scratch. Use the future `mintlify-nav-sync` skill (issue tracked).

## Workflow

### Step 1 — Enumerate repos

Run, in parallel:

```bash
gh repo list JacobPEvans --limit 200 --json name,description,visibility,isArchived,isFork,primaryLanguage,pushedAt,repositoryTopics,url --no-archived
gh repo list Drivist --limit 200 --json name,description,visibility,isArchived,isFork,primaryLanguage,pushedAt,repositoryTopics,url --no-archived
```

Filter to: `visibility == PUBLIC` AND `isFork == false`. Skip the meta `docs` and `JacobPEvans` profile repos.

### Step 2 — Categorize each repo

Map repo name and topics to a sidebar group:

| Match | Sidebar group | Path prefix |
| --- | --- | --- |
| `terraform-*`, `ansible-*` excluding `ansible-splunk` | Infrastructure | `infrastructure/` |
| `nix-*` | Nix Ecosystem | `nix/` |
| `ai-*`, `claude-code-*`, `ai-workflows`, `raycast-*` | AI Development | `ai-development/` |
| `cc-edge-*`, `cc-stream-*`, `VisiCore_*`, `splunk-*`, `tf-splunk-*`, `ansible-splunk` | Observability | `observability/` |
| `*-template`, `secrets-*`, `mlx-*`, `orbstack-*`, `unifi-*` | Tools | `tools/` |
| Everything else | Tools (default) | `tools/` |

Ties → prefer the more specific match. When uncertain, ask before scaffolding.

### Step 3 — Diff against existing pages

For each repo, the expected path is `<group-prefix><repo-name>.mdx`. If the file exists, skip. If it doesn't, queue for scaffolding.

### Step 4 — Scaffold

For each queued repo, copy `template-repo-page.mdx` and replace the marked placeholders:

| Placeholder | Source |
| --- | --- |
| `REPO_NAME` | repo `name` |
| `REPO_DESCRIPTION` | repo `description`; if empty, ask before scaffolding |
| `REPO_LANGUAGE` | `primaryLanguage.name` |
| `REPO_STATUS` | `"active"` (default), `"archived"`, or `"experimental"` based on topics |
| `REPO_LAST_ACTIVE` | relative time from `pushedAt` (e.g., `"this week"`) |
| `REPO_URL` | repo `url` |
| `REPO_TAGLINE` | one-line summary derived from description (cap 12 words) |
| `RELATED_REPOS` | up to 3 sibling repos in the same sidebar group, plus the group overview page |

Replacements happen via `Edit` tool with `replace_all: true`. Never use `sed` — this is exact-string replacement.

### Step 5 — Update `docs.json`

For each new page, insert its path into the appropriate sidebar group's `pages` array, preserving alphabetical order. Use `Edit` on `docs.json`; never regenerate the file.

### Step 6 — Validate

Run, sequentially:

```bash
cd <docs-root>
nix develop --command mint broken-links
nix develop --command mint dev   # smoke-only; kill after 10s
```

Fix any broken-link violations before committing. If `mint dev` errors on frontmatter or MDX syntax, surface the error and ask the author.

### Step 7 — Tiered word-count guard

For every scaffolded page:

- Tier 1 (`tier: 1` in frontmatter) → warn if >450 words.
- Tier 2 (`tier: 2`) → warn if >900 words; error if >1200 words.
- Default tier: if the path is `<group>/overview.mdx` or `introduction.mdx`, tier 1; else tier 2.

Over-budget pages get a `<!-- TIER-GUARD: over budget — consider splitting into sub-pages -->` comment at the top, not a rewrite.

## Outputs

- New MDX files under the right sidebar group
- Updated `docs.json`
- A summary report: `Added N pages: <list>`
- A list of skipped repos with reasons (`already-documented`, `private`, `archived`, `fork`, `uncategorizable`)

## Flags (planned)

- `--dry-run` — list what would be created without writing files
- `--include-archived` — include archived repos (default: skip)
- `--include-forks` — include forks (default: skip)
- `--org <name>` — restrict to a single org

These flags are interpreted manually in the conversation; there is no CLI binary.

## Related

- See `tools/automation.mdx` for the user-facing description.
- See `README.md` in this directory for human-readable usage.
- See open issues with label `skill` for planned improvements.
