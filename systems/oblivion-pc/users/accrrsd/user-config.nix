{ lib, inputs, config, pkgs, ... }:
{
  imports = [
    ./app/ssh.nix
    ./app/hyprland/hyprland.nix
    ./app/waybar/waybar.nix
    ./app/ohmyposh/ohmyposh.nix

    (import ../../../../user-modules/stylix.nix {inherit inputs lib pkgs; themePath = ./theme.json; })
    ../../../../user-modules/virtualSound.nix
    ../../../../user-modules/wezterm.nix
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

  # already enabled by import, needed only for dotfiles
  # programs.wezterm.extraConfig = builtins.readFile ./dotfiles/wezterm.lua;
  xdg.configFile."wezterm/wezterm.lua".source = ./dotfiles/wezterm.lua;

  # example of user usage virtualSound
  user-modules.virtualSurround = {
    enable = true;
    hrtfPath = ../../../../src/sound/SteamAudio.wav;
  };

  xdg.enable = true;
  
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "dolphin.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
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