{ inputs, config, pkgs, stateVersion, ... }:

{
  networking.hostName = "oblivion-pc";

  environment.sessionVariables = {
    HOSTNAME = config.networking.hostName;
  };


  imports = [
    ../default/pc-config.nix
    ./users/users.nix

    # system-wide apps
    ../system-modules/app/steam.nix
    ../system-modules/app/razer-peripherals.nix
    ../system-modules/app/zsh.nix
  ];

  # specific for pc, and needed only if not uefi.
  boot.loader.grub.device = "/dev/sdb";

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
    inputs.zen-browser.packages."${pkgs.system}".default
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "accrrsd";

  system.stateVersion = stateVersion;

}