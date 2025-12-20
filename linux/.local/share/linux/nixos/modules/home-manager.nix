{ config, inputs, username, hostname, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs username hostname; };

    users.${username} = {
      imports = [ ../home/home.nix ];
      programs.home-manager.enable = true;
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        inherit (config.system) stateVersion;
      };
    };
  };
}
