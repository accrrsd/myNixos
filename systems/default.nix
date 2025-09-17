{ lib, pkgs, ... }:

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
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    wl-clipboard
    wl-clip-persist
    fastfetch
    cliphist
    nixpkgs-fmt
  ];

  users.groups.nixos-editors = {};

  programs.firefox.enable = true;
  services.xserver.enable = true;
  nixpkgs.config.allowUnfree = true;
  security.polkit.enable = true;
  services.flatpak.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  programs.git = {
    enable = true;
    config.safe.directory = [ "/nixosConfig" ];
  };
}
