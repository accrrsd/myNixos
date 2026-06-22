{ pkgs, ... }:

{
  programs = {
    gamemode.enable = true;
    gamescope = {
      enable = true;
      # capSysNice = true;
    };
    steam = {
      enable = true;
      # dosent work for me
      # gamescopeSession.enable = true;
    };
  };
  hardware.graphics.enable32Bit = true;
}
