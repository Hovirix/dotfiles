#!/usr/bin/env bash
set -euo pipefail

command -v stow >/dev/null || {
    echo "GNU Stow is required" >&2
    exit 1
}

mkdir -p "$HOME/.gnupg" "$HOME/.ssh"
chmod 700 "$HOME/.gnupg" "$HOME/.ssh"

if [[ -d gpg/.gnupg ]]; then
    find gpg/.gnupg -type d -exec chmod 700 {} +
    find gpg/.gnupg -type f -exec chmod 600 {} +
fi

if [[ -d ssh/.ssh ]]; then
    chmod 700 ssh/.ssh
fi

if [[ -f ssh/.ssh/config ]]; then
    chmod 600 ssh/.ssh/config
fi

stow --no-folding -t "$HOME" */

printf '%s\n' "Dotfiles installed."

