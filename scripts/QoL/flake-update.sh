#!/usr/bin/env bash
# usage example: ./flake-update.sh [pc-name] [package1 package2 ...] (optional)
# if you need update packages only - you can use "" as first argument. ./flake-update.sh "" [package1 package2]

set -euo pipefail

clear

TARGET_HOST="${1:-}"
if [ -z "$TARGET_HOST" ]; then
    TARGET_HOST="$HOSTNAME"
fi

if [ $# -gt 0 ]; then
    shift
fi

FLAKE_DIR="/nixos-config/systems/${TARGET_HOST}/flake"

if [ $# -gt 0 ]; then
    echo "Updating specific inputs inside ${TARGET_HOST}: $*"
    nix flake update --flake "${FLAKE_DIR}" "$@"
else
    echo "Updating all inputs inside ${TARGET_HOST}..."
    nix flake update --flake "${FLAKE_DIR}"
fi