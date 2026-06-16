{ config, pkgs, ... }:
{
  home = {
    username = "accrrsd";
    homeDirectory = "/home/accrrsd";
  };

  # auto update changed services
  systemd.user.startServices = true;

  news.display = "silent";

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 20;
  };

  programs.git = {
    enable = true;
    settings.user.name = "Daniel";
    settings.user.email = "accrrsd@bk.ru";
  };

  xdg.enable = true;

  # for google as browser - use google-chrome-stable.desktop
  
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

  # fix hm problem with mimeapps
  # xdg.configFile."mimeapps.list".force = true

  xdg.userDirs = {
    extraConfig = {
      XDG_GAME_DIR = "${config.home.homeDirectory}/Games";
      XDG_GAME_SAVE_DIR = "${config.home.homeDirectory}/Games/Saves";
    };
  };

  # idk, if it needed.
  # xdg.configFile."menus/applications.menu".text = builtins.readFile ../../src/utils/application.menu;
}