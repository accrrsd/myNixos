# REQUIRES Flake nixcord.url = "github:FlameFlag/nixcord";
# config etc can be found here: https://github.com/FlameFlag/nixcord
{ inputs, ... }: {
  imports = [ inputs.nixcord.homeModules.nixcord ];
  programs.nixcord.enable = true;
}