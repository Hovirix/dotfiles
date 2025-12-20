{ inputs, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  nix = {
    channel.enable = false;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    settings = {
      show-trace = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      download-buffer-size = 524288000;
      experimental-features = [ "nix-command" "flakes" "recursive-nix" "fetch-closure" ];

      substituters = [
        "https://cache.nixos.org"
        "https://helix.cachix.org"
        "https://anyrun.cachix.org"
        "https://hyprland.cachix.org"
        "https://chaotic-nyx.cachix.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
