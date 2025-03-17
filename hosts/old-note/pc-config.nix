
{ config, pkgs, lib, ... }:

{
  networking.hostName = "old-note";
  imports = [
    ../modules/system-packages.nix
    ../modules/pipewire.nix
  ];
}
