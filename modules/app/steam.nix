{ pkgs, ... }:

{
  hardware.graphics.enable32Bit = true;
  programs.steam.enable = true;
  environment.systemPackages = [ pkgs.steam ];
  programs.gamemode.enable = true;
}
