#!/usr/bin/env bash
# usage: ./smart-rebuild.sh [hostname]

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


if [[ ! -d "$FLAKE_DIR" ]]; then
    echo "[!] Error: Flake directory not found: $FLAKE_DIR" >&2
    exit 1
fi

# === Применение ===
echo "=== Rebuilding NixOS for '$TARGET_HOST' ==="
sudo nixos-rebuild switch --flake "$FLAKE_DIR#$TARGET_HOST"

echo "[✓] Rebuild completed successfully"
