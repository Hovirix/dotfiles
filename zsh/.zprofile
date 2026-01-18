if [ -z "$XDG_RUNTIME_DIR" ]; then
  XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"
  mkdir -m 700 "$XDG_RUNTIME_DIR"
  export XDG_RUNTIME_DIR
fi

if [ "$(tty)" = "/dev/tty1" ]; then

  export XDG_SESSION_TYPE=wayland
  export XDG_SESSION_DESKTOP=sway
  export XDG_CURRENT_DESKTOP=sway

  export MOZ_ENABLE_WAYLAND=1
  export ELECTRON_OZONE_PLATFORM_HINT=wayland

  export DISABLE_QT5_COMPAT=1
  export QT_QPA_PLATFORM=wayland
  export QT_AUTO_SCREEN_SCALE_FACTOR=1
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

  export GTK_BACKEND=wayland
  export GTK_WAYLAND_DISABLE_WINDOWDECORATION=1

  export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

  # exec dbus-run-session sway 
  exec systemd-run --user --scope sway
fi
