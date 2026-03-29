{ inputs, config, pkgs, ... }:

{
  networking.hostName = "oblivion-pc";

  imports = [
    ../default.nix
    ./users/users.nix
    
    # modules specific for a pc
    ../../system-modules/hardware/amd-gpu.nix
    ../../system-modules/hardware/disk-mount.nix
    ../../system-modules/hardware/swap.nix

    # system-wide apps
    ../../system-modules/app/steam.nix
    ../../system-modules/app/razer-peripherals.nix
    ../../system-modules/app/zsh.nix
    ../../system-modules/app/neovim.nix

    ../../system-modules/app/hyprland.nix
  ];

  # specific for pc, and needed only if not uefi.
  boot.loader.grub.device = "/dev/sdb";

  environment.systemPackages = with pkgs; [
    telegram-desktop
    chromium
    nodejs
    htop
    qbittorrent
    linux-wallpaperengine
    niri
    emote
  ];

  system-modules.diskMount = {
    enable = true;
    disks = [
      {
        uuid = "82e1e174-9d10-445a-9795-e7b42a74f644";
        mountPoint = "/mnt/hdd1";
        fsType="ext4";
        options = [ "nofail" "x-systemd.automount" ];
      }
    ];
  };

  # swap allowing hybernate and zram allowing more efficient ram storage 
  # example of swap settigns
  system-modules.swap = {
    enable = true;
    swapDisk = "/mnt/hdd1/swapfile";
    size=16*1024; # 16 gb
    enableZram = true;
  };
  
  system.stateVersion = "25.05";
}