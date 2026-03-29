{ config, pkgs, ... }:

{
  home = {
    username = "{{USER_NAME}}";
    homeDirectory = "/home/{{USER_NAME}}";
    stateVersion = "{{NIXPKGS_VERSION}}";
  };
  
  systemd.user.startServices = true;
}
