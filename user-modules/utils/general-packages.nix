{ pkgs, ... }: {
  home.packages = with pkgs; [
    vscode-fhs
    ripgrep
    fastfetch
    nixfmt
  ];
}
