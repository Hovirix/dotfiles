#!/bin/bash
set -euo pipefail

packages=(
  # Firmware and system
  amd-ucode
  linux-firmware

  # Networking
  ufw
  openssh
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
  autotiling-rs

  # Fonts and themes
  ttf-dejavu
  ttf-hack-nerd
  ttf-nerd-fonts-symbols
  noto-fonts-emoji
  papirus-icon-theme

  # Utilities
  mako
  grim
  slurp
  fuzzel
  wlsunset
  libnotify
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
  lazygit
  freetube
  zathura-pdf-mupdf
  ungoogled-chromium-bin

  # Files
  p7zip
  zip
  unzip
  unrar

  # CLI tools
  zsh
  bat
  eza
  fzf
  git
  zoxide
  starship
  fastfetch
  github-cli

  # Virtualization
  libvirt
  dnsmasq
  virt-manager
  qemu-desktop
)

sudo pacman -Syu --noconfirm >/dev/null

for pkg in "${packages[@]}"; do
  echo "Installing $pkg..."
  sudo pacman -S --needed --noconfirm "$pkg" >/dev/null
done

sudo systemctl enable --now tlp
sudo systemctl enable --now libvirtd
# sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

sudo ufw enable
sudo ufw default deny incoming
sudo ufw reload

sudo usermod -aG libvirt "$USER"

exec ~/.dotfiles/linkdots.sh
chsh -s /bin/zsh

exec ./debloat.sh
