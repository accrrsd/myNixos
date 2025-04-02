{ config, pkgs, ... }:
{
  gtk.cursorTheme = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 22;
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    inherit (config.gtk.cursorTheme) name package size;
  };

  qt = {
    enable = true;
    platformTheme = "qtct";
    style.name = config.gtk.cursorTheme.name;
  };
}