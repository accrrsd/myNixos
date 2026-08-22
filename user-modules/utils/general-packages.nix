{ pkgs, ... }: {
  home.packages = with pkgs; [
    vscode
    ripgrep
    fastfetch
    nixfmt
  ];
}
