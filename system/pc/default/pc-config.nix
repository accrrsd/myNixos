
# default config before any host
{ inputs, lib, config, pkgs, ... }:

{
  imports = [
  ../../modules/hardware/boot.nix
  ../../modules/hardware/region.nix
  ../../modules/hardware/sound.nix
  ../../modules/hardware/networking.nix
  ../../modules/hardware/opengl.nix
  ../../modules/hardware/automount.nix
  ../../modules/hardware/printing.nix
  ../../modules/hardware/bluetooth.nix
  ../../modules/hardware/virtualization.nix
  ../../modules/hardware/systemd.nix
  #../../modules/hardware/swap.nix
  
  ../../modules/hardware/sddm.nix
  ../../modules/hardware/plasma.nix
  ];

  environment.systemPackages = with pkgs; [
    git
    wget
    ripgrep
    vscode
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    wl-clipboard
    wl-clip-persist
    fastfetch
    cliphist
    nix-fast-build
  ];

  programs.firefox.enable = true;
  services.xserver.enable = true;
  services.printing.enable = true;
  nixpkgs.config.allowUnfree = true;
  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # Here we create nixos-editors group and allow it to edit nixos folder
  users.groups.nixos-editors = { };
  systemd.tmpfiles.rules = [
    "d /etc/nixos 0775 root nixos-editors -"
  ];

  # Disable clearing permissions on reboot!
  
  boot.tmp.useTmpfs = false;
  # Used for read-write access with group nixos-editors
  system.activationScripts.nixosEditorsPerms.text = ''
    chown -R root:nixos-editors /etc/nixos
    chmod -R g+rw /etc/nixos
    chmod g+s /etc/nixos
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}