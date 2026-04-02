{ lib, inputs, config, pkgs, ... }:
{
  imports = [
    ./app/ssh.nix
    ./app/hyprland/hyprland.nix
    ./app/waybar/waybar.nix
    ./app/ohmyposh/ohmyposh.nix
    ./app/kitty.nix

    ../../../../user-modules/pywal
    ../../../../user-modules/rofi

    # enable flatpack for user pckgs
    #inputs.nix-flatpak.homeManagerModules.default 
    
    #../../../../user-modules/wezterm.nix
  ];

  home = {
    username = "accrrsd";
    homeDirectory = "/home/accrrsd";
    stateVersion = "25.11";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 20;
  };
  
  # auto update changed services
  systemd.user.startServices = true;

  home.packages = with pkgs; [
    swww
    cava
  ];

  # example of flatpack usage
  #services.flatpak.packages = [

  #];

  programs.git = {
    enable = true;
    settings.user.name = "Daniel";
    settings.user.email = "accrrsd@bk.ru";
  };

  # already enabled by import, needed only for dotfiles
  # programs.wezterm.extraConfig = builtins.readFile ./dotfiles/wezterm.lua;
  #xdg.configFile."wezterm/wezterm.lua".source = ./dotfiles/wezterm.lua;

  xdg.enable = true;
  
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
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

  # idk, if it needed.
  xdg.configFile."menus/applications.menu".text = builtins.readFile ../../../../src/utils/application.menu;

}
