{ config, pkgs, lib, ... }:
{
  # Enable AGS and pass package names as strings
  user-modules.ags = {
    enable = true;
    extraPackages = [ "notifd" "apps" ];
  };

  programs.ags.configDir = ./src;

  home.packages = [
    pkgs.libqalculate
    pkgs.libnotify
  ];

  # Write configuration JSON file
  xdg.configFile."ags-settings.json".source = ./ags-settings.json;
}