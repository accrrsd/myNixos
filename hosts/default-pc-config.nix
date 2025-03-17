
# default config before any host
{ inputs, lib, config, pkgs, ... }:

{
  imports = [
  ../modules/hardware/boot.nix
  ../modules/hardware/time.nix
  ../modules/hardware/sound.nix
  ../modules/hardware/networking.nix
  ../modules/hardware/nvidia.nix
  ../modules/hardware/opengl.nix
  ../modules/hardware/automount.nix
  ../modules/hardware/printing.nix
  ../modules/hardware/bluetooth.nix
  ../modules/hardware/virtualization.nix
  ../modules/hardware/sddm.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    neovim
    zig
    wezterm
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code
    wl-clipboard
    ripgrep
    inputs.home-manager.packages.${pkgs.system}.default
  ];

  services.xserver.enable = true;
  services.printing.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.desktopManager.plasma6.enable = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  home-manager.backupFileExtension = "backup";
}
