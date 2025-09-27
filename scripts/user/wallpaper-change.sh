#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path-to-wallpaper>" >&2
  exit 1
fi

WALLPAPER="$1"
HOSTNAME="${2:-$HOSTNAME}"
USER="${3:-$USER}"
THEME_FILE="/nixos-config/systems/$($HOSTNAME)/$USER/theme.json"

[[ -f "$WALLPAPER" ]] || { echo "Error: Wallpaper not found: $WALLPAPER" >&2; exit 1; }
[[ -f "$THEME_FILE" ]] || { echo "Error: Theme file not found: $THEME_FILE" >&2; exit 1; }

jq \
  --arg path "$WALLPAPER" \
  --arg hash "$(nix-prefetch-url "file://$WALLPAPER")" '
  .wallpaper.path = $path |
  .wallpaper.hash = $hash' \
  "$THEME_FILE" > "$THEME_FILE.tmp"

if ! mv "$THEME_FILE.tmp" "$THEME_FILE" 2>/dev/null; then
  sudo mv "$THEME_FILE.tmp" "$THEME_FILE"
fi

swww img "$WALLPAPER" \
  --transition-duration 30 \
  --transition-fps 60 \
  --transition-type any

echo "Rebuilding system..."
sudo nixos-rebuild test --flake /etc/nixos --fast
