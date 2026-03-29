#!/usr/bin/env bash
# usage: ./home-switch.sh [hostname]

set -euo pipefail

clear

CONFIG_ROOT="/nixos-config"
TARGET_HOST="${1:-$HOSTNAME}"
HOST_DIR="$CONFIG_ROOT/systems/$TARGET_HOST"
FLAKE_DIR="$HOST_DIR/flake"

if [[ -z "$TARGET_HOST" ]]; then
    echo "[!] Error: HOSTNAME is not set. Pass as argument or export it." >&2
    exit 1
fi

if ! command -v home-manager &> /dev/null; then
    echo "[!] Error: home-manager command not found in PATH." >&2
    exit 1
fi

if [[ ! -d "$FLAKE_DIR" ]]; then
    echo "[!] Error: Flake directory not found: $FLAKE_DIR" >&2
    exit 1
fi


echo "=== Applying home-manager for '$TARGET_HOST' ==="
home-manager switch --flake "$FLAKE_DIR"

echo "=== Cleaning old generations (keeping 7 days) ==="
home-manager expire-generations --keep 7d
