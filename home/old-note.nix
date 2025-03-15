
{ config, pkgs, ... }:

{
  home.username = "accrrsd";
  home.homeDirectory = "/home/accrrsd";

  home.packages = with pkgs; [
    firefox
  ];

  home.stateVersion = "24.11";
}
