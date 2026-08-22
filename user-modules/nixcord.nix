# DESC: Discord with vencord and declarative config.
# REQUIRES: Flake nixcord.url = "github:FlameFlag/nixcord";
# NOTE: config etc can be found here: https://github.com/FlameFlag/nixcord
{ inputs, lib, ... }: {
  imports = [ inputs.nixcord.homeModules.nixcord ];
  programs.nixcord.enable = true;
  programs.nixcord.discord.vencord.enable = true;
  # try to use theme
  programs.nixcord.config.enabledThemes = lib.mkDefault ["midnight-discord.css"];
}