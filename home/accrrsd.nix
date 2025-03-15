
{ config, pkgs, ... }:

{
  home.username = "accrrsd";
  home.homeDirectory = "/home/accrrsd";

  home.packages = with pkgs; [
    lazygit
    vscode
    wezterm
  ];

  programs.git = {
    enable = true;
    userName = "Daniel";
    userEmail = "accrrsd@bk.ru";
  };

  home.stateVersion = "24.11";
}
