{ pkgs, lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    extraConfig = lib.mkDefault (builtins.readFile ./hyperland.conf);
  };
  
  home.packages = with pkgs; [
    hyprshot
    rofi
    dunst
    brightnessctl
    wl-gammarelay-rs
  ];
}