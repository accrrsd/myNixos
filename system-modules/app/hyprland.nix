{ config, pkgs, ... }:
{
  # system wide because of SDDM
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # glib, gsettings-schemas and org.free commented cause may be overcode.

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
    #glib #gsettings
    #gsettings-desktop-schemas # for gtk dbus portal
  ];

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config = {
    common = {
      default = [ "gtk" ];
      #"org.freedesktop.portal.Settings" = [ "gtk" ];
    };
    hyprland = {
      default = [ "hyprland" "gtk" ];
    };
  };
}
