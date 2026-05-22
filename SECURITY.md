# Security

This file is the GitHub-standard entry point for security disclosures and
the public security posture for this repository.

For the substantive security documentation — golden laws, secrets-management
tools, local AI isolation guarantees, and cross-tool flow diagrams — see the
consolidated section on the docs site:

- **[Security overview](https://docs.jacobpevans.com/security/overview)**
- **[Golden laws](https://docs.jacobpevans.com/security/golden-laws)** — the
  15 non-negotiable rules applied across every JacobPEvans repo.
- **[How it fits together](https://docs.jacobpevans.com/security/how-it-fits-together)**
- **[Local AI isolation](https://docs.jacobpevans.com/security/local-ai-isolation)**

The docs site is the single public source of truth for this material. Per-repo
`README.md` files keep only the literal commands they need; the architecture
narrative lives in one place.

## Reporting a vulnerability

This repository is a documentation site (Mintlify-rendered MDX). It contains
no executable code beyond a Nix dev shell and a Mintlify CLI install path. If
you find a security-relevant issue — credential leak, accidental private-repo
reference, broken-link to a sensitive resource — open a private security
advisory via GitHub's
["Report a vulnerability"](https://github.com/JacobPEvans/docs/security/advisories/new)
flow, or open a regular issue if the matter is not sensitive.

For security concerns in the *documented* tools (Doppler, BWS, SOPS, etc.),
report upstream to those projects directly.

## License

This repository is licensed [MIT](./LICENSE). Documentation content (the MDX
files and diagrams) is also MIT — reuse, fork, and cite freely with attribution.
