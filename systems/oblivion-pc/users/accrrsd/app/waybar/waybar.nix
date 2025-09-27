{ pkgs, lib, ... }:
{

  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = lib.mkDefault ./style.css;

  programs.waybar.enable=true;

  home.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}