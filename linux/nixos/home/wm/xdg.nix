{ pkgs, ... }:
{
  xdg = {

    portal = {
      enable = true;
      wlr.enable = true;
      gtkUsePortal = true;
      xdgOpenUsePortal = true;
      config.common.default = "*";
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };

    mimeApps = {
      enable = true;
      defaultApplications = {

        "image/gif" = "ipv.desktop";
        "image/png" = "imv.desktop";
        "image/jpg" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/webp" = "imv.desktop";

        "text/html" = [ "librewolf.desktop" ];
        "applications/md" = [ "librewolf.desktop" ];
        "x-scheme-handler/ftp" = [ "librewolf.desktop" ];
        "x-scheme-handler/http" = [ "librewolf.desktop" ];
        "x-scheme-handler/https" = [ "librewolf.desktop" ];

        "application/pdf" = "org.pwmt.zathura.desktop";
      };
    };
  };
}
