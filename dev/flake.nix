{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.buildEnv {
        name = "my-nix-packages";
        paths = with pkgs; [
          # LSP servers
          nil
          pyright
          clang-tools
          bash-language-server
          docker-language-server
          dockerfile-language-server
          vscode-langservers-extracted
          # Formatters
          ruff
          shfmt
          dockerfmt
          nixpkgs-fmt
        ];
      };
    };
}
