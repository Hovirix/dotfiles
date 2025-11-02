#!/bin/sh

packages="libvirt dnsmasq virt-manager qemu-desktop"

sudo pacman -S --needed "$packages"

sudo systemctl enable --now libvirtd.service

sudo usermod -aG libvirt "$USER"

echo "Installation complete."
echo "You need to log out and log back in for group changes to take effect."
