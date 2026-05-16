# docs.jacobpevans.com

Source for the documentation site at
[docs.jacobpevans.com](https://docs.jacobpevans.com).

Built with [Mintlify](https://mintlify.com). Content is MDX plus the
`docs.json` config. All MDX, diagrams, and configuration live in this repo, so
the site is fully portable to Docusaurus, Nextra, or any MDX-aware static site
generator if Mintlify is ever unavailable.

## Installation

Requires [Nix with flakes](https://nixos.org/) (recommended) or Node 20+
installed manually.

```bash
nix develop      # Dev shell: mermaid-cli + node 20 + jq
npm i -g mint    # First time only: install the Mintlify CLI
```

## Usage

```bash
mint dev           # Preview at http://localhost:3000
mint broken-links  # Validate internal links
```

## Deploy

Push to `main` triggers an auto-deploy via the Mintlify GitHub app. PRs land
via the standard GitHub flow. Preview branches are a paid Mintlify feature, so
verify locally with `mint dev` before merge.

## DNS

`docs.jacobpevans.com` is a CNAME to `cname.mintlify-dns.com`. Mintlify
provisions HTTPS automatically within ~24h of DNS propagation.

## Identity system

Reef Green primary `#4FB3A9`, Coral accent `#E06B4A`, Ink dark bg `#0B1D2A`,
Paper light bg `#F4EFE6`. Geist for display, JetBrains Mono for terminal-style
accents.

## Structure

```text
docs.json                      Mintlify config (theme, palette, fonts, nav)
introduction.mdx               Landing page
how-it-fits-together.mdx       Full portfolio architecture
architecture/                  System overviews, data pipelines, AI dev pipeline
infrastructure/                Terraform module map
configuration/                 Ansible role map
nix/                           Nix ecosystem
ai-development/                Claude, Gemini, Copilot, MLX
observability/                 Cribl, Splunk, VisiCore, OTEL
tools/                         Dev utilities
about/                         Bio, homelab tour, reef tank
logo/                          SVG wordmark (light + dark)
favicon.svg                    Favicon
.github/workflows/ci.yml       JSON syntax check + broken-links check
flake.nix                      Reproducible dev shell
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

MIT (see `LICENSE`).
