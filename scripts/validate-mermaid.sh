#!/usr/bin/env bash
# Validate every ```mermaid block in every .mdx file with mmdc.
#
# mmdc only knows the .md extension as "markdown — extract mermaid fences."
# .mdx is treated as raw mermaid source, so we copy each .mdx to a temp .md
# (preserving the original path in the filename for error messages). Any
# parse error returns non-zero, failing CI.
#
# Requires: mmdc (mermaid-cli) on PATH and a Chromium reachable via PATH or
# PUPPETEER_EXECUTABLE_PATH. Local: `nix develop` provides mmdc; CI installs both.
set -euo pipefail

fail=0
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
while IFS= read -r f; do
  grep -q '^```mermaid' "$f" || continue
  md="$tmp/$(echo "$f" | tr '/' '_').md"
  cp "$f" "$md"
  mmdc -i "$md" -o "$md.out.svg" --quiet 2>/tmp/_validate-mermaid.err || true
  # mmdc exits 0 even on parse errors (upstream bug); rely on stderr instead.
  # With --quiet, any stderr output from mmdc indicates a real problem.
  if [[ -s /tmp/_validate-mermaid.err ]]; then
    echo "::error file=${f}::Mermaid validation failed" >&2
    sed 's/^/  /' /tmp/_validate-mermaid.err >&2
    fail=1
  fi
done < <(find . -name '*.mdx' -not -path '*/node_modules/*' -not -path '*/.git/*')
exit "$fail"
