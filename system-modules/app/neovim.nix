{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
    git
    neovim
    zig
    kitty
    lazygit
    nerd-fonts.fira-code
    fira-code
  ];
}