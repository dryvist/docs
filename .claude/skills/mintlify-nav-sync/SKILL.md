---
name: mintlify-nav-sync
description: Keep docs.json sidebar in sync with the filesystem. Detect orphan pages (file exists, not in nav), missing files (nav references a non-existent page), and propose ordered group structures. Triggers on "/mintlify-nav-sync", "sync the nav", "check sidebar drift", "find orphan pages", "update docs.json navigation".
---

# mintlify-nav-sync

Read `docs.json` and walk the filesystem for `.mdx` files, then emit a unified patch that brings the two into alignment. Read-only by default; apply with `--apply`.

## When to use

- After scaffolding a new page (it exists on disk but isn't listed in `docs.json` yet).
- After deleting or renaming a page (the nav reference becomes stale).
- Periodic health check to find ordering drift within sidebar groups.
- Before opening a PR to ensure the sidebar is consistent with the file tree.

## When NOT to use

- Rewriting the entire `docs.json` schema or adding new sidebar tabs. This skill patches within existing groups only.
- Authoring page content. Use `mintlify-docs-update` for scaffolding, `mintlify-page-author` for prose.
- Multi-tab navigation restructuring — flag, don't fix.

## Workflow

### Step 1 — Load docs.json

Read `docs.json` from the repo root. Extract the flat list of all page paths from `navigation.tabs[*].groups[*].pages[*]`. These are relative paths without the `.mdx` extension (e.g., `infrastructure/ansible-proxmox`).

```bash
gh api repos/JacobPEvans/docs/contents/docs.json \
  --jq '.content' | base64 -d | \
  jq '[.navigation.tabs[].groups[].pages[]] | flatten'
```

### Step 2 — Walk the filesystem

List all `.mdx` files under the repo root, excluding the `snippets/` directory and the root-level meta files (`introduction.mdx`, `how-it-fits-together.mdx` are included).

```bash
gh api repos/JacobPEvans/docs/git/trees/main?recursive=1 \
  --jq '[.tree[] | select(.type == "blob") | select(.path | endswith(".mdx")) | select(.path | startswith("snippets/") | not) | .path | ltrimstr(".mdx") | sub("\\.mdx$"; "")]'
```

Convert each `.mdx` path to the nav-reference format by stripping the `.mdx` suffix. Store as `filesystem_pages[]`.

### Step 3 — Diff

Compute three sets:

| Set | Definition |
| --- | --- |
| `orphans` | `filesystem_pages` − `nav_pages` — files on disk but absent from nav |
| `ghosts` | `nav_pages` − `filesystem_pages` — nav entries with no backing file |
| `ordering_drift` | groups where the page order doesn't match the canonical rule (see Step 4) |

Report all three sets before proposing any changes.

### Step 4 — Ordering rules

For each group, the canonical order is:

1. `<group-dir>/overview` always first, if it exists.
2. Then all other pages in ascending alphabetical order of their path.

**Exceptions (custom ordering preserved):**

- `"Start here"` group: fixed order `["introduction", "how-it-fits-together"]`. Never reorder.
- `"About"` group: preserve current order exactly. Never reorder.

If a group's current order already satisfies the rules, mark it `OK`. If it doesn't, add it to `ordering_drift` with the proposed corrected order.

### Step 5 — Emit patch

Print a `git diff`-style patch to stdout:

```
--- a/docs.json
+++ b/docs.json
@@ ... @@
 context lines
-removed line
+added line
```

The patch must:

- Insert each orphan path into the correct group's `pages` array, in sorted position.
- Remove each ghost path.
- Reorder any group listed in `ordering_drift`.

If the diff is empty (nothing to change), print `✅ docs.json is already in sync.` and exit.

### Step 6 — Apply (--apply flag only)

If `--apply` was specified:

1. Read the current `docs.json` SHA:

   ```bash
   gh api repos/JacobPEvans/docs/contents/docs.json --jq '.sha'
   ```

2. Compute the updated JSON in memory (apply the patch logic programmatically — never pipe through `patch` or shell redirection).

3. PUT the new content via the Contents API:

   ```bash
   gh api repos/JacobPEvans/docs/contents/docs.json -X PUT \
     -f message="chore(nav): sync docs.json with filesystem" \
     -f content="<base64-encoded new content>" \
     -f branch="<current-branch>" \
     -f sha="<file-sha>"
   ```

4. Print a summary: `Updated docs.json — N insertions, M deletions, P reorders.`

If `--apply` was NOT specified, print:

```
Run /mintlify-nav-sync --apply  to write the patch.
```

## Flags

- `--apply` — write the patch to `docs.json` on the current branch (default: dry-run).
- `--group <name>` — restrict the scan to a single sidebar group (case-insensitive).
- `--no-reorder` — skip ordering drift checks; report orphans and ghosts only.

Flags are interpreted manually in the conversation; there is no CLI binary.

## Output format

```
=== mintlify-nav-sync report ===

Orphans (on disk, not in nav):   N
  + infrastructure/my-new-page

Ghosts (in nav, no backing file): M
  - tools/deleted-page

Ordering drift:                   P group(s)
  infrastructure: [current] → [proposed]

Patch preview:
--- a/docs.json
+++ b/docs.json
...

Run /mintlify-nav-sync --apply to write the patch.
```

## Edge cases

- **New top-level groups** — if `filesystem_pages` contains paths under a directory that has no corresponding sidebar group, flag them as `ungrouped orphans` and do NOT auto-create a new group. Ask the author which group to place them in.
- **`snippets/` directory** — always excluded. Never add snippets to the nav.
- **Root-level pages** (`introduction`, `how-it-fits-together`) — treated as regular nav entries; orphan/ghost detection applies normally.
- **Nested groups** — `docs.json` may have groups with nested page arrays. Walk all levels; the same orphan/ghost logic applies.

## Related

- `mintlify-docs-update` — scaffolds new MDX pages and adds them to `docs.json`.
- `mintlify-build-guard` — runs a full validation suite including broken-link checks and frontmatter validation.
- See open issues with label `skill` for planned improvements.
