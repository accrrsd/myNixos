{ inputs, config, pkgs, ... }:

{
  networking.hostName = "oblivion-pc";

  environment.sessionVariables = {
    HOSTNAME = config.networking.hostName;
  };

  imports = [
    ../default.nix
    ./users/users.nix
    
    # modules specific for a pc
    ../../system-modules/hardware/amd-gpu.nix

    # system-wide apps
    ../../system-modules/app/steam.nix
    ../../system-modules/app/razer-peripherals.nix
    ../../system-modules/app/zsh.nix
    ../../system-modules/app/neovim.nix
  ];

  # specific for pc, and needed only if not uefi.
  boot.loader.grub.device = "/dev/sdb";

  environment.systemPackages = with pkgs; [
    vscode
    git
    telegram-desktop
    chromium
    nodejs
    htop
    transmission_4-gtk
    linux-wallpaperengine
    wezterm
    inputs.zen-browser.packages."${pkgs.system}".default
    niri
  ];

  # system wide because of SDDM
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  system.stateVersion = "25.05";
}