#!/usr/bin/env bash
# usage: ./home-switch.sh

set -euo pipefail

clear

HOSTNAME="${1:-$HOSTNAME}"
CONFIG_DIR="/nixos-config"
HOST_DIR="$CONFIG_DIR/systems/$HOSTNAME"
FLAKE_DIR="$HOST_DIR/flake"
ORIGINAL_DIR="$(pwd)"

echo "=== [1] Applying home manager switch... ==="

if ! command -v home-manager &> /dev/null; then
    echo "[!] Error: HOSTNAME environment variable (or 1st argument) is not set" >&2
    exit 1
fi

if [[ ! -v HOSTNAME ]]; then
    echo "[!] Error: HOSTNAME environment variable is not set" >&2
    exit 1
fi

cleanup() {
    cd "$ORIGINAL_DIR"
}

trap cleanup EXIT


if [[ ! -d "$FLAKE_DIR" ]]; then
    echo "[!] Error: Flake directory not found: $FLAKE_DIR" >&2
    exit 1
fi

home-manager switch --flake "$FLAKE_DIR"