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
%%{init: {'theme':'base','look':'handDrawn','themeVariables':{'primaryColor':'#4FB3A9','primaryTextColor':'#F4EFE6','primaryBorderColor':'#2F7E78','lineColor':'#E06B4A','secondaryColor':'#102937','tertiaryColor':'#0B1D2A','clusterBkg':'transparent','clusterBorder':'#4FB3A9','fontFamily':'Geist','fontSize':'15px'}}}%%
```

Shape vocabulary across the site:

- Rounded boxes for services and processes
- Cylinders for data stores
- Diamonds for decisions
- Subgraphs for logical groupings (Human / AI / Automation / Infrastructure)

## Diagram aspect ratio

Every diagram must render wider than tall in normal desktop viewports.
The Mermaid `flowchart LR` directive is necessary but not sufficient — a
hub-and-spoke layout with `LR` direction still stacks the spokes vertically,
producing a taller-than-wide output. The standard resolution scale is the
monitor: more wide than tall, like the screen the reader is on.

If a diagram is taller than wide when rendered:

- Reduce nodes per rank. Spread horizontally with subgraphs left-to-right.
- Replace radial hub-and-spoke layouts with a linear horizontal subgraph
  (the subgraph border replaces the hub node — see `introduction.mdx`
  "six surfaces" diagram for the canonical example).
- Use `flowchart LR` at the parent and `direction TB` inside each subgraph
  so subgraphs sit side-by-side and stack their contents internally.
- Split into multiple smaller diagrams. We already enforce "one diagram per
  concern" — an over-tall diagram is usually trying to cover two concerns.

Validate at 1440px (desktop) and 768px (tablet) before merging. Mobile
narrow viewports will always stack, and that is acceptable.

## Phases

- **Phase A** (current): foundation, theme, full nav skeleton, 8 priority diagrams, 9 category overviews, profile banner
- **Phase B** (next): top 10 priority repo pages
- **Phase C** (later): remaining ~20 public repos
- **Phase D** (ongoing): new repos get a docs page on creation; quarterly diagram audit
