{ pkgs, ... }:
{
  imports = [
    ./waybar-config.nix
    ./waybar-style.nix
  ];
  
  home.packages = with pkgs; [
    waybar
  ];
}