{ config, pkgs, ... }:
{
  # system wide because of SDDM
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprpolkitagent

    glib #gsettings
    gsettings-desktop-schemas # for gtk dbus portal
  ];

  environment.variables = {
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
  };
  
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk  ];
  xdg.portal.config = {
    common = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.portal.Settings" = [ "gtk" ];
    };
    hyprland = {
      default = [ "hyprland" "gtk" ];
    };
  };
}
