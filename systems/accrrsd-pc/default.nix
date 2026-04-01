{ inputs, config, pkgs, ... }:

{
  networking.hostName = "accrrsd-pc";
  system.stateVersion = "25.11";

  imports = [
    ../general.nix
    ./users

    ../../system-modules/hardware/nvidia.nix
    ../../system-modules/hardware/disk-mount.nix
    # docker stuff
    ../../system-modules/hardware/virtualization.nix

    # system-wide apps
    ../../system-modules/app/steam.nix
    ../../system-modules/app/razer-peripherals.nix
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

  # takes 10 gb to update, holy!
  #nixpkgs.config.cudaSupport = true;

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


  # app image stuff
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.appimage.package = pkgs.appimage-run.override 
  {
    extraPkgs = pkgs: 
    [
      pkgs.icu
      pkgs.libxcrypt-legacy
      pkgs.python312
      pkgs.python312Packages.torch
    ]; 
  };

  programs.amnezia-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    telegram-desktop
    # chromium - cant sync with google account.
    google-chrome
    nodejs
    htop
    qbittorrent
    linux-wallpaperengine
    niri
    emote
    obsidian
    vlc

    zerotierone
    
    # discord - should use flatpak version for better compatablity, or Vesktop - if discord struggle. Can be found in discover (KDE) or using flake nix-flatpak
    
    # java
    # to fix java app (like minecraft) with alsoft err, pass java args with -Dorg.lwjgl.openal.libname=/usr/lib/libopenal.so (you can find lib with nix-index, use nix-locate, then await, then nix-locate libopenal.so)
    jdk
    nix-index

  ];

  # use flake flatpak for declarative packages
  services.flatpak.packages = [
    "com.discordapp.Discord"
  ];

  programs.obs-studio.enable = true;
  programs.obs-studio.package = (pkgs.obs-studio.override {
    cudaSupport = true;
  });
}