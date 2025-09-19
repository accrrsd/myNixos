{ lib, config, pkgs, ... }:
{
  imports = [
    ./app/ssh.nix
    ./app/hyprland/hyprland.nix
    ./app/waybar/waybar.nix
    ./app/ohmyposh/ohmyposh.nix
    ../../../../user-modules/virtualSound.nix
  ];

  home = {
    username = "accrrsd";
    homeDirectory = "/home/accrrsd";
    stateVersion = "25.05";
  };

  home.packages = with pkgs; [
    swww
    cava
  ];

  programs.git = {
    enable = true;
    userName = "Daniel";
    userEmail = "accrrsd@bk.ru";
  };

  # example of user usage virtualSound
  programs.virtualSurround = {
    enable = true;
    hrtfPath = ../../../../src/sound/A3D.wav;
  };

  xdg.enable = true;
  
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "dolphin.desktop";
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
    };
  };

  xdg.userDirs = {
    extraConfig = {
      XDG_GAME_DIR = "${config.home.homeDirectory}/Games";
      XDG_GAME_SAVE_DIR = "${config.home.homeDirectory}/Games/Saves";
    };
  };

  # auto update changed services
  systemd.user.startServices = true;
}