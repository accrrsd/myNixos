{ pkgs, ... }:

{
  services.hardware.openrgb.enable = true;
  hardware.openrazer.enable = true;

  environment.systemPackages = with pkgs; [
    openrazer-daemon
    polychromatic
    openrgb-with-all-plugins
  ];
}

