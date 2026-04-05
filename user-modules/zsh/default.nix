{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = lib.mkDefault (builtins.fromJSON (builtins.readFile ./config.json));
  };
}