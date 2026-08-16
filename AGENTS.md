# Repository Guide

## Chezmoi Source State

- This repository is the chezmoi source directory, not the deployed home tree. Edit source entries here; use `chezmoi diff` to compare them with `$HOME`.
- Chezmoi filename attributes are significant: `dot_` becomes `.`, `executable_` installs with execute permission, and `private_` installs with restricted permissions. Preserve these prefixes when adding or renaming files.
- `README.md`, `AGENTS.md`, and root `assets/` are excluded by `.chezmoiignore`; they are repository-only and are not installed by `chezmoi apply`.
- Preview deployment with `chezmoi apply --dry-run --verbose`; apply intentionally with `chezmoi apply`. There is no build, CI, or repository-wide test suite.

## Coupled Configuration

- `dot_config/sway/config` invokes the scripts in `dot_local/bin/` by their deployed names, without the `executable_` prefix. Keep bindings and script names aligned.
- Sway output names, modes, scales, and workspace assignments are hardware-specific (`eDP-1` and `HDMI-A-1`); do not generalize them without user confirmation.
- Most `dot_local/bin/` scripts are POSIX `sh` with `set -eu`. Only `executable_fz-pass` and `executable_setup-yubikey.sh` currently use Bash; do not introduce Bash syntax into the other scripts.
- Launcher scripts assume a live Wayland/Sway session and external tools or services such as fuzzel, iwd, PipeWire, libvirt, and TLP. Do not execute them as generic tests. Never run `executable_setup-yubikey.sh` for verification; it changes attached YubiKey interfaces and PINs.

## Focused Checks

- Sway: `sway --validate --config dot_config/sway/config`
- Zsh: `zsh -n dot_zshrc dot_zprofile`
- WezTerm: `wezterm --config-file dot_wezterm.lua show-keys >/dev/null`
- Shell scripts: use `sh -n dot_local/bin/executable_<name>` for `#!/bin/sh` files and `bash -n` for the two Bash files.
- Finish with `chezmoi apply --dry-run --verbose`; review any target changes rather than applying them automatically.
