{ pkgs, ... }:
pkgs.writeShellScriptBin "select-wallpaper" (builtins.readFile ./select-wallpaper.sh)