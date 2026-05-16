# Agent instructions for docs.jacobpevans.com

This is the documentation site for Jacob P Evans, built on Mintlify (Hobby tier),
deployed at `https://docs.jacobpevans.com`. The repo is the source of truth — all
MDX, diagrams, and config are version-controlled here.

## About this project

- Pages are MDX files with YAML frontmatter
- Configuration lives in `docs.json`
- Mintlify renders Mermaid natively (ELK layout); fenced ` ```mermaid ` blocks work directly
- Source repo: `https://github.com/JacobPEvans/docs`

## Local development

```bash
nix develop        # Dev shell (flake.nix)
npm i -g mint      # Install Mintlify CLI (one-time)
mint dev           # Start local preview at http://localhost:3000
mint broken-links  # Validate internal links
```

## Identity system

Reef Green primary `#4FB3A9`, Coral accent `#E06B4A`, Ink dark bg `#0B1D2A`,
Paper light bg `#F4EFE6`. Full palette in `docs.json`. Geist for display and
body; JetBrains Mono via inline code for terminal-style accents.

Brand voice (header tagline):

> Splunk and Cribl architect by day. Building the AI dev pipeline by night. Reef tank in the living room, homelab in the basement, both fully monitored.

## Writing style

- Active voice, second person ("you")
- Sentence case for headings
- Code formatting for file names, commands, paths, code references
- One idea per sentence
- Diagrams over prose where structure matters

## Content boundaries — PUBLIC information only

- No real internal IP addresses (use placeholders)
- No real internal hostnames (use plausible-but-fictional names)
- No references to private repos — treat them as if they don't exist
- No credentials, tokens, or sensitive data

If a repo's GitHub visibility is `PRIVATE`, it does not appear here. Verify with `gh repo view OWNER/REPO --json visibility` when in doubt.

## Diagram style

Inline ` ```mermaid ` fenced blocks render natively in Mintlify with ELK layout.
One diagram per concern — do not combine. Each diagram starts with a Mermaid
theme directive so colors match the Reef Green palette:

```text
%%{init: {'theme':'base','themeVariables':{'primaryColor':'#4FB3A9','primaryTextColor':'#F4EFE6','primaryBorderColor':'#2F7E78','lineColor':'#E06B4A','secondaryColor':'#102937','tertiaryColor':'#0B1D2A','clusterBkg':'#102937','clusterBorder':'#2F7E78'}}}%%
```

Shape vocabulary across the site:

- Rounded boxes for services and processes
- Cylinders for data stores
- Diamonds for decisions
- Subgraphs for logical groupings (Human / AI / Automation / Infrastructure)

## Phases

- **Phase A** (current): foundation, theme, full nav skeleton, 8 priority diagrams, 9 category overviews, profile banner
- **Phase B** (next): top 10 priority repo pages
- **Phase C** (later): remaining ~20 public repos
- **Phase D** (ongoing): new repos get a docs page on creation; quarterly diagram audit
