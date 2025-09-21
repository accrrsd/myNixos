{...}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nrebuild = "sudo /nixosConfig/scripts/setup/smart-rebuild.sh";
      hswitch = "/nixosConfig/scripts/setup/home-switch.sh";
      soundRestart = "systemctl --user restart pipewire";
    };
  };
}