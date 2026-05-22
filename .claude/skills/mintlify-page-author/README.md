# mintlify-page-author

Project-level Claude Code skill that authors a single, fully-written Mintlify docs page from a GitHub repo URL or free-text topic.

## What you get

- Fetches the target repo's `README.md` and metadata via `gh`.
- Resolves the sidebar group and target path automatically from the repo name.
- Generates a complete MDX page: frontmatter, tagline, `<RepoMeta>`, prose intro, "What it does" bullets, Reef Green Mermaid diagram, `<Steps>` getting-started block, and `<CardGroup>` related repos.
- Enforces the tier word-count cap (Tier 1 ≤450w, Tier 2 ≤900w hard cap with a split-suggestion on overflow — per issue #2 acceptance criteria).
- Never overwrites an existing page — emits a diff and waits for confirmation.
- Reminds you to run `mintlify-nav-sync` to add the new path to `docs.json`.

## What you don't get

- No batch authoring — use `mintlify-docs-update` for scaffolding multiple shells.
- No Mermaid generation from scratch — delegates to `mintlify-mermaid-theme`.
- No `docs.json` edits — delegates to `mintlify-nav-sync`.

## Installation

This skill is project-scoped — it ships inside the `JacobPEvans/docs` repo.

```bash
git clone https://github.com/JacobPEvans/docs ~/git/docs/main
cd ~/git/docs/main
# Claude Code picks up .claude/skills/mintlify-page-author/ automatically.
```

Requirements:

- Claude Code 4.x or newer.
- `gh` CLI authenticated against an account that can read the target repo.
- `nix` and `direnv` for `mint broken-links` validation.

## Usage

```
/mintlify-page-author https://github.com/JacobPEvans/terraform-proxmox
```

Or describe what you want:

- "Write a docs page for `terraform-proxmox`"
- "Author the page for the Splunk observability stack"
- "Fill in the prose for `nix/nix-ai.mdx`"

The skill emits the full page as a diff for your review before writing.

## Composition

| Skill | Role |
| --- | --- |
| `mintlify-docs-update` | Creates page shells; this skill fills the prose. |
| `mintlify-mermaid-theme` | Refines the Reef Green Mermaid diagram. |
| `mintlify-nav-sync` | Adds the new page to `docs.json`. |
| `mintlify-build-guard` | Validates the finished page. |

## Files in this directory

- `SKILL.md` — the skill definition loaded by Claude Code.
- `README.md` — this file.
