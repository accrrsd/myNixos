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
  ];

  # Write configuration JSON file
  xdg.configFile."ags-launcher.json".text = builtins.toJSON {
    gaps_proportion = 0.33;
    launcher_font = "14pt Hack Nerd Font, sans-serif";
    launcher_icon_size_multiplayer = 1.25;
    commands = {
      c = {
        type = "calc";
        name = "Calculator";
        icon = "accessories-calculator";
      };
      "!" = {
        type = "launch";
        exec = "{args}";
        name = "Run Shell Command";
        icon = "utilities-terminal";
      };
      yi = {
        type = "launch";
        exec = "xdg-open \"https://yandex.ru/images/search?text={urlargs}\"";
        name = "Yandex Images";
        icon = "applications-internet";
      };
      w = {
        type = "launch";
        exec = "select-wallpaper";
        name = "Wallpaper Selector";
        icon = "background";
      };
      yt = {
        type = "launch";
        exec = "xdg-open \"https://www.youtube.com/results?search_query={urlargs}\"";
        name = "Youtube";
        icon = "applications-internet";
      };
    };
  };
}