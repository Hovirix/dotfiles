#!/bin/bash

bloat=(
  base-devel
  btrfs-progs
  cachyos-settings
  cachyos-ananicy-rules
  cachyos-plymouth-bootanimation
  linux-cachyos-headers
  linux-cachyos-lts-headers
  chwd
  f2fs-tools
  inetutils
  iptables-nft
  jfsutils
  opencl-mesa
  gst-plugin-va
  vulkan-radeon
  lib32-mesa
  lib32-opencl-mesa
  lib32-vulkan-radeon
  logrotate
  lsb-release
  lvm2
  man-db
  man-pages
  mdadm
  netctl
  plymouth
  s-nail
  sysfsutils
  texinfo
  which
  xf86-video-amdgpu
  xfsprogs
)

for pkg in "${bloat[@]}"; do
  echo "Removing $pkg..."
  sudo pacman -Rns --noconfirm "$pkg" >/dev/null
done
