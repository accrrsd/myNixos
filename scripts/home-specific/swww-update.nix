{ config, pkgs, ... }:
{
  home.packages = [
    (pkgs.writeScriptBin "update-wallpaper" ''
      #!/usr/bin/env bash
      set -euo pipefail

      if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <path-to-wallpaper>" >&2
        exit 1
      fi

      WALLPAPER="$1"
      THEME_FILE="/etc/nixos/user/$(hostname)/$USER/theme.json"

      # Проверки
      [[ -f "$WALLPAPER" ]] || { echo "Error: Wallpaper not found: $WALLPAPER" >&2; exit 1; }
      [[ -f "$THEME_FILE" ]] || { echo "Error: Theme file not found: $THEME_FILE" >&2; exit 1; }

      # Обновляем JSON (с временным файлом для атомарности)
      ${pkgs.jq}/bin/jq \
        --arg path "$WALLPAPER" \
        --arg hash "$(${pkgs.nix}/bin/nix-prefetch-url "file://$WALLPAPER")" '
        .wallpaper.path = $path |
        .wallpaper.hash = $hash' \
        "$THEME_FILE" > "$THEME_FILE.tmp"

      # Перемещаем с sudo если нужно
      if ! mv "$THEME_FILE.tmp" "$THEME_FILE" 2>/dev/null; then
        sudo mv "$THEME_FILE.tmp" "$THEME_FILE"
      fi

      # Применяем обои
      ${pkgs.swww}/bin/swww img "$WALLPAPER" \
        --transition-duration 30 \
        --transition-fps 60 \
        --transition-type any

      # Пересобираем систему
      echo "Rebuilding system..."
      sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild test --flake /etc/nixos --fast
    '')
  ];
}