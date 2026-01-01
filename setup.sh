#!/usr/bin/env sh
set -eu

ZINIT_DIR="$HOME/.local/share/zinit"
ZINIT_GIT="$ZINIT_DIR/zinit.git"

if [ -d "$ZINIT_GIT/.git" ]; then
  echo "Zinit is already present"
else
  mkdir -p "$ZINIT_DIR"
  git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_GIT"
  echo "Zinit install complete."
fi

for pkg in */; do
  stow "${pkg%/}"
done
