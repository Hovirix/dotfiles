#!/run/current-system/sw/bin/bash
set -euo pipefail

# The portal service has a restricted PATH on NixOS.
export PATH=$PATH:/run/current-system/sw/bin
export LC_ALL=C.UTF-8
config=${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/shell.qml
ipc() { timeout 2 qs ipc -p "$config" call sharePicker "$@"; }
fail() {
    echo "share-picker: $*" >&2
    exit 1
}

# A successful read means a NUL or the size limit was reached, not EOF.
# shortcut: IPC arguments are capped at 64 KiB; use file transport if needed.
if IFS= LC_ALL=C read -r -d '' -n 65537 -t 5 payload; then
    fail 'NUL-containing or oversized source list'
else
    status=$?
    ((status == 1)) || fail 'stdin timed out or failed'
fi
[[ -n $payload ]] || fail 'no sources'
payload=${payload%$'\n'}
mapfile -t sources <<<"$payload"
for line in "${sources[@]}"; do
    [[ -n $line && $line != *$'\r'* ]] || fail 'invalid empty or CR-containing source'
done

read -r token </proc/sys/kernel/random/uuid
token=share-picker.$token
cleanup() {
    ipc dismiss "$token" >/dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
[[ $(ipc open "$token" "$payload") == ready ]] || fail 'shell unavailable or another request is active'

deadline=$((SECONDS + 120))
while ((SECONDS < deadline)); do
    kill -0 "$PPID" 2>/dev/null || fail 'requesting process exited'
    result=$(ipc poll "$token") || fail 'Quickshell disconnected'
    case $result in
        pending) sleep 0.2 ;;
        cancelled | unknown) fail 'cancelled or shell reloaded' ;;
        *)
            [[ $result =~ ^(0|[1-9][0-9]{0,5})$ ]] || fail 'invalid response'
            ((result < ${#sources[@]})) || fail 'source index out of range'
            printf '%s\n' "${sources[result]}"
            exit 0
            ;;
    esac
done
fail 'selection timed out'
