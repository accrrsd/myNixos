{ lib, ... }:

{
  services.desktopManager.plasma6.enable = lib.mkDefault true;
}
