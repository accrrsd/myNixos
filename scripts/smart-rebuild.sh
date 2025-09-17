#!/usr/bin/env bash

set -euo pipefail

clear

if [[ ! -v HOSTNAME ]]; then
    echo "❌ Error: HOSTNAME environment variable is not set" >&2
    exit 1
fi

CONFIG_DIR="/nixosConfig"
HOST_DIR="$CONFIG_DIR/systems/$HOSTNAME"
HW_FILE="$HOST_DIR/hardware-configuration.nix"

echo "=== 1️⃣ Preparing flake: temporarily adding hardware config to Git index ==="
cd "$HOST_DIR"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Error: $HOST_DIR is not a Git repository. Flake requires Git for self-reference."
    exit 1
fi

git add -f "$HW_FILE" 2>/dev/null || {
    echo "❌ Error Could not add $HW_FILE to Git index"
    exit 1
}

echo "=== 2️⃣ Rebuild with flakes ==="

sudo nixos-rebuild switch --flake .#"$HOSTNAME"

echo "=== 3️⃣ Cleaning up: removing hardware config from Git index ==="

git reset "$HW_FILE" 2>/dev/null || {
    echo "⚠️ Warning: Could not reset $HW_FILE from index — probably wasn't added. Ignoring."
}