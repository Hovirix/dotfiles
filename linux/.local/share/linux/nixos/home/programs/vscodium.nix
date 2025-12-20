{ pkgs, username, ... }:
with pkgs;
let
  R-custom = rWrapper.override {
    packages = with rPackages; [
      languageserver
      jsonlite
      ggplot2
      httpgd
      styler
      rlang
      lintr
    ];
  };
in
{
  home.packages = [ R-custom radian ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = [
      # Install Manually
      # R
      # R Syntax
      # R Debugger
    ];

    profiles.default.userSettings = {

      # ================================================================================================
      # IDE config
      # ================================================================================================

      editor = {
        fontSize = 16;
        formatOnSave = true;
        formatOnPaste = true;
        fontLigatures = true;
        minimap.enabled = false;
        stickyScroll.enabled = false;
      };

      explorer = {
        confirmDelete = false;
        confirmDragAndDrop = true;
      };

      window = {
        titleBarStyle = "custom";
        menuBarVisibility = "toogle";
      };

      workbench = {
        settings.editor = "json";
        statusBar.visible = false;
        breadcrumbs.enabled = false;
        breadcrumbs.filePath = false;
        layoutControl.enabled = false;
        tree.enableStickyScroll = false;
        navigationControl.enabled = false;

        editor = {
          enablePreview = false;
          autoLockGroups = false;
        };

        colorTheme = "Catppuccin Mocha";
        preferredDarkColorTheme = "Catppuccin Mocha";
        preferredHighContrastColorTheme = "Catppuccin Mocha";
      };

      # ================================================================================================
      # languages Configuration
      # ================================================================================================

      r = {
        bracketedPaste = true;
        plot.useHttpgd = true;
        formatting.provider = "styler";
        rterm = {
          # linux = "/etc/profiles/per-user/${username}/bin/radian";
          # linux = "/etc/profiles/per-user/${username}/bin/R";
          options = [
            "--r-binary=/etc/profiles/${username}/hovirix/bin/R"
            "--no-save"
            "--no-restore"
          ];
        };
      };
    };
  };
}


