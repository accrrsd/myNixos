{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
    git
    neovim
    zig
    wezterm
    lazygit
    nerd-fonts.fira-code
    fira-code
  ];
}