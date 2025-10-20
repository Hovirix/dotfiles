{ username, pkgs, ... }:
{
  security.sudo.wheelNeedsPassword = false;

  services.getty = {
    autologinOnce = true;
    autologinUser = username;
  };

  # users.mutableUsers = false;
  programs.zsh.enable = true;

  users.users.${username} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
