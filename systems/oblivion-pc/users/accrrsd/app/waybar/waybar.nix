{ pkgs, ... }:
{

  xdg.configFile."waybar/config".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;
  xdg.configFile."waybar/modules".source = ./modules.jsonc;

  programs.waybar = {
    enable = true;
  };
}