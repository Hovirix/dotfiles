{
  description = "My portable dev packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.buildEnv {
          name = "my-nix-packages";

          paths = with pkgs; [

            # Nix
            nil
            nixpkgs-fmt

            # Python
            uv
            ruff
            pyright

            # Bash
            shfmt
            bash-language-server

            # JavaScript
            pnpm
            nodejs

            # YAML
            yamlfix
            yaml-language-server

            # Ansible
            ansible
            ansible-lint

            # Docker
            dockerfmt
            docker-language-server

            # Terraform
            terraform
            terraform-ls

            # Tools
            curlie
            github-copilot-cli
          ];
        };
      }
    );
}
