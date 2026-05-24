# ! to use this module, you should create your own niri config, check user-shared/accrrsd/app/niri/config/ for example
{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    rofi
    brightnessctl
    wl-gammarelay-rs
    alacritty
  ];

  home.activation = {
    reloadNiri = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "''${NIRI_INSTANCE_SIGNATURE-}" ]; then
        ${pkgs.niri}/bin/niri msg action load-config-file
      fi
    '';
  };
}
