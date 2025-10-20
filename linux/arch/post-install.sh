#!/bin/bash
set -euo pipefail

packages=(
  # Firmware and system
  amd-ucode
  linux-firmware

  # Networking
  nftables
  networkmanager

  # Power management
  tlp
  tlp-rdw

  # Bluetooth
  bluez
  bluetui
  bluez-utils

  # Audio
  alsa-lib
  alsa-utils
  alsa-firmware
  alsa-ucm-conf

  # Graphics and desktop
  mesa
  sway
  swaybg
  swayidle
  swaylock
  i3status

  # Fonts and themes
  ttf-hack
  ttf-dejavu
  ttf-nerd-fonts-symbols
  noto-fonts-emoji
  papirus-icon-theme

  # Utilities
  mako
  grim
  slurp
  wlsunset
  wf-recorder
  wl-clipboard
  brightnessctl

  # Applications
  imv
  mpv
  foot
  tmux
  yazi
  btop
  helix
  freetube
  zathura-pdf-mupdf
  ungoogled-chromium-bin

  # CLI tools
  zsh
  bat
  eza
  fzf
  git
  zoxide
  starship
  fastfetch
)

sudo pacman -Syu --noconfirm >/dev/null

for pkg in "${packages[@]}"; do
  echo "Installing $pkg..."
  sudo pacman -S --needed --noconfirm "$pkg" >/dev/null
done

sudo systemctl enable --now tlp
sudo systemctl enable --now nftables
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

exec ~/.dotfiles/linkdots.sh
chsh -s /bin/zsh
