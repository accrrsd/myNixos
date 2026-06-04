{ pkgs, ... }: {
  home.packages = with pkgs; [
    neovim
    zig
    lazygit
  ];
}
