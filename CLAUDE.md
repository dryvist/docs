# CLAUDE.md — docs.jacobpevans.com

Source for [docs.jacobpevans.com](https://docs.jacobpevans.com), a Mintlify-based personal documentation site covering homelab infrastructure, security, AI development, and observability.

Full agent instructions are in [AGENTS.md](./AGENTS.md). Key points for quick reference:

## Stack

- **Framework:** Mintlify (Hobby tier), deployed via GitHub app on push to `main`
- **Content:** MDX files with YAML frontmatter + `docs.json` config
- **Diagrams:** Mermaid with ELK layout (hand-drawn look, canonical theme required — see AGENTS.md)
- **Dev shell:** `nix develop` (flake.nix) or Node 20+

## Quick commands

```bash
nix develop        # Enter dev shell
mint dev           # Local preview at http://localhost:3000
mint broken-links  # Validate internal links
```

## Critical conventions

- All Mermaid blocks **must** start with the canonical `%%{init: ...}%%` directive (exact bytes — see AGENTS.md)
- Run `grep -h '%%{init:' --include='*.mdx' -r . | sort -u | wc -l` — must return `1`
- Public information only: no real IPs, hostnames, credentials, or references to private repos
- Sentence case for headings; active voice, second person

## Repo layout

```
docs.json          Mintlify config (theme, palette, fonts, nav)
*.mdx              Content pages
docs/**            Subdirectory content
.github/workflows/ CI (JSON lint + broken-links check)
flake.nix          Reproducible dev shell
```

## Content boundaries

- **Modify:** `*.mdx`, `docs.json`, `*.md`, diagrams
- **Do not modify:** `.github/workflows/`, `flake.nix`, `package.json`
