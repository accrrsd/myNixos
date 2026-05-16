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
  xdg.portal.config = {
    common = {
      default = [ "gtk" ];
    };
    hyprland = {
      default = [ "hyprland" "gtk" ];
    };
  };
}
