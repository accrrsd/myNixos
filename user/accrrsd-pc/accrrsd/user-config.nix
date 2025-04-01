
{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";

  imports = [
    ./app/ssh/ssh.nix
    ./app/hyprland/hyprland.nix
    ./app/waybar/waybar.nix
    ./app/ohmyposh/ohmyposh.nix
  ];

  home.username = "accrrsd";
  home.homeDirectory = "/home/accrrsd";

  programs.git = {
    enable = true;
    userName = "Daniel";
    userEmail = "accrrsd@bk.ru";
  };

  home.packages = with pkgs; [
    swww
    cava
  ];

  # auto update changed services
  systemd.user.startServices = true;
}
