{ inputs, config, pkgs, ... }:

{
  networking.hostName = "accrrsd-pc";
  system.stateVersion = "25.11";

  imports = [
    ../default.nix
    ./users/users.nix

    ../../system-modules/hardware/nvidia.nix
    ../../system-modules/hardware/disk-mount.nix

    # system-wide apps
    ../../system-modules/app/steam.nix
    #../../system-modules/app/razer-peripherals.nix
    ../../system-modules/app/zsh.nix
    ../../system-modules/app/neovim.nix

    ../../system-modules/app/hyprland.nix
  ];

  
  # works only if hyprland in flakse
  #programs.hyprland.extraConfig = ''
    #monitor=HDMI-A-1,5120x1440@144.00,auto,1 
  #'';




  boot.kernelParams = [
    "nvidia.NVreg_ValidateModes=0"
    "nvidia.NVreg_EnableModeValidation=1"
    # "module_blacklist=i915"
    # "nvidia-drm.fbdev=1"
    "video=HDMI-A-1:5120x1440@144e"
  ];

  system-modules.diskMount = {
    enable = true;
    disks = [
      {
        uuid = "0670796770795DFD";
        mountPoint = "/mnt/hdd1";
        fsType="ntfs";
        options = [ "nofail" "x-systemd.automount" ];
      }
    ];
  };

  # for newer cards is better to have open, but if it sause errors - can be disabled to false (default)
  hardware.nvidia.open = true;


  environment.systemPackages = with pkgs; [
    telegram-desktop
    chromium
    nodejs
    htop
    qbittorrent
    linux-wallpaperengine
    niri
    emote
    obsidian
    vlc
    discord

    # app image manager
    gearlever
  ];
}