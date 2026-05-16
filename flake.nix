{
  description = "Dev shell for docs.jacobpevans.com (Mintlify + Mermaid)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_20
            mermaid-cli
            jq
          ];

          shellHook = ''
            echo "docs.jacobpevans.com dev shell"
            echo ""
            echo "  mint dev          start local preview at http://localhost:3000"
            echo "  mint broken-links validate internal links"
            echo "  mmdc -i x.mmd -o x.svg  render mermaid to SVG"
            echo ""
            command -v mint >/dev/null 2>&1 || echo "tip: run 'npm i -g mint' to install the Mintlify CLI"
          '';
        };
      });
}
