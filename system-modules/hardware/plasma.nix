{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.plasma-workspace
  ];
  services.desktopManager.plasma6.enable = lib.mkDefault true;
}
