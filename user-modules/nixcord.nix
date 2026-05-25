# REQUIRES Flake nixcord.url = "github:FlameFlag/nixcord";
# config etc can be found here: https://github.com/FlameFlag/nixcord
{ inputs, lib, ... }: {
  imports = [ inputs.nixcord.homeModules.nixcord ];
  programs.nixcord.enable = true;

  # try to use theme
  programs.nixcord.config.enabledThemes = lib.mkDefault ["midnight-discord.css"];
}