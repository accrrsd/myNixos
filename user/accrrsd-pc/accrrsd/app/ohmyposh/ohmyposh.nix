{ config, pkgs, ... }:
{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./config.json);
  };

  # redefine system-wide zsh, needed for oh-my-posh
  programs.zsh.enable = true;
}