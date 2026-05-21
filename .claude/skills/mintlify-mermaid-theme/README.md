# mintlify-mermaid-theme

Project-level Claude Code skill that generates Reef Green-themed Mermaid diagrams with pinned theme variables and house shape conventions.

## What you get

- Accepts a plain-language intent description and returns a validated Mermaid fenced block.
- Pins the Reef Green `%%{init: ...}%%` directive on every diagram (colors, `handDrawn` look, Geist font).
- Enforces a consistent shape vocabulary: rounded boxes for services, cylinders for data stores, diamonds for decisions, circles for endpoints.
- Applies `style` overrides — Coral border for focal nodes, Reef Green for neighbors.
- Validates the block through `mmdc` before returning.

## What you do NOT get

- No PNG/SVG rendering — the Mintlify build pipeline handles that.
- No replacement of `obsidian-visual-skills:mermaid-visualizer` — this wraps it for docs-specific conventions.
- No authoring of surrounding page content — use `mintlify-page-author` for that.

## Installation

This skill is project-scoped — it ships inside the `JacobPEvans/docs` repo and is loaded automatically by Claude Code when a session opens in this repo.

```bash
git clone https://github.com/JacobPEvans/docs ~/git/docs/main
cd ~/git/docs/main
# Claude Code picks up .claude/skills/mintlify-mermaid-theme/ automatically.
```

Requirements:

- Claude Code 4.x or newer (skill API support).
- `nix` and `direnv` for the `mmdc` validation step (`nix develop`).

## Usage

From a Claude Code session in this repo:

```
/mintlify-mermaid-theme
```

Or describe what you want:

- "Add a diagram showing how nix-ai consumes models from Hugging Face and writes results to S3."
- "Visualize the relationship between terraform-proxmox and ansible-proxmox."
- "Draw the data flow for the MLX benchmark pipeline."

The skill activates on those triggers and prompts for intent if not supplied.

### How it works in plain English

1. You describe the relationship in plain language.
2. The skill identifies nodes (services, stores, decisions, endpoints) and edges (relationships).
3. It picks shapes from the house vocabulary (rounded boxes, cylinders, diamonds, circles).
4. It emits the Mermaid block with the Reef Green `%%{init}%%` directive and `style` overrides.
5. It validates through `mmdc` and returns the final block, ready to paste into an MDX file.

## Limitations

- Orientation defaults to `LR`; request `TD` explicitly for top-down hierarchies.
- Complex diagrams with more than 12 nodes may need manual cleanup after generation.
- `mmdc` validation requires the dev shell (`nix develop`); skip if unavailable and let CI catch it instead.

## Files in this directory

- `SKILL.md` — the skill definition (loaded by Claude Code when the skill activates).
- `README.md` — this file.

## Composes with

- **`mintlify-page-author`** — calls this skill to generate the `## How it fits` diagram on every new page.
- **`mintlify-build-guard`** — validates all Mermaid blocks in the repo via `mmdc`; diagrams from this skill should pass automatically.
