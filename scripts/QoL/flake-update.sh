#!/usr/bin/env bash
# usage example: ./flake-update.sh [pc-name] [package1 package2 ...] (optional)
# if you need update packages only - you can use "" as first argument. ./flake-update.sh "" [package1 package2]

set -euo pipefail

clear

TARGET_HOST="${1:-$HOSTNAME}"

if [ $# -gt 0 ]; then
    shift
fi

FLAKE_DIR="/nixos-config/systems/${TARGET_HOST}/flake"

if [ $# -gt 0 ]; then
    echo "Update some packages inside ${TARGET_HOST}: $*"
    nix flake update --flake "${FLAKE_DIR}" "${@/#/--update-input }"
else
    echo "Update all packages inside ${TARGET_HOST}..."
    nix flake update --flake "${FLAKE_DIR}"
fi