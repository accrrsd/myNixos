{ inputs, pkgs, ... }:
{
  imports = [
    ./hyprland-config.nix
  ];
  
  home.packages = with pkgs; [
    wofi
    dunst
    wlsunset
    kitty
    brightnessctl
    vlc
    cliphist
  ];
}