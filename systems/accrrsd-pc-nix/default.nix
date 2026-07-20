{ inputs, config, pkgs, ... }:

{
  networking.hostName = "accrrsd-pc-nix";
  system.stateVersion = "25.11";

  imports = [
    ../general.nix
    ./users

    ../../system-modules/hardware/nvidia.nix
    ../../system-modules/hardware/disk-mount.nix
    # docker stuff
    ../../system-modules/hardware/virtualization.nix
    ../../system-modules/app/zerotier.nix

    # system-wide apps
    ../../system-modules/app/steam.nix
    ../../system-modules/app/razer-peripherals.nix
    ../../system-modules/app/rgb-control.nix
    ../../system-modules/app/zsh.nix

    ../../system-modules/app/hyprland.nix
    ../../system-modules/app/niri.nix
    # ../../system-modules/app/zapret-container.nix
    ../../system-modules/app/zapret2.nix

    ../../system-modules/hardware/smooth-fonts.nix
  ];
  
  boot.kernelParams = [
    "nvidia.NVreg_ValidateModes=0"
    "nvidia.NVreg_EnableModeValidation=1"
    # "module_blacklist=i915"
    # "nvidia-drm.fbdev=1"
    "video=HDMI-A-1:5120x1440@144e"
  ];

  # dual boot, read: https://search.nixos.org/options?channel=unstable&show=boot.loader.systemd-boot.windows.%3Cname%3E.efiDeviceHandle
  boot.loader.systemd-boot = {
    edk2-uefi-shell.enable = true;
    windows."0_Windows".efiDeviceHandle = "HD1c";
    # dont need 60+ configurations
    configurationLimit = 5;
  };

  # takes eternaty to update, holy!
  #nixpkgs.config.cudaSupport = true;

  # with windows dualboot sometimes disk can be locked. You can unlock it with:
  # sudo umount /mnt/hdd1 && sudo ntfsfix -d /dev/sda1 && sudo systemctl restart mnt-hdd1.automount

system-modules.diskMount = {
    enable = true;
    disks = [
      {
        uuid = "0670796770795DFD";
        mountPoint = "/mnt/hdd1";
        fsType = "ntfs3"; 
        options = [ 
          "nofail" 
          "x-systemd.automount"
          "nohidden"
          "gid=100"       
          "fmask=0000"    
          "dmask=0000"
        ];
      }
    ];
  };

  # Declarative bluetooth for dualboot
  hardware.bluetooth.syncWithWindows.regFile = ./bluetooth.reg;

  # for newer cards is better to have open, but if it cause errors - can be disabled to false (default)
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

  # vpn
  programs.amnezia-vpn.enable = true;

  environment.systemPackages = with pkgs; [
    liquidctl
  ];

  # disable firewall for debug and coding stuff
  networking.firewall.enable = false;

  systemd.services.liquidctl = {
    description = "Initialize liquidctl and set pump speed to 60%";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.liquidctl}/bin/liquidctl initialize all"
        "${pkgs.liquidctl}/bin/liquidctl set pump speed 60"
      ];
      RemainAfterExit = true;
    };
  };

  # services.zapret-container = {
  #   enable = true;
  # };

  services.zapret2 = {
    enable = true;
    # change desync profile
    luaDesync = ["multidisorder:pos=1,sniext+1,host+1,midsld-2,midsld,midsld+2,endhost-1"];
    # change domenlist
    # userHostlist = [ "youtube.com" "discord.com" ];
  };

  # use flake flatpak for declarative packages
  services.flatpak.packages = [
    # you can use flatseal to allow usage of /mnt/ files
    # flatpak access settings
    "com.github.tchx84.Flatseal"
  ];

  # obs with good codec
  programs.obs-studio.enable = true;
  programs.obs-studio.package = (pkgs.obs-studio.override {
    cudaSupport = true;
  });
}
