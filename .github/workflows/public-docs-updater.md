---
engine: copilot
imports:
  - githubnext/agentics/workflows/doc-updater.md@main
on:
  schedule: daily
  workflow_dispatch:
permissions:
  contents: read
  issues: read
  pull-requests: read
network:
  allowed:
    - defaults
    - github
safe-outputs:
  create-pull-request:
    expires: 2d
    title-prefix: "[docs] "
    labels: [documentation, automation]
    draft: false
    protected-files: fallback-to-issue
---

# Public Docs Updater

<!--
Thin GH-AW wrapper. Upstream provides the documentation-updater workflow shape;
this local prompt changes the scope to the public dryvist portfolio docs.
Run `gh aw compile public-docs-updater --action-tag v0.68.3` after edits.
-->

You are updating the public documentation repository for `docs.jacobpevans.com`.

The upstream imported instructions are the baseline for documentation quality, style matching, safe output, and PR creation. This wrapper overrides the activity scope and target repo rules below.

## Target repository

- Treat the current checkout as the `dryvist/docs` repository.
- Update only public-facing docs in this repository.
- Never create PRs against source repositories.
- Create at most one documentation PR for the whole run.

## Source repositories

Scan public repositories under the `dryvist` owner.

Skip:

- `dryvist/docs`
- archived repositories
- forks
- private repositories

## Activity window

Use the last 24 hours.

Collect all update signals together before editing docs. Do not edit one
repository at a time. Build a single activity digest first, then decide what
public docs need to change from that full digest.

- merged pull requests with `mergedAt` inside the window
- open pull requests with `updatedAt` inside the window
- draft pull requests with `updatedAt` inside the window

For each included PR, preserve and use:

- repository
- PR number and URL
- title
- body/description
- state
- draft status
- labels
- author
- base and head refs
- updated time
- merged time, when present

Use merged PRs as shipped/current behavior. Use open or draft PRs only as in-progress or upcoming context. Do not describe open or draft work as already shipped.

## Suggested collection flow

Use GitHub tooling or `gh` commands to gather a complete digest before editing. A suitable CLI shape is:

```bash
SINCE="$(date -u -d '1 day ago' +%Y-%m-%dT%H:%M:%SZ)"
gh repo list dryvist --visibility public --limit 1000 --json name,isArchived,isFork |
  jq -r '.[] | select(.name != "docs" and .isArchived == false and .isFork == false) | .name'
```

Then, for each repository, collect recent merged and open PR metadata with
titles and bodies. Use a high limit so all public PR activity in the window is
considered together:

```bash
gh pr list --repo "dryvist/REPO" --state all --limit 1000 \
  --search "updated:>=$SINCE" \
  --json number,title,body,state,isDraft,updatedAt,mergedAt,url,labels,author,baseRefName,headRefName
```

Filter the results so closed PRs are included only when `mergedAt` is inside the window, while open and draft PRs are included when `updatedAt` is inside the window.

If a repository appears to have more than 1000 updated PRs inside the window,
switch to paginated GitHub API calls for that repository before editing docs.

## Documentation rules

- Keep all content public-safe.
- Do not mention private repositories, private hostnames, real internal IPs, credentials, or sensitive operational details.
- Prefer updating existing docs pages over adding new pages.
- If a new page is necessary, add it to `docs.json`.
- Follow the existing Mintlify MDX style.
- Preserve the original voice and structure of nearby docs.
- Include source PR links in the final PR body.

## PR output

If documentation changes are needed, create one PR with:

- a concise `[docs] ...` title
- a summary of docs changed
- a list of source PRs grouped by merged vs in-progress
- a note that open/draft PRs were treated as in-progress context only

If no docs changes are needed, exit without a PR.
