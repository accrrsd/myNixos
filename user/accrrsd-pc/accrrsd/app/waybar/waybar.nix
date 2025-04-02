{ pkgs, ... }:
{
  imports = [
    ./waybar-config.nix
    ./waybar-style.nix
  ];

  programs.waybar = {
    enable = true;
  };
}