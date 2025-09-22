{ inputs, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    extraConfig = builtins.readFile ./hyperland.conf;
  };
  
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