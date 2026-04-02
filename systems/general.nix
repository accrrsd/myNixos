{ config, lib, pkgs, ... }:

{
  imports = [
    #../system-modules/hardware/grub-boot.nix
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

  # use systemd as default loader
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # wayland fixes
  programs.xwayland.enable = true;

  networking.hostName = lib.mkDefault "default";
  system.stateVersion = lib.mkDefault "25.05";

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "nrebuild" (builtins.readFile ../scripts/setup/smart-rebuild.sh))
    (writeShellScriptBin "hswitch" (builtins.readFile ../scripts/setup/home-switch.sh))
    (writeShellScriptBin "nupdate" (builtins.readFile ../scripts/setup/flake-update.sh))
    
    vscode
    git
    wget
    ripgrep
    wl-clipboard
    wl-clip-persist
    fastfetch
    cliphist
    nixfmt-rfc-style
    # allows use home-manager command without rebuild-swtich. (allow rebuild user only stuff)
    home-manager
    # documents, wallpapers, etc folders.
    xdg-user-dirs
  ];

  users.groups.nixos-editors = {};

  programs.firefox.enable = lib.mkDefault  true;
  services.xserver.enable = lib.mkDefault true;
  nixpkgs.config.allowUnfree = lib.mkDefault  true;
  security.polkit.enable = lib.mkDefault  true;
  services.flatpak = lib.mkDefault {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];
  };
  nix.settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];

  # xdg assosiation
  xdg.menus.enable = true;
  xdg.mime.enable = true;

  xdg.portal = {
    enable = lib.mkDefault true;
    wlr.enable = lib.mkDefault true;
    extraPortals = lib.mkDefault [ 
      # pkgs.xdg-desktop-portal-gtk - not needed (for now)
      # pkgs.xdg-desktop-portal-kde # - many dependencies
    ];
  };

  programs.git = {
    enable = lib.mkDefault true;
    config.safe.directory = lib.mkDefault [ "/nixos-config" ];
  };

  environment.sessionVariables = {
    HOSTNAME = config.networking.hostName;
  };
}
