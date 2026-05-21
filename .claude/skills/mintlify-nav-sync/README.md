# mintlify-nav-sync

Project-level Claude Code skill that keeps `docs.json` sidebar in sync with the `.mdx` files on disk.

## What you get

- Reads `docs.json` and walks the filesystem in one pass.
- Detects **orphans**: `.mdx` files that exist on disk but are absent from the nav.
- Detects **ghosts**: nav entries that reference a path with no backing `.mdx` file.
- Detects **ordering drift**: groups where pages aren't in canonical order (overview first, then alphabetical).
- Emits a `git diff`-style patch to stdout (dry-run by default).
- Writes the patch back to `docs.json` when `--apply` is passed.

## What you don't get

- No authoring of page content — see `mintlify-docs-update` for scaffolding.
- No new top-level sidebar groups — the skill flags ungrouped orphans and asks where to put them.
- No `snippets/` management — that directory is always excluded.

## Installation

This skill is project-scoped — it ships inside the `JacobPEvans/docs` repo and is loaded automatically by Claude Code when a session opens in this repo.

```bash
git clone https://github.com/JacobPEvans/docs ~/git/docs/main
cd ~/git/docs/main
# Claude Code picks up .claude/skills/mintlify-nav-sync/ automatically.
```

Requirements:

- Claude Code 4.x or newer (skill API support).
- `gh` CLI authenticated against an account with read access to `JacobPEvans/docs`.

## Usage

From a Claude Code session in this repo:

```
/mintlify-nav-sync
```

Or describe what you want:

- "Check sidebar drift"
- "Find orphan pages"
- "Sync the nav"
- "Is docs.json in sync?"

With the apply flag:

```
/mintlify-nav-sync --apply
```

### Optional flags (interpret manually in chat)

- `--apply` — write the patch to `docs.json` (default: dry-run).
- `--group <name>` — restrict to a single sidebar group.
- `--no-reorder` — skip ordering drift; report orphans and ghosts only.

## Ordering rules

The skill enforces this canonical order within each group:

1. `<group>/overview` always first.
2. Remaining pages in ascending alphabetical order.

**Exceptions:**

- `"Start here"` — fixed order `[introduction, how-it-fits-together]`, never touched.
- `"About"` — current order preserved, never reordered.

## Files in this directory

- `SKILL.md` — the skill definition (loaded by Claude Code when the skill activates).
- `README.md` — this file.
