
{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";

  imports = [
    ./app/ssh/ssh.nix
    ./app/hyprland/hyprland.nix
    ./app/waybar/waybar.nix
    ./app/ohmyposh/ohmyposh.nix
    ./app/cursor/cursor.nix
  ];

  home.username = "accrrsd";
  home.homeDirectory = "/home/accrrsd";

  home.packages = with pkgs; [
    swww
    cava
  ];

  programs.git = {
    enable = true;
    userName = "Daniel";
    userEmail = "accrrsd@bk.ru";
  };

  # auto update changed services
  systemd.user.startServices = true;
}
