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
One diagram per concern — do not combine.

### The canonical theme directive (use **exactly this**, byte-for-byte)

Every Mermaid block on the site MUST begin with this directive. The
`look:'handDrawn'` is non-negotiable — it gives the diagrams personality
that matches the site's voice. Any deviation (different fontSize, missing
`look`, different palette) is a bug.

```text
%%{init: {'theme':'base','look':'handDrawn','themeVariables':{'fontFamily':'Geist','fontSize':'14px','primaryColor':'#FBF7EE','primaryTextColor':'#0B1D2A','primaryBorderColor':'#2F7E78','lineColor':'#2F7E78','secondaryColor':'#F4EFE6','tertiaryColor':'#FFE7DC','clusterBkg':'rgba(47,126,120,0.06)','clusterBorder':'#2F7E78'}}}%%
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
classDef src      fill:#FFE7DC,stroke:#E06B4A,stroke-width:2px,color:#0B1D2A;
classDef hop      fill:#FBF7EE,stroke:#2F7E78,stroke-width:2px,color:#0B1D2A;
classDef sink     fill:#F4EFE6,stroke:#0B1D2A,stroke-width:2px,color:#0B1D2A;
classDef gate     fill:#FFE7DC,stroke:#E06B4A,stroke-width:2.5px,color:#0B1D2A;
classDef external fill:#F4EFE6,stroke:#E6B35A,stroke-width:2px,color:#0B1D2A;
classDef host     fill:#FBF7EE,stroke:#2F7E78,stroke-width:2px,color:#0B1D2A;
classDef ai       fill:#FFE7DC,stroke:#E06B4A,stroke-width:2px,color:#0B1D2A;
classDef auto     fill:#F4EFE6,stroke:#0B1D2A,stroke-width:1.5px,color:#0B1D2A;
```

| Class | Meaning |
| --- | --- |
| `src` / `ai` / `gate` | Coral. Origin of a flow, AI-touched, or a decision gate. |
| `hop` / `host` | Paper-card + green. Intermediate hops, the parent shell, hosts. |
| `sink` / `auto` | Paper + ink. Sinks (Splunk indexer), automation steps. |
| `external` | Paper + amber. External actors (Internet, AWS DR). |

### Canonical edge palette (indexed `linkStyle`)

```text
%% physical / network — solid green
linkStyle 0,1,2 stroke:#2F7E78,stroke-width:2px;

%% data / telemetry — dashed coral
linkStyle 3,4 stroke:#E06B4A,stroke-width:2px,stroke-dasharray:4 3;

%% control / provisioning — solid ink, lower weight
linkStyle 5 stroke:#0B1D2A,stroke-width:1.5px;

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

## Phases

- **Phase A** (current): foundation, theme, full nav skeleton, 8 priority diagrams, 9 category overviews, profile banner
- **Phase B** (next): top 10 priority repo pages
- **Phase C** (later): remaining ~20 public repos
- **Phase D** (ongoing): new repos get a docs page on creation; quarterly diagram audit
