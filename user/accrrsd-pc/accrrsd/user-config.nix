{ lib, config, pkgs, ... }:

let
  getPkgFromStr = import ../../../functions/getPkgFromStr.nix { inherit lib pkgs; };
  findWallpaper = import ../../../functions/find-wallpaper.nix {inherit lib; };

  themeData = builtins.fromJSON (builtins.readFile (./. + "/theme/theme.json"));

  maybeCursorPkg = getPkgFromStr themeData.cursor.${themeData.polarity}.package;
  maybeWallpaper = findWallpaper (./. + "/theme/wallpaper");
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
      "text/html" = "zen-browser.desktop";
      "inode/directory" = "dolphin.desktop";
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
    # disable stylix wallpaper - needed for advanced wallpaper scripts
    targets.hyprpaper.enable = lib.mkForce false;
    image = lib.mkIf (maybeWallpaper != null) maybeWallpaper;

    polarity = themeData.polarity;

    cursor = {
      name = themeData.cursor.${themeData.polarity}.name;
      size = themeData.cursor.${themeData.polarity}.size;
      package = lib.mkIf (maybeCursorPkg != null) maybeCursorPkg;
    };
  };
}