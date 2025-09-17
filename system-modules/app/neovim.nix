{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
    git
    neovim
    zig
    wezterm
    lazygit
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code
  ];
}