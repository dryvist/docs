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

The canonical, reader-facing standard — information architecture, page naming,
frontmatter (`page_type`), navigation density, and cited sources — is the published
page [`conventions/documentation-standards`](conventions/documentation-standards.mdx).
Author new pages to it by default.

## Technical writing

Follow [Google technical-writing style](https://developers.google.com/tech-writing/one),
aimed at an 8th-grade reading level. Short sentences, one idea each. Plain words
over Latinate ones. Active voice. Keep terms of art, but define each one the
first time you use it.

Rewrite big words and long sentences into plain, direct ones:

| Instead of | Write |
| --- | --- |
| "utilize the configuration to facilitate deployment" | "use the config to deploy" |
| "In order to authenticate, it is necessary that you provide a token" | "To authenticate, provide a token" |
| "The build was terminated by the runner due to a timeout" | "The runner stopped the build after a timeout" |
| "Prior to commencing, ensure the prerequisites are satisfied" | "Before you start, check the prerequisites" |

Never cut a sentence to fit a character limit. If a line runs long, restructure
it — split the sentence, use a bullet, or make a table — rather than reflowing
the text to a fixed width.

When your runtime has Claude Code skill support, invoke the `elements-of-style`
plugin's `writing-clearly-and-concisely` skill before writing prose.

## Content boundaries — PUBLIC information only

- No real internal IP addresses (use placeholders)
- No real internal hostnames (use plausible-but-fictional names)
- No references to private repos — treat them as if they don't exist
- No credentials, tokens, or sensitive data

If a repo's GitHub visibility is `PRIVATE`, it does not appear here. Verify with `gh repo view OWNER/REPO --json visibility` when in doubt.

## Diagrams

Every repo with non-trivial architecture ships diagrams, rendered as inline
Mermaid. The reader-facing summary — format, placement, what to draw, and when
to reach for a table or `<Steps>` instead — is the published page
[`conventions/diagramming`](conventions/diagramming.mdx).

The full authoring rules are split across two canonical pages. Follow both when
you emit any Mermaid on this site:

- [`conventions/mermaid-style`](conventions/mermaid-style.mdx) — the byte-for-byte
  theme directive, shape vocabulary, `classDef` and `linkStyle` palettes, the four
  narrative shapes, and density caps.
- [`conventions/mermaid-links`](conventions/mermaid-links.mdx) — making diagram
  nodes navigable with the `click` directive, and the external-URL workaround.

## Phases

- **Phase A** (current): foundation, theme, full nav skeleton, 8 priority diagrams, 9 category overviews, profile banner
- **Phase B** (next): top 10 priority repo pages
- **Phase C** (later): remaining ~20 public repos
- **Phase D** (ongoing): new repos get a docs page on creation; quarterly diagram audit
