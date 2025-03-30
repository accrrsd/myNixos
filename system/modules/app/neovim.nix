{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
    git
    neovim
    zig
    wezterm
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code
    wl-clipboard
  ];
}