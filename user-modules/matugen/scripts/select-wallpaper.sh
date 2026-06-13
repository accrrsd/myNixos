#!/usr/bin/env bash
set -euo pipefail

SCHEME_NAME="${1:-content}"
MODE="${2:-dark}"

if [[ "$MODE" != "dark" && "$MODE" != "light" ]]; then
    echo "Err: Second arg (mode) must be 'light' or 'dark'. Get: '$MODE'" >&2
    exit 1
fi

wall_dirs=(
    "/nixos-config/src/predefined-wallpaper"
    "$HOME/Pictures/Wallpapers"
)

cacheDir="$HOME/.cache/wallpapers/"
monitor_res=250
rofi_theme="$HOME/.config/rofi/wall_select.rasi"

mkdir -p "$cacheDir"

get_thumbnail() {
    local full_path="$1"
    local hash=$(echo -n "$full_path" | sha256sum | cut -c1-12)
    echo "$cacheDir/$hash.png"
}

for wall_dir in "${wall_dirs[@]}"; do
    [ -d "$wall_dir" ] || continue
    find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | while IFS= read -r -d '' imagen; do
        thumbnail="$(get_thumbnail "$imagen")"
        if [ ! -f "$thumbnail" ]; then
            magick "$imagen" -strip -thumbnail "${monitor_res}x${monitor_res}^" -gravity center -extent "${monitor_res}x${monitor_res}" "$thumbnail"
        fi
    done
done

wall_selection=$(find "${wall_dirs[@]}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | while IFS= read -r -d '' imagen; do
    thumbnail="$(get_thumbnail "$imagen")"
    printf "%s\x00icon\x1f%s\n" "$imagen" "$thumbnail"
done | shuf | rofi -wayland -dmenu -theme "$rofi_theme" -theme-str "element-icon{size:${monitor_res}px;border-radius:0px;}")

[[ -n "$wall_selection" ]] || exit 1

awww img "$wall_selection" --transition-step 10 --transition-fps 30 --transition-type any &
matugen image "$wall_selection" -m "$MODE" --source-color-index 0 -t "scheme-$SCHEME_NAME" & sleep 0.2

exit 0


# Possible schemes (without scheme- prefix)
# tonal-spot  - Default Material You palette. Balanced and soft.
# fidelity    - Matches the source color as closely as possible.
# content     - Optimized for content-based colors, natural look.
# expressive  - High contrast, vibrant, and bold accent colors.
# fruit-salad - High saturation and diverse "playful" color mix.
# rainbow     - Vivid colors with minimal neutral/gray tones.
# neutral     - Desaturated, grayscale-heavy, minimalist palette.
# monochrome  - Shades of a single color for a clean, uniform look.