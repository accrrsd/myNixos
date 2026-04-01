{ pkgs, ... }:
{
  home.packages = with pkgs; (import ./wallpaper-scripts { inherit pkgs; }) ++ [
    pywal
    pywalfox-native
    swww
  ];

  xdg.configFile."wal/templates/".source = ./templates;
}