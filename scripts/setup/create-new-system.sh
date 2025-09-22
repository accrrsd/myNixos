#!/usr/bin/env bash
# usage example: ./create-new-system.sh <pc-name> <username> [nixpkgs-version] (optional)

set -euo pipefail

PC_NAME="$1"
USER_NAME="$2"
NIXPKGS_VERSION="${3:-25.05}"

CONFIG_ROOT="/nixos-config"
SYSTEMS_DIR="$CONFIG_ROOT/systems"
NEW_SYSTEM_DIR="$SYSTEMS_DIR/$PC_NAME"
FLAKE_DIR="$NEW_SYSTEM_DIR/flake"
USERS_DIR="$NEW_SYSTEM_DIR/users/$USER_NAME"
TEMPLATE_DIR="$CONFIG_ROOT/scripts/setup/template"

if [[ ! -f /etc/nixos/configuration.nix ]]; then
  echo "[!] Error: /etc/nixos/configuration.nix not found"
  exit 1
fi

GRUB_LINE=$(grep -E 'boot\.loader\.grub\.device' /etc/nixos/configuration.nix || true)
if [[ -z "$GRUB_LINE" ]]; then
  echo "[!] Error: boot.loader.grub.device not found in /etc/nixos/configuration.nix, probably using UEFI"
fi

echo "===Creating $USER_NAME@$PC_NAME with GRUB:$GRUB_LINE ==="

mkdir -p "$FLAKE_DIR" "$USERS_DIR/app" "$USERS_DIR/dotfiles"

render_template() {
  sed \
    -e "s|{{PC_NAME}}|$PC_NAME|g" \
    -e "s|{{USER_NAME}}|$USER_NAME|g" \
    -e "s|{{GRUB_LINE}}|$GRUB_LINE|g"
}

render_template < "$TEMPLATE_DIR/flake.nix.tpl" > "$FLAKE_DIR/flake.nix"
render_template < "$TEMPLATE_DIR/pc-config.nix.tpl" > "$NEW_SYSTEM_DIR/pc-config.nix"
render_template < "$TEMPLATE_DIR/users.nix.tpl" > "$NEW_SYSTEM_DIR/users.nix"
render_template < "$TEMPLATE_DIR/user-config.nix.tpl" > "$USERS_DIR/user-config.nix"

echo "[✓] Done. New config was created in $NEW_SYSTEM_DIR"
