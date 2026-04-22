{ lib, inputs, config, pkgs, ... }:
{
  imports = [
    ../../../../user-modules/hyprland
    ../../../../user-modules/zsh
    ../../../../user-modules/kitty.nix

    ../../../../user-shared/accrrsd/app/waybar
    ../../../../user-shared/accrrsd/app/ssh.nix
    ../../../../user-shared/accrrsd/app/hyprland

    #../../../../user-modules/pywal
    ../../../../user-modules/matugen
    ../../../../user-modules/rofi
    ../../../../user-modules/qt-gtk.nix

    # enable flatpack for user pckgs
    #inputs.nix-flatpak.homeManagerModules.default
  ];

  wayland.windowManager.hyprland.extraConfig = ''monitor=HDMI-A-1,5120x1440@144.00,auto,1'';
  user-shared.hyprland.colorScheme = "matugen";
  user-modules.rofi.colorScheme = "matugen";

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
