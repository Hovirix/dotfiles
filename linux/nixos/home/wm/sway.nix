{ pkgs, username, ... }: {

  # ================================================================================================
  # Environment config
  # ================================================================================================

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";

    DISABLE_QT5_COMPAT = 1;
    QT_QPA_PLATFORM = "wayland";
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;

    NIXOS_OZONE_WL = 1;
    MOZ_ENABLE_WAYLAND = 1;
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";

    GTK_CSD = 0;
    GTK_BACKEND = "wayland";
    GTK_WAYLAND_DISABLE_WINDOWDECORATION = 1;
  };

  # ================================================================================================
  # Sway 
  # ================================================================================================

  wayland.windowManager.sway = {
    enable = true;
    xwayland = false;
    systemd.enable = false;

    # ------------------------------------------------
    # Configuration
    # ------------------------------------------------

    extraConfig = ''
      set $browser            chromium
      set $terminal           foot
      set $launcher           tofi-drun | xargs swaymsg exec --
      set $file-manager       nautilus
      set $Tfile-manager      $terminal -e yazi
      set $audio-manager      com.saivert.pwvucontrol
      set $bluetooth-manager  io.github.kaii_lb.Overskride '';

    config = {

      # ------------------------------------------------
      # Startup
      # ------------------------------------------------

      startup = [
        # { command = "mako"; }
        { command = "${pkgs.autotiling-rs}/bin/autotiling-rs"; }
        { command = "${pkgs.wlsunset}/bin/wlsunset -t 3000 -T 6500 -s 20:00 -S 07:00 -g 0.7"; }
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
        { command = "${pkgs.swaybg}/bin/swaybg -i ~/nixos/laptop/home/wallpapers/nixos-mocha.png"; }
        {
          command = ''
            ${pkgs.swayidle}/bin/swayidle -w \
              before-sleep "${pkgs.swaylock}/bin/swaylock -fF" \
              timeout 60 '${pkgs.sway}/bin/swaymsg "output * power off"' \
                      resume '${pkgs.sway}/bin/swaymsg "output * power on"' \
              timeout 120 "${pkgs.systemd}/bin/systemctl suspend" \
              timeout 1800 "${pkgs.systemd}/bin/systemctl poweroff"
          '';
        }
      ];

      # ------------------------------------------------
      # Monitors
      # ------------------------------------------------

      output = {

        eDP-1 = {
          scale = "1.5";
          # resolution = "2880x1800@60.001Hz";
          resolution = "2880x1800@120.000Hz";

          adaptive_sync = "off";
          max_render_time = "off";

          subpixel = "rgb";
          color_profile = "srgb";
          render_bit_depth = "10";
        };

        HDMI-A-1 = {
          scale = "1.25";
          position = "-1920,0";
          resolution = "2560x1440";

          subpixel = "rgb";
          color_profile = "srgb";
        };
      };

      # ------------------------------------------------
      # Inputs
      # ------------------------------------------------

      input = {

        "type:touchpad" = {
          dwt = "enabled";
          tap = "enabled";
          pointer_accel = "1";
          accel_profile = "flat";
          natural_scroll = "enabled";
        };

        "type:mouse" = {
          pointer_accel = "0.4";
          accel_profile = "flat";
        };
      };

      # ------------------------------------------------
      # Window
      # ------------------------------------------------

      window = {
        border = 2;
        titlebar = false;
        hideEdgeBorders = "both";
      };

      floating = {
        border = 2;
        titlebar = false;
        modifier = "mod4";
        criteria = map (id: { app_id = id; }) [
          "^yazi$"
          "^com.saivert.pwvucontrol$"
          "^io.github.kaii_lb.Overskride$"
          "chrome-nngceckbapebfimnlniiiahkandclblb-Default"
        ];
      };

      # ------------------------------------------------
      # Window Rules
      # ------------------------------------------------

      assigns = {
        "1" = map (id: { app_id = id; }) [ "^chromium-browser$" ];
        # "2" = map (id: { app_id = id; }) [ "^org.pwmt.zathura$" ];
        "3" = map (id: { app_id = id; }) [ "^codium$" "^Rstudio$" ];
        "4" = map (id: { app_id = id; }) [ "^AppFlowy" ];
        "5" = map (id: { app_id = id; }) [ "^FreeTube" ];
      };

      # ------------------------------------------------
      # Workspace Rules
      # ------------------------------------------------

      # workspaceAutoBackAndForth = true;
      defaultWorkspace = "workspace number 1";

      workspaceOutputAssign =
        (map (ws: { workspace = ws; output = "eDP-1"; }) [ "1" "2" "3" "4" "5" ]) ++
        (map (ws: { workspace = ws; output = "HDMI-A-1"; }) [ "6" "7" "8" "9" "10" ]);

      # ------------------------------------------------
      # Keybindings
      # ------------------------------------------------

      keycodebindings = {
        # Switch workspaces with mainMod + [0-9]
        "mod4+9" = "scratchpad show";
        "mod4+10" = "workspace number 1";
        "mod4+11" = "workspace number 2";
        "mod4+12" = "workspace number 3";
        "mod4+13" = "workspace number 4";
        "mod4+14" = "workspace number 5";
        "mod4+15" = "workspace number 6";
        "mod4+16" = "workspace number 7";
        "mod4+17" = "workspace number 8";
        "mod4+18" = "workspace number 9";
        "mod4+19" = "workspace number 10";

        # Switch workspaces with mainMod + [0-9]
        "mod4+Shift+9" = "move scratchpad";
        "mod4+Shift+10" = "move container to workspace number 1";
        "mod4+Shift+11" = "move container to workspace number 2";
        "mod4+Shift+12" = "move container to workspace number 3";
        "mod4+Shift+13" = "move container to workspace number 4";
        "mod4+Shift+14" = "move container to workspace number 5";
        "mod4+Shift+15" = "move container to workspace number 6";
        "mod4+Shift+16" = "move container to workspace number 7";
        "mod4+Shift+17" = "move container to workspace number 8";
        "mod4+Shift+18" = "move container to workspace number 9";
        "mod4+Shift+19" = "move container to workspace number 10";
      };

      keybindings = {

        # Apps 
        "mod4+r" = "exec $launcher";
        "mod4+Return" = "exec $terminal";

        "mod1+1" = "exec $browser";
        "mod1+2" = "exec $Tfile-manager";
        "mod1+4" = "exec appflowy";

        # Scripts
        "mod4+c" = "exec caffeine";
        "mod4+w" = "exec wireguard-toggle";

        # Display
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl -q s 5%+";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl -q s 5%-";

        # Screenshot
        "mod4+s" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy anything";
        "mod4+Control+s" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save anything";
        "mod4+Control+mod1+s" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save screen";

        # Multimedia
        "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1";

        # System
        "mod4+q" = "kill";
        "mod4+t" = "floating toggle";
        "mod4+f" = "fullscreen toggle";

        "mod4+Shift+e" = "exec swaymsg exit";
        "mod4+Shift+r" = "exec swaymsg reload";

        "mod4+Shift+Control+r" = "exec systemctl reboot";
        "mod4+Shift+Control+s" = "exec systemctl suspend";
        "mod4+Shift+Control+p" = "exec systemctl poweroff";

        # Window
        "mod4+h" = "focus left";
        "mod4+l" = "focus right";
        "mod4+k" = "focus up";
        "mod4+j" = "focus down";

        "mod4+Shift+h" = "move left";
        "mod4+Shift+l" = "move right";
        "mod4+Shift+k" = "move up";
        "mod4+Shift+j" = "move down";

        "mod4+Control+h" = "resize shrink width 10 px";
        "mod4+Control+l" = "resize grow width 10 px";
        "mod4+Control+k" = "resize shrink height 10 px";
        "mod4+Control+j" = "resize grow height 10 px";

      };

      # ------------------------------------------------
      # Style
      # ------------------------------------------------

      gaps = {
        # inner = 10;
        # outer = 0;
        # right = 0;
        # left = 0;
        # top = 0;
        # bottom = 0;
        # vertical = 0;
        # horizontal = 0;
        # # smartGaps = true;
        smartBorders = "on";
      };

      colors = {
        focused = {
          background = "#CAD4F5";
          border = "#CAD4F5";
          childBorder = "#CAD4F5";
          indicator = "#CAD4F5";
          text = "#CAD4F5";
        };

        unfocused = {
          background = "#1E1E2E";
          border = "#1E1E2E";
          childBorder = "#1E1E2E";
          indicator = "#1E1E2E";
          text = "#1E1E2E";
        };

        focusedInactive = {
          background = "#1E1E2E";
          border = "#1E1E2E";
          childBorder = "#1E1E2E";
          indicator = "#1E1E2E";
          text = "#1E1E2E";
        };
      };

      # ------------------------------------------------
      # Bar
      # ------------------------------------------------

      bars = [{

        position = "top";
        trayPadding = 0;
        statusCommand = "${pkgs.i3status}/bin/i3status";

        extraConfig = ''
          output eDP-1
          separator_symbol ""
        '';

        fonts = {
          names = [ "DroidSansM Nerd Font" ];
          style = "Regular";
          size = 11.0;
        };

        colors = {
          separator = "#1e1e2e";
          background = "#1e1e2e";

          focusedWorkspace = {
            text = "#1e1e2e";
            border = "#fab387";
            background = "#fab387";
          };

          activeWorkspace = {
            text = "#1e1e2e";
            border = "#eba0ac";
            background = "#eba0ac";
          };

          urgentWorkspace = {
            text = "#1e1e2e";
            border = "#74c7ec";
            background = "#74c7ec";
          };
        };
      }];
    };
  };
}



