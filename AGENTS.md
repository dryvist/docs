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

## Diagram style

Inline ` ```mermaid ` fenced blocks render natively in Mintlify with ELK layout.
One diagram per concern — do not combine.

### The canonical theme directive (use **exactly this**, byte-for-byte)

Every Mermaid block on the site MUST begin with this directive. The
`look:'handDrawn'` is non-negotiable — it gives the diagrams personality
that matches the site's voice. Any deviation (different fontSize, missing
`look`, different palette) is a bug.

```text
%%{init: {'theme':'base','look':'handDrawn','themeVariables':{'fontFamily':'Geist','fontSize':'14px','primaryColor':'#102937','primaryTextColor':'#F4EFE6','primaryBorderColor':'#4FB3A9','lineColor':'#4FB3A9','secondaryColor':'#0B1D2A','tertiaryColor':'#1A2A38','clusterBkg':'rgba(79,179,169,0.08)','clusterBorder':'#4FB3A9'}}}%%
```

To check the site is consistent:

```bash
grep -h '%%{init:' --include='*.mdx' -r . | sort -u | wc -l
# Must return 1.
```

### Shape vocabulary

- Stadium `([Label])` for services and processes
- Cylinder `[(Label)]` for data stores
- Diamond `{Label}` for decisions / gates
- Circle `((Label))` for endpoints / external actors
- Hexagon `{{Label}}` for special-purpose nodes (use sparingly)
- Subgraphs for things that physically or logically co-locate
  (a cluster, a host, a network, a repo group) — **never** for roles or phases

### Canonical classDef palette

Use the semantic class names below. Pick ONE per node based on what it
represents; don't invent new classes per page. This keeps the same colour
meaning the same idea everywhere.

```text
classDef src      fill:#102937,stroke:#E06B4A,stroke-width:2px,color:#F4EFE6;
classDef hop      fill:#102937,stroke:#4FB3A9,stroke-width:2px,color:#F4EFE6;
classDef sink     fill:#102937,stroke:#F4EFE6,stroke-width:2px,color:#F4EFE6;
classDef gate     fill:#102937,stroke:#E06B4A,stroke-width:2.5px,color:#F4EFE6;
classDef external fill:#102937,stroke:#E6B35A,stroke-width:2px,color:#F4EFE6;
classDef host     fill:#102937,stroke:#4FB3A9,stroke-width:2px,color:#F4EFE6;
classDef ai       fill:#102937,stroke:#E06B4A,stroke-width:2px,color:#F4EFE6;
classDef auto     fill:#102937,stroke:#F4EFE6,stroke-width:1.5px,color:#F4EFE6;
```

All classes share the same dark fill (`#102937`) so the diagram blends
with the page; the **border colour** is what carries the semantic
meaning. Text is always paper (`#F4EFE6`) — readable against the dark fill.

| Class | Border | Meaning |
| --- | --- | --- |
| `src` / `ai` / `gate` | Coral `#E06B4A` | Origin, AI-touched, or a decision gate. |
| `hop` / `host` | Bright green `#4FB3A9` | Intermediate hops, the parent shell, hosts. |
| `sink` / `auto` | Paper `#F4EFE6` | Sinks (Splunk indexer), automation steps. |
| `external` | Amber `#E6B35A` | External actors (Internet, AWS DR). |

### Canonical edge palette (indexed `linkStyle`)

```text
%% physical / network — solid bright green
linkStyle 0,1,2 stroke:#4FB3A9,stroke-width:2px;

%% data / telemetry — dashed coral
linkStyle 3,4 stroke:#E06B4A,stroke-width:2px,stroke-dasharray:4 3;

%% control / provisioning — solid paper, lower weight
linkStyle 5 stroke:#F4EFE6,stroke-width:1.5px;

%% external / DR — dotted amber
linkStyle 6 stroke:#E6B35A,stroke-width:1.5px,stroke-dasharray:2 4;

%% abort / failure — dashed dark coral
linkStyle 7 stroke:#C25638,stroke-width:1.5px,stroke-dasharray:2 4;
```

### Fun touches (consistent across the site)

Within the canonical palette, these are **encouraged** for personality:

- **Mix node shapes** purposefully — stadiums for processes, cylinders
  for stores, diamonds for decisions, circles for external actors.
  Variety helps readers parse at a glance.
- **Short labels.** `claude process`, not `the Claude Code subprocess`.
  Two lines max (use `<br/>` sparingly).
- **Edge labels are fine** when they add information (`"renew leases"`,
  `"hands off"`, `"applies"`). Skip them when the chain is obvious.
- **FontAwesome icons** in node labels where they reinforce the shape:
  `[fa:fa-shield Security]`, `[fa:fa-server Host]`. Stick to filled
  variants for visual weight.

## Mermaid — layout rules

Before emitting any mermaid block, run the four checks below. If a
diagram fails ANY check, redesign it before writing the fence.

### Rule 1 · One narrative shape per diagram

Decide which of these four shapes the data IS, then commit to it. If you
can't pick one, you have two concerns — split into two diagrams.

- **LINEAR CHAIN** — `A → B → C → D → E`. Use `flowchart LR`. No subgraphs
  for "roles" or "phases" (they always cause zigzag). To show role/owner,
  color nodes via `classDef`. Don't put them in columns.
- **PARALLEL CONVERGENCE** — two chains that join at the end. Use
  `flowchart LR`. Declare the longer chain first (its nodes appear higher
  in source). ELK will rank the shorter chain on the second row.
- **HIERARCHY / TREE** — a parent with grouped children. Use `flowchart TB`.
  Children grouped in subgraphs with `direction LR`. Cap subgraph contents
  at 5 nodes — overflow gets a second subgraph at the same rank.
- **HUB AND SPOKES** — one central node connected to 4–8 leaves. Use
  `flowchart LR`, put leaves in a single subgraph with `direction TB`. Do
  not draw all edges from hub — chain leaves inside the subgraph with
  invisible `~~~` links so they stack, then one edge hub → first leaf.

### Rule 2 · Subgraphs are for THINGS that live together, not for ROLES

Subgraphs add a visual box. If the box doesn't represent something that
physically or logically co-locates, do NOT make it a subgraph.

- **Forbidden** subgraph names: `Human`, `AI`, `Automation`, `Phase 1`,
  any role or temporal phase. A workflow that hands off
  Human → AI → Human → AI draws a zigzag because arrows cross subgraph
  boundaries N times; visual complexity goes O(n) → O(n²).
- **Allowed** subgraph names — actual co-location: `Proxmox cluster`,
  `Cribl tier`, `UniFi network`, `AWS DR`, `Edge`, `Infrastructure`,
  `Configuration`, `Nix`, `AI Development`, `Observability`.
- For role/owner: use `classDef`, color the nodes. The chain stays linear.

```text
classDef human  fill:#FBF7EE,stroke:#2F7E78,stroke-width:2px;
classDef ai     fill:#FFE7DC,stroke:#E06B4A,stroke-width:2px;
classDef auto   fill:#F4EFE6,stroke:#0B1D2A,stroke-width:1.5px;
class H1,H3 human
class A1,A2,A3 ai
class T1,T2,T3 auto
```

### Rule 3 · Density caps — measured, not vibed

- Max **5 nodes per rank** (per LR column or TB row).
- Max **5 nodes inside any single subgraph**. 6+ → split into two
  subgraphs at the same rank.
- Max **12 nodes per diagram total**. Past 12, you have two diagrams.
- Max **ONE subgraph boundary per edge**. An edge that crosses two
  boundaries means a subgraph is in the wrong place; reorder source
  declarations until each edge crosses ≤1 boundary.

Aspect-ratio sanity check (mentally render before emitting):

- Wider than 2.5:1 → outer direction is wrong (use TB instead)
- Taller than 1:1.2 → too many siblings somewhere (cap at 5)
- Goal: between 16:9 and 4:3.

### Rule 4 · `classDef` always, `linkStyle` by index

- **Never emit per-node `style` statements.** Always use `classDef`. A
  diagram with 8 identical `style X fill:...` lines is a code smell — the
  8 nodes share a category; give them a class.
- **Never emit a global `linkStyle default stroke:#E06B4A`**. It paints
  every edge the same colour and throws away semantic differentiation.
  Color edges by what they represent, using indexed `linkStyle`:

```text
%% edges 0-2 are deployment, edges 3-5 are telemetry
linkStyle 0,1,2 stroke:#2F7E78,stroke-width:2px;
linkStyle 3,4,5 stroke:#E06B4A,stroke-width:2px,stroke-dasharray:4 3;
```

Edge index = declaration order, zero-based. Count carefully.

Standard edge palette for this site:

| Meaning | Style | Colour |
| --- | --- | --- |
| Physical / network | solid | `#2F7E78` (deep green) |
| Data / telemetry | dashed | `#E06B4A` (coral) |
| Control / provisioning | solid, lower weight | `#0B1D2A` (ink) |
| External / DR | dotted | `#E6B35A` (amber) |

### Self-check before emitting

- [ ] Diagram is one of the four shapes (chain / convergence / hierarchy / hub)
- [ ] No subgraph is named for a role (Human, AI, Phase 1, etc.)
- [ ] Every rank ≤5 nodes, every subgraph ≤5 nodes, total ≤12
- [ ] Every edge crosses ≤1 subgraph boundary
- [ ] Zero `style` statements; all visual grouping via `classDef`
- [ ] Zero `linkStyle default`; edges colored by semantic category
- [ ] Mentally rendered aspect ratio between 4:3 and 16:9

If ANY box is unchecked, redesign before responding. Show the self-check
as a comment block ABOVE the mermaid fence so a human can verify your
reasoning:

```text
%% Shape: linear chain. Boundary crossings: 0. Ranks: 9×1.
%% Aspect: ~3:1 (LR). Pass.
```

### When NOT to use Mermaid

If the content is a flat list, a comparison, or sequential steps without
branching, prefer the native Mintlify primitive instead. Mermaid is for
shapes; tables and Steps are for everything else.

| Use | When |
| --- | --- |
| `<Steps>` | Sequential process where each step is one action |
| Table | Categorisation, comparison, "X column maps to Y column" |
| Mermaid | One of the four shapes above; structure ≥ 4 nodes with real edges |
| Prose with bold leads | Relationships that read better as a paragraph |

## Mermaid — drill-down links

Make diagram nodes navigable. Mintlify honors Mermaid's `click`
directive: each node gets a pointer cursor, a hover tooltip, and
navigates on click. This is the canonical way to get "zoom in to a
detail page" behaviour on this site — no custom components, no SVG
export, no JavaScript.

### When to add clicks

Add `click` whenever a node represents a topic that has its own
detail page on this site or its own canonical external URL (a repo,
a dashboard, a vendor doc). This is **the default for context,
overview, and hub diagrams** — not an optional embellishment.

Skip clicks for: nodes that don't map to a real destination (a
transient process, an abstract concept like "Code" or "Ship"), or
destinations that are still TODO and would 404.

### Canonical syntax — INTERNAL links only

Use only this form. One `click` per line. Always include a tooltip —
for hover-only users it's the only signal of where the click goes.

```text
click NodeId "/path/to/internal/page" "Short hover tooltip"
```

Place the `click` block AFTER all `classDef` definitions and `class`
assignments, and BEFORE any `linkStyle` lines.

### External URLs — do NOT click them from the diagram

Mermaid has open bugs
([#3077](https://github.com/mermaid-js/mermaid/issues/3077),
[#5550](https://github.com/mermaid-js/mermaid/issues/5550)) where
`_blank` is parsed but silently dropped from the rendered SVG.
Clicking an external link on a node navigates the current tab away —
the diagram disappears, the back button is the only way home.

Workaround: put external links in a **table** or **CardGroup**
directly under the diagram. Mintlify automatically adds
`target="_blank" rel="noreferrer"` to external markdown anchors, so
those open in a new tab correctly.

Inside the Mermaid block, click ONLY the internal nodes; leave the
external-pointing nodes without a `click` directive and add an HTML
comment naming where the repo lives:

```text
flowchart LR
  Tool([Tool]) --> Pack([cc-edge-foo])
  click Tool "/observability/overview" "Tool overview"
  %% No click on Pack — external repo lives in the table below.
```

Then the table directly under the diagram carries the external link:

```text
| Repo | Notes |
| --- | --- |
| [cc-edge-foo](https://github.com/owner/cc-edge-foo) | What it does |
```

When the Mermaid bugs are fixed upstream, this convention will
expand to allow external clicks; until then, internal-only.

### Self-check addition

Append these to the existing self-check before emitting any context,
overview, or hub diagram:

- [ ] Every node whose label names a topic with a detail page has a `click` line
- [ ] All `click` URLs are site-relative paths (`/security/overview`), never external `https://...`
- [ ] External repo URLs live in a table or CardGroup beside the diagram, NOT in `click` directives
- [ ] Tooltips are ≤40 chars and describe the destination (not the node)
- [ ] No `click` points at a page that doesn't exist yet (would 404)
- [ ] CI Mermaid validation passes (`./scripts/validate-mermaid.sh` from repo root)

### Example

```text
flowchart LR
  Ovr([Overview]) --> Detail([Detail page])
  classDef hop fill:#102937,stroke:#4FB3A9,stroke-width:2px,color:#F4EFE6;
  class Ovr,Detail hop
  click Ovr "/overview" "Read the full overview"
  click Detail "/overview/detail" "The deep dive"
```

### When NOT to use clicks

- **Pure sequence / timeline diagrams** where every node is a stage
  in one flow (e.g. CI step "Lint") — clicks would imply each stage
  has its own page when the whole pipeline is one page.
- **Diagrams in repo READMEs that render on GitHub.** GitHub's
  Mermaid renderer honors `click` differently and absolute URLs are
  required there. Keep site-relative click diagrams on
  docs.jacobpevans.com; if a README needs an interactive diagram,
  link out to the relevant docs page instead.

## Phases

- **Phase A** (current): foundation, theme, full nav skeleton, 8 priority diagrams, 9 category overviews, profile banner
- **Phase B** (next): top 10 priority repo pages
- **Phase C** (later): remaining ~20 public repos
- **Phase D** (ongoing): new repos get a docs page on creation; quarterly diagram audit
