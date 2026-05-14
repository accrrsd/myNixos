{ config, pkgs, ... }:
{
  # system wide because of SDDM
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
  ];

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
}