{ pkgs, ... }:

let
  selectWallpaper = pkgs.writeShellScriptBin "select-wallpaper" (builtins.readFile ./select-wallpaper.sh);
  startupMatugenUi = pkgs.writeShellScriptBin "startup-matugen-ui" (builtins.readFile ./startup-matugen-ui.sh);
in
[ selectWallpaper startupMatugenUi ]