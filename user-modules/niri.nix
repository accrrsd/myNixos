# ! to use this module, you should create your own niri config, check user-shared/accrrsd/app/niri/config/ for example
{ pkgs, lib, ... }:
{
  imports = [
    ./utils/wayland-utils.nix
  ];

  home.packages = with pkgs; [
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
