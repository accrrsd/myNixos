{ config, lib, pkgs, ... }:

{
  imports = [
    ../system-modules/hardware/boot.nix
    ../system-modules/hardware/region.nix
    ../system-modules/hardware/sound.nix
    ../system-modules/hardware/networking.nix
    ../system-modules/hardware/opengl.nix
    ../system-modules/hardware/automount.nix
    ../system-modules/hardware/printing.nix
    ../system-modules/hardware/bluetooth.nix
    ../system-modules/hardware/virtualization.nix
    ../system-modules/hardware/systemd.nix
    ../system-modules/hardware/sddm.nix
    ../system-modules/hardware/plasma.nix
    ../system-modules/hardware/autoclean.nix
  ];

  networking.hostName = lib.mkDefault "default";
  system.stateVersion = lib.mkDefault "25.05";

  environment.systemPackages = with pkgs; [
    vscode
    git
    wget
    ripgrep
    wl-clipboard
    wl-clip-persist
    fastfetch
    cliphist
    nixpkgs-fmt
    # allows use home-manager command without rebuild-swtich. (allow rebuild user only stuff)
    home-manager
  ];

  users.groups.nixos-editors = {};

  programs.firefox.enable = lib.mkDefault  true;
  services.xserver.enable = lib.mkDefault true;
  nixpkgs.config.allowUnfree = lib.mkDefault  true;
  security.polkit.enable = lib.mkDefault  true;
  services.flatpak.enable = lib.mkDefault  true;
  nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];

  xdg.portal = {
    enable = lib.mkDefault true;
    wlr.enable = lib.mkDefault true;
  };

  programs.git = {
    enable = lib.mkDefault true;
    config.safe.directory = lib.mkDefault [ "/nixos-config" ];
  };

  environment.sessionVariables = {
    HOSTNAME = config.networking.hostName;
  };
}
