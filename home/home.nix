
{ config, pkgs, ... }:

{
  home.username = "accrrsd";
  home.homeDirectory = "/home/accrrsd";

  # Программы, которые будут устанавливаться через Home Manager:
  home.packages = with pkgs; [
    git
    neovim
  ];

  # Настройки Git
  programs.git = {
    enable = true;
    userName = "accrrsd";
    userEmail = "your.email@example.com";
  };

  home.stateVersion = "23.11";  # Укажи свою версию NixOS
}
