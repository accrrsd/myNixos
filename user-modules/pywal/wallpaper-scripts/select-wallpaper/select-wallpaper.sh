#!/usr/bin/env bash
set -euo pipefail

# === НАСТРОЙКИ ===
# Массив путей к папкам с обоями
wall_dirs=(
    "/nixos-config/src/predefined-wallpaper"
    "$HOME/Pictures/Wallpapers"
)

cacheDir="$HOME/.cache/wallpapers/"
monitor_res=250
rofi_theme="$HOME/.config/rofi/wall_select.rasi"

# === ИНИЦИАЛИЗАЦИЯ ===
mkdir -p "$cacheDir"

# === ФУНКЦИЯ ДЛЯ ИМЕНИ МИНИАТЮРЫ ===
get_thumbnail() {
    local full_path="$1"
    local hash=$(echo -n "$full_path" | sha256sum | cut -c1-12)
    echo "$cacheDir/$hash.png"
}

# === СОЗДАНИЕ МИНИАТЮР ===
for wall_dir in "${wall_dirs[@]}"; do
    [ -d "$wall_dir" ] || continue
    find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | while IFS= read -r -d '' imagen; do
        thumbnail="$(get_thumbnail "$imagen")"
        if [ ! -f "$thumbnail" ]; then
            magick "$imagen" -strip -thumbnail "${monitor_res}x${monitor_res}^" -gravity center -extent "${monitor_res}x${monitor_res}" "$thumbnail"
        fi
    done
done

# === ФОРМИРОВАНИЕ СПИСКА ДЛЯ ROFI И ВЫБОР ===
# Собираем список, передаём в rofi, результат — полный путь к выбранному файлу
wall_selection=$(find "${wall_dirs[@]}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | while IFS= read -r -d '' imagen; do
    thumbnail="$(get_thumbnail "$imagen")"
    printf "%s\x00icon\x1f%s\n" "$imagen" "$thumbnail"
done | shuf | rofi -wayland -dmenu -theme "$rofi_theme" -theme-str "element-icon{size:${monitor_res}px;border-radius:0px;}")

# Если ничего не выбрано — выходим
[[ -n "$wall_selection" ]] || exit 1

# === ПРИМЕНЕНИЕ ===
swww img "$wall_selection" --transition-step 10 --transition-fps 30 --transition-type center &
wal -i "$wall_selection" &
sleep 0.2

# === ОБНОВЛЕНИЕ КОНФИГОВ ===
pkill waybar || true
waybar &
cp "$HOME/.cache/wal/cava_conf" "$HOME/.config/cava/config" 2>/dev/null || true
[[ $(pidof cava) != "" ]] && pkill -USR1 cava || true

exit 0