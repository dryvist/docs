# CLAUDE.md

## Project overview

Source for [docs.jacobpevans.com](https://docs.jacobpevans.com) — a Mintlify-powered documentation site
covering the full homelab stack (Nix, Terraform, Ansible, Cribl/Splunk observability, AI development).

## Dev environment

```bash
nix develop      # Reproducible shell: mermaid-cli, node 20, jq
npm i -g mint    # One-time install of the Mintlify CLI
```

## Key commands

```bash
mint dev           # Local preview at http://localhost:3000
mint broken-links  # Validate internal links
```

## File layout

- `docs.json` — Mintlify config: theme, nav, palette, fonts
- `*.mdx` — Content pages (MDX + optional Mintlify components)
- `architecture/`, `infrastructure/`, `configuration/`, `nix/`, `ai-development/`, `observability/`, `tools/`, `about/` — content sections
- `.github/workflows/ci.yml` — JSON syntax check + broken-links CI

## Editing guidelines

- All content is MDX; use standard Markdown for prose and Mintlify components (`<Tip>`, `<Warning>`, `<CodeGroup>`) sparingly.
- Diagrams are Mermaid (rendered via `mermaid-cli` in the dev shell).
- Do not modify `docs.json` navigation without verifying `mint dev` renders correctly.
- Do not touch `.github/workflows/` or `flake.nix` without understanding the CI/dev-shell impact.

## Deploy

Push to `main` → auto-deploy via the Mintlify GitHub app. No manual deploy step required.
