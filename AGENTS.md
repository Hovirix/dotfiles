# Repository Guide

## Chezmoi Source State

- This repository is the chezmoi source directory, not the deployed home tree. Edit source entries here; use `chezmoi diff` to compare them with `$HOME`.
- Chezmoi filename attributes are significant: `dot_` becomes `.`, `executable_` installs with execute permission, and `private_` installs with restricted permissions. Preserve these prefixes when adding or renaming files.
- `README.md`, `AGENTS.md`, and root `assets/` are excluded by `.chezmoiignore`; they are repository-only and are not installed by `chezmoi apply`.
- Preview deployment with `chezmoi apply --dry-run --verbose`; apply intentionally with `chezmoi apply`. There is no build, CI, or repository-wide test suite.

## Coupled Configuration

- `dot_config/mango/config.conf` invokes the scripts in `dot_local/bin/` by their deployed names, without the `executable_` prefix. Keep bindings and script names aligned.
- Mango `exec-once` lines are shell-interpreted (`~` expansion, `;` chaining work); plain `VAR=value` lines are environment assignments, not shell.
- Since lazygit 0.63 the `git.mergetool` YAML key no longer exists; its "Open merge tool" action shells out to plain `git mergetool`. Helix is therefore wired up as the merge tool via `[merge] tool = helix` and `[mergetool "helix"]` in `dot_config/git/config`, not in `dot_config/lazygit/config.yml`.
- Mango output names, modes, scales, and tag assignments are hardware-specific (`eDP-1` and `HDMI-A-1`); do not generalize them without user confirmation.
- Most `dot_local/bin/` scripts are POSIX `sh` with `set -eu`. Only `executable_setup-yubikey.sh` currently uses Bash; do not introduce Bash syntax into the other scripts.
- Launcher scripts assume a live Wayland/Mango session and external tools or services such as iwd, PipeWire, libvirt, and TLP. Do not execute them as generic tests. Never run `executable_setup-yubikey.sh` for verification; it changes attached YubiKey interfaces and PINs.

## Desktop UI Direction

- The desktop UI is a native Quickshell implementation under `dot_config/quickshell/`. Keep it cohesive rather than introducing separate launchers or unrelated UI toolkits.
- The desired visual language is shadcn/ui Lyra exactly as specified upstream (`base-lyra`, Phosphor icons, JetBrains Mono), with Catppuccin Mocha mapped onto the semantic color tokens. Use normal `JetBrains Mono` for text and `Symbols Nerd Font Mono` only for icon glyphs. The user accent is peach: `primary` is `#fab387` (peach) with `primaryForeground` Base `#1e1e2e`. All other color roles follow the Catppuccin usage table exactly: Background Pane Base; Secondary Panes Mantle (`popover`); Surface Elements Surface 0 (`secondary`, `muted`, `input`); Body/Headline Text; Sub-Headlines Subtext 0 (`mutedForeground`); Selection Background Overlay 2 (`selection`, used at 20-30% opacity); Links/Tags Blue (`link`); Success Green, Warnings Yellow, Errors Red (`success`, `warning`, `destructive`). Never reintroduce mauve or a solid `accent` token.
- Lyra geometry is `rounded-none` everywhere: radius 0 on cards, popovers, buttons, rows, tracks, and indicators. No per-overlay corner values.
- Window borders are peach: popup menu cards (`Ui/Popup`) and OSD cards (`Ui/Osd`) use a solid 1px `primary` border. The only exception is notifications, whose border depends on urgency: Critical `destructive`, Normal `primary`, Low `subtleRing`. Structural dividers inside a surface stay neutral: `bg-border` at 1px (`Ui.Separator`, the `border` token at Surface 0) — never peach. Do not use translucent borders where adjacent backgrounds would make nominally identical borders appear different.
- Lyra type scale: base text is `text-xs/relaxed` (12px, relaxed leading; `fontSizeBody` here, also used for labels and values), card/popup titles are `text-sm font-medium` (14px, weight 500; `fontSizeTitle` here), secondary text is `text-muted-foreground`, and numeric values are `tabular-nums` (JetBrains Mono already satisfies this).
- Lyra spacing: card/popover internal gap and padding is `--spacing(4)` = 16px (`space4`/`dialogPadding`); tight inner gaps are `gap-1` = 4px (`space1`); progress blocks use `gap-3` = 12px (`space3`).
- Lyra components, exactly: button `h-8 gap-1.5 px-2.5` (32/6/10px); progress track `h-1` (4px, `progressHeight`) `bg-muted` with indicator `h-full bg-primary`; separator `h-px w-full bg-border`; card header = title + description stacked on the left with an action slot on the right; card content padded by the card spacing.
- No shadows anywhere (Lyra is sharp/flat); one `duration-100` animation token for micro-transitions.
- `dot_config/quickshell/Appearance/Appearance.qml` is the only design-token source. Put reusable colors, typography, spacing, dimensions, borders, and animation values there; panels must not grow one-off visual constants (no hardcoded pixel sizes, gaps, or heights). Keep the token set minimal: no dead tokens (every token must have at least one use) and no duplicate values under different names; merge rather than add (e.g. labels/values share `fontSizeBody`).
- `dot_config/quickshell/Ui/` contains reusable presentation and input primitives. Extend those primitives when behavior or chrome is shared. Keep each feature self-contained under `dot_config/quickshell/Components/<Feature>/` with its `Service.qml` beside its panel(s) and helper JS (e.g. `Components/Audio/Service.qml`, `AudioMenu.qml`, `VolumeOsd.qml`, `audio-model.js`); same-directory types resolve without imports. Panels that need a differently-named sibling use a `Panel`/`Osd`/`Menu` suffix only to avoid type clashes (e.g. `BatteryPanel.qml`).
- Use semantic popup widths from `Appearance.qml`: compact for small pickers, standard for single-column menus, wide for browsers/calendars, and workspace for multi-column controls. Do not invent a width for each overlay.
- Keep panels keyboard-first, compact, square, and visually aligned. Selected rows use one cursor highlight (`selection` at 30% opacity for the keyboard cursor, 20% for the current/active state); pointer hover must update that cursor rather than creating a second hover-only visual state.

## Quickshell Behavior

- `dot_config/quickshell/shell.qml` owns service instances, panels, the single-open-overlay controller, and the `shell` IPC handler. Mango bindings call that IPC handler with `quickshell ipc call shell <method>`.
- If a deployed change breaks QML parsing, the daemon can exit entirely with no auto-restart (`exec-once` only runs at Mango startup): `busctl --user ... GetNameOwner` showing no owner plus dead instances means relaunch with `quickshell --daemonize --no-duplicate`, the same command Mango autostart uses. Always verify `quickshell -p` loads clean before deploying.
- Keep the binding and IPC names synchronized. Current native surfaces are launcher, battery, clock, emoji, audio, display, recent files, notifications, volume OSD, and brightness OSD. Screenshots run outside Quickshell via `dot_local/bin/executable_screenshot` on `SUPER+s` / `SUPER+SHIFT+s`.
- Quickshell owns the desktop notification D-Bus service through `Components/Notifications/Service.qml`; notifications render through `Components/Notifications/NotificationsPanel.qml`. Do not add Mako or another notification daemon alongside it. The server must advertise `actions`, `body-markup`, `body-hyperlinks`, `persistence`, and image support — Chrome/Chromium checks capabilities and falls back to its internal Message Center if the server looks crippled (diagnose with `busctl --user monitor org.freedesktop.Notifications`: no `Notify` call means Chrome kept it internally; Chrome also caches capabilities, so restart it after server changes).
- `shell.qml` pins `//@ pragma IconTheme Papirus-Dark` so `Quickshell.iconPath()` resolves themed icons; the pragma only takes effect on a full Quickshell restart, not a config reload. Notifications render title + `StyledText` body (links in `link` blue, clickable via `Qt.openUrlExternally`) with the icon vertically centered against the text, plus one button per non-default action; clicking the card body invokes the `default` action if present, else dismisses.- Shared keyboard handling belongs in `Ui/KeyCatcher.qml`. Vim navigation is appropriate for control menus, but searchable pickers must disable letter shortcuts so every printable character, including `h`, `j`, `k`, `l`, `x`, and spaces, can be entered.
- Popups that receive keyboard input must be focusable and explicitly restore focus to their key catcher when shown.
- Prefer Quickshell APIs and typed objects over parsing command output. Use external processes only when Quickshell has no suitable API or the process is the actual system control interface.
- Repeater delegates evaluate their bindings while hidden and transiently during model resets, so guard delegate bindings against `undefined`/`null` model data (return `""`, never call methods on a possibly-unset model object).
- `xdg-desktop-portal` does not start under Mango: `graphical-session.target` refuses manual start and the portal unit's `Requisite` on it fails, so `org.freedesktop.portal.Desktop` never activates. Mango autostart runs `dbus-update-activation-environment --systemd ...` to keep the user bus usable. The `qt.qpa.services ... Could not activate remote peer 'org.freedesktop.portal.Desktop'` warning at Quickshell startup is benign and environmental. PENDING: a `~/.config/systemd/user/xdg-desktop-portal.service.d/override.conf` drop-in clearing `Requisite=` so on-demand D-Bus activation works.
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
