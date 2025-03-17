{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  openrazer-daemon
  polychromatic
  openrgb-with-all-plugins
  ];

  services.hardware.openrgb.enable = true;
}

