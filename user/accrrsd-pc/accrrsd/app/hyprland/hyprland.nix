{ inputs, pkgs, ... }:
{
  imports = [
    ./hyprland-config.nix
  ];
  
  home.packages = with pkgs; [
    hyprshot
    wofi
    dunst
    wlsunset
    kitty
    brightnessctl
    vlc
  ];
}