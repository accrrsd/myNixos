
{ inputs, config, pkgs, lib, ... }:

{
  networking.hostName = "accrrsd-pc";
  imports = [
  ./home-manager.nix
  ../../modules/app/steam.nix
  ../../modules/app/peripherals.nix
  ../../modules/hardware/autoclean.nix
  ];
  
  environment.systemPackages = with pkgs; [
  vscode
  git
  lazygit
  neovim
  telegram-desktop
  zig
  wezterm
  (nerdfonts.override { fonts = [ "FiraCode" ]; })
  fira-code
  wl-clipboard
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
