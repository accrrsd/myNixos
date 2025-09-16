{...}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      nrebuild = "sudo nixos-rebuild switch --flake /etc/nixos/";
      nfrebuild = "sudo nixos-rebuild switch --fast --flake /etc/nixos/";
      ntest = "sudo nixos-rebuild test --flake /etc/nixos/";
      nftest = "sudo nixos-rebuild test --fast --flake /etc/nixos/";
    };
  };
}