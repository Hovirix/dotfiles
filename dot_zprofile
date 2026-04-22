if [ -z "$XDG_RUNTIME_DIR" ]; then
  XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"
  mkdir -m 700 "$XDG_RUNTIME_DIR"
  export XDG_RUNTIME_DIR
fi

if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then

  export WLR_RENDERER=vulkan
  export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

  exec sway
  # exec dbus-run-session sway 
  # exec systemd-run --user --scope sway
fi
