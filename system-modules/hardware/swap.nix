{ config, lib, pkgs, ... }:

let
  cfg = config.system-modules.swap;
  ramSizeGB = config.hardware.memorySize or 8;
  defaultZramPercent =
    if ramSizeGB < 4 then 100 else
    if ramSizeGB < 8 then 75 else
    if ramSizeGB < 16 then 60 else
    if ramSizeGB < 32 then 50 else
    33;
in
{
  options.system-modules.swap = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable (swap, zram) configuration.";
    };

    swapDisk = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/swapfile";
      description = ''
        Path to swap, prefer use hdd - wears out the SSD.
        Example: `/mnt/hdd/swapfile`.
      '';
    };

    size = lib.mkOption {
      type = lib.types.int;
      default = 16 * 1024; # 16 GiB
      description = "Swap file size in MiB (for hybernation and fallback)";
    };

    enableZram = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable zram (always has priority over swap)";
    };

    zramMemoryPercent = lib.mkOption {
      type = lib.types.int;
      default = defaultZramPercent;
      description = "Max ram percent that zram would use. Automatically set if you provide config.hardware.memorySize.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        swapDevices = [
          {
            device = cfg.swapDisk;
            size = cfg.size;
            priority = 10;
          }
        ];
        systemd.oomd.enable = true;
      }

      (lib.mkIf cfg.enableZram {
        zramSwap.enable = true;
        zramSwap.memoryPercent = cfg.zramMemoryPercent;
        zramSwap.priority = 100;
      })
    ]
  );
}
