{ pkgs, ... }:
with pkgs;
let
  Rstudio = rstudioWrapper.override {
    packages = with rPackages; [
      languageserver
      ggplot2
      httpgd
      styler
      dplyr
      rlang
      lintr
      BSDA
    ];
  };
in
{
  home.packages = with pkgs;[

    # DEV
    gcc
    python3
    Rstudio
    nix-tree

    # CONNECTIONS
    overskride
    protonvpn-gui

    # MEDIA
    mpv
    imv
    pwvucontrol

    # DISPLAY
    wdisplays

    # APPS
    unzip
    nautilus
    appflowy
    tor-browser
    qalculate-gtk
    gnome-calendar
    gpu-screen-recorder-gtk

  ];
}
