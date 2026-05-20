---
name: mintlify-page-author
description: Author a single Mintlify docs page from a GitHub repo URL or free-text topic, enforcing the Reef Green theme, house voice, and tier word-count caps. Use when asked to "write a docs page for <repo>", "author a page", "fill in the prose for <page>", or "/mintlify-page-author". Complements mintlify-docs-update (which scaffolds shells) by generating complete prose.
---

# mintlify-page-author

Author a single, fully-written Mintlify page from a GitHub repo URL or a free-text topic. Enforces the Reef Green theme, house voice, the tier word-count cap, and the standard component vocabulary (Card grid + Steps + Frame + Mermaid).

## When to use

- A repo page shell (from `mintlify-docs-update`) needs prose filled in.
- A topic or concept page needs to be written from scratch.
- A page is flagged over-budget and needs a split suggestion.

## When NOT to use

- Batch-scaffolding multiple pages — use `mintlify-docs-update`.
- Rewriting `docs.json` sidebar order — use `mintlify-nav-sync`.
- Generating Mermaid diagrams independently — delegate to `mintlify-mermaid-theme`.
- Updating an existing, already-published page — make targeted edits instead.

## Inputs

- **GitHub repo URL** (preferred) — e.g. `https://github.com/JacobPEvans/terraform-proxmox`.
- **Free-text topic** — e.g. `"write a page about the Splunk observability stack"`.
- **Target path** (optional) — if not given, derive from repo name and sidebar categorisation.
- **Tier override** (optional) — `--tier 1` or `--tier 2`. Default: path-derived (see below).

## Workflow

### Step 1 — Resolve inputs

1. If a GitHub repo URL was given, extract `owner/repo`.
2. Fetch repo metadata:

   ```bash
   gh repo view <owner>/<repo> --json name,description,primaryLanguage,repositoryTopics,url
   ```

3. Fetch `README.md`:

   ```bash
   gh api repos/<owner>/<repo>/contents/README.md --jq '.content' | base64 -d
   ```

4. If no README exists, note the gap and continue — the author will fill placeholders.

### Step 2 — Resolve tier and target path

Determine tier from the target path when given:

- Path ends with `/overview.mdx` or equals `introduction.mdx` → **tier 1** (word cap: 450).
- All other paths → **tier 2** (word cap: 900 warn / 1200 hard).
- `--tier` flag overrides path inference.

If no target path was given, derive it from the sidebar mapping used by `mintlify-docs-update`:

| Repo name pattern | Sidebar group | Path prefix |
| --- | --- | --- |
| `terraform-*`, `ansible-*` (excl. `ansible-splunk`) | Infrastructure | `infrastructure/` |
| `nix-*` | Nix Ecosystem | `nix/` |
| `ai-*`, `claude-code-*`, `ai-workflows`, `raycast-*` | AI Development | `ai-development/` |
| `cc-edge-*`, `cc-stream-*`, `VisiCore_*`, `*splunk*` | Observability | `observability/` |
| Everything else | Tools | `tools/` |

### Step 3 — Check for existing page

```bash
gh api repos/JacobPEvans/docs/contents/<target-path> 2>/dev/null | jq -r '.name // empty'
```

If a file exists at the target path: **stop and emit a diff for review instead of overwriting**.

### Step 4 — Generate page content

Produce a complete MDX file following the house structure. Fill every section with prose derived from the README and repo metadata:

```mdx
---
title: "<repo-name>"
description: "<one-sentence description from repo description field>"
tier: <1 or 2>
---

import { RepoMeta, RepoFit } from "/snippets/repo-summary.mdx";

> <optional blockquote tagline — max 14 words, present-tense, action-oriented>

<RepoMeta
  language="<primary language>"
  status="<active | archived | experimental>"
  lastActive="<relative time from pushedAt>"
  repoUrl="<repo URL>"
/>

<brief 1-2 sentence intro placing the repo in its sidebar group context>

## What it does

- <concrete capability 1 — starts with a verb>
- <concrete capability 2>
- <concrete capability 3>
- <optional 4th bullet>
- <optional 5th bullet>

## How it fits

Delegate Mermaid generation to `mintlify-mermaid-theme` (or use the Reef Green preset below when that skill is unavailable):

```mermaid
%%{init: {'theme':'base','look':'handDrawn','themeVariables':{'primaryColor':'#4FB3A9','primaryTextColor':'#F4EFE6','primaryBorderColor':'#2F7E78','lineColor':'#E06B4A','secondaryColor':'#102937','tertiaryColor':'#0B1D2A','clusterBkg':'transparent','clusterBorder':'#4FB3A9','fontFamily':'Geist','fontSize':'15px'}}}%%
flowchart LR
  Repo(["<repo-name>"]) -->|<edge label>| Neighbor1(["<neighbor 1>"])
  Repo -->|<edge label>| Neighbor2(["<neighbor 2>"])

  style Repo fill:transparent,stroke:#E06B4A,stroke-width:4px,color:#F4EFE6
  style Neighbor1 fill:transparent,stroke:#4FB3A9,stroke-width:2px,color:#F4EFE6
  style Neighbor2 fill:transparent,stroke:#4FB3A9,stroke-width:2px,color:#F4EFE6

  linkStyle default stroke:#E06B4A,stroke-width:3px
\`\`\`

<RepoFit>
<one-line boundary statement: what this repo owns vs. what its neighbors own>
</RepoFit>

## Getting started

<Steps>
  <Step title="<imperative step title 1>">
    <step body with commands or prose>
  </Step>
  <Step title="<imperative step title 2>">
    <step body>
  </Step>
  <Step title="<imperative step title 3>">
    <step body>
  </Step>
</Steps>

## Related repos

<CardGroup cols={2}>
  <Card title="<related repo 1 title>" icon="<lucide icon>" href="<in-site path or GitHub URL>">
    <one-line description>
  </Card>
  <Card title="<related repo 2 title>" icon="<lucide icon>" href="<in-site path or GitHub URL>">
    <one-line description>
  </Card>
  <Card title="Source on GitHub" icon="github" href="<repo URL>">
    Issues, releases, full README.
  </Card>
</CardGroup>
\`\`\`

#### Prose rules

- **House voice**: second-person, present-tense, concrete verbs. No "leverages", "facilitates", "robust", "seamless".
- **Bullets**: start with a verb ("Provisions", "Enforces", "Exposes"). Three to five — remove unused slots.
- **Steps**: 3-5 in `<Steps>`. Titles in imperative form. Bodies contain runnable commands where possible.
- **Cards**: up to 3 related repos plus the always-present "Source on GitHub" Card.
- **Tagline**: present-tense, ≤14 words, no trailing period.

### Step 5 — Word-count guard

Count words in the generated output (excluding frontmatter YAML and code fences):

```bash
echo "<page-content>" | sed '/^---/,/^---/d' | sed 's/```.*```//g' | wc -w
```

- Tier 1 ≤ 450 words → pass.
- Tier 2 ≤ 900 words → pass; 901-1200 → warn and suggest split; >1200 → fail, propose sub-pages.

When over budget, emit a split suggestion: list candidate sub-page titles and paths rather than truncating prose.

### Step 6 — Emit for review

Never write the file directly. Output the full generated MDX as a diff block and ask the author to confirm before writing:

```
The following page is ready to write to `<target-path>`. Confirm to proceed, or request changes.
```

After confirmation, write the file with the `Write` or `Edit` tool. Then remind the author to run:

```bash
nix develop --command mint broken-links
```

and to delegate Mermaid generation to `mintlify-mermaid-theme` if the diagram needs refinement.

## Outputs

- A fully authored MDX file at `<target-path>`.
- A word-count summary: `<N> words — within Tier <1|2> budget` or a split suggestion if over budget.
- A reminder to add the path to `docs.json` via `mintlify-nav-sync` if it is a new page.

## Composition

| Skill | Role |
| --- | --- |
| `mintlify-docs-update` | Scaffolds shells with placeholder tokens that this skill fills. |
| `mintlify-mermaid-theme` | Generates or refines the Reef Green Mermaid diagram. |
| `mintlify-nav-sync` | Inserts the new path into `docs.json` after this skill writes the page. |
| `mintlify-build-guard` | Validates the finished page (broken links, frontmatter, word count). |

## Flags (interpreted in chat, no CLI binary)

- `--tier 1 | --tier 2` — override tier inference.
- `--dry-run` — emit the generated content without writing the file.
- `--diff-only` — show only the diff against the existing shell, not the full file.
