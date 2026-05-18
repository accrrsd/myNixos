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

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];

  # All of this commented cause may be overcode.

  # pkgs
  #glib #gsettings
  #gsettings-desktop-schemas # for gtk dbus portal

  # xdg.portal.config.hyprland.default = [ "hyprland" "gtk" ]
  #"org.freedesktop.portal.Settings" = [ "gtk" ];

  xdg.portal.config = {
    common = {
      default = [ "gtk" ];
    };
    hyprland = {
      default = [ "hyprland" "gtk" ];
    };
  };
}