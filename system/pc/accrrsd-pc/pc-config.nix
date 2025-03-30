
{ inputs, config, pkgs, lib, ... }:

{
  networking.hostName = "accrrsd-pc";

  imports = [
  ./users.nix
  ../../modules/app/steam.nix
  ../../modules/app/razer-peripherals.nix
  ../../modules/hardware/autoclean.nix
  ];
  
  environment.systemPackages = with pkgs; [
  vscode
  git
  lazygit
  telegram-desktop
  chromium
  nodejs
  dolphin
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk  pkgs.xdg-desktop-portal-hyprland];
}