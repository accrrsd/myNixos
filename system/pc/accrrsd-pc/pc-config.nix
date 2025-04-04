
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
  htop
  inputs.zen-browser.packages."${system}".default
  transmission_4-gtk
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
  
  # even more avaiable packages!
  services.flatpak.enable = true;

  stylix.enable = true;
  stylix.image = ../../default-wallpaper.jpg;
  
  #stylix.targets.overlays.enable = false;
  #stylix.image = "${config.home.homeDirectory}/Pictures/red-tree.jpg";
  #stylix.image = "${config.users.users.username.home}"/Pictures/red-tree.jpg;
}