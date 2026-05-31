#!/usr/bin/env bash
# Secret-scan gate for the public docs repo (docs.jacobpevans.com).
#
# Scans the committed tree with gitleaks. When the private org ruleset is present
# as the GITLEAKS_PRIVATE_CONFIG secret (same-repo PRs + push to main), it is used
# with --redact so matches never appear in logs. Fork PRs cannot read the secret
# and fall back to the committed generic .gitleaks.toml (credential detection only).
# Fail-closed: any finding exits non-zero and fails the job.
#
# gitleaks is installed from its pinned Apache-2.0 release binary rather than the
# gitleaks GitHub Action, which requires a paid license for organization accounts.
set -euo pipefail

VERSION="8.30.1"
SHA256="551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb"
ASSET="gitleaks_${VERSION}_linux_x64.tar.gz"

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${VERSION}/${ASSET}" -o "${tmp}/${ASSET}"
echo "${SHA256}  ${tmp}/${ASSET}" | sha256sum -c -
tar -xzf "${tmp}/${ASSET}" -C "${tmp}" gitleaks

# Scan exactly the committed content (no .git, no untracked scratch).
mkdir -p "${tmp}/tree"
git archive HEAD | tar -x -C "${tmp}/tree"

config=".gitleaks.toml"
if [ -n "${GITLEAKS_PRIVATE_CONFIG:-}" ]; then
  config="${tmp}/private.toml"
  printf '%s' "${GITLEAKS_PRIVATE_CONFIG}" > "${config}"
  echo "Scanning with the private org ruleset (redacted)."
else
  echo "Private ruleset unavailable (fork PR?) — using the committed generic baseline."
fi

"${tmp}/gitleaks" detect --no-git --no-banner --redact \
  --source "${tmp}/tree" --config "${config}"
echo "Secret scan passed: no leaks found."
