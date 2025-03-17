
{ config, pkgs, ... }:

{
  imports = [
    ./de/hyprland/hyprland.nix
    ./app/wofi/wofi.nix
  ];

  home.username = "accrrsd";
  home.homeDirectory = "/home/accrrsd";

  home.packages = with pkgs; [
    htop
  ];

  programs.git = {
    enable = true;
    userName = "Daniel";
    userEmail = "accrrsd@bk.ru";
  };

  # Make Mason work
  home.sessionPath = [
    "$HOME/.local/bin"
  ];


  home.stateVersion = "24.11";

  systemd.user.startServices = "sd-switch";

  # DE specific for user, not specific for host
  home.file.".config/sddm.conf.d/autologin.conf".text = ''
    [Autologin]
    User=accrrsd
    Session=hyprland
  '';
}

