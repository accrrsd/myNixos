{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
  
    history = {
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    initContent = ''
      # allows use xdg.configFile to autocomplete zsh scripts
      mkdir -p $HOME/.config/zsh/completions
      fpath=($HOME/.config/zsh/completions $fpath)
    '';
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = lib.mkDefault (builtins.fromJSON (builtins.readFile ./config.json));
  };
}