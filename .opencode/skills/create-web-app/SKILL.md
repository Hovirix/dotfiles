---
name: Create Web App
description: Add a Chromium web app to this chezmoi desktop setup with a local icon for the Quickshell launcher. Use when asked to create a web-app shortcut or launcher entry.
---

Create a web app in the directory returned by `chezmoi source-path` (the chezmoi source, not the deployed home directory). Ask for its name and URL if either is missing.

1. Inspect `dot_local/share/applications/` and `dot_local/share/icons/hicolor/` for an existing entry or icon. Do not overwrite one without checking its contents. Choose a lowercase kebab-case filename shared by the entry and icon.
2. Add `dot_local/share/applications/<name>.desktop` using the existing web-app entries as the template: `Type=Application`, `Name=`, `Exec=chromium --app=<URL>`, `Icon=<name>`, `Terminal=false`. Accept only HTTP(S) URLs; quote and escape the URL as a desktop-entry `Exec` argument when needed (including doubling literal `%` characters). Do not use a shell to launch it.
3. Fetch a recognizable icon from the app's official site or upstream project. Prefer SVG in `dot_local/share/icons/hicolor/scalable/apps/<name>.svg`; use PNG in `dot_local/share/icons/hicolor/128x128/apps/<name>.png` when SVG is unavailable. Check that the download is an actual image, is visible on the dark launcher, and is not a generic favicon or error page. Keep the `Icon=` value extensionless. Never embed credentials or private URLs in an icon-fetching service.
4. Check that the entry's `Icon=` name matches the icon filename and preview with `chezmoi apply --dry-run --verbose` (use a targeted preview if unrelated changes interfere). Do not deploy unless asked. Tell the user to apply the new entry and icon; an already-running Quickshell may need a restart to pick up newly installed icon names.
