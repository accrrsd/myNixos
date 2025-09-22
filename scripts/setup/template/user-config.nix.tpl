{ config, pkgs, ... }:

{
  home = {
    username = "test";
    homeDirectory = "/home/test";
    stateVersion = "{{NIXPKGS_VERSION}}";
  };
  
  systemd.user.startServices = true;
}
