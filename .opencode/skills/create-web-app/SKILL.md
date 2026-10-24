---
name: Create Web App
description: Add a Chromium web app to this Stow desktop setup with a local icon for the Quickshell launcher. Use when asked to create a web-app shortcut or launcher entry.
---

Create a web app in the repository's `desktop` Stow package, not as a regular file in the deployed home directory. Ask for its name and URL if either is missing.

1. Inspect `desktop/.local/share/applications/` and `desktop/.local/share/icons/hicolor/` for an existing entry or icon. Do not overwrite one without checking its contents. Choose a lowercase kebab-case filename shared by the entry and icon.
2. Add `desktop/.local/share/applications/<name>.desktop` using the existing web-app entries as the template: `Type=Application`, `Name=`, `Exec=chromium --app=<URL>`, `Icon=<name>`, `Terminal=false`. Accept only HTTP(S) URLs; quote and escape the URL as a desktop-entry `Exec` argument when needed (including doubling literal `%` characters). Do not use a shell to launch it.
3. Fetch a recognizable icon from the app's official site or upstream project. Prefer SVG in `desktop/.local/share/icons/hicolor/scalable/apps/<name>.svg`; use PNG in `desktop/.local/share/icons/hicolor/128x128/apps/<name>.png` when SVG is unavailable. Check that the download is an actual image, is visible on the dark launcher, and is not a generic favicon or error page. Keep the `Icon=` value extensionless. Never embed credentials or private URLs in an icon-fetching service.
4. Check that the entry's `Icon=` name matches the icon filename and preview from the repository root with `stow -n -v --no-folding -t "$HOME" desktop`. Do not deploy unless asked; installation uses the same command without `-n`. An already-running Quickshell may need a restart to pick up newly installed icon names.
