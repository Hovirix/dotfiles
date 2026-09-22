# Repository Guide

## Chezmoi Source State

- This repository is the chezmoi source directory, not the deployed home tree. Edit source entries here; use `chezmoi diff` to compare them with `$HOME`.
- Chezmoi filename attributes are significant: `dot_` becomes `.`, `executable_` installs with execute permission, and `private_` installs with restricted permissions. Preserve these prefixes when adding or renaming files.
- `README.md`, `AGENTS.md`, and root `assets/` are excluded by `.chezmoiignore`; they are repository-only and are not installed by `chezmoi apply`.
- Preview deployment with `chezmoi apply --dry-run --verbose`; apply intentionally with `chezmoi apply`. There is no build, CI, or repository-wide test suite.

## Coupled Configuration

- `dot_config/mango/config.conf` invokes the scripts in `dot_local/bin/` by their deployed names, without the `executable_` prefix. Keep bindings and script names aligned.
- Since lazygit 0.63 the `git.mergetool` YAML key no longer exists; its "Open merge tool" action shells out to plain `git mergetool`. Helix is therefore wired up as the merge tool via `[merge] tool = helix` and `[mergetool "helix"]` in `dot_config/git/config`, not in `dot_config/lazygit/config.yml`.
- Mango output names, modes, scales, and tag assignments are hardware-specific (`eDP-1` and `HDMI-A-1`); do not generalize them without user confirmation.
- Most `dot_local/bin/` scripts are POSIX `sh` with `set -eu`. Only `executable_setup-yubikey.sh` currently uses Bash; do not introduce Bash syntax into the other scripts.
- Launcher scripts assume a live Wayland/Mango session and external tools or services such as iwd, PipeWire, libvirt, and TLP. Do not execute them as generic tests. Never run `executable_setup-yubikey.sh` for verification; it changes attached YubiKey interfaces and PINs.

## Desktop UI Direction

- The desktop UI is a native Quickshell implementation under `dot_config/quickshell/`. Keep it cohesive rather than introducing separate launchers or unrelated UI toolkits.
- The desired visual language is shadcn/ui Lyra with square geometry, Catppuccin Mocha semantic colors, and `JetBrainsMono Nerd Font Mono` for text and icons. Preserve this style when adding or changing surfaces.
- `dot_config/quickshell/Appearance/Appearance.qml` is the only design-token source. Put reusable colors, typography, spacing, dimensions, borders, and animation values there; overlays must not grow one-off visual constants.
- `dot_config/quickshell/Ui/` contains reusable presentation and input primitives. Extend those primitives when behavior or chrome is shared. Keep device and command integration in `Services/`, and compose services plus UI primitives in `Overlays/`.
- Use semantic popup widths from `Appearance.qml`: compact for small pickers, standard for single-column menus, wide for browsers/calendars, and workspace for multi-column controls. Do not invent a width for each overlay.
- Keep panels keyboard-first, compact, square, and visually aligned. Selected rows use one cursor highlight; pointer hover must update that cursor rather than creating a second hover-only visual state.
- Use opaque `border` for structural edges and `subtleRing` only for deliberately translucent floating rings. Do not use translucent borders where adjacent backgrounds would make nominally identical borders appear different.

## Quickshell Behavior

- `dot_config/quickshell/shell.qml` owns services, overlays, the single-open-overlay controller, and the `shell` IPC handler. Mango bindings call that IPC handler with `quickshell ipc call shell <method>`.
- Keep the binding and IPC names synchronized. Current native surfaces are launcher, battery, clock, emoji, audio, display, recent files, screenshot, volume OSD, and brightness OSD.
- Shared keyboard handling belongs in `Ui/KeyCatcher.qml`. Vim navigation is appropriate for control menus, but searchable pickers must disable letter shortcuts so every printable character, including `h`, `j`, `k`, `l`, `x`, and spaces, can be entered.
- Popups that receive keyboard input must be focusable and explicitly restore focus to their key catcher when shown.
- Prefer Quickshell APIs and typed objects over parsing command output. Use external processes only when Quickshell has no suitable API or the process is the actual system control interface.
- Omarchy `quattro` is a behavioral and architectural reference, not a runtime dependency. Adapt useful patterns to this system; do not call `omarchy-*`, `uwsm-app`, or assume Omarchy files and environment variables exist.

## Application Launcher

- `SUPER+R` must open the native Apps mode through `quickshell ipc call shell launcher`. Do not replace it with Fuzzel or another launcher.
- Apps must come directly from Quickshell's `DesktopEntries.applications` model. Do not scan `.desktop` files with shell, AWK, `find`, or a generated helper script.
- Keep native `DesktopEntry` objects through filtering and rendering. Launch the selected entry with `DesktopEntry.execute()`; never reconstruct or evaluate its `Exec=` line through `sh -c`.
- Search application name, generic name, comment, keywords, and desktop ID. With no query, sort alphabetically. During search, prioritize name-prefix matches, then other name matches, then metadata matches.
- Resolve icons with `Quickshell.iconPath()`, while preserving absolute and `file://`/`image://` sources and falling back to `application-x-executable`.
- Application icons are 28px, and their image boxes align exactly with the left edge of the `Launch:` prompt. Application names use `fontSizeTitle`; secondary metadata remains smaller.
- Keep the launcher usable entirely from the keyboard: typing filters, Backspace edits, arrows move the cursor, Enter launches, and Escape closes.
- A hidden QML item can still evaluate its bindings. Never let delegates for string-backed modes call string methods on `DesktopEntry` objects; give mutually exclusive views mode-specific models or use type-safe helpers.

## Change And Deployment Workflow

- Edit the chezmoi source paths, not files under `~/.config` or `~/.local/bin` directly.
- For Quickshell changes, first launch the source configuration separately with `quickshell -p dot_config/quickshell`; exercise the affected IPC method and inspect `quickshell log` for QML binding errors. A configuration merely loading is not sufficient verification.
- Screenshots from a live Wayland session are useful for checking spacing, alignment, clipping, focus, and whether models actually render. Do not infer visual correctness only from QML syntax.
- Use targeted `chezmoi apply --force <deployed-path>` when testing a small UI change so unrelated source-state changes are not deployed. The running Quickshell daemon should reload the deployed file; inspect its log after reload.
- Do not leave temporary indexers, hardcoded `/home/<user>` paths, debug logging, screenshots, or duplicated visual tokens in the repository.

## Focused Checks

- Mango: `mango -c dot_config/mango/config.conf -p`
- Zsh: `zsh -n dot_zshrc dot_zprofile`
- WezTerm: `wezterm --config-file dot_wezterm.lua show-keys >/dev/null`
- Shell scripts: use `sh -n dot_local/bin/executable_<name>` for `#!/bin/sh` files and `bash -n` for the two Bash files.
- Quickshell: start the source config with `quickshell -p dot_config/quickshell`, invoke the changed `shell` IPC method, and inspect its instance log. Kill only that source instance when finished; do not disrupt the deployed instance unnecessarily.
- Finish with `chezmoi apply --dry-run --verbose`; review any target changes rather than applying them automatically.
