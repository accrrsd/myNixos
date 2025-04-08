{ lib, config, pkgs, ... }:

let
  getPkgFromStr = import ../../../functions/getPkgFromStr.nix { inherit lib pkgs; };
  themeData = builtins.fromJSON (builtins.readFile (./. + "/theme.json"));
  maybeCursorPkg = getPkgFromStr themeData.cursor.${themeData.polarity}.package;

  wallpaperCfg = themeData.wallpaper or {};
  hasWallpaper = wallpaperCfg ? path && wallpaperCfg ? hash;
  
  fetchRes = lib.optionalAttrs hasWallpaper (builtins.tryEval (
    builtins.fetchurl {
      url = "file://${wallpaperCfg.path}";
      sha256 = wallpaperCfg.hash;
    }
  ));
in
{
  home.stateVersion = "24.11";

  imports = [
    ./app/ssh/ssh.nix
    ./app/hyprland/hyprland.nix
    ./app/waybar/waybar.nix
    ./app/ohmyposh/ohmyposh.nix
    # did not use because of stylix cursor
    #./app/cursor/cursor.nix
    ../../../scripts/home-specific/swww-update.nix
  ];

  home.username = "accrrsd";
  home.homeDirectory = "/home/accrrsd";

  home.packages = with pkgs; [
    swww
    cava
  ];

  programs.git = {
    enable = true;
    userName = "Daniel";
    userEmail = "accrrsd@bk.ru";
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

  stylix = {
    enable = true;
    autoEnable = true;
    targets = {
      # trying to disable stylix wallpaper - needed for advanced wallpaper scripts
      hyprpaper.enable = lib.mkForce false;
      # fixes some apps
      gnome.enable = true;
      gtk.enable = true;
    };

    # does not work without autoenable
    #targets.qt.enable = true;
    #targets.kvantum.enable = true;
    #targets.xresources.enable = true;
    
    image = lib.mkIf fetchRes.success fetchRes.value;

    polarity = themeData.polarity;

    cursor = {
      name = themeData.cursor.${themeData.polarity}.name;
      size = themeData.cursor.${themeData.polarity}.size;
      package = lib.mkIf (maybeCursorPkg != null) maybeCursorPkg;
    };
  };
}