{ pkgs, ... }:
pkgs.writeShellScriptBin "change-wallpaper" ''
  file=$(ls /nixos-config/src/predefined-wallpaper  | shuf -n 1)
  swww img /nixos-config/src/predefined-wallpaper/$file --transition-step 10 --transition-fps 30 --transition-type center &
  wal -n -i /nixos-config/src/predefined-wallpaper/$file &
  sleep 0.2
  cp ~/.cache/wal/cava_conf ~/.config/cava/config &
  [[ $(pidof cava) != "" ]] && pkill -USR1 cava &
''