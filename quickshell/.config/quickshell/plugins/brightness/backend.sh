#!/usr/bin/env bash
set -euo pipefail

monitor=${1:?Missing monitor}
operation=${2:?Missing operation}
bus=${3:-}
maximum=${4:-}
target=${5:-}

case "$monitor" in
    eDP-* | LVDS-* | DSI-*)
        if [[ $operation == set ]]; then
            [[ $target =~ ^[0-9]+$ ]] || exit 1
            result=$(brightnessctl --class=backlight set "$target" -m)
        elif [[ $operation == get ]]; then
            result=$(brightnessctl --class=backlight -m)
        else
            exit 1
        fi
        IFS=, read -r _ _ current _ maximum <<<"$result"
        [[ $current =~ ^[0-9]+$ && $maximum =~ ^[1-9][0-9]*$ ]] || exit 1
        printf '%s %s internal\n' "$current" "$maximum"
        exit
        ;;
esac

if [[ $operation == get ]]; then
    # DisplayPort AUX buses live under the connector; HDMI uses its ddc link.
    path=""
    for connector in /sys/class/drm/card*-"$monitor"; do
        path=$(find -H "$connector" -maxdepth 1 -type d -name 'i2c-*' -print -quit) || continue
        if [[ -z $path ]]; then
            path=$(readlink -f "$connector/ddc") || continue
        fi
        break
    done
    bus=${path##*/i2c-}
    [[ $bus =~ ^[0-9]+$ ]] || {
        echo "No DDC display for $monitor" >&2
        exit 1
    }
    result=$(ddcutil --bus "$bus" --skip-ddc-checks getvcp 10 --terse)
    [[ $result =~ ^VCP\ 10\ C\ ([0-9]+)\ ([0-9]+)$ ]] || exit 1
    current=$((10#${BASH_REMATCH[1]}))
    maximum=$((10#${BASH_REMATCH[2]}))
    ((maximum > 0 && current <= maximum)) || exit 1
elif [[ $operation == set ]]; then
    [[ $bus =~ ^[0-9]+$ && $maximum =~ ^[1-9][0-9]*$ && $target =~ ^[0-9]+$ ]] || exit 1
    ((target <= maximum)) || exit 1
    # This MSI needs longer settling before write verification.
    ddcutil --bus "$bus" --skip-ddc-checks --disable-dynamic-sleep --sleep-multiplier 5 setvcp 10 "$target" >&2
    current=$target
else
    exit 1
fi
printf '%s %s %s\n' "$current" "$maximum" "$bus"
