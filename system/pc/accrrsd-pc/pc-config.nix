
{ inputs, config, pkgs, lib, ... }:

{
  networking.hostName = "accrrsd-pc";

  environment.sessionVariables = {
    HOSTNAME = config.networking.hostName;
  };

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
  transmission_4-gtk
  linux-wallpaperengine
  inputs.zen-browser.packages."${system}".default
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
  
  # even more avaiable packages! (for example - zen browser not from flakes because its broke after any update)
  services.flatpak.enable = true;

  # disable system wide stylix, because user wide stylix dont apply on all apps with that setup
  stylix.enable = false;
  # used as fallback image
  stylix.image = ./default-wallpaper.jpg;

  # allow ntfs (windows)
  boot.supportedFilesystems = [ "ntfs" ];
  # Disk mouning (SPECIFIC FOR PC) Get uuid and etc from command sudo blkid | grep -E "nvme0n1p3|sda1"
  fileSystems."/mnt/nvme" = {
    device = "/dev/disk/by-uuid/B07836FF7836C3BE";
    fsType = "ntfs";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "nofail"
      "windows_names"
    ];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/0670796770795DFD";
    fsType = "ntfs";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "nofail"
      "windows_names"
    ];
  };
}