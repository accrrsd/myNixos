#!/usr/bin/env bash
# usage example: ./flake-update.sh [pc-name] (optional)

set -euo pipefail

clear

TARGET_HOST="${1:-$HOSTNAME}"

nix flake update --flake "/nixos-config/systems/${TARGET_HOST}/flake"
