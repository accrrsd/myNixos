
{ pkgs, ... }:

{
  home.file.".config/scripts/change_wallpaper.sh".text = ''
    
#!/usr/bin/env bash

# Пути
WALLPAPERS_PATH="$HOME/shared-across/dotfiles/wallpapers/"
HYPR_DIR="$HOME/.config/hypr/hyprpaper.conf"
CACHE_PATH="$HOME/.cache/wallpaper_previews/"

# Создаём кеш для превью, если его нет
mkdir -p "$CACHE_PATH"

# Генерация превью
for img in "$WALLPAPERS_PATH"*; do
    preview="$CACHE_PATH$(basename "$img")"
    if [ ! -f "$preview" ]; then
        convert "$img" -resize 200x200 "$preview"
    fi
done

# Выбор обоев через wofi с превью
NEW_WALL=$(ls "$WALLPAPERS_PATH" | wofi --dmenu --allow-images --preview "$CACHE_PATH" --preview-size 200)

# Проверка выбора
if [ -n "$NEW_WALL" ]; then
    # Установка новых обоев
    echo '' > "$HYPR_DIR"
    echo "preload = $WALLPAPERS_PATH$NEW_WALL" >> "$HYPR_DIR"
    echo "wallpaper =,$WALLPAPERS_PATH$NEW_WALL" >> "$HYPR_DIR"
    echo "splash = false" >> "$HYPR_DIR"

    # Копирование текущих обоев
    cp -rf "$WALLPAPERS_PATH$NEW_WALL" ~/.cache/current_wallpaper

    # Перезагрузка hyprpaper
    pkill hyprpaper && hyprpaper &
else
    echo "Выбор отменён."
fi
  '';

  # Делаем скрипт исполняемым
  home.activation = {
    makeWallpaperScriptExecutable = ''
      chmod +x $HOME/.config/scripts/change_wallpaper.sh
    '';
  };

  home.packages = with pkgs; [
    wofi
    imagemagick
  ];
}
