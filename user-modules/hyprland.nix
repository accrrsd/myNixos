# ! to use this module, you should create your own hyprland config, check user-shared/accrrsd/app/hyprland/config/ for example
{ pkgs, lib, ... }:
{
  imports = [
    ./utils/wayland-utils.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
  };

  home.activation = {
    reloadHyprland = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "''${HYPRLAND_INSTANCE_SIGNATURE-}" ]; then
        ${pkgs.hyprland}/bin/hyprctl reload
      fi
    '';
  };
}
