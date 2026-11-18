#!/bin/sh
set -eu

# Keep NixOS's installed backend, but allow its normal user-config lookup.
portal=$(sed -n 's/^ExecStart=//p' /etc/systemd/user/xdg-desktop-portal-wlr.service)
case "$portal" in
    /nix/store/*/libexec/xdg-desktop-portal-wlr) exec "$portal" ;;
    *)
        echo 'share-picker: unexpected vendor portal executable' >&2
        exit 1
        ;;
esac
