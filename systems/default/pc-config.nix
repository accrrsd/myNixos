
# default config before any host
{ inputs, lib, config, pkgs, ... }:

{
  imports = [
  ./hardware-configuration.nix
  ../../system-modules/hardware/boot.nix
  ../../system-modules/hardware/region.nix
  ../../system-modules/hardware/sound.nix
  ../../system-modules/hardware/networking.nix
  ../../system-modules/hardware/opengl.nix
  ../../system-modules/hardware/automount.nix
  ../../system-modules/hardware/printing.nix
  ../../system-modules/hardware/bluetooth.nix
  ../../system-modules/hardware/virtualization.nix
  ../../system-modules/hardware/systemd.nix
  ../../system-modules/hardware/sddm.nix
  ../../system-modules/hardware/plasma.nix
  ../../system-modules/hardware/autoclean.nix
  ];

  networking.hostName = "default";
  system.stateVersion = "25.05";

  environment.systemPackages = with pkgs; [
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

  # create a group that can edit /nixConfig folder. You can get rights for it by bootstrap script.
  users.groups.nixos-editors = {};

  programs.firefox.enable = true;
  services.xserver.enable = true;
  # services.printing.enable = true;
  nixpkgs.config.allowUnfree = true;
  security.polkit.enable = true;
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  programs.git = {
    enable = true;
    config = {
      safe.directory = [
      # instead files in /etc/nixos, we use that folder to store our flakes and stuff, /etc/nixos stay pure and user dont touch it.
        "/nixosConfig"
      ];
    };
  };
}