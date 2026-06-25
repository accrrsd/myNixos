{ config, pkgs, ... }:
let
hyprExit = ''
    if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
      exit 1
    fi
    VERSION=$(hyprctl version | awk '/^Hyprland/ {print $2}' | cut -d'-' -f1)
    MINOR_VERSION=$(echo "$VERSION" | cut -d'.' -f2)
    if [ -n "$MINOR_VERSION" ] && [ "$MINOR_VERSION" -gt 54 ]; then
      hyprctl dispatch "hl.dsp.exit()"
    else
      hyprctl dispatch exit
    fi
  '';
in
{
  # system wide because of SDDM
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    hyprpolkitagent
    # i dont really understand needed it or not. For now its commented.
    # glib
    # gsettings-desktop-schemas
    (writeShellScriptBin "hyprExit" hyprExit)
  ];

  # environment.variables.GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

  xdg.portal.config = {
    common = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.portal.Settings" = [ "gtk" ];
    };
    hyprland = {
      default = [ "hyprland" "gtk" ];
    };
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
}