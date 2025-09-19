#!/usr/bin/env bash

set -euo pipefail

clear

if [[ ! -v HOSTNAME ]]; then
    echo "[!] Error: HOSTNAME environment variable is not set" >&2
    exit 1
fi

HOSTNAME="${1:-$HOSTNAME}"
CONFIG_DIR="/nixosConfig"
HOST_DIR="$CONFIG_DIR/systems/$HOSTNAME"
FLAKE_DIR="$HOST_DIR/flake"
HW_FILE="$FLAKE_DIR/hardware-configuration.nix"

cleanup() {
    if [[ -f "$HW_FILE" ]] && git rev-parse --git-dir >/dev/null 2>&1; then
        git reset "$HW_FILE" 2>/dev/null && echo "[✓] Reset $HW_FILE from index" || \
        echo "[!] Warning: Could not reset $HW_FILE from index — probably wasn't added. Ignoring."
    fi
}

trap cleanup EXIT

echo "=== [1] Preparing flake: temporarily adding hardware config to Git index ==="

cd "$FLAKE_DIR"

# Copy hardware-configuration if missing
if [[ ! -f "$HW_FILE" ]]; then
    echo "[→] Copying /etc/nixos/hardware-configuration.nix → $HW_FILE"
    sudo cp /etc/nixos/hardware-configuration.nix "$HW_FILE"
    # Исправление: используем $USER и группу по умолчанию, если CURRENT_USER/GROUP не заданы
    sudo chown "${CURRENT_USER:-$USER}:${GROUP:-$(id -gn)}" "$HW_FILE"
    sudo chmod 644 "$HW_FILE"
fi

# Verify it's a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "[!] Error: $FLAKE_DIR is not a Git repository. Flake requires Git for self-reference."
    exit 1
fi

# Add hardware config to index temporarily
git add -f "$HW_FILE" 2>/dev/null || {
    echo "[!] Error: Could not add $HW_FILE to Git index"
    exit 1
}

echo "=== [2] Rebuild with flakes ==="

sudo nixos-rebuild switch --flake .#"$HOSTNAME"

echo "[✓] Rebuild completed successfully"