#!/bin/sh
set -eu

if ! command -v ya >/dev/null 2>&1; then
  echo "run_after_upgrade-yazi-plugins: ya not found, skipping" >&2
  exit 0
fi

ya pkg upgrade
chezmoi re-add "$HOME/.config/yazi/package.toml"

