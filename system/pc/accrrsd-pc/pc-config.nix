
{ inputs, config, pkgs, lib, ... }:

{
  networking.hostName = "accrrsd-pc";

  imports = [
  ./users.nix
  ../../modules/app/steam.nix
  ../../modules/app/razer-peripherals.nix
  ../../modules/hardware/autoclean.nix
  ../../modules/hardware/nvidia.nix
  # System wide zsh, needed for accrrsd
  ../../modules/app/zsh.nix
  ../../modules/app/neovim.nix
  ];
  
  environment.systemPackages = with pkgs; [
  vscode
  git
  lazygit
  telegram-desktop
  chromium
  nodejs
  dolphin
  htop
  inputs.zen-browser.packages."${system}".default
  ];
  
  # even more avaiable packages!
  services.flatpak.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
}