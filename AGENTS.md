# Agent instructions for docs.jacobpevans.com

This is the generated Mintlify projection for the public documentation site.
Documentation is authored in a separate private source; this repository is a
publication target, not a knowledge base.

## Generated-content boundary

- AI agents never author or edit content in this repository.
- Pages, assets, and `docs.json` arrive only in a publisher-generated pull request.
- Generated pull requests come only from the publisher identity and merge
  automatically once every required check passes. No separate human approval
  gates a generated pull request.
- Humans may maintain repository control-plane files such as workflows and this
  policy, but must not hand-edit the generated projection.
- Raw live secrets, private keys, and recovery codes are prohibited in every
  documentation source.

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

The canonical authoring standard lives in the private source repository. Treat
the rendered conventions pages here as generated output.

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

These rules describe publisher output. Do not write prose directly here.

## Content boundaries — PUBLIC information only

- No real internal IP addresses (use placeholders)
- No real internal hostnames (use plausible-but-fictional names)
- No references to private repos — treat them as if they don't exist
- No credentials, tokens, or sensitive data

The publisher enforces this boundary before it opens a public pull request.

## Diagrams

Every repo with non-trivial architecture ships diagrams, rendered as inline
Mermaid. The reader-facing summary — format, placement, what to draw, and when
to reach for a table or `<Steps>` instead — is the published page
[`conventions/diagramming`](/conventions/diagramming).

The full authoring rules are split across two canonical pages. Follow both when
you emit any Mermaid on this site:

- [`conventions/mermaid-style`](/conventions/mermaid-style) — the byte-for-byte
  theme directive, shape vocabulary, `classDef` and `linkStyle` palettes, the four
  narrative shapes, and density caps.
- [`conventions/mermaid-links`](/conventions/mermaid-links) — making diagram
  nodes navigable with the `click` directive, and the external-URL workaround.

## Paired pages

Until the generated projection is live, some pages here have a counterpart page
in the private authoring source. A change to such a page must name the
counterpart path in the pull request body and link the paired pull request. A
page with no counterpart says so explicitly instead.

The pairing table itself is not kept here. It lives with the architecture
decision record in the private source, so there is one list, in one place,
reviewed alongside the decision.
