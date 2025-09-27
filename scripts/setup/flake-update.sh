#!/usr/bin/env bash
# usage example: ./flake-update.sh [pc-name] (optional)

set -euo pipefail

clear

HOSTNAME="${1:-$HOSTNAME}"

nix flake update --flake "/nixos-config/systems/${HOSTNAME}/flake"