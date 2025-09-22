{ lib, config, pkgs, ... }:
{
  home = {
    username = "test";
    homeDirectory = "/home/test";
    stateVersion = "25.05";
  };
  
  systemd.user.startServices = true;
}