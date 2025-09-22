{ pkgs, ... }:
{

  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;

  programs.waybar.enable=true;

  home.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}