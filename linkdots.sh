#!/bin/sh
set -eu

DOTS="$HOME/.dotfiles"

mkdir -p "$HOME/.config"
ln -svfn "$DOTS/home/.config/"* "$HOME/.config/"
ln -svfn "$DOTS/home/.zshrc" "$HOME/.zshrc"
ln -svfn "$DOTS/home/.zprofile" "$HOME/.zprofile"
