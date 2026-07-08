{ config, lib, pkgs, ... }:

# to get disk data - use sudo blkid
# also can help lsblk -f 

let
  cfg = config.system-modules.diskMount;
in
{
  options.system-modules.diskMount = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable disk automount via fileSystems.";
    };

    disks = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          uuid = lib.mkOption {
            type = lib.types.str;
            description = "Disk UUID.";
          };

          mountPoint = lib.mkOption {
            type = lib.types.path;
            description = "Disk mount point.";
          };

          fsType = lib.mkOption {
            type = lib.types.str;
            default = "auto";
            description = "Type of file system.";
          };

          options = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "nofail" "x-systemd.automount" ];
            description = "Mount options.";
          };
        };
      });
      default = [ ];
      description = "Disk of disk for mounting.";
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems = lib.mkMerge (
      lib.forEach cfg.disks (disk: {
        "${disk.mountPoint}" = {
          device = "/dev/disk/by-uuid/${disk.uuid}";
          fsType = disk.fsType;
          options = disk.options;
        };
      })
    );
  };
}
