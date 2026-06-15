{ pkgs, ... }:

{
  # openrazer (not a polychromatic) have a configct with openrgb
  hardware.openrazer.enable = true;
  environment.systemPackages = with pkgs; [
    polychromatic
    openrazer-daemon
  ];
}
