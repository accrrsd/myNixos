{ pkgs, ... }:
pkgs.writeShellScriptBin "startup ui" ''
  dunst &
  swww-daemon &

  change_wallpaper &

  sleep 0.1
  waybar &
''