# ! to use this module, you should create your own hyprland config, check user-shared/accrrsd/app/hyprland/config/ for example
{ pkgs, lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
  };

  home.packages = with pkgs; [
    hyprshot
    rofi
    brightnessctl
    wl-gammarelay-rs
  ];

  home.activation = {
    reloadHyprland = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "''${HYPRLAND_INSTANCE_SIGNATURE-}" ]; then
        ${pkgs.hyprland}/bin/hyprctl reload
      fi
    '';
  };
}
