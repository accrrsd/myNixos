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
    mako
    wlsunset
    kitty
    brightnessctl
    vlc
  ];
}