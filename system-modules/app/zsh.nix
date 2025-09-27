{...}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nrebuild = "sudo /nixos-config/scripts/setup/smart-rebuild.sh";
      nupdate = "/nixos-config/scripts/setup/flake-update.sh";
      hswitch = "/nixos-config/scripts/setup/home-switch.sh";
      soundRestart = "systemctl --user restart pipewire";
    };
  };
}