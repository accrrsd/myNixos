{ pkgs, ... }:
let
  selectWallpaper = pkgs.writeShellScriptBin "select-wallpaper" (builtins.readFile ./select-wallpaper.sh);
  startupPywalUi = pkgs.writeShellScriptBin "startup-pywal-ui" (builtins.readFile ./startup-pywal-ui.sh);
in
[ selectWallpaper startupPywalUi ]