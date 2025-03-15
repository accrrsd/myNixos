
{ config, pkgs, lib, ... }:

{
  networking.hostName = "accrrsd-pc";
  imports = [
    ./../modules/system-packages.nix
  ];


  environment.systemPackages = with pkgs; [
  vim
  wget
  vscode
  git
  lazygit
  neovim
  telegram-desktop
  zig
  wezterm
  (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  fira-code
  wl-clipboard
  steam
  ];
}
