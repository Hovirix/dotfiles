{
  programs.yazi = {
    enable = true;

    settings = {
      log.enabled = false;

      mgr = {
        ratio = [ 2 4 3 ];
        show_hidden = false;
        show_symlink = true;
        sort_by = "extension";

        append_keymap = [{
          on = [ "g" "t" ];
          desc = "Open Trash";
          run = "shell 'cd ~/.local/share/Trash/files'";
        }];
      };

      opener = {
        edit = [{ run = ''hx "$@" ''; for = "unix"; }];
        zip = [{ run = ''unzip "$@" ''; orphan = true; for = "unix"; }];
        pdf = [{ run = ''zathura "$@" ''; orphan = true; for = "unix"; }];
        imv = [{ run = ''imv-wayland "$@" ''; orphan = true; for = "unix"; }];
      };

      open.prepend_rules = [
        { name = "*.zip"; use = "zip"; }
        { name = "*.pdf"; use = "pdf"; }
        { name = "*.jpg"; use = "imv"; }
        { name = "*.png"; use = "imv"; }
        { name = "*.gif"; use = "imv"; }
        { name = "*.bmp"; use = "imv"; }
        { name = "*.svg"; use = "imv"; }
        { name = "*.ico"; use = "imv"; }
        { name = "*.heic"; use = "imv"; }
        { name = "*.jpeg"; use = "imv"; }
        { name = "*.tiff"; use = "imv"; }
        { name = "*.webp"; use = "imv"; }
      ];
    };
  };
}

