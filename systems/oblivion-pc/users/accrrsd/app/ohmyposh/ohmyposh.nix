{ config, pkgs, ... }:
{
  # HERE and not in user-modules cause it REQUIERS zhs per user.
  
  # redefine system-wide zsh, needed for oh-my-posh
  programs.zsh = {
    enable = true;
    # user specific aliases
    shellAliases = {
      wreload = "pkill waybar && hyprctl dispatch exec waybar";
    };
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./config.json);
  };
}