{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
    git
    neovim
    zig
    lazygit
    nerd-fonts.fira-code
    fira-code
  ];
}