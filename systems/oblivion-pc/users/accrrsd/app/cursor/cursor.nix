# Not used anymore, but still here as example
{ config, pkgs, lib, ... }:
let
  getPkgFromStr = import ../../../functions/getPkgFromStr.nix { inherit lib pkgs; };
  themeData = builtins.fromJSON (builtins.readFile (./. + "/theme/theme.json"));
  maybeCursorPkg = getPkgFromStr themeData.cursor.${themeData.polarity}.package;
in
{
  gtk.cursorTheme = {
    name = themeData.cursor.${themeData.polarity}.name;
    size = themeData.cursor.${themeData.polarity}.size;
    package = lib.mkIf (maybeCursorPkg != null) maybeCursorPkg;
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = themeData.cursor.${themeData.polarity}.name;
    size = themeData.cursor.${themeData.polarity}.size;
    package = lib.mkIf (maybeCursorPkg != null) maybeCursorPkg;
  };

  qt = {
    enable = true;
    platformTheme = "qtct";
    style.name = config.gtk.cursorTheme.name;
  };
}