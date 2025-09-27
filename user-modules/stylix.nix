# REQUIRED STYLIX IN FLAKES! JUST AS INPUT, since imports = [ inputs.stylix.homeModules.stylix ]; declared here and do not needed in other places.
# Usage: imports = imports = [ (import ./user-modules/stylix.nix {inherit inputs lib pkgs; themePath = ./theme.json; })];


{ inputs, lib, pkgs, themePath, ... }:

let
  themeData = builtins.fromJSON (builtins.readFile themePath);

  getPkgFromStr = import ../functions/getPkgFromStr.nix { inherit lib pkgs; };

  polarity = lib.attrByPath [ "polarity" ] null themeData;
  cursorCfg = lib.attrByPath [ "cursor" polarity ] { } themeData;
  maybeCursorPkg = getPkgFromStr {
    pkgString = lib.attrByPath [ "package" ] null cursorCfg;
    strict = false;
  };

  wallpaperPath = lib.attrByPath [ "wallpaper" "path" ] null themeData;
  wallpaperHash = lib.attrByPath [ "wallpaper" "hash" ] null themeData;

  wallpaperFetch =
    if wallpaperPath != null && wallpaperHash != null then
      builtins.fetchurl {
        url = "file://${wallpaperPath}";
        sha256 = wallpaperHash;
      }
    else
      null;

in {
  imports = [ inputs.stylix.homeModules.stylix ];

  stylix = {
    enable = true;
    autoEnable = true;

    image = lib.mkIf (wallpaperFetch != null) wallpaperFetch;
    polarity = lib.mkIf (polarity != null) polarity;

    cursor = {
      name = lib.mkIf (cursorCfg ? name) cursorCfg.name;
      size = lib.mkIf (cursorCfg ? size) cursorCfg.size;
      package = lib.mkIf (maybeCursorPkg != null) maybeCursorPkg;
    };
  };
}
