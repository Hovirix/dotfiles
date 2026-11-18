---
name: Quickshell Plugin
description: Create or modify Quickshell plugins in this repository.
---

# Quickshell plugins

1. Read repository instructions, `quickshell/.config/quickshell/shell.qml`, relevant core/UI components, and the closest plugin. Reuse sound patterns, not existing bugs.
2. Keep feature state, actions, and backend logic in `plugins/<name>/`; compose explicitly in `shell.qml`. Preserve existing IPC and behavior. Avoid plugin frameworks and speculative abstractions.
3. Core owns window geometry, screen limits, and navigation. Reuse `core/SearchLayout.qml`, `ui/`, and `Theme.qml`; don't duplicate sizing or override panel geometry in plugins.
4. Match the existing design: Catppuccin Mocha Peach accent, no animations or visible scrollbars. Keep selection visible and scrollable. Support keyboard navigation, Enter, and Escape without intercepting normal text editing or IME.
5. Use QML/JS for state. Use `backend.sh` and existing system tools only when needed; validate input, handle failures, coalesce slow writes, and preserve hardware calibration.
6. Edit canonical files and preserve symlinks. Install new files with Stow `--no-folding`. Review the diff and run relevant checks unless declined; don't operate hardware, schedule actions, or capture screenshots without authorization.
