
{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";

  imports = [
    ./app/ssh.nix
  ];

  home.username = "accrrsd";
  home.homeDirectory = "/home/accrrsd";

  programs.git.userName = "Daniel";
  programs.git.userEmail = "accrrsd@bk.ru";

  home.packages = with pkgs; [
    htop
  ];

  # auto update changed services
  systemd.user.startServices = true;
}
