{ config, pkgs, ... }:
{
  # install niri via programs. so sddm can see it.
  programs.niri.enable = true;
}